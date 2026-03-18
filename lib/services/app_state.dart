import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../models/module_models.dart';
import 'local_db.dart';
import 'sync_service.dart';
import 'sms_service.dart';
import 'supabase_service.dart';

class AppState extends ChangeNotifier {
  // Current organization
  Organization? _currentOrg;
  Organization? get currentOrg => _currentOrg;

  // User's role in current organization
  UserRole _userRole = UserRole.member;
  UserRole get userRole => _userRole;

  // Organizations user belongs to
  List<Organization> _organizations = [];
  List<Organization> get organizations => _organizations;

  // Activated modules for current org
  List<OrgModule> _activatedModules = [];
  List<OrgModule> get activatedModules => _activatedModules;

  // Org Members (enhanced)
  List<OrgMember> _members = [];
  List<OrgMember> get members => _members;

  // Org Members (with roles)
  List<OrgMember> _orgMembers = [];
  List<OrgMember> get orgMembers => _orgMembers;

  // Contributions & Expenses
  List<Contribution> _contributions = [];
  List<Contribution> get contributions => _contributions;

  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  // Loans
  List<Loan> _loans = [];
  List<Loan> get loans => _loans;

  List<LoanRepayment> _loanRepayments = [];
  List<LoanRepayment> get loanRepayments => _loanRepayments;

  // Merry-Go-Round
  List<MerryGoRoundCycle> _merryGoRoundCycles = [];
  List<MerryGoRoundCycle> get merryGoRoundCycles => _merryGoRoundCycles;

  // Shares
  List<Share> _shares = [];
  List<Share> get shares => _shares;

  // Goals
  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  List<GoalContribution> _goalContributions = [];
  List<GoalContribution> get goalContributions => _goalContributions;

  // Welfare
  List<WelfareContribution> _welfareContributions = [];
  List<WelfareContribution> get welfareContributions => _welfareContributions;

  // Summary
  Map<String, dynamic> _summary = {
    'memberCount': 0,
    'totalContributions': 0.0,
    'totalExpenses': 0.0,
  };
  Map<String, dynamic> get summary => _summary;

  // Connectivity & Sync
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _syncStatus;
  String? get syncStatus => _syncStatus;

  // Current user ID — from Supabase auth (single source of truth)
  String get currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'guest';

  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  bool _isPlatformAdmin = false;
  bool get isPlatformAdmin => _isPlatformAdmin;

  String? _supportSessionId;
  DateTime? _supportExpiresAt;
  String? _supportOrgId;
  String? get supportSessionId => _supportSessionId;
  DateTime? get supportExpiresAt => _supportExpiresAt;
  String? get supportOrgId => _supportOrgId;
  bool get isInSupportMode =>
      _supportSessionId != null &&
      _supportOrgId != null &&
      _supportExpiresAt != null &&
      _supportExpiresAt!.isAfter(DateTime.now());

  AppState() {
    Future.delayed(Duration.zero, () => _init());
  }

  Future<void> _init() async {
    try {
      // Initialize Supabase service
      await SupabaseService().init();

      await _loadOrganizations();
      await _loadPlatformAdminStatus();
      await _listenConnectivity();
      // If online and authenticated, trigger initial sync
      if (_isOnline && isAuthenticated && _currentOrg != null) {
        await syncNow();
      }
    } catch (e) {
      debugPrint('Error initializing AppState: $e');
    }
  }

  Future<void> _loadPlatformAdminStatus() async {
    try {
      if (!isAuthenticated) {
        _isPlatformAdmin = false;
        return;
      }
      // Only check when online; offline -> hide super admin features
      final result = await Connectivity().checkConnectivity();
      final online = result.any((r) => r != ConnectivityResult.none);
      if (!online) {
        _isPlatformAdmin = false;
        return;
      }

      final userId = currentUserId;
      final row = await Supabase.instance.client
          .from('platform_admins')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();
      _isPlatformAdmin = row != null;
      notifyListeners();
    } catch (_) {
      _isPlatformAdmin = false;
    }
  }

