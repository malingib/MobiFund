import 'dart:convert';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────
// BILLING TIERS
// ─────────────────────────────────────────
enum BillingTier {
  free,
  pro,
  enterprise,
}

extension BillingTierExtension on BillingTier {
  String get name {
    switch (this) {
      case BillingTier.free:
        return 'Free';
      case BillingTier.pro:
        return 'Pro';
      case BillingTier.enterprise:
        return 'Enterprise';
    }
  }

  String get code {
    switch (this) {
      case BillingTier.free:
        return 'free';
      case BillingTier.pro:
        return 'pro';
      case BillingTier.enterprise:
        return 'enterprise';
    }
  }

  static BillingTier fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'pro':
        return BillingTier.pro;
      case 'enterprise':
        return BillingTier.enterprise;
      default:
        return BillingTier.free;
    }
  }
}

// ─────────────────────────────────────────
// ORGANIZATION (CHAMA)
// ─────────────────────────────────────────
class Organization {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final BillingTier tier;
  final DateTime createdAt;
  final bool isActive;
  final bool synced;

  Organization({
    String? id,
    required this.name,
    this.description,
    this.logoUrl,
    this.tier = BillingTier.free,
    DateTime? createdAt,
    this.isActive = true,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description ?? '',
        'logo_url': logoUrl ?? '',
        'tier': tier.code,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'synced': synced ? 1 : 0,
      };

  factory Organization.fromMap(Map<String, dynamic> m) => Organization(
        id: m['id'],
        name: m['name'],
        description: m['description'] == '' ? null : m['description'],
        logoUrl: m['logo_url'] == '' ? null : m['logo_url'],
        tier: BillingTierExtension.fromCode(m['tier'] ?? 'free'),
        createdAt: DateTime.parse(m['created_at']),
        isActive: (m['is_active'] ?? 1) == 1,
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'name': name,
        'description': description,
        'logo_url': logoUrl,
        'tier': tier.code,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };

  Organization copyWith({
    String? name,
    String? description,
    String? logoUrl,
    BillingTier? tier,
    bool? isActive,
    bool? synced,
  }) =>
      Organization(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        logoUrl: logoUrl ?? this.logoUrl,
        tier: tier ?? this.tier,
        createdAt: createdAt,
        isActive: isActive ?? this.isActive,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// USER ROLE (RBAC)
// ─────────────────────────────────────────
enum UserRole {
  admin, // Full access - can manage organization, members, all modules
  treasurer, // Financial access - manage contributions, expenses, loans
  secretary, // Administrative - manage members, meetings, communications
  member, // Basic access - view own data, contribute
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.treasurer:
        return 'Treasurer';
      case UserRole.secretary:
        return 'Secretary';
      case UserRole.member:
        return 'Member';
    }
  }

  String get code {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.treasurer:
        return 'treasurer';
      case UserRole.secretary:
        return 'secretary';
      case UserRole.member:
        return 'member';
    }
  }

  static UserRole fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'treasurer':
        return UserRole.treasurer;
      case 'secretary':
        return UserRole.secretary;
      default:
        return UserRole.member;
    }
  }
}

// ─────────────────────────────────────────
// ORGANIZATION MEMBER (User-Organization Pivot)
// ─────────────────────────────────────────
class OrgMember {
  final String id;
  final String orgId;
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final UserRole role;
  final DateTime joinedAt;
  final bool isActive;
  final bool synced;

  OrgMember({
    String? id,
    required this.orgId,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.role = UserRole.member,
    DateTime? joinedAt,
    this.isActive = true,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'user_id': userId,
        'name': name,
        'phone': phone ?? '',
        'email': email ?? '',
        'role': role.code,
        'joined_at': joinedAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'synced': synced ? 1 : 0,
      };

  factory OrgMember.fromMap(Map<String, dynamic> m) => OrgMember(
        id: m['id'],
        orgId: m['org_id'],
        userId: m['user_id'],
        name: m['name'],
        phone: m['phone'] == '' ? null : m['phone'],
        email: m['email'] == '' ? null : m['email'],
        role: UserRoleExtension.fromCode(m['role'] ?? 'member'),
        joinedAt: DateTime.parse(m['joined_at']),
        isActive: (m['is_active'] ?? 1) == 1,
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'user_id': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role.code,
        'joined_at': joinedAt.toIso8601String(),
        'is_active': isActive,
      };

  OrgMember copyWith({
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    bool? isActive,
    bool? synced,
  }) =>
      OrgMember(
        id: id,
        orgId: orgId,
        userId: userId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        email: email ?? this.email,
        role: role ?? this.role,
        joinedAt: joinedAt,
        isActive: isActive ?? this.isActive,
        synced: synced ?? this.synced,
      );

  String get initials {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return '??';
    final parts = trimmedName.split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmedName.substring(0, trimmedName.length >= 2 ? 2 : 1).toUpperCase();
  }

}

// ─────────────────────────────────────────
// MODULE (Feature Activation)
// ─────────────────────────────────────────
enum ModuleType {
  base, // Always active - Contributions & Expenses
  loans, // Loans module
  merryGoRound, // Merry-Go-Round module
  shares, // Shares/Savings module
  goals, // Goals/Investment module
  welfare, // Welfare module
}

extension ModuleTypeExtension on ModuleType {
  String get name {
    switch (this) {
      case ModuleType.base:
        return 'Base Module';
      case ModuleType.loans:
        return 'Loans';
      case ModuleType.merryGoRound:
        return 'Merry-Go-Round';
      case ModuleType.shares:
        return 'Shares & Savings';
      case ModuleType.goals:
        return 'Goals & Investment';
      case ModuleType.welfare:
        return 'Welfare';
    }
  }

