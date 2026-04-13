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

class _ContributionsScreenState extends State<ContributionsScreen>
    with SingleTickerProviderStateMixin {
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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _txCodeCtrl.dispose();
    _tabController.dispose();
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

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.success,
                      AppTheme.success.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Contributions',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
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
                icon: const Icon(Icons.add_circle, color: AppTheme.success),
                onPressed: state.members.isEmpty
                    ? null
                    : () => setState(() => _showForm = true),
              ),
            ],
          ),

          // Tab Bar
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'All Contributions'),
                  Tab(text: 'Members'),
                ],
                labelColor: AppTheme.success,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorColor: AppTheme.success,
                indicatorWeight: 3,
              ),
            ),
            pinned: true,
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContributionsList(state, filtered),
                _buildMembersList(state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _showForm
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                if (state.members.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                          'Please add members first before recording contributions'),
                      backgroundColor: AppTheme.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      action: SnackBarAction(
                        label: 'Add Members',
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to members tab
                          _tabController.animateTo(1);
                        },
                      ),
                    ),
                  );
                } else {
                  setState(() => _showForm = true);
                }
              },
              backgroundColor: AppTheme.success,
              icon: const Icon(Icons.add),
              label: const Text('Add Contribution'),
            ),
    );
  }

  Widget _buildContributionsList(AppState state, List<Contribution> filtered) {
    return Column(
      children: [
        if (_showForm) _buildContributionForm(state),
        if (state.members.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.filter_list, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String?>(
                    value: _filterMemberId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('All members')),
                      ...state.members.map((m) => DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(m.name),
                          )),
                    ],
                    onChanged: (v) => setState(() => _filterMemberId = v),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 64, color: AppTheme.textLight),
                      const SizedBox(height: 16),
                      Text(
                        'No contributions yet',
                        style: AppTheme.body.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _contribCard(context, filtered[index], state),
                ),
        ),
      ],
    );
  }

  Widget _buildMembersList(AppState state) {
    if (state.members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline,
                size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: AppTheme.body.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = state.members[index];
        final memberContributions =
            state.contributions.where((c) => c.userId == member.id).toList();
        final totalContributed =
            memberContributions.fold(0.0, (sum, c) => sum + c.amount);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navigate to member detail screen (to be created)
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  MemberAvatar(
                    initials: member.name.substring(0, 1).toUpperCase(),
                    size: 48,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${memberContributions.length} contributions',
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
                        formatKes(totalContributed),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContributionForm(AppState state) {
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
              items: state.members
                  .map((m) => DropdownMenuItem<String>(
                        value: m.id,
                        child: Text(m.name),
                      ))
                  .toList(),
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
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
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
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (v) => setState(() {
                _paymentMethod = v ?? 'cash';
              }),
              prefixIcon: Icons.payments_outlined,
            ),
            if (_paymentMethod == 'mpesa') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'M-Pesa Receipt Code (optional)',
                hint: 'e.g. QWE123ABC',
                controller: _txCodeCtrl,
                prefixIcon: Icons.phone_android_outlined,
              ),
            ] else if (_paymentMethod == 'bank') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bank Reference (optional)',
                hint: 'e.g. FTN-883920',
                controller: _txCodeCtrl,
                prefixIcon: Icons.account_balance_outlined,
              ),
            ] else if (_paymentMethod == 'other') ...[
              const SizedBox(height: 16),
              AppTextField(
                label: 'Transaction Reference (optional)',
                hint: 'e.g. REF-123456',
                controller: _txCodeCtrl,
                prefixIcon: Icons.receipt_long_outlined,
              ),
            ],
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
      ),
    );
  }

  Widget _contribCard(BuildContext ctx, Contribution c, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          MemberAvatar(
            initials:
                state.getMemberName(c.userId).substring(0, 1).toUpperCase(),
            size: 44,
            color: AppTheme.success,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.getMemberName(c.userId),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
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
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _delete(ctx, c, state),
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.bg,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
