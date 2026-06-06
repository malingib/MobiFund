import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';

class BillingTiersScreen extends StatelessWidget {
  const BillingTiersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentTier = state.currentOrg?.tier ?? BillingTier.free;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Plans & Pricing'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.softGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
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
                      'Plans that scale with the group',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep the free essentials or move into automation, recon, and richer reporting.',
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
              _buildTierCard(
                context,
                tier: BillingTier.free,
                title: 'Free',
                price: 'KES 0',
                period: '/ month',
                features: [
                  'Up to 10 members',
                  'Basic contributions',
                  'Manual reports',
                  'Standard support'
                ],
                isCurrent: currentTier == BillingTier.free,
                color: AppTheme.textSecondary,
                onUpgrade: () =>
                    _confirmUpgrade(context, BillingTier.free, 'Free'),
              ),
              const SizedBox(height: 18),
              _buildTierCard(
                context,
                tier: BillingTier.pro,
                title: 'Pro',
                price: 'KES 2,500',
                period: '/ month',
                features: [
                  'Up to 100 members',
                  'Automated M-Pesa Recon',
                  'Advanced Analytics',
                  'Priority SMS Support'
                ],
                isCurrent: currentTier == BillingTier.pro,
                isPopular: true,
                color: AppTheme.primary,
                onUpgrade: () =>
                    _confirmUpgrade(context, BillingTier.pro, 'Pro'),
              ),
              const SizedBox(height: 18),
              _buildTierCard(
                context,
                tier: BillingTier.enterprise,
                title: 'Enterprise',
                price: 'Custom',
                period: '',
                features: [
                  'Unlimited members',
                  'Custom White-labeling',
                  'API Integration',
                  'Dedicated Account Manager'
                ],
                isCurrent: currentTier == BillingTier.enterprise,
                color: AppTheme.accent,
                onUpgrade: () => _confirmUpgrade(
                    context, BillingTier.enterprise, 'Enterprise'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context, {
    required BillingTier tier,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrent,
    bool isPopular = false,
    required Color color,
    required VoidCallback onUpgrade,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.92),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headline.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Current Plan',
                          style: TextStyle(
                              color: AppTheme.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4, left: 2),
                      child: Text(period, style: AppTheme.caption),
                    ),
                  ],
                ),
                const Divider(height: 32),
                ...features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppTheme.success, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(f,
                                  style: AppTheme.body.copyWith(fontSize: 14))),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : onUpgrade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? AppTheme.primary : AppTheme.surface,
                      foregroundColor:
                          isPopular ? Colors.white : AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      isCurrent
                          ? 'Current'
                          : (tier == BillingTier.free
                              ? 'Switch to Free'
                              : 'Upgrade to $title'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUpgrade(
    BuildContext context,
    BillingTier tier,
    String title,
  ) async {
    final state = context.read<AppState>();
    final currentTier = state.currentOrg?.tier;
    if (currentTier == tier) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to $title Plan'),
        content: Text(
            'Moving to the $title plan unlocks ${tier == BillingTier.free ? 'the base experience' : 'premium tooling'} and adjusts billing automatically.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await state.updateOrganizationTier(tier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to the $title plan.'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }
}