  Future<void> setPlatformMpesaConfig({
    required String mpesaEnv,
    required String consumerKey,
    required String consumerSecret,
    required String passkey,
    required String shortcode,
  }) async {
    if (!_isPlatformAdmin) {
      throw Exception('Forbidden: platform admin required');
    }

    final res = await Supabase.instance.client.functions.invoke(
      'platform-set-mpesa-config',
      body: {
        'mpesa_env': mpesaEnv,
        'consumer_key': consumerKey,
        'consumer_secret': consumerSecret,
        'passkey': passkey,
        'shortcode': shortcode,
      },
    );

    final data = res.data as Map?;
    if (res.status != 200 || data == null || data['success'] != true) {
      throw Exception(data?['error']?.toString() ?? 'Failed to save config');
    }
  }

  Future<void> enterSupportMode({
    required String sessionId,
    required DateTime expiresAt,
    required Organization organization,
  }) async {
    _supportSessionId = sessionId;
    _supportExpiresAt = expiresAt;
    _supportOrgId = organization.id;

    // Ensure org exists locally so the chama shell can operate normally.
    await LocalDb.insertOrganization(organization.copyWith(synced: true));
    await _loadOrganizations();
    await selectOrganization(organization.id);
    notifyListeners();
  }

  Future<void> exitSupportMode() async {
    _supportSessionId = null;
    _supportExpiresAt = null;
    _supportOrgId = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // ORGANIZATION MANAGEMENT
  // ─────────────────────────────────────────
  Future<void> _loadOrganizations() async {
    // If online and authenticated, fetch from Supabase first
    if (isAuthenticated && _isOnline) {
      try {
        final supabase = SupabaseService();
        final remoteOrgs = await supabase.getOrganizations();
        if (remoteOrgs.isNotEmpty) {
          // Sync to local DB
          for (final org in remoteOrgs) {
            await LocalDb.insertOrganization(org);
          }
          _organizations = remoteOrgs;
        } else {
          // Fallback to local DB
          _organizations = await LocalDb.getOrganizations();
        }
      } catch (e) {
        debugPrint('Error fetching orgs from Supabase: $e');
        _organizations = await LocalDb.getOrganizations();
      }
    } else {
      // Offline or not authenticated - use local DB only
      _organizations = await LocalDb.getOrganizations();
    }

    // If still no organizations, create a default one
    if (_organizations.isEmpty) {
      final defaultOrg = Organization(
        name: 'My Chama',
        description: 'Default organization',
      );
      await LocalDb.insertOrganization(defaultOrg);

      // Add user as admin member
      final userMember = OrgMember(
        orgId: defaultOrg.id,
        userId: currentUserId,
        name: 'Admin User',
        role: UserRole.admin,
      );
      await LocalDb.insertOrgMember(userMember);
      await LocalDb.activateModule(defaultOrg.id, ModuleType.base);

      _organizations = [defaultOrg];
    }

    // Set first org as current if none selected
    if (_currentOrg == null && _organizations.isNotEmpty) {
      await selectOrganization(_organizations.first.id);
    }

    notifyListeners();
  }

  Future<void> selectOrganization(String orgId) async {
    final org = await LocalDb.getOrganization(orgId);
    if (org != null) {
      _currentOrg = org;
      await loadAll();
      notifyListeners();
    }
  }

  Future<void> createOrganization(String name, {String? description}) async {
    final org = Organization(
      name: name,
      description: description,
    );
    await LocalDb.insertOrganization(org);

    // Create user as admin member
    final userMember = OrgMember(
      orgId: org.id,
      userId: currentUserId,
      name: isAuthenticated
          ? (Supabase.instance.client.auth.currentUser?.userMetadata?['name'] ??
              'Admin')
          : 'Admin',
      role: UserRole.admin,
    );
    await LocalDb.insertOrgMember(userMember);

    // Activate base module by default
    await LocalDb.activateModule(org.id, ModuleType.base);

    await _loadOrganizations();
  }

  // ─────────────────────────────────────────
  // MODULE MANAGEMENT
  // ─────────────────────────────────────────
  bool isModuleActive(ModuleType moduleType) {
    if (_currentOrg == null) return false;
    return _activatedModules.any(
      (m) => m.moduleType == moduleType && m.isActive,
    );
  }

  Future<void> activateModule(ModuleType moduleType,
      {Map<String, dynamic>? config}) async {
    if (_currentOrg == null) return;
    await LocalDb.activateModule(_currentOrg!.id, moduleType, config: config);
    await _loadActivatedModules();
    notifyListeners();
  }

  Future<void> updateOrganizationTier(BillingTier tier) async {
    if (_currentOrg == null) return;
    if (_currentOrg!.tier == tier) return;

    // Enterprise-grade rule: only admin can change billing tier
    if (!hasPermission(UserRole.admin)) {
      throw Exception(
          'Permission denied: admin required to change billing tier');
    }

    final previous = _currentOrg!;
    final updatedOrg = previous.copyWith(tier: tier);

    // Remote-first when possible to avoid local/remote drift
    if (isAuthenticated && _isOnline) {
      await SupabaseService()
          .client
          .from('organizations')
          .update({'tier': tier.code}).eq('id', updatedOrg.id);
    }

    await LocalDb.updateOrganization(updatedOrg);
    _organizations = _organizations
        .map((org) => org.id == updatedOrg.id ? updatedOrg : org)
        .toList();
    _currentOrg = updatedOrg;
    notifyListeners();
  }

  Future<void> deactivateModule(ModuleType moduleType) async {
    if (_currentOrg == null) return;
    await LocalDb.deactivateModule(_currentOrg!.id, moduleType);
    await _loadActivatedModules();
    notifyListeners();
  }

  Future<void> _loadActivatedModules() async {
    if (_currentOrg == null) return;
    _activatedModules = await LocalDb.getOrgModules(_currentOrg!.id);
  }

  // ─────────────────────────────────────────
  // MEMBER INVITATION
  // ─────────────────────────────────────────
  Future<void> inviteMemberToOrg({
    required String orgId,
    required String memberName,
    required String memberPhone,
    UserRole role = UserRole.member,
  }) async {
    // SECURITY: Only admin/treasurer can invite members
    if (!hasPermission(UserRole.treasurer)) {
      throw Exception(
          'Permission denied: Only treasurer or admin can invite members');
    }

    // Check if member already exists in org
    final existingMembers = await LocalDb.getOrgMembers(orgId);
    final alreadyMember = existingMembers.any(
      (m) => m.phone == memberPhone,
    );

    if (alreadyMember) {
      throw Exception(
          'Member with this phone already exists in the organization');
    }

    final newMember = OrgMember(
      orgId: orgId,
      userId: 'pending_${memberPhone.hashCode.abs()}',
      name: memberName,
      phone: memberPhone,
      role: role,
    );
    await LocalDb.insertOrgMember(newMember);

    // Send SMS invitation — fixed: message uses org name, not member name
    if (_isOnline) {
      await SmsService.sendSms(
        recipient: memberPhone.replaceAll(' ', ''),
        message:
            'Hello $memberName! You have been invited to join ${_currentOrg?.name ?? 'Mobifund'} as a ${role.name}. Download the Mobifund app to get started.',
      );
    }

    await loadAll();
  }

  Future<void> updateMember(OrgMember member) async {
    await LocalDb.insertOrgMember(member);
    if (_isOnline) {
      await SupabaseService()
          .client
          .from('org_members')
          .upsert(member.toSupabase());
    }
    await loadAll();
  }

  // ─────────────────────────────────────────
  // DATA LOADING — FULL RELOAD
  // ─────────────────────────────────────────
  Future<void> loadAll() async {
    if (_currentOrg == null) return;
    _isLoading = true;
    notifyListeners();

    final orgId = _currentOrg!.id;

    // If online and authenticated, fetch from Supabase first
    if (isAuthenticated && _isOnline) {
      await _loadFromSupabase(orgId);
    } else {
      // Load from local DB
      await _loadFromLocalDb(orgId);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load all data from Supabase (online mode)
  Future<void> _loadFromSupabase(String orgId) async {
    try {
      final supabase = SupabaseService();

      // Fetch all data in parallel from Supabase
      await Future.wait([
        supabase.fetchMembers(orgId).then((members) async {
          _members = members;
          await Future.wait(members.map((m) => LocalDb.insertMember(m)));
        }),
        supabase.client
            .from('org_members')
            .select()
            .eq('org_id', orgId)
            .eq('is_active', true)
            .then((response) async {
          _orgMembers =
              (response as List).map((m) => OrgMember.fromMap(m)).toList();
          await Future.wait(_orgMembers.map((m) => LocalDb.insertOrgMember(m)));
          _resolveUserRole(orgId);
        }),
        supabase.fetchContributions(orgId).then((contributions) async {
          _contributions = contributions;
          await Future.wait(
              contributions.map((c) => LocalDb.insertContribution(c)));
        }),
        supabase.fetchExpenses(orgId).then((expenses) async {
          _expenses = expenses;
          await Future.wait(expenses.map((e) => LocalDb.insertExpense(e)));
        }),
        supabase.fetchLoans(orgId).then((loans) async {
          _loans = loans;
          await Future.wait(loans.map((l) => LocalDb.insertLoan(l)));
        }),
        supabase.client
            .from('loan_repayments')
            .select()
            .eq('org_id', orgId)
            .order('date', ascending: false)
            .then((response) async {
          _loanRepayments =
              (response as List).map((r) => LoanRepayment.fromMap(r)).toList();
          await Future.wait(
              _loanRepayments.map((r) => LocalDb.insertLoanRepayment(r)));
        }),
        supabase.client
            .from('merry_go_round_cycles')
            .select()
            .eq('org_id', orgId)
            .order('created_at', ascending: false)
            .then((response) async {
          _merryGoRoundCycles = (response as List)
              .map((c) => MerryGoRoundCycle.fromMap(c))
              .toList();
          await Future.wait(_merryGoRoundCycles
              .map((c) => LocalDb.insertMerryGoRoundCycle(c)));
        }),
        supabase.client
            .from('shares')
            .select()
            .eq('org_id', orgId)
            .order('purchase_date', ascending: false)
            .then((response) async {
          _shares = (response as List).map((s) => Share.fromMap(s)).toList();
          await Future.wait(_shares.map((s) => LocalDb.insertShare(s)));
        }),
        supabase.client
            .from('goals')
            .select()
            .eq('org_id', orgId)
            .order('created_at', ascending: false)
            .then((response) async {
          _goals = (response as List).map((g) => Goal.fromMap(g)).toList();
          await Future.wait(_goals.map((g) => LocalDb.insertGoal(g)));
        }),
        supabase.client
            .from('goal_contributions')
            .select()
            .eq('org_id', orgId)
            .order('date', ascending: false)
            .then((response) async {
          _goalContributions = (response as List)
              .map((c) => GoalContribution.fromMap(c))
              .toList();
          await Future.wait(
              _goalContributions.map((c) => LocalDb.insertGoalContribution(c)));
        }),
        supabase.client
            .from('welfare_contributions')
            .select()
            .eq('org_id', orgId)
            .order('date', ascending: false)
            .then((response) async {
          _welfareContributions = (response as List)
              .map((c) => WelfareContribution.fromMap(c))
              .toList();
          await Future.wait(_welfareContributions
              .map((c) => LocalDb.insertWelfareContribution(c)));
        }),
      ]);

      // Load summary and modules from local DB (calculated data)
      await Future.wait([
        _loadSummary(orgId),
        _loadActivatedModules(),
      ]);
    } catch (e) {
      debugPrint('Error loading from Supabase: $e');
      // Fallback to local DB
      await _loadFromLocalDb(orgId);
    }
  }

  /// Load all data from local database (offline mode)
  Future<void> _loadFromLocalDb(String orgId) async {
    await Future.wait([
      _loadMembers(orgId),
      _loadOrgMembers(orgId),
      _loadContributions(orgId),
      _loadExpenses(orgId),
      _loadSummary(orgId),
      _loadLoans(orgId),
      _loadLoanRepayments(),
      _loadMerryGoRoundCycles(orgId),
      _loadShares(orgId),
      _loadGoals(orgId),
      _loadGoalContributions(),
      _loadWelfareContributions(orgId),
      _loadActivatedModules(),
    ]);
  }

  void _resolveUserRole(String orgId) {
    try {
      final me = _orgMembers.firstWhere(
        (m) => m.userId == currentUserId,
        orElse: () => OrgMember(
            orgId: orgId,
            userId: currentUserId,
            name: 'Unknown',
            role: UserRole.member),
      );
      _userRole = me.role;
    } catch (_) {}
  }

  Future<void> reconcileMpesa(String statementId) async {
    _isLoading = true;
    notifyListeners();
    // Simulate API call to reconciliation microservice
    await Future.delayed(const Duration(seconds: 3));
    _isLoading = false;
    notifyListeners();
  }

  bool isFeatureAllowed(String feature) {
    if (_currentOrg == null) return false;
    final tier = _currentOrg!.tier;

    switch (feature) {
      case 'mpesa_recon':
        return tier == BillingTier.pro || tier == BillingTier.enterprise;
      case 'advanced_analytics':
        return tier == BillingTier.pro || tier == BillingTier.enterprise;
      case 'unlimited_members':
        return tier == BillingTier.enterprise;
      default:
        return true;
    }
  }

  // ─────────────────────────────────────────
  // GRANULAR DATA LOADERS
  // ─────────────────────────────────────────
  Future<void> _loadMembers(String orgId) async {
    _members = await LocalDb.getMembers(orgId: orgId);
  }

  Future<void> _loadOrgMembers(String orgId) async {
    _orgMembers = await LocalDb.getOrgMembers(orgId);
    // Resolve current user's role
    final me = _orgMembers.firstWhere(
      (m) => m.userId == currentUserId,
      orElse: () => OrgMember(
          orgId: orgId,
          userId: currentUserId,
          name: 'Unknown',
          role: UserRole.member),
    );
    _userRole = me.role;
  }

  Future<void> _loadContributions(String orgId) async {
    _contributions = await LocalDb.getContributions(orgId: orgId);
  }

  Future<void> _loadExpenses(String orgId) async {
    _expenses = await LocalDb.getExpenses(orgId: orgId);
  }

  Future<void> _loadSummary(String orgId) async {
    _summary = await LocalDb.getSummary(orgId: orgId);
  }

  Future<void> _loadLoans(String orgId) async {
    _loans = await LocalDb.getLoans(orgId: orgId);
  }

  Future<void> _loadLoanRepayments() async {
    _loanRepayments = await LocalDb.getLoanRepayments();
  }

  Future<void> _loadMerryGoRoundCycles(String orgId) async {
    _merryGoRoundCycles = await LocalDb.getMerryGoRoundCycles(orgId: orgId);
  }

  Future<void> _loadShares(String orgId) async {
    _shares = await LocalDb.getShares(orgId: orgId);
  }

  Future<void> _loadGoals(String orgId) async {
    _goals = await LocalDb.getGoals(orgId: orgId);
  }

  Future<void> _loadGoalContributions() async {
    _goalContributions = await LocalDb.getGoalContributions();
  }

  Future<void> _loadWelfareContributions(String orgId) async {
    _welfareContributions = await LocalDb.getWelfareContributions(orgId: orgId);
  }

  // ─────────────────────────────────────────
  // CONNECTIVITY
  // ─────────────────────────────────────────
  Future<void> _listenConnectivity() async {
    try {
      // Get current connectivity status (not just the next event)
      final result = await Connectivity().checkConnectivity();
      _isOnline = result.any((r) => r != ConnectivityResult.none);
      notifyListeners();
      if (_isOnline) await syncNow();
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }

    // Listen for changes
    Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
        if (_isOnline) await syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _syncStatus = 'Syncing…';
    notifyListeners();

    try {
      await SyncService.pushUnsynced();
      await SyncService.pullAll(orgId: _currentOrg?.id);
      // Reload just members, contributions, expenses after sync
      if (_currentOrg != null) {
        await _loadMembers(_currentOrg!.id);
        await _loadContributions(_currentOrg!.id);
        await _loadExpenses(_currentOrg!.id);
        await _loadSummary(_currentOrg!.id);
        await _loadLoans(_currentOrg!.id);
      }
      _syncStatus = 'Synced ✓';
    } catch (e) {
      _syncStatus = 'Sync failed';
      debugPrint('Sync error: $e');
    }

    _isSyncing = false;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 3));
    _syncStatus = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // MEMBERS — GRANULAR UPDATES
  // ─────────────────────────────────────────
  Future<void> addMember(OrgMember member) async {
    await LocalDb.insertMember(member);
    if (_isOnline) {
      try {
        await SyncService.pushUnsynced();
      } catch (_) {}
    }

    // Granular reload — only members and summary
    if (_currentOrg != null) {
      await _loadMembers(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();

    // Send SMS notification
    if (member.phone != null && _isOnline) {
      await SmsService.sendSms(
        recipient: member.phone!.replaceAll(' ', ''),
        message:
            'Welcome to ${_currentOrg?.name ?? 'Mobifund'}! You have been added as a member. Start contributing to grow together.',
      );
    }
  }

  Future<void> deleteMember(String id) async {
    await LocalDb.deleteMember(id);
    if (_isOnline) await SyncService.deleteRemoteMember(id);
    if (_currentOrg != null) {
      await _loadMembers(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // CONTRIBUTIONS — GRANULAR UPDATES
  // ─────────────────────────────────────────
  Future<void> addContribution(Contribution contribution) async {
    await LocalDb.insertContribution(contribution);
    if (_isOnline) {
      try {
        await SyncService.pushUnsynced();
      } catch (_) {}
    }

    // Granular reload — only contributions and summary
    if (_currentOrg != null) {
      await _loadContributions(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();

    // Send SMS notification
    final member = _members.firstWhere((m) => m.id == contribution.userId,
        orElse: () => OrgMember(
            orgId: _currentOrg?.id ?? '', userId: '', name: 'Member'));
    if (member.phone != null && _isOnline) {
      await SmsService.sendSms(
        recipient: member.phone!.replaceAll(' ', ''),
        message: SmsTemplates.contributionReceived(
          memberName: member.name.split(' ').first,
          amount: contribution.amount,
          date: contribution.date,
        ),
      );
    }
  }

  Future<void> deleteContribution(String id) async {
    await LocalDb.deleteContribution(id);
    if (_isOnline) await SyncService.deleteRemoteContribution(id);
    if (_currentOrg != null) {
      await _loadContributions(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // EXPENSES — GRANULAR UPDATES
  // ─────────────────────────────────────────
  Future<void> addExpense(Expense expense) async {
    await LocalDb.insertExpense(expense);
    if (_isOnline) {
      try {
        await SyncService.pushUnsynced();
      } catch (_) {}
    }

    // Granular reload — only expenses and summary
    if (_currentOrg != null) {
      await _loadExpenses(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();

    // Send SMS notification to treasurer/admin
    if (_isOnline) {
      final treasurers = _orgMembers.where(
          (m) => m.role == UserRole.treasurer || m.role == UserRole.admin);
      for (final treasurer in treasurers) {
        if (treasurer.phone != null) {
          await SmsService.sendSms(
            recipient: treasurer.phone!.replaceAll(' ', ''),
            message: SmsTemplates.expenseNotification(
              expenseType: expense.type,
              amount: expense.amount,
              date: expense.date,
            ),
          );
        }
      }
    }
  }

  Future<void> deleteExpense(String id) async {
    await LocalDb.deleteExpense(id);
    if (_isOnline) await SyncService.deleteRemoteExpense(id);
    if (_currentOrg != null) {
      await _loadExpenses(_currentOrg!.id);
      await _loadSummary(_currentOrg!.id);
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // LOANS — GRANULAR UPDATES
  // ─────────────────────────────────────────
  Future<void> applyForLoan(Loan loan) async {
    await LocalDb.insertLoan(loan);
    if (_currentOrg != null) await _loadLoans(_currentOrg!.id);
    notifyListeners();
  }

  Future<void> approveLoan(String loanId) async {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final updatedLoan = loan.copyWith(
      status: LoanStatus.approved,
      approvalDate: DateTime.now(),
    );
    await LocalDb.updateLoan(updatedLoan);
    if (_currentOrg != null) await _loadLoans(_currentOrg!.id);
    notifyListeners();
  }

  Future<void> disburseLoan(String loanId) async {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final updatedLoan = loan.copyWith(
      status: LoanStatus.disbursed,
      disbursementDate: DateTime.now(),
    );
    await LocalDb.updateLoan(updatedLoan);
    if (_currentOrg != null) await _loadLoans(_currentOrg!.id);
    notifyListeners();

    // Send SMS notification
    final member = _members.firstWhere((m) => m.id == loan.memberId,
        orElse: () => OrgMember(
            orgId: _currentOrg?.id ?? '', userId: '', name: 'Member'));
    if (member.phone != null && _isOnline) {
      await SmsService.sendSms(
        recipient: member.phone!.replaceAll(' ', ''),
        message: SmsTemplates.loanApproved(
          memberName: member.name.split(' ').first,
          amount: loan.principal,
          dueDate: loan.dueDate,
        ),
      );
    }
  }

  Future<void> repayLoan(LoanRepayment repayment) async {
    await LocalDb.insertLoanRepayment(repayment);

    // Update loan balance
    final loan = _loans.firstWhere((l) => l.id == repayment.loanId);
    final newBalance =
        (loan.balance - repayment.amount).clamp(0.0, double.infinity);
    final newPaidAmount = loan.paidAmount + repayment.amount;

    LoanStatus newStatus = loan.status;
    DateTime? completedDate;

    if (newBalance <= 0) {
      newStatus = LoanStatus.completed;
      completedDate = DateTime.now();
    }

    final updatedLoan = loan.copyWith(
      balance: newBalance,
      paidAmount: newPaidAmount,
      status: newStatus,
      completedDate: completedDate,
    );
    await LocalDb.updateLoan(updatedLoan);
    if (_currentOrg != null) {
      await _loadLoans(_currentOrg!.id);
      await _loadLoanRepayments();
    }
    notifyListeners();
  }

  Future<void> rejectLoan(String loanId) async {
    final loan = _loans.firstWhere((l) => l.id == loanId);
    final updatedLoan = loan.copyWith(status: LoanStatus.rejected);
    await LocalDb.updateLoan(updatedLoan);
    if (_currentOrg != null) await _loadLoans(_currentOrg!.id);
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // MERRY-GO-ROUND
  // ─────────────────────────────────────────
  Future<void> createMerryGoRoundCycle(MerryGoRoundCycle cycle) async {
    await LocalDb.insertMerryGoRoundCycle(cycle);
    if (_currentOrg != null) await _loadMerryGoRoundCycles(_currentOrg!.id);
    notifyListeners();
  }

  Future<void> advanceMerryGoRoundCycle(String cycleId) async {
    final cycle = _merryGoRoundCycles.firstWhere((c) => c.id == cycleId);

    if (cycle.currentPosition >= cycle.totalMembers - 1) {
      final updatedCycle = cycle.copyWith(status: 'completed');
      await LocalDb.updateMerryGoRoundCycle(updatedCycle);
    } else {
      final newPosition = cycle.currentPosition + 1;
      final newRecipientId = newPosition < cycle.memberOrder.length
          ? cycle.memberOrder[newPosition]
          : null;

      final updatedCycle = cycle.copyWith(
        currentPosition: newPosition,
        currentRecipientId: newRecipientId,
        completedRecipients: [
          ...cycle.completedRecipients,
          cycle.currentRecipientId ?? ''
        ],
      );
      await LocalDb.updateMerryGoRoundCycle(updatedCycle);

      // Send SMS to new recipient
      if (newRecipientId != null && _isOnline) {
        final member = _members.firstWhere(
          (m) => m.id == newRecipientId,
          orElse: () => OrgMember(
              orgId: _currentOrg?.id ?? '', userId: '', name: 'Member'),
        );
        if (member.phone != null) {
          await SmsService.sendSms(
            recipient: member.phone!.replaceAll(' ', ''),
            message: SmsTemplates.merryGoRoundPayout(
              memberName: member.name.split(' ').first,
              amount: cycle.contributionAmount * cycle.totalMembers,
              cycle: cycle.currentPosition + 1,
            ),
          );
        }
      }
    }

    if (_currentOrg != null) await _loadMerryGoRoundCycles(_currentOrg!.id);
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // SHARES
  // ─────────────────────────────────────────
  Future<void> purchaseShares(Share share) async {
    await LocalDb.insertShare(share);
    if (_currentOrg != null) await _loadShares(_currentOrg!.id);
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // GOALS
  // ─────────────────────────────────────────
  Future<void> createGoal(Goal goal) async {
    await LocalDb.insertGoal(goal);
    if (_currentOrg != null) await _loadGoals(_currentOrg!.id);
    notifyListeners();
  }

  Future<void> contributeToGoal(GoalContribution contribution) async {
    await LocalDb.insertGoalContribution(contribution);

    // Update goal raised amount
    final goal = _goals.firstWhere((g) => g.id == contribution.goalId);
    final newRaisedAmount = goal.raisedAmount + contribution.amount;
    final newContributorCount = goal.contributorCount + 1;

    String? newStatus = goal.status;
    DateTime? completedAt;

    if (newRaisedAmount >= goal.targetAmount) {
      newStatus = 'completed';
      completedAt = DateTime.now();
    }

    final updatedGoal = goal.copyWith(
      raisedAmount: newRaisedAmount,
      contributorCount: newContributorCount,
      status: newStatus,
      completedAt: completedAt,
    );
    await LocalDb.updateGoal(updatedGoal);
    if (_currentOrg != null) {
      await _loadGoals(_currentOrg!.id);
      await _loadGoalContributions();
    }
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // WELFARE
  // ─────────────────────────────────────────
  Future<void> contributeToWelfare(WelfareContribution contribution) async {
    await LocalDb.insertWelfareContribution(contribution);
    if (_currentOrg != null) await _loadWelfareContributions(_currentOrg!.id);
    notifyListeners();

    // Send SMS to contributor
    if (_isOnline && contribution.beneficiaryId != null) {
      final member = _members.firstWhere(
        (m) => m.id == contribution.memberId,
        orElse: () =>
            OrgMember(orgId: _currentOrg?.id ?? '', userId: '', name: 'Member'),
      );
      final beneficiary = _members.firstWhere(
        (m) => m.id == contribution.beneficiaryId,
        orElse: () => OrgMember(
            orgId: _currentOrg?.id ?? '', userId: '', name: 'a member'),
      );

      if (member.phone != null) {
        await SmsService.sendSms(
          recipient: member.phone!.replaceAll(' ', ''),
          message: SmsTemplates.welfareContribution(
            memberName: member.name.split(' ').first,
            amount: contribution.amount,
            beneficiary: beneficiary.name,
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  String getMemberName(String memberId) {
    try {
      return _members.firstWhere((m) => m.id == memberId).name;
    } catch (_) {
      return 'Unknown';
    }
  }

  double getMemberTotal(String memberId) {
    return _contributions
        .where((c) => c.userId == memberId)
        .fold(0.0, (s, c) => s + c.amount);
  }

  OrgMember? getCurrentOrgMember() {
    try {
      return _orgMembers.firstWhere((m) => m.userId == currentUserId);
    } catch (_) {
      return null;
    }
  }

  bool hasPermission(UserRole requiredRole) {
    final userMember = getCurrentOrgMember();
    if (userMember == null) return false;

    // Admin has all permissions
    if (userMember.role == UserRole.admin) return true;

    // Check role hierarchy
    const roleHierarchy = {
      UserRole.admin: 4,
      UserRole.treasurer: 3,
      UserRole.secretary: 2,
      UserRole.member: 1,
    };

    return roleHierarchy[userMember.role]! >= roleHierarchy[requiredRole]!;
  }

  // ─────────────────────────────────────────
  //  ANALYTICS HELPERS
  // ─────────────────────────────────────────

  double calculateGrowth() {
    if (contributions.isEmpty) return 0;

    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    final thisMonth = contributions
        .where((c) =>
            c.date.isAfter(thisMonthStart) ||
            c.date.isAtSameMomentAs(thisMonthStart))
        .fold(0.0, (sum, c) => sum + c.amount);

    final lastMonth = contributions
        .where((c) =>
            (c.date.isAfter(lastMonthStart) ||
                c.date.isAtSameMomentAs(lastMonthStart)) &&
            c.date.isBefore(thisMonthStart))
        .fold(0.0, (sum, c) => sum + c.amount);

    if (lastMonth <= 0) return thisMonth > 0 ? 100 : 0;

    return ((thisMonth - lastMonth) / lastMonth * 100);
  }

  Map<String, double> getExpenseBreakdown() {
    final breakdown = <String, double>{};
    for (var e in expenses) {
      breakdown[e.type] = (breakdown[e.type] ?? 0) + e.amount;
    }
    return breakdown;
  }

  List<Map<String, dynamic>> getTopContributors() {
    final contributorTotals = <String, Map<String, dynamic>>{};

    for (var c in contributions) {
      if (!contributorTotals.containsKey(c.userId)) {
        contributorTotals[c.userId] = {
          'memberId': c.userId,
          'name': getMemberName(c.userId),
          'total': 0.0,
          'count': 0,
        };
      }
      contributorTotals[c.userId]!['total'] += c.amount;
      contributorTotals[c.userId]!['count']++;
    }

    final list = contributorTotals.values.toList();
    list.sort((a, b) => (b['total'] as double).compareTo(a['total'] as double));

    return list.map((c) {
      final name = c['name'] as String;
      c['initials'] = name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
      return c;
    }).toList();
  }

  List<Map<String, dynamic>> getRecentActivity() {
    final activities = <Map<String, dynamic>>[];

    // Add recent contributions
    for (var c in contributions.take(5)) {
      activities.add({
        'type': 'contribution',
        'date': c.date,
        'amount': c.amount,
        'label': getMemberName(c.userId),
      });
    }

    // Add recent expenses
    for (var e in expenses.take(5)) {
      activities.add({
        'type': 'expense',
        'date': e.date,
        'amount': e.amount,
        'label': e.type,
      });
    }

    activities.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return activities.take(5).toList();
  }
}
