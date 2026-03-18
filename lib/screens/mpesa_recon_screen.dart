import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MpesaReconScreen extends StatefulWidget {
  const MpesaReconScreen({super.key});

  @override
  State<MpesaReconScreen> createState() => _MpesaReconScreenState();
}

class _MpesaReconScreenState extends State<MpesaReconScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadTransactions);
  }

  Future<void> _loadTransactions() async {
    final state = context.read<AppState>();
    final orgId = state.currentOrg?.id;
    if (orgId == null) return;

    if (!state.isAuthenticated || !state.isOnline) {
      setState(() {
        _transactions = const [];
        _error = 'Connect to the internet and sign in to reconcile M-Pesa.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rows = await Supabase.instance.client
          .from('mpesa_transactions')
          .select()
          .eq('org_id', orgId)
          .order('created_at', ascending: false)
          .limit(200);

      setState(() {
        _transactions =
            (rows as List).cast<Map<String, dynamic>>().toList(growable: false);
      });
    } catch (e) {
      setState(() => _error = 'Failed to load transactions: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isMatchedByContribution(AppState state, Map<String, dynamic> tx) {
    final receipt = (tx['mpesa_receipt_number'] as String?)?.trim();
    if (receipt == null || receipt.isEmpty) return false;
    return state.contributions.any((c) =>
        (c.transactionCode ?? '').trim().toUpperCase() ==
        receipt.toUpperCase());
  }

  Future<void> _manualMatch(AppState state, Map<String, dynamic> tx) async {
    final orgId = state.currentOrg?.id;
    if (orgId == null) return;
    if (!state.hasPermission(UserRole.treasurer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission denied: Treasurer/Admin only'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    final receipt = (tx['mpesa_receipt_number'] as String?)?.trim();
    final phone = (tx['phone'] as String?)?.trim();
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final createdAtStr = tx['transaction_date'] ?? tx['created_at'];
    final date = createdAtStr != null
        ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now()
        : DateTime.now();

    String? selectedMemberId;
    final noteCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Match Payment', style: AppTheme.headline),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt: ${receipt ?? '-'}\nPhone: ${phone ?? '-'}\nAmount: ${formatKes(amount)}',
              style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedMemberId,
              dropdownColor: AppTheme.bg,
              decoration: const InputDecoration(labelText: 'Member'),
              items: state.members
                  .cast<OrgMember>()
                  .map(
                      (m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                  .toList(),
              onChanged: (v) => selectedMemberId = v,
              validator: (v) => v == null ? 'Select a member' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                hintText: 'e.g. April contribution via M-Pesa',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Match'),
          ),
        ],
      ),
    );

    if (ok != true || selectedMemberId == null) {
      noteCtrl.dispose();
      return;
    }

    // Create contribution locally (and sync if online)
    final contrib = Contribution(
      orgId: orgId,
      userId: selectedMemberId!,
      amount: amount,
      date: date,
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      paymentMethod: 'mpesa',
      transactionCode: receipt,
    );
    noteCtrl.dispose();

    await state.addContribution(contrib);

    // Mark tx as matched and link member_id in Supabase
    try {
      await Supabase.instance.client
          .from('mpesa_transactions')
          .update({'member_id': selectedMemberId, 'status': 'matched'}).eq(
              'id', tx['id']);
    } catch (_) {}

    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('M-Pesa Recon')),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(
            child: _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: AppTheme.body.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) => _buildTransactionTile(
                      state,
                      _transactions[index],
                    ),
                  ),
          ),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final state = context.watch<AppState>();
    final matched =
        _transactions.where((t) => _isMatchedByContribution(state, t)).length;
    final unmatched = _transactions.length - matched;
    final total = _transactions.fold<double>(
        0.0, (s, t) => s + ((t['amount'] as num?)?.toDouble() ?? 0.0));

    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.primary.withValues(alpha: 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Unmatched', unmatched.toString(), AppTheme.warning),
          _summaryItem('Matched', matched.toString(), AppTheme.success),
          _summaryItem('Total', formatKes(total), AppTheme.primary),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: AppTheme.caption),
      ],
    );
  }

  Widget _buildTransactionTile(AppState state, Map<String, dynamic> tx) {
    final bool isMatched = _isMatchedByContribution(state, tx) ||
        (tx['status']?.toString().toLowerCase() == 'matched');
    final code = (tx['mpesa_receipt_number'] as String?)?.trim() ??
        (tx['checkout_request_id'] as String?)?.trim() ??
        '-';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final createdAtStr = tx['transaction_date'] ?? tx['created_at'];
    final d = createdAtStr != null
        ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now()
        : DateTime.now();

    final memberId = tx['member_id'] as String?;
    String? memberName;
    if (memberId != null) {
      try {
        memberName = state.members
            .cast<OrgMember>()
            .firstWhere((m) => m.id == memberId)
            .name;
      } catch (_) {
        memberName = null;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isMatched ? AppTheme.success : AppTheme.warning)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isMatched ? Icons.check_circle_outline : Icons.help_outline,
              color: isMatched ? AppTheme.success : AppTheme.warning,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName ?? 'Unassigned',
                  style: AppTheme.body.copyWith(fontWeight: FontWeight.bold),
                ),
                Text('Code: $code', style: AppTheme.caption),
                Text(DateFormat('dd MMM, HH:mm').format(d),
                    style: AppTheme.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatKes(amount),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              if (!isMatched)
                TextButton(
                  onPressed: () => _manualMatch(state, tx),
                  child: const Text('Match Manually',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _loadTransactions,
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.sync),
          label: Text(_isLoading ? 'LOADING...' : 'REFRESH'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}
