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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Modules',
          style: TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modules that feel built-in, not bolted on',
                      style: AppTheme.displayMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start with the essentials and activate the rest as your group grows.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _ModulePill(label: 'Core first'),
                        _ModulePill(label: 'Optional add-ons'),
                        _ModulePill(label: 'Live status'),
                      ],
                    ),
                  ],
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
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.86,
                ),
                itemCount: modules.where((m) => m['isCore'] == true).length,
                itemBuilder: (ctx, i) {
                  final coreModules =
                      modules.where((m) => m['isCore'] == true).toList();
                  return _moduleCard(context, coreModules[i], state);
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Optional Modules',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 12,
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
                  childAspectRatio: 0.86,
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
      borderRadius: BorderRadius.circular(22),
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
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive ? (module['color'] as Color) : AppTheme.border,
              width: isActive ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (module['color'] as Color).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (module['color'] as Color).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  module['icon'] as IconData,
                  color: module['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                module['title'] as String,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                module['description'] as String,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              const Spacer(),
              if (!isActive) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withValues(alpha: 0.10),
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
              ] else if (isCore) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Core',
                    style: TextStyle(
                      fontSize: 10,
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

class _ModulePill extends StatelessWidget {
  final String label;

  const _ModulePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
