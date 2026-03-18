import 'dart:convert';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────
// LOAN TYPES
// ─────────────────────────────────────────
enum LoanType {
  softLoan,    // Payable within 1 month, no interest
  normalLoan,  // Custom repayment period with interest
}

extension LoanTypeExtension on LoanType {
  String get name {
    switch (this) {
      case LoanType.softLoan:
        return 'Soft Loan';
      case LoanType.normalLoan:
        return 'Normal Loan';
    }
  }

  String get code {
    switch (this) {
      case LoanType.softLoan:
        return 'soft_loan';
      case LoanType.normalLoan:
        return 'normal_loan';
    }
  }

  static LoanType fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'soft_loan':
        return LoanType.softLoan;
      case 'normal_loan':
        return LoanType.normalLoan;
      default:
        return LoanType.softLoan;
    }
  }
}

// ─────────────────────────────────────────
// LOAN STATUS
// ─────────────────────────────────────────
enum LoanStatus {
  pending,
  approved,
  rejected,
  disbursed,
  active,
  completed,
  defaulted,
}

extension LoanStatusExtension on LoanStatus {
  String get name {
    switch (this) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.approved:
        return 'Approved';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.disbursed:
        return 'Disbursed';
      case LoanStatus.active:
        return 'Active';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
    }
  }

  static LoanStatus fromCode(String code) {
    switch (code.toLowerCase()) {
      case 'pending':
        return LoanStatus.pending;
      case 'approved':
        return LoanStatus.approved;
      case 'rejected':
        return LoanStatus.rejected;
      case 'disbursed':
        return LoanStatus.disbursed;
      case 'active':
        return LoanStatus.active;
      case 'completed':
        return LoanStatus.completed;
      case 'defaulted':
        return LoanStatus.defaulted;
      default:
        return LoanStatus.pending;
    }
  }
}

