import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import '../models/module_models.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'chama_tracker.db'),
      version: 5,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateToV2(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          await _migrateToV4(db);
        }
        if (oldVersion < 5) {
          await _migrateToV5(db);
        }
      },
    );
  }

  static Future<void> _createAllTables(Database db) async {
    // Organizations table
    await db.execute('''
      CREATE TABLE organizations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        logo_url TEXT,
        tier TEXT DEFAULT 'free',
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Organization members table (RBAC)
    await db.execute('''
      CREATE TABLE org_members (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        role TEXT NOT NULL DEFAULT 'member',
        joined_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Organization modules table (Module activation)
    await db.execute('''
      CREATE TABLE org_modules (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        module_type TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        config TEXT,
        activated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Members table (enhanced with org_id)
    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        notes TEXT,
        joined_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Contributions table (enhanced with org_id)
    await db.execute('''
      CREATE TABLE contributions (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        payment_method TEXT,
        transaction_code TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id),
        FOREIGN KEY (member_id) REFERENCES members(id)
      )
    ''');

    // Expenses table (enhanced with org_id)
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE loans (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        loan_type TEXT NOT NULL,
        principal REAL NOT NULL,
        interest_rate REAL DEFAULT 0,
        interest_amount REAL,
        total_amount REAL,
        repayment_period_months INTEGER DEFAULT 1,
        monthly_installment REAL,
        paid_amount REAL DEFAULT 0,
        balance REAL,
        status TEXT NOT NULL DEFAULT 'pending',
        guarantor_id TEXT,
        purpose TEXT,
        application_date TEXT NOT NULL,
        approval_date TEXT,
        disbursement_date TEXT,
        due_date TEXT NOT NULL,
        completed_date TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Loan repayments table
    await db.execute('''
      CREATE TABLE loan_repayments (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        loan_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT,
        transaction_code TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id),
        FOREIGN KEY (loan_id) REFERENCES loans(id)
      )
    ''');

    // Merry-Go-Round cycles table
    await db.execute('''
      CREATE TABLE merry_go_round_cycles (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        total_members INTEGER NOT NULL,
        contribution_amount REAL NOT NULL,
        frequency TEXT NOT NULL DEFAULT 'monthly',
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'planning',
        member_order TEXT,
        current_position INTEGER DEFAULT 0,
        current_recipient_id TEXT,
        completed_recipients TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Shares table
    await db.execute('''
      CREATE TABLE shares (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        number_of_shares INTEGER NOT NULL,
        price_per_share REAL NOT NULL,
        total_value REAL NOT NULL,
        payment_method TEXT,
        transaction_code TEXT,
        purchase_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        raised_amount REAL DEFAULT 0,
        target_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'planning',
        category TEXT NOT NULL DEFAULT 'general',
        contributor_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        completed_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Goal contributions table
    await db.execute('''
      CREATE TABLE goal_contributions (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        goal_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id),
        FOREIGN KEY (goal_id) REFERENCES goals(id)
      )
    ''');

    // Welfare contributions table
    await db.execute('''
      CREATE TABLE welfare_contributions (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        beneficiary_id TEXT,
        reason TEXT,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_members_org ON members(org_id)');
    await db
        .execute('CREATE INDEX idx_contributions_org ON contributions(org_id)');
    await db.execute(
        'CREATE INDEX idx_contributions_member ON contributions(member_id)');
    await db.execute('CREATE INDEX idx_expenses_org ON expenses(org_id)');
    await db.execute('CREATE INDEX idx_org_members_org ON org_members(org_id)');
    await db.execute('CREATE INDEX idx_org_modules_org ON org_modules(org_id)');
    await db.execute('CREATE INDEX idx_loans_org ON loans(org_id)');
    await db.execute('CREATE INDEX idx_shares_org ON shares(org_id)');
    await db.execute('CREATE INDEX idx_goals_org ON goals(org_id)');
  }

  static Future<void> _migrateToV3(Database db) async {
    try {
      await db.execute(
          'ALTER TABLE organizations ADD COLUMN tier TEXT DEFAULT "free"');
    } catch (_) {}
  }

  static Future<void> _migrateToV4(Database db) async {
    // Create missing tables with IF NOT EXISTS
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loans (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        loan_type TEXT NOT NULL,
        principal REAL NOT NULL,
        interest_rate REAL DEFAULT 0,
        interest_amount REAL,
        total_amount REAL,
        repayment_period_months INTEGER DEFAULT 1,
        monthly_installment REAL,
        paid_amount REAL DEFAULT 0,
        balance REAL,
        status TEXT NOT NULL DEFAULT 'pending',
        guarantor_id TEXT,
        purpose TEXT,
        application_date TEXT NOT NULL,
        approval_date TEXT,
        disbursement_date TEXT,
        due_date TEXT NOT NULL,
        completed_date TEXT,
        notes TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS loan_repayments (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        loan_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        payment_method TEXT,
        transaction_code TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id),
        FOREIGN KEY (loan_id) REFERENCES loans(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS merry_go_round_cycles (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        total_members INTEGER NOT NULL,
        contribution_amount REAL NOT NULL,
        frequency TEXT NOT NULL DEFAULT 'monthly',
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'planning',
        member_order TEXT,
        current_position INTEGER DEFAULT 0,
        current_recipient_id TEXT,
        completed_recipients TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS shares (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        number_of_shares INTEGER NOT NULL,
        price_per_share REAL NOT NULL,
        total_value REAL NOT NULL,
        payment_method TEXT,
        transaction_code TEXT,
        purchase_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        raised_amount REAL DEFAULT 0,
        target_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'planning',
        category TEXT NOT NULL DEFAULT 'general',
        contributor_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        completed_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS goal_contributions (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        goal_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id),
        FOREIGN KEY (goal_id) REFERENCES goals(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS welfare_contributions (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        member_id TEXT NOT NULL,
        amount REAL NOT NULL,
        beneficiary_id TEXT,
        reason TEXT,
        note TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (org_id) REFERENCES organizations(id)
      )
    ''');

    // Create indexes if they don't exist
    await _createIndexIfNotExists(db, 'idx_loans_org', 'loans', 'org_id');
    await _createIndexIfNotExists(db, 'idx_shares_org', 'shares', 'org_id');
    await _createIndexIfNotExists(db, 'idx_goals_org', 'goals', 'org_id');
  }

  static Future<void> _migrateToV5(Database db) async {
    // Add payment metadata to contributions (for reconciliation)
    try {
      await db
          .execute('ALTER TABLE contributions ADD COLUMN payment_method TEXT');
    } catch (_) {}
    try {
      await db.execute(
          'ALTER TABLE contributions ADD COLUMN transaction_code TEXT');
    } catch (_) {}

    await _createIndexIfNotExists(
        db, 'idx_contributions_tx_code', 'contributions', 'transaction_code');
  }

  static Future<void> _createIndexIfNotExists(Database db, String indexName,
      String tableName, String columnName) async {
    try {
      await db.execute(
          'CREATE INDEX IF NOT EXISTS $indexName ON $tableName($columnName)');
    } catch (_) {}
  }

  static Future<void> _migrateToV2(Database db) async {
    // Create new tables for multi-tenancy
    await db.execute('''
      CREATE TABLE IF NOT EXISTS organizations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        logo_url TEXT,
        created_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS org_members (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        role TEXT NOT NULL DEFAULT 'member',
        joined_at TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS org_modules (
        id TEXT PRIMARY KEY,
        org_id TEXT NOT NULL,
        module_type TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        config TEXT,
        activated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Add org_id to existing tables
    try {
      await db.execute(
          'ALTER TABLE members ADD COLUMN org_id TEXT DEFAULT "default"');
    } catch (_) {}

    try {
      await db.execute(
          'ALTER TABLE contributions ADD COLUMN org_id TEXT DEFAULT "default"');
    } catch (_) {}

    try {
      await db.execute(
          'ALTER TABLE expenses ADD COLUMN org_id TEXT DEFAULT "default"');
    } catch (_) {}

    // Add is_active to members
    try {
      await db.execute(
          'ALTER TABLE members ADD COLUMN is_active INTEGER DEFAULT 1');
    } catch (_) {}

    // Add email to members
    try {
      await db.execute('ALTER TABLE members ADD COLUMN email TEXT');
    } catch (_) {}
  }

  // ─────────────────────────────────────────
  // ORGANIZATIONS
  // ─────────────────────────────────────────
  static Future<void> insertOrganization(Organization org) async {
    final d = await db;
    await d.insert('organizations', org.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Organization>> getOrganizations() async {
    final d = await db;
    final rows = await d.query('organizations',
        where: 'is_active = 1', orderBy: 'created_at DESC');
    return rows.map(Organization.fromMap).toList();
  }

  static Future<Organization?> getOrganization(String id) async {
    final d = await db;
    final rows =
        await d.query('organizations', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Organization.fromMap(rows.first);
  }

  static Future<void> updateOrganization(Organization org) async {
    final d = await db;
    await d.update('organizations', org.toMap(),
        where: 'id = ?', whereArgs: [org.id]);
  }

  // ─────────────────────────────────────────
  // ORG MEMBERS (RBAC)
  // ─────────────────────────────────────────
  static Future<void> insertOrgMember(OrgMember member) async {
    final d = await db;
    await d.insert('org_members', member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<OrgMember>> getOrgMembers(String orgId) async {
    final d = await db;
    final rows = await d.query(
      'org_members',
      where: 'org_id = ? AND is_active = 1',
      whereArgs: [orgId],
      orderBy: 'joined_at ASC',
    );
    return rows.map(OrgMember.fromMap).toList();
  }

  static Future<OrgMember?> getOrgMember(String orgId, String userId) async {
    final d = await db;
    final rows = await d.query(
      'org_members',
      where: 'org_id = ? AND user_id = ?',
      whereArgs: [orgId, userId],
    );
    if (rows.isEmpty) return null;
    return OrgMember.fromMap(rows.first);
  }

  static Future<void> updateOrgMemberRole(
      String orgId, String userId, UserRole role) async {
    final d = await db;
    await d.update(
      'org_members',
      {'role': role.code},
      where: 'org_id = ? AND user_id = ?',
      whereArgs: [orgId, userId],
    );
  }

  // ─────────────────────────────────────────
  // ORG MODULES (Module Activation)
  // ─────────────────────────────────────────
  static Future<void> insertOrgModule(OrgModule module) async {
    final d = await db;
    await d.insert('org_modules', module.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<OrgModule>> getOrgModules(String orgId) async {
    final d = await db;
    final rows = await d.query(
      'org_modules',
      where: 'org_id = ? AND is_active = 1',
      whereArgs: [orgId],
    );
    return rows.map(OrgModule.fromMap).toList();
  }

  static Future<bool> isModuleActive(
      String orgId, ModuleType moduleType) async {
    final d = await db;
    final rows = await d.query(
      'org_modules',
      where: 'org_id = ? AND module_type = ? AND is_active = 1',
      whereArgs: [orgId, moduleType.code],
    );
    return rows.isNotEmpty;
  }

  static Future<void> activateModule(String orgId, ModuleType moduleType,
      {Map<String, dynamic>? config}) async {
    final d = await db;
    final existing = await d.query(
      'org_modules',
      where: 'org_id = ? AND module_type = ?',
      whereArgs: [orgId, moduleType.code],
    );

    if (existing.isEmpty) {
      final module =
          OrgModule(orgId: orgId, moduleType: moduleType, config: config);
      await d.insert('org_modules', module.toMap());
    } else {
      await d.update(
        'org_modules',
        {'is_active': 1, 'config': config != null ? jsonEncode(config) : ''},
        where: 'org_id = ? AND module_type = ?',
        whereArgs: [orgId, moduleType.code],
      );
    }
  }

  static Future<void> deactivateModule(
      String orgId, ModuleType moduleType) async {
    final d = await db;
    await d.update(
      'org_modules',
      {'is_active': 0},
      where: 'org_id = ? AND module_type = ?',
      whereArgs: [orgId, moduleType.code],
    );
  }

  // ─────────────────────────────────────────
  // MEMBERS
  // ─────────────────────────────────────────
  static Future<void> insertMember(OrgMember m) async {
    final d = await db;
    await d.insert('members', m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<OrgMember>> getMembers({String? orgId}) async {
    final d = await db;
    final rows = await d.query(
      'members',
      where: orgId != null ? 'org_id = ? AND is_active = 1' : 'is_active = 1',
      whereArgs: orgId != null ? [orgId] : null,
      orderBy: 'joined_at ASC',
    );
    return rows.map(OrgMember.fromMap).toList();
  }

  static Future<void> deleteMember(String id) async {
    final d = await db;
    await d.update('members', {'is_active': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<OrgMember>> getUnsyncedMembers() async {
    final d = await db;
    final rows = await d.query('members', where: 'synced = 0');
    return rows.map(OrgMember.fromMap).toList();
  }

  static Future<void> markMemberSynced(String id) async {
    final d = await db;
    await d.update('members', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────
  // CONTRIBUTIONS
  // ─────────────────────────────────────────
  static Future<void> insertContribution(Contribution c) async {
    final d = await db;
    await d.insert('contributions', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Contribution>> getContributions(
      {String? orgId, String? memberId}) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (orgId != null && memberId != null) {
      where = 'org_id = ? AND member_id = ?';
      whereArgs = [orgId, memberId];
    } else if (orgId != null) {
      where = 'org_id = ?';
      whereArgs = [orgId];
    } else if (memberId != null) {
      where = 'member_id = ?';
      whereArgs = [memberId];
    }

    final rows = await d.query(
      'contributions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return rows.map(Contribution.fromMap).toList();
  }

  static Future<void> deleteContribution(String id) async {
    final d = await db;
    await d.delete('contributions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Contribution>> getUnsyncedContributions() async {
    final d = await db;
    final rows = await d.query('contributions', where: 'synced = 0');
    return rows.map(Contribution.fromMap).toList();
  }

  static Future<void> markContributionSynced(String id) async {
    final d = await db;
    await d.update('contributions', {'synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────
  // EXPENSES
  // ─────────────────────────────────────────
  static Future<void> insertExpense(Expense e) async {
    final d = await db;
    await d.insert('expenses', e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Expense>> getExpenses(
      {String? orgId, String? type}) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (orgId != null && type != null) {
      where = 'org_id = ? AND type = ?';
      whereArgs = [orgId, type];
    } else if (orgId != null) {
      where = 'org_id = ?';
      whereArgs = [orgId];
    } else if (type != null) {
      where = 'type = ?';
      whereArgs = [type];
    }

    final rows = await d.query(
      'expenses',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  static Future<void> deleteExpense(String id) async {
    final d = await db;
    await d.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Expense>> getUnsyncedExpenses() async {
    final d = await db;
    final rows = await d.query('expenses', where: 'synced = 0');
    return rows.map(Expense.fromMap).toList();
  }

  static Future<void> markExpenseSynced(String id) async {
    final d = await db;
    await d.update('expenses', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────
  // SUMMARY (per organization)
  // ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getSummary({String? orgId}) async {
    final d = await db;

    String orgFilter = orgId != null ? 'WHERE org_id = ?' : '';
    List<dynamic>? args = orgId != null ? [orgId] : null;

    final memberCount = Sqflite.firstIntValue(await d.rawQuery(
            'SELECT COUNT(*) FROM members $orgFilter', args)) ??
        0;

    final totalContribs = (await d.rawQuery(
                'SELECT SUM(amount) as s FROM contributions $orgFilter', args))
            .first['s'] ??
        0.0;
    final totalExpenses = (await d.rawQuery(
                'SELECT SUM(amount) as s FROM expenses $orgFilter', args))
            .first['s'] ??
        0.0;

    return {
      'memberCount': memberCount,
      'totalContributions': (totalContribs as num).toDouble(),
      'totalExpenses': (totalExpenses as num).toDouble(),
    };
  }

  // ─────────────────────────────────────────
  // LOANS MODULE
  // ─────────────────────────────────────────
  static Future<void> insertLoan(Loan loan) async {
    final d = await db;
    await d.insert('loans', loan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Loan>> getLoans({String? orgId, String? memberId}) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (orgId != null && memberId != null) {
      where = 'org_id = ? AND member_id = ?';
      whereArgs = [orgId, memberId];
    } else if (orgId != null) {
      where = 'org_id = ?';
      whereArgs = [orgId];
    }

    final rows = await d.query('loans',
        where: where, whereArgs: whereArgs, orderBy: 'application_date DESC');
    return rows.map(Loan.fromMap).toList();
  }

  static Future<void> updateLoan(Loan loan) async {
    final d = await db;
    await d
        .update('loans', loan.toMap(), where: 'id = ?', whereArgs: [loan.id]);
  }

  static Future<void> deleteLoan(String id) async {
    final d = await db;
    await d.delete('loans', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Loan>> getUnsyncedLoans() async {
    final d = await db;
    final rows = await d.query('loans', where: 'synced = 0');
    return rows.map(Loan.fromMap).toList();
  }

  static Future<void> markLoanSynced(String id) async {
    final d = await db;
    await d.update('loans', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────
  // LOAN REPAYMENTS
  // ─────────────────────────────────────────
  static Future<void> insertLoanRepayment(LoanRepayment repayment) async {
    final d = await db;
    await d.insert('loan_repayments', repayment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<LoanRepayment>> getLoanRepayments({String? loanId}) async {
    final d = await db;
    final rows = await d.query(
      'loan_repayments',
      where: loanId != null ? 'loan_id = ?' : null,
      whereArgs: loanId != null ? [loanId] : null,
      orderBy: 'date DESC',
    );
    return rows.map(LoanRepayment.fromMap).toList();
  }

  // ─────────────────────────────────────────
  // MERRY-GO-ROUND CYCLES
  // ─────────────────────────────────────────
  static Future<void> insertMerryGoRoundCycle(MerryGoRoundCycle cycle) async {
    final d = await db;
    await d.insert('merry_go_round_cycles', cycle.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<MerryGoRoundCycle>> getMerryGoRoundCycles(
      {String? orgId}) async {
    final d = await db;
    final rows = await d.query(
      'merry_go_round_cycles',
      where: orgId != null ? 'org_id = ?' : null,
      whereArgs: orgId != null ? [orgId] : null,
      orderBy: 'created_at DESC',
    );
    return rows.map(MerryGoRoundCycle.fromMap).toList();
  }

  static Future<void> updateMerryGoRoundCycle(MerryGoRoundCycle cycle) async {
    final d = await db;
    await d.update('merry_go_round_cycles', cycle.toMap(),
        where: 'id = ?', whereArgs: [cycle.id]);
  }

  // ─────────────────────────────────────────
  // SHARES MODULE
  // ─────────────────────────────────────────
  static Future<void> insertShare(Share share) async {
    final d = await db;
    await d.insert('shares', share.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Share>> getShares(
      {String? orgId, String? memberId}) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (orgId != null && memberId != null) {
      where = 'org_id = ? AND member_id = ?';
      whereArgs = [orgId, memberId];
    } else if (orgId != null) {
      where = 'org_id = ?';
      whereArgs = [orgId];
    }

    final rows = await d.query('shares',
        where: where, whereArgs: whereArgs, orderBy: 'purchase_date DESC');
    return rows.map(Share.fromMap).toList();
  }

  static Future<void> updateShare(Share share) async {
    final d = await db;
    await d.update('shares', share.toMap(),
        where: 'id = ?', whereArgs: [share.id]);
  }

  // ─────────────────────────────────────────
  // GOALS MODULE
  // ─────────────────────────────────────────
  static Future<void> insertGoal(Goal goal) async {
    final d = await db;
    await d.insert('goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Goal>> getGoals({String? orgId}) async {
    final d = await db;
    final rows = await d.query(
      'goals',
      where: orgId != null ? 'org_id = ?' : null,
      whereArgs: orgId != null ? [orgId] : null,
      orderBy: 'created_at DESC',
    );
    return rows.map(Goal.fromMap).toList();
  }

  static Future<void> updateGoal(Goal goal) async {
    final d = await db;
    await d
        .update('goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  static Future<void> deleteGoal(String id) async {
    final d = await db;
    await d.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  // ─────────────────────────────────────────
  // GOAL CONTRIBUTIONS
  // ─────────────────────────────────────────
  static Future<void> insertGoalContribution(
      GoalContribution contribution) async {
    final d = await db;
    await d.insert('goal_contributions', contribution.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<GoalContribution>> getGoalContributions(
      {String? goalId}) async {
    final d = await db;
    final rows = await d.query(
      'goal_contributions',
      where: goalId != null ? 'goal_id = ?' : null,
      whereArgs: goalId != null ? [goalId] : null,
      orderBy: 'date DESC',
    );
    return rows.map(GoalContribution.fromMap).toList();
  }

  // ─────────────────────────────────────────
  // WELFARE MODULE
  // ─────────────────────────────────────────
  static Future<void> insertWelfareContribution(
      WelfareContribution contribution) async {
    final d = await db;
    await d.insert('welfare_contributions', contribution.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<WelfareContribution>> getWelfareContributions(
      {String? orgId, String? memberId}) async {
    final d = await db;
    String? where;
    List<dynamic>? whereArgs;

    if (orgId != null && memberId != null) {
      where = 'org_id = ? AND member_id = ?';
      whereArgs = [orgId, memberId];
    } else if (orgId != null) {
      where = 'org_id = ?';
      whereArgs = [orgId];
    }

    final rows = await d.query('welfare_contributions',
        where: where, whereArgs: whereArgs, orderBy: 'date DESC');
    return rows.map(WelfareContribution.fromMap).toList();
  }

  // ─────────────────────────────────────────
  // CLEAR DATA (for logout/switch org)
  // ─────────────────────────────────────────
  static Future<void> clearOrgData(String orgId) async {
    final d = await db;
    await d.delete('members', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('contributions', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('expenses', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('loans', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('loan_repayments', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('merry_go_round_cycles',
        where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('shares', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('goals', where: 'org_id = ?', whereArgs: [orgId]);
    await d
        .delete('goal_contributions', where: 'org_id = ?', whereArgs: [orgId]);
    await d.delete('welfare_contributions',
        where: 'org_id = ?', whereArgs: [orgId]);
  }

  static Future<void> clearAllData() async {
    final d = await db;
    await d.delete('organizations');
    await d.delete('org_members');
    await d.delete('org_modules');
    await d.delete('members');
    await d.delete('contributions');
    await d.delete('expenses');
    await d.delete('loans');
    await d.delete('loan_repayments');
    await d.delete('merry_go_round_cycles');
    await d.delete('shares');
    await d.delete('goals');
    await d.delete('goal_contributions');
    await d.delete('welfare_contributions');
  }

  /// Clear offline cache (mark all unsynced records as needing re-sync)
  /// Returns the number of records that were cleared.
  static Future<Map<String, int>> clearCache() async {
    final d = await db;
    // Reset synced status to force re-pull on next sync
    final members = await d.update('members', {'synced': 0});
    final contributions = await d.update('contributions', {'synced': 0});
    final expenses = await d.update('expenses', {'synced': 0});
    final loans = await d.update('loans', {'synced': 0});
    return {
      'members': members,
      'contributions': contributions,
      'expenses': expenses,
      'loans': loans,
    };
  }
}
