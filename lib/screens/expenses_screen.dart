import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

const List<String> kExpenseTypes = [
  'Transport',
  'Food & Refreshments',
  'Venue / Rent',
  'Stationery',
  'Loan Payout',
  'Investment',
  'Utilities',
  'Emergency Fund',
  'Other',
];

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;
  String? _filterType;
  bool _showForm = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _customTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            surface: AppTheme.bg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;
    final type = _customTypeCtrl.text.trim().isNotEmpty
        ? _customTypeCtrl.text.trim()
        : _selectedType;
    if (type == null || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select or enter an expense type'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final expense = Expense(
      orgId: context.read<AppState>().currentOrg!.id,
      type: type,
      amount: double.parse(_amountCtrl.text),
      date: _selectedDate,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    await context.read<AppState>().addExpense(expense);
    _amountCtrl.clear();
    _descCtrl.clear();
    _customTypeCtrl.clear();
    setState(() {
      _saving = false;
      _selectedDate = DateTime.now();
      _selectedType = null;
      _showForm = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Expense recorded successfully'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext ctx, Expense e, AppState state) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: AppTheme.danger),
            ),
            const SizedBox(width: 12),
            Text('Delete Expense', style: AppTheme.headline),
          ],
        ),
        content: Text(
          'Delete ${e.type} — ${formatKes(e.amount)}?',
          style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: Text('Cancel',
                style: AppTheme.body.copyWith(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            style: TextButton.styleFrom(
              backgroundColor: AppTheme.danger,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await state.deleteExpense(e.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleted'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allTypes = {...kExpenseTypes, ...state.expenses.map((e) => e.type)}
        .toList()
      ..sort();
    final filtered = _filterType == null
        ? state.expenses
        : state.expenses.where((e) => e.type == _filterType).toList();
    final total = filtered.fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.danger,
                      AppTheme.danger.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Expenses',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.receipt_long,
                            color: Colors.white70, size: 20),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatKes(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${filtered.length} transactions',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppTheme.danger),
                onPressed: () => setState(() => _showForm = true),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildContent(state, filtered, allTypes),
          ),
        ],
      ),
      floatingActionButton: _showForm
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _showForm = true),
              backgroundColor: AppTheme.danger,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
    );
  }

  Widget _buildContent(
      AppState state, List<Expense> filtered, List<String> allTypes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showForm) _buildExpenseForm(state),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              const Icon(Icons.filter_list, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String?>(
                  value: _filterType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All types')),
                    ...allTypes.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        )),
                  ],
                  onChanged: (v) => setState(() => _filterType = v),
                ),
              ),
            ],
          ),
        ),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppTheme.textLight),
                  SizedBox(height: 16),
                  Text('No expenses yet',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _expenseCard(context, filtered[index], state),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildExpenseForm(AppState state) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New Expense', style: AppTheme.headline),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _showForm = false),
                  color: AppTheme.textLight,
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppDropdown<String>(
              label: 'Expense Type',
              value: _selectedType,
              items: kExpenseTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Custom Type (optional)',
              hint: 'Enter custom expense type…',
              controller: _customTypeCtrl,
              prefixIcon: Icons.edit_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Amount (KES)',
              hint: 'e.g. 2500',
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.attach_money,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'DATE',
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.primary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        formatDate(_selectedDate),
                        style: AppTheme.body.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Description',
              hint: 'What was this expense for?',
              controller: _descCtrl,
              maxLines: 3,
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _addExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text('Record Expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseCard(BuildContext ctx, Expense e, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: AppTheme.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDate(e.date)}${e.description != null ? ' · ${e.description}' : ''}',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatKes(e.amount),
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _delete(ctx, e, state),
                child: const Icon(Icons.delete_outline,
                    color: AppTheme.textLight, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
