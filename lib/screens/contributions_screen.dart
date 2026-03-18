import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _txCodeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedMemberId;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;
  String? _filterMemberId;
  bool _showForm = false;
  String _paymentMethod = 'cash';

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _txCodeCtrl.dispose();
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

  Future<void> _addContribution() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select a member'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final state = context.read<AppState>();
    final contrib = Contribution(
      orgId: state.currentOrg!.id,
      userId: _selectedMemberId!,
      amount: double.parse(_amountCtrl.text),
      date: _selectedDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      transactionCode: _txCodeCtrl.text.trim().isEmpty
          ? null
          : _txCodeCtrl.text.trim().toUpperCase(),
    );
    await state.addContribution(contrib);
    _amountCtrl.clear();
    _noteCtrl.clear();
    _txCodeCtrl.clear();
    setState(() {
      _saving = false;
      _selectedDate = DateTime.now();
      _showForm = false;
      _paymentMethod = 'cash';
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contribution recorded successfully'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _delete(BuildContext ctx, Contribution c, AppState state) async {
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
            Text('Delete', style: AppTheme.headline),
          ],
        ),
        content: Text(
          'Delete this contribution of ${formatKes(c.amount)}?',
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
      await state.deleteContribution(c.id);
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
    final filtered = _filterMemberId == null
        ? state.contributions
        : state.contributions
            .where((c) => c.userId == _filterMemberId)
            .toList();
    final total = filtered.fold(0.0, (s, c) => s + c.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.success,
                  AppTheme.success.withValues(alpha: 0.7)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Contributions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(Icons.trending_up, color: Colors.white70, size: 20),
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

          const SizedBox(height: 20),

          // Add contribution button or form
          if (!_showForm)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: state.members.isEmpty
                    ? null
                    : () => setState(() => _showForm = true),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppTheme.border, strokeAlign: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: AppTheme.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Record Contribution',
                              style: AppTheme.headline,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add a new contribution',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textLight,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Contribution', style: AppTheme.headline),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showForm = false),
                          color: AppTheme.textLight,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppDropdown<String>(
                      label: 'Member',
                      value: _selectedMemberId,
                      items: (() {
                        final items = <DropdownMenuItem<String>>[];
                        for (final m in state.members) {
                          items.add(DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(m.name),
                          ));
                        }
                        return items;
                      })(),
                      onChanged: (v) => setState(() => _selectedMemberId = v),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Amount (KES)',
                      hint: 'e.g. 5000',
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter amount';
                        if (double.tryParse(v) == null ||
                            double.parse(v) <= 0) {
                          return 'Enter valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AppDropdown<String>(
                      label: 'Payment Method',
                      value: _paymentMethod,
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
                        DropdownMenuItem(value: 'bank', child: Text('Bank')),
                      ],
                      onChanged: (v) => setState(() {
                        _paymentMethod = v ?? 'cash';
                      }),
                      prefixIcon: Icons.payments_outlined,
                    ),
                    if (_paymentMethod != 'cash') ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: _paymentMethod == 'mpesa'
                            ? 'M-Pesa Receipt Code (optional)'
                            : 'Bank Reference (optional)',
                        hint: _paymentMethod == 'mpesa'
                            ? 'e.g. QWE123ABC'
                            : 'e.g. FTN-883920',
                        controller: _txCodeCtrl,
                        prefixIcon: _paymentMethod == 'mpesa'
                            ? Icons.phone_android_outlined
                            : Icons.account_balance_outlined,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
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
                          label: 'Note (optional)',
                          hint: 'e.g. Monthly — April',
                          controller: _noteCtrl,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _addContribution,
                            style: ElevatedButton.styleFrom(
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
                                : const Text('Record Contribution'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Filter + list
          SectionCard(
            title: 'History',
            trailing: state.members.isNotEmpty
                ? DropdownButton<String?>(
                    value: _filterMemberId,
                    dropdownColor: AppTheme.bg,
                    underline: const SizedBox(),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All members')),
                      ...(() {
                        final itemList = <DropdownMenuItem<String>>[];
                        for (final m in state.members) {
                          itemList.add(DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(m.name),
                          ));
                        }
                        return itemList;
                      })(),
                    ],
                    onChanged: (v) => setState(() => _filterMemberId = v),
                  )
                : null,
            child: Column(
              children: [
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No contributions',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  )
                else
                  ...filtered.map((c) => _contribTile(context, c, state)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contribTile(BuildContext ctx, Contribution c, AppState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          MemberAvatar(
            initials:
                state.getMemberName(c.userId).substring(0, 1).toUpperCase(),
            size: 40,
            color: AppTheme.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.getMemberName(c.userId),
                  style: AppTheme.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${formatDate(c.date)}'
                  '${c.paymentMethod != null ? ' · ${c.paymentMethod}' : ''}'
                  '${c.transactionCode != null ? ' · ${c.transactionCode}' : ''}'
                  '${c.note != null ? ' · ${c.note}' : ''}',
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
                formatKes(c.amount),
                style: const TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                onTap: () => _delete(ctx, c, state),
                child: const Icon(Icons.close,
                    color: AppTheme.textLight, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