// ─────────────────────────────────────────
// LOAN
// ─────────────────────────────────────────
class Loan {
  final String id;
  final String orgId;
  final String memberId;
  final LoanType loanType;
  final double principal;
  final double interestRate; // Percentage (e.g., 5 for 5%)
  final double interestAmount;
  final double totalAmount;
  final int repaymentPeriodMonths;
  final double monthlyInstallment;
  final double paidAmount;
  final double balance;
  final LoanStatus status;
  final String? guarantorId;
  final String? purpose;
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final DateTime? disbursementDate;
  final DateTime dueDate;
  final DateTime? completedDate;
  final String? notes;
  final bool synced;
  Loan({
    String? id,
    required this.orgId,
    required this.memberId,
    required LoanType loanType,
    required this.principal,
    this.interestRate = 0,
    double? interestAmount,
    double? totalAmount,
    this.repaymentPeriodMonths = 1,
    double? monthlyInstallment,
    this.paidAmount = 0,
    double? balance,
    this.status = LoanStatus.pending,
    this.guarantorId,
    this.purpose,
    DateTime? applicationDate,
    this.approvalDate,
    this.disbursementDate,
    DateTime? dueDate,
    this.completedDate,
    this.notes,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        applicationDate = applicationDate ?? DateTime.now(),
        interestAmount = interestAmount ?? (principal * interestRate / 100),
        totalAmount = totalAmount ?? (principal + (principal * interestRate / 100)),
        monthlyInstallment = monthlyInstallment ?? ((principal + (principal * interestRate / 100)) / repaymentPeriodMonths),
        balance = balance ?? (principal + (principal * interestRate / 100)),
        dueDate = dueDate ?? _calculateDueDate(applicationDate ?? DateTime.now(), repaymentPeriodMonths),
        loanType = loanType == LoanType.softLoan 
            ? (interestRate == 0 ? loanType : LoanType.softLoan) // Soft loans have 0 interest
            : loanType;

  static DateTime _calculateDueDate(DateTime start, int months) {
    final month = start.month - 1 + months;
    final year = start.year + month ~/ 12;
    final newMonth = month % 12 + 1;
    final day = DateTime(year, newMonth + 1, 0).day < start.day
        ? DateTime(year, newMonth + 1, 0).day
        : start.day;
    return DateTime(year, newMonth, day);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'loan_type': loanType.code,
        'principal': principal,
        'interest_rate': interestRate,
        'interest_amount': interestAmount,
        'total_amount': totalAmount,
        'repayment_period_months': repaymentPeriodMonths,
        'monthly_installment': monthlyInstallment,
        'paid_amount': paidAmount,
        'balance': balance,
        'status': status.name.toLowerCase(),
        'guarantor_id': guarantorId ?? '',
        'purpose': purpose ?? '',
        'application_date': applicationDate.toIso8601String(),
        'approval_date': approvalDate?.toIso8601String() ?? '',
        'disbursement_date': disbursementDate?.toIso8601String() ?? '',
        'due_date': dueDate.toIso8601String(),
        'completed_date': completedDate?.toIso8601String() ?? '',
        'notes': notes ?? '',
        'synced': synced ? 1 : 0,
      };

  factory Loan.fromMap(Map<String, dynamic> m) => Loan(
        id: m['id'],
        orgId: m['org_id'],
        memberId: m['member_id'],
        loanType: LoanTypeExtension.fromCode(m['loan_type'] ?? 'soft_loan'),
        principal: (m['principal'] as num).toDouble(),
        interestRate: (m['interest_rate'] as num?)?.toDouble() ?? 0,
        interestAmount: (m['interest_amount'] as num?)?.toDouble(),
        totalAmount: (m['total_amount'] as num?)?.toDouble(),
        repaymentPeriodMonths: m['repayment_period_months'] ?? 1,
        monthlyInstallment: (m['monthly_installment'] as num?)?.toDouble(),
        paidAmount: (m['paid_amount'] as num?)?.toDouble() ?? 0,
        balance: (m['balance'] as num?)?.toDouble(),
        status: LoanStatusExtension.fromCode(m['status'] ?? 'pending'),
        guarantorId: m['guarantor_id'] == '' ? null : m['guarantor_id'],
        purpose: m['purpose'] == '' ? null : m['purpose'],
        applicationDate: DateTime.parse(m['application_date']),
        approvalDate: m['approval_date'] == '' || m['approval_date'] == null
            ? null
            : DateTime.parse(m['approval_date']),
        disbursementDate: m['disbursement_date'] == '' || m['disbursement_date'] == null
            ? null
            : DateTime.parse(m['disbursement_date']),
        dueDate: DateTime.parse(m['due_date']),
        completedDate: m['completed_date'] == '' || m['completed_date'] == null
            ? null
            : DateTime.parse(m['completed_date']),
        notes: m['notes'] == '' ? null : m['notes'],
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'loan_type': loanType.code,
        'principal': principal,
        'interest_rate': interestRate,
        'interest_amount': interestAmount,
        'total_amount': totalAmount,
        'repayment_period_months': repaymentPeriodMonths,
        'monthly_installment': monthlyInstallment,
        'paid_amount': paidAmount,
        'balance': balance,
        'status': status.name.toLowerCase(),
        'guarantor_id': guarantorId,
        'purpose': purpose,
        'application_date': applicationDate.toIso8601String(),
        'approval_date': approvalDate?.toIso8601String(),
        'disbursement_date': disbursementDate?.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'notes': notes,
      };

  Loan copyWith({
    LoanStatus? status,
    double? paidAmount,
    double? balance,
    DateTime? approvalDate,
    DateTime? disbursementDate,
    DateTime? completedDate,
    bool? synced,
  }) =>
      Loan(
        id: id,
        orgId: orgId,
        memberId: memberId,
        loanType: loanType,
        principal: principal,
        interestRate: interestRate,
        interestAmount: interestAmount,
        totalAmount: totalAmount,
        repaymentPeriodMonths: repaymentPeriodMonths,
        monthlyInstallment: monthlyInstallment,
        paidAmount: paidAmount ?? this.paidAmount,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        guarantorId: guarantorId,
        purpose: purpose,
        applicationDate: applicationDate,
        approvalDate: approvalDate ?? this.approvalDate,
        disbursementDate: disbursementDate ?? this.disbursementDate,
        dueDate: dueDate,
        completedDate: completedDate ?? this.completedDate,
        notes: notes,
        synced: synced ?? this.synced,
      );

  bool get isOverdue =>
      DateTime.now().isAfter(dueDate) && status == LoanStatus.active && balance > 0;

  double get progressPercent => totalAmount > 0 ? (paidAmount / totalAmount * 100) : 0;
}

// ─────────────────────────────────────────
// LOAN REPAYMENT
// ─────────────────────────────────────────
class LoanRepayment {
  final String id;
  final String orgId;
  final String loanId;
  final String memberId;
  final double amount;
  final DateTime date;
  final String? paymentMethod; // cash, mpesa, bank
  final String? transactionCode;
  final String? notes;
  final DateTime createdAt;
  final bool synced;

  LoanRepayment({
    String? id,
    required this.orgId,
    required this.loanId,
    required this.memberId,
    required this.amount,
    DateTime? date,
    this.paymentMethod,
    this.transactionCode,
    this.notes,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'loan_id': loanId,
        'member_id': memberId,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'payment_method': paymentMethod ?? '',
        'transaction_code': transactionCode ?? '',
        'notes': notes ?? '',
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory LoanRepayment.fromMap(Map<String, dynamic> m) => LoanRepayment(
        id: m['id'],
        orgId: m['org_id'],
        loanId: m['loan_id'],
        memberId: m['member_id'],
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date']),
        paymentMethod: m['payment_method'] == '' ? null : m['payment_method'],
        transactionCode: m['transaction_code'] == '' ? null : m['transaction_code'],
        notes: m['notes'] == '' ? null : m['notes'],
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'loan_id': loanId,
        'member_id': memberId,
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'payment_method': paymentMethod,
        'transaction_code': transactionCode,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  LoanRepayment copyWith({bool? synced}) => LoanRepayment(
        id: id,
        orgId: orgId,
        loanId: loanId,
        memberId: memberId,
        amount: amount,
        date: date,
        paymentMethod: paymentMethod,
        transactionCode: transactionCode,
        notes: notes,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// MERRY-GO-ROUND CYCLE
// ─────────────────────────────────────────
class MerryGoRoundCycle {
  final String id;
  final String orgId;
  final String name;
  final int totalMembers;
  final double contributionAmount;
  final String frequency; // weekly, biweekly, monthly
  final DateTime startDate;
  final DateTime endDate;
  final String status; // planning, active, completed
  final List<String> memberOrder; // Member IDs in rotation order
  final int currentPosition; // Current member index
  final String? currentRecipientId; // Member currently receiving
  final List<String> completedRecipients; // Members who have received
  final DateTime createdAt;
  final bool synced;

  MerryGoRoundCycle({
    String? id,
    required this.orgId,
    required this.name,
    required this.totalMembers,
    required this.contributionAmount,
    this.frequency = 'monthly',
    DateTime? startDate,
    DateTime? endDate,
    this.status = 'planning',
    this.memberOrder = const [],
    this.currentPosition = 0,
    this.currentRecipientId,
    this.completedRecipients = const [],
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 365)),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'name': name,
        'total_members': totalMembers,
        'contribution_amount': contributionAmount,
        'frequency': frequency,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status,
        'member_order': jsonEncode(memberOrder),
        'current_position': currentPosition,
        'current_recipient_id': currentRecipientId ?? '',
        'completed_recipients': jsonEncode(completedRecipients),
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory MerryGoRoundCycle.fromMap(Map<String, dynamic> m) => MerryGoRoundCycle(
        id: m['id'],
        orgId: m['org_id'],
        name: m['name'],
        totalMembers: m['total_members'] ?? 0,
        contributionAmount: (m['contribution_amount'] as num).toDouble(),
        frequency: m['frequency'] ?? 'monthly',
        startDate: DateTime.parse(m['start_date']),
        endDate: DateTime.parse(m['end_date']),
        status: m['status'] ?? 'planning',
        memberOrder: m['member_order'] != null && m['member_order'] != ''
            ? List<String>.from(jsonDecode(m['member_order']))
            : [],
        currentPosition: m['current_position'] ?? 0,
        currentRecipientId: m['current_recipient_id'] == '' ? null : m['current_recipient_id'],
        completedRecipients: m['completed_recipients'] != null && m['completed_recipients'] != ''
            ? List<String>.from(jsonDecode(m['completed_recipients']))
            : [],
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'name': name,
        'total_members': totalMembers,
        'contribution_amount': contributionAmount,
        'frequency': frequency,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'status': status,
        'member_order': memberOrder,
        'current_position': currentPosition,
        'current_recipient_id': currentRecipientId,
        'completed_recipients': completedRecipients,
        'created_at': createdAt.toIso8601String(),
      };

  MerryGoRoundCycle copyWith({
    String? status,
    int? currentPosition,
    String? currentRecipientId,
    List<String>? completedRecipients,
    bool? synced,
  }) =>
      MerryGoRoundCycle(
        id: id,
        orgId: orgId,
        name: name,
        totalMembers: totalMembers,
        contributionAmount: contributionAmount,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        status: status ?? this.status,
        memberOrder: memberOrder,
        currentPosition: currentPosition ?? this.currentPosition,
        currentRecipientId: currentRecipientId ?? this.currentRecipientId,
        completedRecipients: completedRecipients ?? this.completedRecipients,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );

  double get totalPool => contributionAmount * totalMembers;
  double get distributedAmount => contributionAmount * completedRecipients.length;
  double get remainingAmount => totalPool - distributedAmount;
  int get remainingRecipients => totalMembers - completedRecipients.length;
}

// ─────────────────────────────────────────
// SHARE/SAVING
// ─────────────────────────────────────────
class Share {
  final String id;
  final String orgId;
  final String memberId;
  final int numberOfShares;
  final double pricePerShare;
  final double totalValue;
  final String? paymentMethod;
  final String? transactionCode;
  final DateTime purchaseDate;
  final bool isActive;
  final DateTime createdAt;
  final bool synced;

  Share({
    String? id,
    required this.orgId,
    required this.memberId,
    required this.numberOfShares,
    this.pricePerShare = 1000,
    double? totalValue,
    this.paymentMethod,
    this.transactionCode,
    DateTime? purchaseDate,
    this.isActive = true,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        purchaseDate = purchaseDate ?? DateTime.now(),
        totalValue = totalValue ?? (numberOfShares * pricePerShare),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'number_of_shares': numberOfShares,
        'price_per_share': pricePerShare,
        'total_value': totalValue,
        'payment_method': paymentMethod ?? '',
        'transaction_code': transactionCode ?? '',
        'purchase_date': purchaseDate.toIso8601String(),
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory Share.fromMap(Map<String, dynamic> m) => Share(
        id: m['id'],
        orgId: m['org_id'],
        memberId: m['member_id'],
        numberOfShares: m['number_of_shares'] ?? 0,
        pricePerShare: (m['price_per_share'] as num).toDouble(),
        totalValue: (m['total_value'] as num).toDouble(),
        paymentMethod: m['payment_method'] == '' ? null : m['payment_method'],
        transactionCode: m['transaction_code'] == '' ? null : m['transaction_code'],
        purchaseDate: DateTime.parse(m['purchase_date']),
        isActive: (m['is_active'] ?? 1) == 1,
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'number_of_shares': numberOfShares,
        'price_per_share': pricePerShare,
        'total_value': totalValue,
        'payment_method': paymentMethod,
        'transaction_code': transactionCode,
        'purchase_date': purchaseDate.toIso8601String(),
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
      };

  Share copyWith({
    bool? isActive,
    bool? synced,
  }) =>
      Share(
        id: id,
        orgId: orgId,
        memberId: memberId,
        numberOfShares: numberOfShares,
        pricePerShare: pricePerShare,
        totalValue: totalValue,
        paymentMethod: paymentMethod,
        transactionCode: transactionCode,
        purchaseDate: purchaseDate,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// GOAL/INVESTMENT
// ─────────────────────────────────────────
class Goal {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final double targetAmount;
  final double raisedAmount;
  final DateTime targetDate;
  final String status; // planning, active, completed, cancelled
  final String category; // education, business, property, etc.
  final int contributorCount;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool synced;

  Goal({
    String? id,
    required this.orgId,
    required this.name,
    this.description = '',
    required this.targetAmount,
    this.raisedAmount = 0,
    DateTime? targetDate,
    this.status = 'planning',
    this.category = 'general',
    this.contributorCount = 0,
    DateTime? createdAt,
    this.completedAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        targetDate = targetDate ?? DateTime.now().add(const Duration(days: 365)),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'name': name,
        'description': description,
        'target_amount': targetAmount,
        'raised_amount': raisedAmount,
        'target_date': targetDate.toIso8601String(),
        'status': status,
        'category': category,
        'contributor_count': contributorCount,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String() ?? '',
        'synced': synced ? 1 : 0,
      };

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
        id: m['id'],
        orgId: m['org_id'],
        name: m['name'],
        description: m['description'] == '' ? null : m['description'],
        targetAmount: (m['target_amount'] as num).toDouble(),
        raisedAmount: (m['raised_amount'] as num).toDouble(),
        targetDate: DateTime.parse(m['target_date']),
        status: m['status'] ?? 'planning',
        category: m['category'] ?? 'general',
        contributorCount: m['contributor_count'] ?? 0,
        createdAt: DateTime.parse(m['created_at']),
        completedAt: m['completed_at'] == '' || m['completed_at'] == null
            ? null
            : DateTime.parse(m['completed_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'name': name,
        'description': description,
        'target_amount': targetAmount,
        'raised_amount': raisedAmount,
        'target_date': targetDate.toIso8601String(),
        'status': status,
        'category': category,
        'contributor_count': contributorCount,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  Goal copyWith({
    double? raisedAmount,
    String? status,
    int? contributorCount,
    DateTime? completedAt,
    bool? synced,
  }) =>
      Goal(
        id: id,
        orgId: orgId,
        name: name,
        description: description,
        targetAmount: targetAmount,
        raisedAmount: raisedAmount ?? this.raisedAmount,
        targetDate: targetDate,
        status: status ?? this.status,
        category: category,
        contributorCount: contributorCount ?? this.contributorCount,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
        synced: synced ?? this.synced,
      );

  double get progressPercent => targetAmount > 0 ? (raisedAmount / targetAmount * 100) : 0;
  double get remainingAmount => targetAmount - raisedAmount;
  bool get isOnTrack => DateTime.now().isBefore(targetDate);
}

// ─────────────────────────────────────────
// GOAL CONTRIBUTION
// ─────────────────────────────────────────
class GoalContribution {
  final String id;
  final String orgId;
  final String goalId;
  final String memberId;
  final double amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final bool synced;

  GoalContribution({
    String? id,
    required this.orgId,
    required this.goalId,
    required this.memberId,
    required this.amount,
    this.note,
    DateTime? date,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'goal_id': goalId,
        'member_id': memberId,
        'amount': amount,
        'note': note ?? '',
        'date': date.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory GoalContribution.fromMap(Map<String, dynamic> m) => GoalContribution(
        id: m['id'],
        orgId: m['org_id'],
        goalId: m['goal_id'],
        memberId: m['member_id'],
        amount: (m['amount'] as num).toDouble(),
        note: m['note'] == '' ? null : m['note'],
        date: DateTime.parse(m['date']),
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'goal_id': goalId,
        'member_id': memberId,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
      };

  GoalContribution copyWith({bool? synced}) => GoalContribution(
        id: id,
        orgId: orgId,
        goalId: goalId,
        memberId: memberId,
        amount: amount,
        note: note,
        date: date,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}

// ─────────────────────────────────────────
// WELFARE CONTRIBUTION
// ─────────────────────────────────────────
class WelfareContribution {
  final String id;
  final String orgId;
  final String memberId;
  final double amount;
  final String? beneficiaryId; // Member receiving welfare
  final String? reason;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final bool synced;

  WelfareContribution({
    String? id,
    required this.orgId,
    required this.memberId,
    required this.amount,
    this.beneficiaryId,
    this.reason,
    this.note,
    DateTime? date,
    DateTime? createdAt,
    this.synced = false,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'amount': amount,
        'beneficiary_id': beneficiaryId ?? '',
        'reason': reason ?? '',
        'note': note ?? '',
        'date': date.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };

  factory WelfareContribution.fromMap(Map<String, dynamic> m) => WelfareContribution(
        id: m['id'],
        orgId: m['org_id'],
        memberId: m['member_id'],
        amount: (m['amount'] as num).toDouble(),
        beneficiaryId: m['beneficiary_id'] == '' ? null : m['beneficiary_id'],
        reason: m['reason'] == '' ? null : m['reason'],
        note: m['note'] == '' ? null : m['note'],
        date: DateTime.parse(m['date']),
        createdAt: DateTime.parse(m['created_at']),
        synced: (m['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toSupabase() => {
        'id': id,
        'org_id': orgId,
        'member_id': memberId,
        'amount': amount,
        'beneficiary_id': beneficiaryId,
        'reason': reason,
        'note': note,
        'date': date.toIso8601String().split('T')[0],
        'created_at': createdAt.toIso8601String(),
      };

  WelfareContribution copyWith({bool? synced}) => WelfareContribution(
        id: id,
        orgId: orgId,
        memberId: memberId,
        amount: amount,
        beneficiaryId: beneficiaryId,
        reason: reason,
        note: note,
        date: date,
        createdAt: createdAt,
        synced: synced ?? this.synced,
      );
}
