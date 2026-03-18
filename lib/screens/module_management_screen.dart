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
        backgroundColor: AppTheme.bg,
        elevation: 0,
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Activate Features',
                  style: AppTheme.headline.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enable only the modules your chama needs',
                  style: AppTheme.body.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Current Organization
                if (state.currentOrg != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Organization',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.currentOrg!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Base Module (Always Active)
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

                // Loans Module
                _moduleCard(
                  context,
                  icon: Icons.monetization_on,
                  title: 'Loans',
                  description: 'Soft & Normal loans with automated calculations',
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

                // Merry-Go-Round Module
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

                // Shares Module
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

                // Goals Module
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

                // Welfare Module
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

                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(8),
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
                              'Module Data',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warning,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Deactivating a module hides it from view but preserves all data. You can reactivate it anytime.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.warning.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
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
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppTheme.primary : AppTheme.border,
          width: isActive ? 2 : 1,
        ),
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
