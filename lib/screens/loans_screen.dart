import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/module_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canApply = state.hasPermission(UserRole.member);
    final canApprove = state.hasPermission(UserRole.treasurer);

    // Filter loans
    var loans = state.loans;
    if (_filterStatus != 'all') {
      loans = loans
          .where((l) => l.status.name.toLowerCase() == _filterStatus)
          .toList();
    }

    // Calculate totals
    final totalDisbursed = state.loans
        .where((l) =>
            l.status == LoanStatus.disbursed || l.status == LoanStatus.active)
        .fold(0.0, (sum, l) => sum + l.principal);
    final totalRepaid = state.loans.fold(0.0, (sum, l) => sum + l.paidAmount);
    final totalOutstanding = totalDisbursed - totalRepaid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                child: _statCard(
                  'Disbursed',
                  formatKes(totalDisbursed),
                  Icons.monetization_on,
                  AppTheme.success,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                child: _statCard(
                  'Outstanding',
                  formatKes(totalOutstanding),
                  Icons.trending_up,
                  AppTheme.warning,
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 3,
                child: _statCard(
                  'Repaid',
                  formatKes(totalRepaid),
                  Icons.check_circle,
                  AppTheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply for Loan Button
          if (canApply)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showApplyLoanDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Apply for Loan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All', loans.length),
                const SizedBox(width: 8),
                _filterChip(
                    'Pending',
                    state.loans
                        .where((l) => l.status == LoanStatus.pending)
                        .length),
                const SizedBox(width: 8),
                _filterChip(
                    'Active',
                    state.loans
                        .where((l) => l.status == LoanStatus.active)
                        .length),
                const SizedBox(width: 8),
                _filterChip(
                    'Completed',
                    state.loans
                        .where((l) => l.status == LoanStatus.completed)
                        .length),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Loans List
          SectionCard(
            title: 'Loans',
            child: loans.isEmpty
                ? _emptyState()
                : Column(
                    children: loans
                        .map((loan) =>
                            _loanTile(context, loan, canApprove, state))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    final isSelected = _filterStatus == label.toLowerCase();
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (v) {
        setState(() => _filterStatus = label.toLowerCase());
      },
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primary,
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.monetization_on_outlined,
                size: 48, color: AppTheme.textLight),
            SizedBox(height: 12),
            Text(
              'No loans yet',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanTile(
      BuildContext context, Loan loan, bool canApprove, AppState state) {
    final isOverdue = loan.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? AppTheme.danger : AppTheme.border,
          width: isOverdue ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _getLoanTypeColor(loan.loanType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  loan.loanType == LoanType.softLoan
                      ? Icons.account_balance_wallet
                      : Icons.monetization_on,
                  color: _getLoanTypeColor(loan.loanType),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.getMemberName(loan.memberId),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${loan.loanType.name} • Due ${_formatDate(loan.dueDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(loan.status),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: loan.progressPercent / 100,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverdue ? AppTheme.danger : AppTheme.success,
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Principal',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  Text(
                    formatKes(loan.principal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Balance',
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  Text(
                    formatKes(loan.balance),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isOverdue ? AppTheme.danger : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions
          if (canApprove && loan.status == LoanStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectLoan(context, loan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _approveLoan(context, loan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],

          // Repay button for active loans
          if (loan.status == LoanStatus.active) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _repayLoanDialog(context, loan),
                icon: const Icon(Icons.payment),
                label: const Text('Make Repayment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(LoanStatus status) {
    Color color;
    switch (status) {
      case LoanStatus.pending:
        color = AppTheme.warning;
        break;
      case LoanStatus.approved:
      case LoanStatus.disbursed:
        color = AppTheme.primary;
        break;
      case LoanStatus.active:
        color = AppTheme.success;
        break;
      case LoanStatus.completed:
        color = AppTheme.success;
        break;
      default:
        color = AppTheme.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getLoanTypeColor(LoanType type) {
    switch (type) {
      case LoanType.softLoan:
        return AppTheme.primary;
      case LoanType.normalLoan:
        return AppTheme.success;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showApplyLoanDialog(BuildContext context) {
    final state = context.read<AppState>();
    final amountCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    var loanType = LoanType.softLoan;
    int repaymentMonths = 1;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.bg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Apply for Loan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Loan Type
                  DropdownButtonFormField<LoanType>(
                    initialValue: loanType,
                    decoration: const InputDecoration(
                      labelText: 'Loan Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: LoanType.softLoan,
                          child: Text('Soft Loan (0% interest, 1 month)')),
                      DropdownMenuItem(
                          value: LoanType.normalLoan,
                          child: Text('Normal Loan (Custom terms)')),
                    ],
                    onChanged: (v) {
                      setDialogState(() => loanType = v!);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Amount
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (KES)',
                      hintText: 'e.g. 5000',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount required';
                      if (double.tryParse(v) == null) return 'Invalid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Repayment Period (only for normal loans)
                  if (loanType == LoanType.normalLoan) ...[
                    TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Repayment Period (Months)',
                        hintText: 'e.g. 3',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        repaymentMonths = int.tryParse(v) ?? 1;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Purpose
                  TextFormField(
                    controller: purposeCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Purpose (optional)',
                      hintText: 'What is this loan for?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final principal = double.parse(amountCtrl.text);
                  final loan = Loan(
                    orgId: state.currentOrg!.id,
                    memberId: state.currentUserId,
                    loanType: loanType,
                    principal: principal,
                    repaymentPeriodMonths:
                        loanType == LoanType.softLoan ? 1 : repaymentMonths,
                    purpose: purposeCtrl.text.trim().isEmpty
                        ? null
                        : purposeCtrl.text.trim(),
                  );
                  state.applyForLoan(loan);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loan application submitted'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }

  void _approveLoan(BuildContext context, Loan loan) {
    final state = context.read<AppState>();
    state.approveLoan(loan.id);
    state.disburseLoan(loan.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loan approved and disbursed'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  void _rejectLoan(BuildContext context, Loan loan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Loan'),
        content: const Text(
            'Are you sure you want to reject this loan application?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In production: update status to rejected
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loan rejected'),
                  backgroundColor: AppTheme.danger,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _repayLoanDialog(BuildContext context, Loan loan) {
    final state = context.read<AppState>();
    final amountCtrl =
        TextEditingController(text: loan.monthlyInstallment.toStringAsFixed(2));
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Make Repayment'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Outstanding Balance: ${formatKes(loan.balance)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Repayment Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Amount required';
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) return 'Invalid amount';
                  if (amount > loan.balance) return 'Amount exceeds balance';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: 'mpesa',
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
                ],
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Transaction Code (optional)',
                  hintText: 'e.g. QFH123456',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final repayment = LoanRepayment(
                  orgId: state.currentOrg!.id,
                  loanId: loan.id,
                  memberId: state.currentUserId,
                  amount: double.parse(amountCtrl.text),
                  paymentMethod: 'mpesa',
                );
                state.repayLoan(repayment);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Repayment recorded successfully'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Record Repayment'),
          ),
        ],
      ),
    );
  }
}
