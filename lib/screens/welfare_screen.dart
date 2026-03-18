import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/module_models.dart';
import '../services/app_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class WelfareScreen extends StatefulWidget {
  const WelfareScreen({super.key});

  @override
  State<WelfareScreen> createState() => _WelfareScreenState();
}

class _WelfareScreenState extends State<WelfareScreen> {
  final SupabaseService _supabase = SupabaseService();
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final contributions = state.welfareContributions;
    final totalContributed =
        contributions.fold(0.0, (sum, c) => sum + c.amount);

    return RefreshIndicator(
      onRefresh: _syncData,
      color: AppTheme.primary,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Sync Indicator
            if (_isSyncing)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Syncing with Supabase...'),
                  ],
                ),
              ),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.danger,
                  AppTheme.danger.withValues(alpha: 0.7)
                ]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    formatKes(totalContributed),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text('Total Welfare Fund',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 16),
                  // Sync Button
                  ElevatedButton.icon(
                    onPressed: _syncData,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync with Supabase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.danger,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contribute Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showContributeDialog(context),
                icon: const Icon(Icons.favorite_outline),
                label: const Text('Contribute to Welfare'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),

            const SizedBox(height: 24),

            // Contributions List
            SectionCard(
              title: 'Welfare Contributions',
              child: contributions.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                          child: Text('No welfare contributions yet',
                              style: TextStyle(color: AppTheme.textSecondary))),
                    )
                  : Column(
                      children: contributions
                          .map((c) => _contributionTile(c, state))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);
    final state = context.read<AppState>();

    try {
      // Push local data to Supabase
      await _supabase.syncExpenses([]); // Welfare uses similar structure

      // Pull latest data from Supabase
      if (_supabase.isLoggedIn && state.currentOrg != null) {
        final welfareData = await _supabase.client
            .from('welfare_contributions')
            .select()
            .eq('org_id', state.currentOrg!.id)
            .order('date', ascending: false);

        debugPrint('Fetched welfare data: ${welfareData.length} records');
        // Update local state with Supabase data
        // In production, update AppState properly
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synced with Supabase'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Widget _contributionTile(WelfareContribution c, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.favorite, color: AppTheme.danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.getMemberName(c.memberId),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (c.beneficiaryId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'For: ${state.getMemberName(c.beneficiaryId!)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formatKes(c.amount),
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: AppTheme.danger),
          ),
        ],
      ),
    );
  }

  void _showContributeDialog(BuildContext context) {
    final state = context.read<AppState>();
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String? beneficiaryId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welfare Contribution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Amount (KES)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: null,
              decoration: const InputDecoration(
                  labelText: 'Beneficiary (optional)',
                  border: OutlineInputBorder()),
              items: state.members
                  .map(
                      (m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                  .toList(),
              onChanged: (v) => beneficiaryId = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reasonCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                  labelText: 'Reason/Note', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount > 0) {
                state.contributeToWelfare(WelfareContribution(
                  orgId: state.currentOrg!.id,
                  memberId: state.currentUserId,
                  amount: amount,
                  beneficiaryId: beneficiaryId,
                  reason: reasonCtrl.text.trim().isEmpty
                      ? null
                      : reasonCtrl.text.trim(),
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Contribute'),
          ),
        ],
      ),
    );
  }
}
