import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'contributions_screen.dart';
import 'expenses_screen.dart';
import 'loans_screen.dart';
import 'merry_go_round_screen.dart';
import 'shares_screen.dart';
import 'goals_screen.dart';
import 'welfare_screen.dart';

class ModulesHubScreen extends StatelessWidget {
  const ModulesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading) {
      return const GridSkeleton();
    }

    final modules = <Map<String, dynamic>>[
      // Core modules - always accessible
      {
        'title': 'Contributions',
        'description': 'Record & track member contributions',
        'icon': Icons.add_circle,
        'color': AppTheme.success,
        'type': ModuleType.base,
        'screen': null, // Navigate to contributions
        'isCore': true,
      },
      {
        'title': 'Expenses',
        'description': 'Track group expenses',
        'icon': Icons.remove_circle,
        'color': AppTheme.danger,
        'type': ModuleType.base,
        'screen': null, // Navigate to expenses
        'isCore': true,
      },
      {
        'title': 'Loans',
        'description': 'Apply & manage loans',
        'icon': Icons.monetization_on,
        'color': AppTheme.success,
        'type': ModuleType.loans,
        'screen': const LoansScreen(),
      },
      {
        'title': 'Merry-Go-Round',
        'description': 'Rotational savings',
        'icon': Icons.autorenew,
        'color': AppTheme.primary,
        'type': ModuleType.merryGoRound,
        'screen': const MerryGoRoundScreen(),
      },
      {
        'title': 'Shares',
        'description': 'Share ownership',
        'icon': Icons.pie_chart,
        'color': AppTheme.accent,
        'type': ModuleType.shares,
        'screen': const SharesScreen(),
      },
      {
        'title': 'Goals',
        'description': 'Investment goals',
        'icon': Icons.flag,
        'color': AppTheme.warning,
        'type': ModuleType.goals,
        'screen': const GoalsScreen(),
      },
      {
        'title': 'Welfare',
        'description': 'Member support',
        'icon': Icons.favorite,
        'color': AppTheme.danger,
        'type': ModuleType.welfare,
        'screen': const WelfareScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.18),
                      blurRadius: 26,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Text(
                  'Modules',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Core Features',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _ModuleGrid(
                modules: modules.where((m) => m['isCore'] == true).toList(),
                buildCard: (m) => _moduleCard(context, m, state),
              ),
              const SizedBox(height: 22),
              Text(
                'Optional Modules',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              _ModuleGrid(
                modules: modules.where((m) => m['isCore'] != true).toList(),
                buildCard: (m) => _moduleCard(context, m, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moduleCard(
      BuildContext context, Map<String, dynamic> module, AppState state) {
    final isCore = module['isCore'] == true;
    final isActive =
        isCore || state.isModuleActive(module['type'] as ModuleType);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isActive
            ? () {
                // Handle core modules navigation
                if (module['title'] == 'Contributions') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ContributionsScreen()),
                  );
                } else if (module['title'] == 'Expenses') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                  );
                } else if (module['screen'] != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => module['screen'] as Widget),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? (module['color'] as Color) : AppTheme.border,
              width: isActive ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (module['color'] as Color).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                module['title'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                module['description'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppTheme.textSecondary,
                  height: 1.3,
                ),
              ),
              if (!isActive) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ] else if (isCore) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Core',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact grid of module tiles. Three across on phones, four on wider
/// surfaces. The aspect ratio is intentionally short — the tile content
/// is title + 2-line description + tiny badge, and a square would leave
/// dead space below the badge. Layout is dictated by content, not the grid.
class _ModuleGrid extends StatelessWidget {
  final List<Map<String, dynamic>> modules;
  final Widget Function(Map<String, dynamic>) buildCard;

  const _ModuleGrid({required this.modules, required this.buildCard});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final crossAxisCount = w >= 520 ? 4 : 3;
        const spacing = 10.0;
        final tileWidth =
            (w - spacing * (crossAxisCount - 1)) / crossAxisCount;
        // Short tiles — content is ~3 stacked lines + tiny badge.
        final tileHeight = tileWidth * 0.95;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: modules
              .map((m) => SizedBox(
                    width: tileWidth,
                    height: tileHeight,
                    child: buildCard(m),
                  ))
              .toList(),
        );
      },
    );
  }
}
