import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/app_state.dart';
import '../models/models.dart';

class ModuleManagementScreen extends StatelessWidget {
  const ModuleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Manage Modules',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, state, child) {
          return Container(
            decoration: const BoxDecoration(gradient: AppTheme.softGradient),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Module management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enable only the modules your group actually uses.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (state.currentOrg != null)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.business,
                              color: AppTheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current organization',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.currentOrg!.name,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  _moduleCard(
                    context,
                    icon: Icons.home,
                    title: 'Base Module',
                    description: 'Contributions, Expenses & Members',
                    isActive: true,
                    isRequired: true,
                    onToggle: (v) {},
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    icon: Icons.monetization_on,
                    title: 'Loans',
                    description:
                        'Soft & Normal loans with automated calculations',
                    isActive: state.isModuleActive(ModuleType.loans),
                    onToggle: (v) {
                      if (v) {
                        state.activateModule(ModuleType.loans);
                      } else {
                        state.deactivateModule(ModuleType.loans);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    icon: Icons.autorenew,
                    title: 'Merry-Go-Round',
                    description: 'Rotational savings and distribution',
                    isActive: state.isModuleActive(ModuleType.merryGoRound),
                    onToggle: (v) {
                      if (v) {
                        state.activateModule(ModuleType.merryGoRound);
                      } else {
                        state.deactivateModule(ModuleType.merryGoRound);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    icon: Icons.pie_chart,
                    title: 'Shares & Savings',
                    description: 'Track member shares and stakes',
                    isActive: state.isModuleActive(ModuleType.shares),
                    onToggle: (v) {
                      if (v) {
                        state.activateModule(ModuleType.shares);
                      } else {
                        state.deactivateModule(ModuleType.shares);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    icon: Icons.flag,
                    title: 'Goals & Investment',
                    description: 'Group investment goals tracking',
                    isActive: state.isModuleActive(ModuleType.goals),
                    onToggle: (v) {
                      if (v) {
                        state.activateModule(ModuleType.goals);
                      } else {
                        state.deactivateModule(ModuleType.goals);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _moduleCard(
                    context,
                    icon: Icons.favorite,
                    title: 'Welfare',
                    description: 'Member support and community fund',
                    isActive: state.isModuleActive(ModuleType.welfare),
                    onToggle: (v) {
                      if (v) {
                        state.activateModule(ModuleType.welfare);
                      } else {
                        state.deactivateModule(ModuleType.welfare);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.warning.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Module data stays safe',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.warning,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Deactivating a module hides it from view but preserves all data. You can reactivate it anytime.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppTheme.warning.withValues(alpha: 0.92),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isActive,
    bool isRequired = false,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppTheme.primary.withValues(alpha: 0.18)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isRequired)
            Switch(
              value: isActive,
              onChanged: onToggle,
              activeThumbColor: AppTheme.primary,
            ),
        ],
      ),
    );
  }
}
