import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../models/models.dart';
import '../models/module_models.dart';
import 'report_center_screen.dart';
import 'mpesa_recon_screen.dart';
import 'module_management_screen.dart';

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
      onRefresh: () async {
        // Surface sync failures to the user. The indicator's spinner
        // dismisses as soon as the future completes (or throws), so we
        // rethrow after notifying so the gesture completes naturally.
        final messenger = ScaffoldMessenger.of(context);
        try {
          await state.syncNow();
        } catch (e) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Sync failed. Showing your last saved data.'),
              backgroundColor: AppTheme.danger,
            ),
          );
          rethrow;
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth > 1120 ? 1080.0 : constraints.maxWidth;
          final isNarrow = contentWidth < 560;
          final actionWidth = isNarrow ? contentWidth : (contentWidth - 12) / 2;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.pageBottom,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroHeader(
                      context,
                      orgName: state.currentOrg?.name ?? 'Your group',
                      roleLabel: state.userRole.name,
                      memberCount: state.members.length,
                      contributionGrowth: contributionGrowth,
                      isOnline: state.isOnline,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _balanceCard(balance, totalC, totalE),
                    const SizedBox(height: AppSpacing.lg),
                    _InlineStatusRow(
                      memberCount: state.members.length,
                      contributionGrowth: contributionGrowth,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _NextUpCard(
                      cycles: state.merryGoRoundCycles,
                      onActivate: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ModuleManagementScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: actionWidth,
                          child: AppActionTile(
                            icon: Icons.analytics_outlined,
                            title: 'Reports',
                            subtitle: 'Open insights',
                            color: AppTheme.primary,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ReportCenterScreen(),
                              ),
                            ),
                          ),
                        ),
                        if (state.isFeatureAllowed('mpesa_recon'))
                          SizedBox(
                            width: actionWidth,
                            child: AppActionTile(
                              icon: Icons.sync_alt_outlined,
                              title: 'Reconcile M-Pesa',
                              subtitle: 'Match deposits to members',
                              color: AppTheme.success,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MpesaReconScreen(),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _sectionHeader(
                      context,
                      title: 'What changed',
                    ),
                    const SizedBox(height: AppSpacing.sm + 2),
                    AppAnalyticsCard(
                      title: 'Recent activity',
                      content: recentActivity.isEmpty
                          ? AppEmptyState(
                              icon: state.isOnline
                                  ? Icons.receipt_long_outlined
                                  : Icons.cloud_off_outlined,
                              title: state.isOnline
                                  ? 'No activity yet'
                                  : "You're offline.",
                              message: state.isOnline
                                  ? 'Contributions and expenses will appear here as your group records them.'
                                  : 'Reconnect to sync the latest activity from this group.',
                            )
                          : Column(
                              children: recentActivity
                                  .map((a) => _recentActivityItem(a))
                                  .toList(),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg - 2),
                    AppAnalyticsCard(
                      title: 'Income vs Expenses',
                      content: _incomeExpenseChart(totalC, totalE),
                    ),
                    const SizedBox(height: AppSpacing.lg - 2),
                    AppAnalyticsCard(
                      title: 'Expense Breakdown',
                      content: _expenseBreakdownChart(expenseBreakdown),
                    ),
                    const SizedBox(height: AppSpacing.lg - 2),
                    AppAnalyticsCard(
                      title: 'Top Contributors',
                      content: _topContributorsList(topContributors),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _heroHeader(
    BuildContext context, {
    required String orgName,
    required String roleLabel,
    required int memberCount,
    required double contributionGrowth,
    required bool isOnline,
  }) {
    return Semantics(
      header: true,
      label: '$orgName dashboard header',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl - 2),
        decoration: BoxDecoration(
          gradient: AppTheme.heroGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: AppTheme.shadowHero,
        ),
        child: Stack(
          children: [
            // Decorative shapes — pure ornament, must be hidden from a11y.
            const Positioned(
              right: -8,
              top: -8,
              child: ExcludeSemantics(
                child: _DecorativeCircle(
                  size: 92,
                  color: AppTheme.heroDecorationWhite,
                ),
              ),
            ),
            Positioned(
              left: 120,
              bottom: -12,
              child: ExcludeSemantics(
                child: _DecorativeCircle(
                  size: 66,
                  color: AppTheme.accent.withValues(alpha: 0.16),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: AppTheme.heroIconTile,
                      child: const Icon(
                        Icons.savings_outlined,
                        color: Colors.white,
                        size: AppIconSize.xl - 12,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orgName,
                            style: AppTheme.sectionHeader.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Treasury snapshot',
                            style: AppTheme.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      label: isOnline ? 'Status: online' : 'Status: offline',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: AppSpacing.xs + 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? AppTheme.accent2.withValues(alpha: 0.16)
                              : Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? AppTheme.accent2
                                    : Colors.white70,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs + 2),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: AppTheme.label.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg + 2),
                Wrap(
                  spacing: AppSpacing.sm + 2,
                  runSpacing: AppSpacing.sm + 2,
                  children: [
                    _HeroStatusChip(
                      icon: Icons.people_outline,
                      label: '$memberCount members',
                    ),
                    _HeroStatusChip(
                      icon: Icons.trending_up_outlined,
                      label:
                          '+${contributionGrowth.toStringAsFixed(0)}% growth',
                    ),
                    _HeroStatusChip(
                      icon: Icons.verified_outlined,
                      label: roleLabel.toUpperCase(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(double balance, double totalC, double totalE) {
    return Semantics(
      container: true,
      label:
          'Treasury snapshot. Current balance ${formatKes(balance)} Kenyan Shillings.',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl - 2),
        decoration: BoxDecoration(
          color: AppTheme.surface2,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.fromBorderSide(AppTheme.cardBorder),
          boxShadow: AppTheme.shadowCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: AppIconSize.md - 2,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    'Treasury snapshot',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Semantics(
                  liveRegion: true,
                  label: 'Live data',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      const Text(
                        'Live',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formatKes(balance),
              style: AppTheme.heroBalance,
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            Text(
              'Current balance after contributions and expenses.',
              style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm + 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contributions',
                          style: AppTheme.label,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formatKes(totalC),
                          style: AppTheme.tileValue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm + 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: AppTheme.label,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formatKes(totalE),
                          style: AppTheme.tileValue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    Widget? action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTheme.headline.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _incomeExpenseChart(double income, double expense) {
    return Semantics(
      container: true,
      label:
          'Income ${formatKes(income)} Kenyan Shillings, Expenses ${formatKes(expense)} Kenyan Shillings.',
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: income > expense ? income * 1.2 : expense * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => AppTheme.textPrimary,
                tooltipPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                tooltipMargin: AppSpacing.sm,
                getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                  '${group.x == 0 ? 'Income' : 'Expenses'}\n${formatKes(rod.toY)}',
                  AppTheme.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const titles = ['Income', 'Expenses'];
                    final index = value.toInt();
                    if (index < 0 || index >= titles.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(titles[index],
                          style: AppTheme.caption
                              .copyWith(color: AppTheme.textSecondary)),
                    );
                  },
                ),
              ),
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    gradient: LinearGradient(colors: [
                      AppTheme.success,
                      AppTheme.success.withValues(alpha: 0.7)
                    ]),
                    width: 40,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expense,
                    gradient: LinearGradient(colors: [
                      AppTheme.danger,
                      AppTheme.danger.withValues(alpha: 0.7)
                    ]),
                    width: 40,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expenseBreakdownChart(Map<String, double> breakdown) {
    if (breakdown.isEmpty) {
      return const AppEmptyState(
        icon: Icons.pie_chart_outline_rounded,
        title: 'No expense data',
        message: 'Once you log expenses, the breakdown will show here.',
      );
    }

    final total = breakdown.values.fold(0.0, (sum, val) => sum + val);
    final entries = breakdown.entries.toList();

    final breakdownLabel = entries
        .map((e) =>
            '${e.key} ${(e.value / total * 100).toStringAsFixed(0)} percent')
        .join(', ');

    return Column(
      children: [
        Semantics(
          container: true,
          label: 'Expense breakdown: $breakdownLabel.',
          excludeSemantics: true,
          child: SizedBox(
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
                    titleStyle: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: _getExpenseColor(e.key),
                        shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.xs + 2),
                Text(
                  e.key,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _topContributorsList(List<Map<String, dynamic>> contributors) {
    if (contributors.isEmpty) {
      return const AppEmptyState(
        icon: Icons.people_outline,
        title: 'No contributions yet',
        message:
            'When members record contributions, top contributors will appear here.',
      );
    }

    return Column(
      children: contributors.take(5).map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  c['initials'],
                  style: AppTheme.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'], style: AppTheme.rowTitle),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text('${c['count']} contributions',
                        style: AppTheme.caption
                            .copyWith(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(
                formatKes(c['total']),
                style: AppTheme.rowTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.success,
                ),
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 3),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm + 2)),
            child: Icon(isContrib ? Icons.arrow_downward : Icons.arrow_upward,
                color: color, size: AppIconSize.sm - 2),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child:
                Text(a['label'], style: AppTheme.body.copyWith(fontSize: 13)),
          ),
          Text(
            '${isContrib ? '+' : '-'}${formatKes(a['amount'])}',
            style: AppTheme.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
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

// ─────────────────────────────────────────
// INLINE STATUS ROW
// Two icon + value cells, no card chrome. Replaces the 3-tile
// "identical card grid" anti-pattern called out in DESIGN.md §6.
// Earned restraint: members and growth are the only two numbers a
// treasurer needs to glance at; "Activity" is downstream of the feed.
// ─────────────────────────────────────────
class _InlineStatusRow extends StatelessWidget {
  final int memberCount;
  final double contributionGrowth;

  const _InlineStatusRow({
    required this.memberCount,
    required this.contributionGrowth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _StatusCell(
            icon: Icons.people_outline,
            value: '$memberCount',
            label: memberCount == 1 ? 'member' : 'members',
          ),
          const SizedBox(width: AppSpacing.xl),
          _StatusCell(
            icon: Icons.trending_up_outlined,
            value:
                '+${contributionGrowth.toStringAsFixed(0)}%',
            label: 'growth',
          ),
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatusCell({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$value $label',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// NEXT UP CARD
// Shows the chama's next scheduled event. Source: the active MGR cycle.
// If the chama has no cycle (or all cycles are completed), the card
// teaches "Activate the MGR module" — never renders a generic empty
// state with no next step.
// ─────────────────────────────────────────
class _NextUpCard extends StatelessWidget {
  final List<MerryGoRoundCycle> cycles;
  final VoidCallback onActivate;

  const _NextUpCard({
    required this.cycles,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    final active = cycles
        .where((c) => c.status == 'active' || c.status == 'planning')
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final next = active.isEmpty ? null : active.first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.fromBorderSide(AppTheme.cardBorder),
        boxShadow: AppTheme.shadowCard,
      ),
      child: next == null
          ? _EmptyNextUp(onActivate: onActivate)
          : _NextUpContent(cycle: next),
    );
  }
}

class _EmptyNextUp extends StatelessWidget {
  final VoidCallback onActivate;
  const _EmptyNextUp({required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Icon(
            Icons.event_outlined,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'No upcoming event',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Schedule a merry-go-round cycle to track the next payout.',
                style: AppTheme.body.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              TextButton(
                onPressed: () {
                  AppHaptics.light();
                  onActivate();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: AppTheme.primary,
                ),
                child: const Text(
                  'Activate MGR',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextUpContent extends StatelessWidget {
  final MerryGoRoundCycle cycle;
  const _NextUpContent({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final payoutIndex = cycle.currentPosition + 1;
    final totalMembers = cycle.totalMembers;
    final isFinal = payoutIndex >= totalMembers;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Icon(
            Icons.event_outlined,
            color: AppTheme.accent,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFinal
                    ? 'Final payout — ${cycle.name}'
                    : 'Next payout — ${cycle.name}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isFinal
                    ? 'Last cycle closing on ${formatShortDate(cycle.endDate)}'
                    : 'Payout $payoutIndex of $totalMembers — ${formatShortDate(cycle.startDate)}',
                style: AppTheme.body.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                '${formatKes(cycle.contributionAmount)} per member',
                style: AppTheme.body.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStatusChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 4,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: AppIconSize.xs),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            label,
            style: AppTheme.label.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pure ornament. Used by the hero's two `Positioned` shapes behind the
/// brand mark. Both call sites must wrap the circle in `ExcludeSemantics`
/// so screen readers don't read the shape as content. If you need a
/// meaningful shape (an avatar, a status indicator), use `MemberAvatar`
/// or build a real widget — do not extend this.
class _DecorativeCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _DecorativeCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

/// Subtle stagger entry for the 3 quick-stat tiles. One AnimationController
/// drives 3 staggered opacity tweens and a 12→0 Y offset.
///
/// Respects `MediaQuery.disableAnimations` (the OS-level "reduce motion"
/// setting on iOS/Android). When the user has opted out of motion, the
/// tiles render at full opacity with no animation, no controller, and no
/// tween-driven rebuilds.
class _StaggeredStats extends StatefulWidget {
  final List<Widget> children;
  const _StaggeredStats({required this.children});

  @override
  State<_StaggeredStats> createState() => _StaggeredStatsState();
}

class _StaggeredStatsState extends State<_StaggeredStats>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _stagger = Duration(milliseconds: 60);
  static const _tile = Duration(milliseconds: 320);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _tile + _stagger * 2,
    );
    // Defer to next frame so the transition is from the skeleton, not
    // from nothing. Skip if the user has set "reduce motion" at the OS
    // level — the controller is a no-op when reduceAnimations is true.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.of(context).disableAnimations) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (reduceMotion)
            widget.children[i]
          else
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final start = i *
                    _stagger.inMilliseconds /
                    _controller.duration!.inMilliseconds;
                final end =
                    (i * _stagger.inMilliseconds + _tile.inMilliseconds) /
                        _controller.duration!.inMilliseconds;
                final clamped = (_controller.value - start)
                    .clamp(0.0, end - start)
                    .toDouble();
                final t = (clamped / (end - start)).clamp(0.0, 1.0);
                final eased = Curves.easeOutCubic.transform(t);
                return Opacity(
                  opacity: eased,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - eased)),
                    child: child,
                  ),
                );
              },
              child: widget.children[i],
            ),
      ],
    );
  }
}
