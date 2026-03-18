import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/module_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final goals = state.goals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Goal Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateGoalDialog(context),
              icon: const Icon(Icons.flag),
              label: const Text('Create New Goal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Goals Grid
          goals.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.flag_outlined, size: 64, color: AppTheme.textLight),
                        SizedBox(height: 16),
                        Text('No goals yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: goals.length,
                  itemBuilder: (ctx, i) => _goalCard(goals[i]),
                ),
        ],
      ),
    );
  }

  Widget _goalCard(Goal goal) {
    final progress = goal.progressPercent;
    final isComplete = goal.status == 'completed';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? AppTheme.success : AppTheme.primary,
          width: isComplete ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(goal.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(goal.category),
                  color: _getCategoryColor(goal.category),
                  size: 20,
                ),
              ),
              const Spacer(),
              if (isComplete)
                const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            goal.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '${formatKes(goal.raisedAmount)} of ${formatKes(goal.targetAmount)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? AppTheme.success : AppTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _contributeDialog(goal),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Contribute'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'education':
        return AppTheme.primary;
      case 'business':
        return AppTheme.success;
      case 'property':
        return AppTheme.warning;
      default:
        return AppTheme.accent;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'education':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'property':
        return Icons.home;
      default:
        return Icons.flag;
    }
  }

  void _showCreateGoalDialog(BuildContext context) {
    final state = context.read<AppState>();
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    String category = 'general';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: targetCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount (KES)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'education', child: Text('Education')),
                DropdownMenuItem(value: 'business', child: Text('Business')),
                DropdownMenuItem(value: 'property', child: Text('Property')),
              ],
              onChanged: (v) => category = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              state.createGoal(Goal(
                orgId: state.currentOrg!.id,
                name: nameCtrl.text.trim(),
                targetAmount: double.tryParse(targetCtrl.text) ?? 0,
                category: category,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _contributeDialog(Goal goal) {
    final state = context.read<AppState>();
    final amountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Contribute to Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Goal: ${goal.name}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (KES)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text) ?? 0;
              if (amount > 0) {
                state.contributeToGoal(GoalContribution(
                  orgId: state.currentOrg!.id,
                  goalId: goal.id,
                  memberId: state.currentUserId,
                  amount: amount,
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