  String get code {
    switch (this) {
      case ModuleType.base:
        return 'base';
      case ModuleType.loans:
        return 'loans';
      case ModuleType.merryGoRound:
        return 'merry_go_round';
      case ModuleType.shares:
        return 'shares';
      case ModuleType.goals:
        return 'goals';
      case ModuleType.welfare:
        return 'welfare';
    }
  }

  String get description {
    switch (this) {
      case ModuleType.base:
        return 'Contributions & Expenses tracking';
      case ModuleType.loans:
        return 'Soft & Normal loans with automated calculations';
      case ModuleType.merryGoRound:
        return 'Rotational savings and distribution';
      case ModuleType.shares:
        return 'Track member shares and savings';
      case ModuleType.goals:
        return 'Group investment goals tracking';
      case ModuleType.welfare:
        return 'Member welfare and support fund';
    }
  }

  static ModuleType fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'base':
        return ModuleType.base;
      case 'loans':
        return ModuleType.loans;
      case 'merry_go_round':
        return ModuleType.merryGoRound;
      case 'shares':
        return ModuleType.shares;
      case 'goals':
        return ModuleType.goals;
      case 'welfare':
        return ModuleType.welfare;
      default:
        return ModuleType.base;
    }
  }
}

// ─────────────────────────────────────────
// ORGANIZATION MODULE (Activated Modules)
// ─────────────────────────────────────────
class OrgModule {
  final String id;
  final String orgId;
  final ModuleType moduleType;
  final bool isActive;
  final Map<String, dynamic>? config;
  final DateTime activatedAt;
  final bool synced;

  OrgModule({
    String? id,
    required this.orgId,
    required this.moduleType,
    this.isActive = true,
    this.config,
    DateTime? activatedAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        activatedAt = activatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'module_type': moduleType.code,
        'is_active': isActive ? 1 : 0,
        'config': config != null ? jsonEncode(config) : '',
        'activated_at': activatedAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory OrgModule.fromMap(Map<String, dynamic> m) => OrgModule(
        id: m['id'],
        orgId: m['org_id'],
        moduleType: ModuleTypeExtension.fromCode(m['module_type'] ?? 'base'),
        isActive: (m['is_active'] ?? 1) == 1,
        config: m['config'] != '' && m['config'] != null
            ? jsonDecode(m['config'])
            : null,
        activatedAt: DateTime.parse(m['activated_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'module_type': moduleType.code,
        'is_active': isActive,
        'config': config,
        'activated_at': activatedAt.toIso8601String(),
      };

  OrgModule copyWith({
    bool? isActive,
    Map<String, dynamic>? config,
    bool? synced,
  }) =>
      OrgModule(
        id: id,
        orgId: orgId,
        moduleType: moduleType,
        isActive: isActive ?? this.isActive,
        config: config ?? this.config,
        activatedAt: activatedAt,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// CONTRIBUTION (Enhanced with org_id)
// ─────────────────────────────────────────
class Contribution {
  final String id;
  final String orgId; // Multi-tenancy support
  final String userId;
  final double amount;
  final DateTime date;
  final String? note;
  final String? paymentMethod; // cash, mpesa, bank
  final String? transactionCode; // M-Pesa receipt / bank ref
  final DateTime createdAt;
  final bool synced;

  Contribution({
    String? id,
    required this.orgId,
    required this.userId,
    required this.amount,
    required this.date,
    this.note,
    this.paymentMethod,
    this.transactionCode,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'user_id': userId,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'note': note ?? '',
        'payment_method': paymentMethod ?? '',
        'transaction_code': transactionCode ?? '',
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory Contribution.fromMap(Map<String, dynamic> m) => Contribution(
        id: m['id'],
        orgId: m['org_id'],
        userId: m['user_id'],
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date']),
        note: m['note'] == '' ? null : m['note'],
        paymentMethod:
            m['payment_method'] == '' ? null : (m['payment_method'] as String?),
        transactionCode: m['transaction_code'] == ''
            ? null
            : (m['transaction_code'] as String?),
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'user_id': userId,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'note': note,
        'payment_method': paymentMethod,
        'transaction_code': transactionCode,
        'created_at': createdAt.toIso8601String(),
      };

  Contribution copyWith({bool? synced}) => Contribution(
        id: id,
        orgId: orgId,
        userId: userId,
        amount: amount,
        date: date,
        note: note,
        paymentMethod: paymentMethod,
        transactionCode: transactionCode,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// EXPENSE (Enhanced with org_id)
// ─────────────────────────────────────────
class Expense {
  final String id;
  final String orgId; // Multi-tenancy support
  final String type;
  final double amount;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final bool synced;

  Expense({
    String? id,
    required this.orgId,
    required this.type,
    required this.amount,
    required this.date,
    this.description,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'description': description ?? '',
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
        id: m['id'],
        orgId: m['org_id'],
        type: m['type'],
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date']),
        description: m['description'] == '' ? null : m['description'],
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'type': type,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  Expense copyWith({bool? synced}) => Expense(
        id: id,
        orgId: orgId,
        type: type,
        amount: amount,
        date: date,
        description: description,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}
