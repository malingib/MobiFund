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
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        title: const Text(
          'Modules',
          style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Modules',
              style: AppTheme.headline
                  .copyWith(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Access your activated features',
              style: AppTheme.body.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),

            // Core Modules (always active)
            Text(
              'Core Features',
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: modules.where((m) => m['isCore'] == true).length,
              itemBuilder: (ctx, i) {
                final coreModules =
                    modules.where((m) => m['isCore'] == true).toList();
                return _moduleCard(context, coreModules[i], state);
              },
            ),

            const SizedBox(height: 24),

            // Optional Modules
            Text(
              'Optional Modules',
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: modules.where((m) => m['isCore'] != true).length,
              itemBuilder: (ctx, i) {
                final optionalModules =
                    modules.where((m) => m['isCore'] != true).toList();
                return _moduleCard(context, optionalModules[i], state);
              },
            ),
          ],
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
      borderRadius: BorderRadius.circular(20),
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
                    MaterialPageRoute(builder: (_) => module['screen'] as Widget),
                  );
                }
              }
            : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.cardBg : AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? (module['color'] as Color) : AppTheme.border,
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: (module['color'] as Color).withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(colors: [
                          module['color'],
                          (module['color'] as Color).withValues(alpha: 0.7)
                        ])
                      : null,
                  color: isActive
                      ? null
                      : (module['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  module['icon'] as IconData,
                  color: isActive ? Colors.white : module['color'],
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                module['title'] as String,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.textPrimary : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                module['description'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? AppTheme.textSecondary : AppTheme.textLight,
                ),
                textAlign: TextAlign.center,
              ),
              if (!isActive) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Inactive',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600),
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
