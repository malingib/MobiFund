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

    var loans = state.loans;
    if (_filterStatus != 'all') {
      loans = loans
          .where((l) => l.status.name.toLowerCase() == _filterStatus)
          .toList();
    }

    final totalDisbursed = state.loans
        .where((l) =>
            l.status == LoanStatus.disbursed || l.status == LoanStatus.active)
        .fold(0.0, (sum, l) => sum + l.principal);
    final totalRepaid = state.loans.fold(0.0, (sum, l) => sum + l.paidAmount);
    final totalOutstanding = totalDisbursed - totalRepaid;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Loan Portfolio',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatKes(totalDisbursed),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.loans.length} total loans',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _compactStatCard(
                            'Disbursed',
                            formatKes(totalDisbursed),
                            Icons.monetization_on,
                            AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _compactStatCard(
                            'Outstanding',
                            formatKes(totalOutstanding),
                            Icons.trending_up,
                            AppTheme.warning,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _compactStatCard(
                            'Repaid',
                            formatKes(totalRepaid),
                            Icons.check_circle,
                            AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (canApply)
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppTheme.primaryLight),
                  onPressed: () => _showApplyLoanDialog(context),
                ),
            ],
          ),
          SliverPersistentHeader(
            delegate: _FilterBarDelegate(
              filterStatus: _filterStatus,
              state: state,
              onFilterChanged: (status) {
                setState(() => _filterStatus = status);
              },
            ),
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: loans.isEmpty
                ? SliverFillRemaining(
                    child: _emptyState(),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final loan = loans[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < loans.length - 1 ? 12 : 0,
                          ),
                          child: _loanTile(context, loan, canApprove, state),
                        );
                      },
                      childCount: loans.length,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: canApply
          ? FloatingActionButton.extended(
              onPressed: () => _showApplyLoanDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Apply for Loan'),
            )
          : null,
    );
  }

  Widget _compactStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on_outlined,
              size: 64, color: AppTheme.textLight),
          SizedBox(height: 16),
          Text(
            'No loans yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _loanTile(
      BuildContext context, Loan loan, bool canApprove, AppState state) {
    final isOverdue = loan.isOverdue;

    return Container(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${loan.loanType.name} · Due ${_formatDate(loan.dueDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _statusBadge(loan.status),
            ],
          ),
          const SizedBox(height: 14),
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
              _miniStat(
                  'Principal', formatKes(loan.principal), AppTheme.textPrimary),
              _miniStat(
                'Balance',
                formatKes(loan.balance),
                isOverdue ? AppTheme.danger : AppTheme.textPrimary,
              ),
            ],
          ),
          if (canApprove && loan.status == LoanStatus.pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectLoan(context, loan),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
          if (loan.status == LoanStatus.active) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _repayLoanDialog(context, loan),
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('Make Repayment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
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

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final String filterStatus;
  final AppState state;
  final void Function(String) onFilterChanged;

  _FilterBarDelegate({
    required this.filterStatus,
    required this.state,
    required this.onFilterChanged,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', state.loans.length),
            const SizedBox(width: 8),
            _filterChip(
                'Pending',
                state.loans
                    .where((l) => l.status == LoanStatus.pending)
                    .length),
            const SizedBox(width: 8),
            _filterChip('Active',
                state.loans.where((l) => l.status == LoanStatus.active).length),
            const SizedBox(width: 8),
            _filterChip(
                'Completed',
                state.loans
                    .where((l) => l.status == LoanStatus.completed)
                    .length),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count) {
    final isSelected = filterStatus == label.toLowerCase();
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(label.toLowerCase()),
      selectedColor: AppTheme.primary.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primary,
    );
  }

  @override
  double get maxExtent => 52;

  @override
  double get minExtent => 52;

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) {
    return oldDelegate.filterStatus != filterStatus ||
        oldDelegate.state.loans.length != state.loans.length;
  }
}
