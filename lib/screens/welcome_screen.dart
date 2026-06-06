import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Marketing + orientation surface for first-launch (and returning)
/// unauthenticated users. The product surfaces, not a pitch deck.
///
/// IA:
///   1. AppBar with Skip (pushes /login)
///   2. Wordmark + one-line value statement
///   3. Three value chips, tappable, open a 3-bullet explainer
///   4. Two trust-flavored mini-metrics (no vanity numbers)
///   5. Primary CTA "Create your chama"  → /register
///   6. Secondary CTA "I already have an account" → /login
///   7. Footer microcopy (Terms + Privacy)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.light();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Wordmark(),
              const SizedBox(height: AppSpacing.xxl),
              _Chips(),
              const SizedBox(height: AppSpacing.xxl),
              _TrustMetrics(),
              const SizedBox(height: AppSpacing.xxxl),
              _PrimaryCta(),
              const SizedBox(height: AppSpacing.md),
              _SecondaryCta(),
              const SizedBox(height: AppSpacing.xl),
              _FooterMicrocopy(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// WORDMARK + VALUE STATEMENT
// No hero gradient. The product reads as one instrument; the splash
// owns the brand display, this screen owns the value display.
// ─────────────────────────────────────────
class _Wordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'MobiFund welcome',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.savings_outlined,
              color: Colors.white,
              size: AppIconSize.xl,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'MobiFund',
            style: AppTheme.displayLarge.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Run your chama on one ledger. Reconcile M-Pesa in minutes.',
            style: AppTheme.body.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// VALUE CHIPS
// Three chips, value-not-features. Tappable, opens a 3-bullet
// explainer bottom sheet. Tinted with primary @ 8% per the design
// system — no rainbow, no second accent.
// ─────────────────────────────────────────
class _Chips extends StatelessWidget {
  static const _ChipData _trackContributions = _ChipData(
    icon: Icons.receipt_long_outlined,
    label: 'Track every contribution',
    body: [
      'Record a contribution in under five seconds.',
      'Every entry ties to a member and a date.',
      'Reconcile against M-Pesa automatically.',
    ],
  );

  static const _ChipData _approveLoans = _ChipData(
    icon: Icons.handshake_outlined,
    label: 'Approve loans transparently',
    body: [
      'Members see outstanding balances and history.',
      'Treasurers approve with a single tap.',
      'Interest and repayments are auto-tracked.',
    ],
  );

  static const _ChipData _reconcileMpesa = _ChipData(
    icon: Icons.sync_alt_outlined,
    label: 'Reconcile M-Pesa automatically',
    body: [
      'Pulls statements from the Daraja API.',
      'Matches incoming deposits to members.',
      'Flags anything that does not reconcile.',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _ValueChip(data: _trackContributions),
        _ValueChip(data: _approveLoans),
        _ValueChip(data: _reconcileMpesa),
      ],
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final List<String> body;
  const _ChipData({
    required this.icon,
    required this.label,
    required this.body,
  });
}

class _ValueChip extends StatelessWidget {
  final _ChipData data;
  const _ValueChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: data.label,
      child: Material(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          onTap: () {
            AppHaptics.selection();
            _showExplainer(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, size: 18, color: AppTheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  data.label,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExplainer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Icon(
                        data.icon,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        data.label,
                        style: AppTheme.headline.copyWith(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ...data.body.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm + 2,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            line,
                            style: AppTheme.body.copyWith(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// TRUST MINI-METRICS
// Two rows, not three. No vanity counts. The "what you can rely on"
// voice — DESIGN.md §1.
// ─────────────────────────────────────────
class _TrustMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BUILT FOR KENYAN CHAMAS',
          style: AppTheme.caption.copyWith(
            color: AppTheme.textLight,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _TrustMetric(
          icon: Icons.cloud_off_outlined,
          title: 'Offline-first',
          body: 'Your ledger works without signal.',
        ),
        const SizedBox(height: AppSpacing.md),
        const _TrustMetric(
          icon: Icons.account_balance_wallet_outlined,
          title: 'M-Pesa native',
          body: 'Reconciles against your Daraja statement.',
        ),
      ],
    );
  }
}

class _TrustMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _TrustMetric({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: AppTheme.body.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// PRIMARY CTA
// The loudest thing on the screen. 48dp height per the design system.
// ─────────────────────────────────────────
class _PrimaryCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          AppHaptics.medium();
          Navigator.of(context).pushReplacementNamed('/register');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
        ),
        child: const Text('Create your chama'),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SECONDARY CTA
// TextButton — quiet. The secondary path is one tap away, not loud.
// ─────────────────────────────────────────
class _SecondaryCta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: TextButton(
        onPressed: () {
          AppHaptics.light();
          Navigator.of(context).pushReplacementNamed('/login');
        },
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        child: const Text('I already have an account'),
      ),
    );
  }
}

// ─────────────────────────────────────────
// FOOTER MICROCOPY
// 12px muted. Legally required, not a sales pitch.
// ─────────────────────────────────────────
class _FooterMicrocopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'By continuing you agree to our Terms and Privacy Policy.',
        style: AppTheme.caption.copyWith(
          color: AppTheme.textLight,
          fontSize: 11,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
