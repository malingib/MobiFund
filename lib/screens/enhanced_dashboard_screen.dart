import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/notification_service.dart';
import 'report_center_screen.dart';
import 'mpesa_recon_screen.dart';

class EnhancedDashboardScreen extends StatelessWidget {
  const EnhancedDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading) {
      return const DashboardSkeleton();
    }

    final totalC = state.summary['totalContributions'] as double;
    final totalE = state.summary['totalExpenses'] as double;
    final balance = totalC - totalE;

    // Get analytics data from AppState
    final contributionGrowth = state.calculateGrowth();
    final expenseBreakdown = state.getExpenseBreakdown();
    final topContributors = state.getTopContributors();
    final recentActivity = state.getRecentActivity();

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.bg,
      onRefresh: () => state.syncNow(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _balanceCard(balance, totalC, totalE),

            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(child: _quickStat('Members', '${state.members.length}', Icons.people, AppTheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: _quickStat('Active', '${state.contributions.length}', Icons.trending_up, AppTheme.success)),
                const SizedBox(width: 12),
                Expanded(child: _quickStat('Growth', '+${contributionGrowth.toStringAsFixed(0)}%', Icons.arrow_upward, AppTheme.accent)),
              ],
            ),

            const SizedBox(height: 24),

            // Analytics Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics',
                  style: AppTheme.headline.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReportCenterScreen()),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: const Text('Reports'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        if (state.isFeatureAllowed('mpesa_recon')) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MpesaReconScreen()),
                          );
                        } else {
                          NotificationService().showInfo(context, 'M-Pesa Recon is a Pro feature');
                        }
                      },
                      icon: const Icon(Icons.sync, size: 18),
                      label: Text(
                        'M-Pesa Recon',
                        style: TextStyle(
                          color: state.isFeatureAllowed('mpesa_recon') ? AppTheme.success : AppTheme.textLight,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Income vs Expense Chart
            _analyticsCard(
              'Income vs Expenses',
              _incomeExpenseChart(totalC, totalE),
            ),

            const SizedBox(height: 16),

            // Expense Breakdown
            _analyticsCard(
              'Expense Breakdown',
              _expenseBreakdownChart(expenseBreakdown),
            ),

            const SizedBox(height: 16),

            // Top Contributors
            _analyticsCard(
              'Top Contributors',
              _topContributorsList(topContributors),
            ),

            const SizedBox(height: 16),

            // Recent Activity
            _analyticsCard(
              'Recent Activity',
              recentActivity.isEmpty
                  ? _emptyState('No recent activity')
                  : Column(children: recentActivity.map((a) => _recentActivityItem(a)).toList()),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(double balance, double totalC, double totalE) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            formatKes(balance),
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contributions', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(formatKes(totalC), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expenses', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(formatKes(totalE), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _analyticsCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _incomeExpenseChart(double income, double expense) {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: income > expense ? income * 1.2 : expense * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Income', 'Expenses'];
                  final index = value.toInt();
                  if (index < 0 || index >= titles.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(titles[index], style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  gradient: LinearGradient(colors: [AppTheme.success, AppTheme.success.withValues(alpha: 0.7)]),
                  width: 40,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expense,
                  gradient: LinearGradient(colors: [AppTheme.danger, AppTheme.danger.withValues(alpha: 0.7)]),
                  width: 40,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseBreakdownChart(Map<String, double> breakdown) {
    if (breakdown.isEmpty) {
      return const Center(child: Text('No expense data', style: TextStyle(color: AppTheme.textSecondary)));
    }

    final total = breakdown.values.fold(0.0, (sum, val) => sum + val);
    final entries = breakdown.entries.toList();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sections: entries.map((e) {
                final percentage = (e.value / total * 100).clamp(0, 100);
                return PieChartSectionData(
                  value: e.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  color: _getExpenseColor(e.key),
                  radius: 60,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: _getExpenseColor(e.key), shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(e.key, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _topContributorsList(List<Map<String, dynamic>> contributors) {
    if (contributors.isEmpty) {
      return const Center(child: Text('No contributions yet', style: TextStyle(color: AppTheme.textSecondary)));
    }

    return Column(
      children: contributors.take(5).map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  c['initials'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${c['count']} contributions', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(
                formatKes(c['total']),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.success),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _recentActivityItem(Map<String, dynamic> a) {
    final isContrib = a['type'] == 'contribution';
    final color = isContrib ? AppTheme.success : AppTheme.danger;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(isContrib ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(a['label'], style: const TextStyle(fontSize: 13)),
          ),
          Text(
            '${isContrib ? '+' : '-'}${formatKes(a['amount'])}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppTheme.textLight),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Color _getExpenseColor(String type) {
    final colors = {
      'Transport': AppTheme.primary,
      'Food': AppTheme.success,
      'Venue': AppTheme.warning,
      'Stationery': AppTheme.accent,
      'Utilities': AppTheme.danger,
    };
    return colors[type] ?? AppTheme.textLight;
  }
}
