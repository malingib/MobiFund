import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/app_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class PlatformOrgDetailScreen extends StatelessWidget {
  final Map<String, dynamic> row;

  const PlatformOrgDetailScreen({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final supabase = SupabaseService();
    final orgName = (row['org_name'] ?? 'Organization').toString();
    final tier = (row['tier'] ?? 'free').toString();
    final orgId = (row['org_id'] ?? '').toString();

    final memberCount = (row['member_count'] ?? 0).toString();
    final totalContrib = (row['total_contributions'] ?? 0).toString();
    final totalExpense = (row['total_expenses'] ?? 0).toString();
    final loanCount = (row['loan_count'] ?? 0).toString();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: Text(
          orgName,
          style: AppTheme.headline.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tier: ${tier.toUpperCase()}',
              style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            _kpiGrid(
              memberCount: memberCount,
              totalContrib: totalContrib,
              totalExpense: totalExpense,
              loanCount: loanCount,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Support Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Start a time-bound support session to access this org as admin-equivalent. All writes will be audited.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: orgId.isEmpty
                          ? null
                          : () async {
                              final state = context.read<AppState>();
                              try {
                                final res = await supabase.startSupportSession(
                                  orgId: orgId,
                                  reason: 'Support investigation',
                                  ttlMinutes: 30,
                                );
                                if (res['success'] != true) {
                                  throw Exception(
                                      res['error']?.toString() ?? 'Failed');
                                }
                                final session = (res['session'] as Map)
                                    .cast<String, dynamic>();
                                final org = Organization.fromMap(
                                  (res['organization'] as Map)
                                      .cast<String, dynamic>(),
                                );
                                final expiresAt =
                                    DateTime.parse(session['expires_at'].toString());
                                await state.enterSupportMode(
                                  sessionId: session['id'].toString(),
                                  expiresAt: expiresAt,
                                  organization: org,
                                );
                                if (!context.mounted) return;
                                Navigator.of(context)
                                    .pushNamedAndRemoveUntil('/home', (r) => false);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: AppTheme.danger,
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Start Support Session (30 min)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warning,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiGrid({
    required String memberCount,
    required String totalContrib,
    required String totalExpense,
    required String loanCount,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _kpiCard('Members', memberCount, Icons.people, AppTheme.primary),
        _kpiCard('Loans', loanCount, Icons.handshake_outlined, AppTheme.accent),
        _kpiCard('Contributions', totalContrib, Icons.trending_up, AppTheme.success),
        _kpiCard('Expenses', totalExpense, Icons.trending_down, AppTheme.danger),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

