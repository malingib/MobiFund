import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────
// MODERN STAT CARD (Gradient)
// ─────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// WHITE CARD (for sections)
// ─────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTheme.headline,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.6, color: AppTheme.border),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// MEMBER AVATAR (Modern)
// ─────────────────────────────────────────
class MemberAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? color;

  const MemberAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? AppTheme.primary,
            color ?? AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (color ?? AppTheme.primary).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// BADGE (Modern)
// ─────────────────────────────────────────
class AppBadge extends StatelessWidget {
  final String label;
  final bool isExpense;

  const AppBadge({super.key, required this.label, this.isExpense = false});

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? AppTheme.danger : AppTheme.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// APP TEXT FIELD
// ─────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final IconData? prefixIcon;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // `TextFormField` requires a `Material` ancestor. Wrapping it makes
        // the widget resilient when used inside overlays/bottom sheets.
        Material(
          type: MaterialType.transparency,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: AppTheme.body.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: AppTheme.primary, size: 20)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// APP DROPDOWN
// ─────────────────────────────────────────
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: (val) {
                AppHaptics.selection();
                onChanged(val);
              },
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppTheme.primary),
              style: AppTheme.body.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// QUICK ACTION BUTTON
// ─────────────────────────────────────────
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        AppHaptics.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primary).withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: (color ?? AppTheme.primary).withValues(alpha: 0.10),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color ?? AppTheme.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? AppTheme.primary).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// BALANCE CARD (Hero)
// ─────────────────────────────────────────
class BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String? subtitle;
  final VoidCallback? onRefresh;

  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onRefresh != null)
                InkWell(
                  onTap: () {
                    AppHaptics.selection();
                    AppHaptics.light();
                    onRefresh!();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Tooltip(
                      message: 'Refresh',
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SKELETON LOADERS (Shimmer)
// ─────────────────────────────────────────
class AppSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.border.withValues(alpha: 0.5),
      highlightColor: AppTheme.surface.withValues(alpha: 0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton(width: double.infinity, height: 180, borderRadius: 28),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: AppSkeleton(width: 100, height: 80, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(
                  child: AppSkeleton(width: 100, height: 80, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(
                  child: AppSkeleton(width: 100, height: 80, borderRadius: 18)),
            ],
          ),
          SizedBox(height: 24),
          AppSkeleton(width: 150, height: 24),
          SizedBox(height: 12),
          AppSkeleton(width: double.infinity, height: 200, borderRadius: 20),
          SizedBox(height: 16),
          AppSkeleton(width: double.infinity, height: 200, borderRadius: 20),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            AppSkeleton(width: 50, height: 50, borderRadius: 25),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 150, height: 16),
                  SizedBox(height: 8),
                  AppSkeleton(width: 100, height: 12),
                ],
              ),
            ),
            AppSkeleton(width: 80, height: 20),
          ],
        ),
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: 6,
      itemBuilder: (context, index) =>
          const AppSkeleton(width: 100, height: 100, borderRadius: 20),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────
String formatKes(double amount) {
  return 'KES ${NumberFormat('#,##0').format(amount)}';
}

String formatDate(DateTime d) => DateFormat('dd MMM yyyy').format(d);

String formatShortDate(DateTime d) => DateFormat('dd MMM').format(d);

// ─────────────────────────────────────────
// QUICK STAT TILE
// A small icon + value + label card. Used for the dashboard's three
// "Members / Activity / Growth" tiles. Designed to be read as a single
// "Members, 12" announcement by TalkBack.
// ─────────────────────────────────────────
class AppQuickStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AppQuickStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppTheme.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: onTap != null,
      label: '$label, $value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  AppHaptics.selection();
                  AppHaptics.light();
                  onTap!();
                },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg - 2),
            decoration: BoxDecoration(
              color: AppTheme.surface2,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm + 2),
                  ),
                  child: Icon(icon, color: color, size: AppIconSize.md),
                ),
                const SizedBox(height: AppSpacing.sm + 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs / 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ACTION TILE
// A row tile with icon, title, subtitle, and trailing chevron.
// Used for navigation entries (Reports, M-Pesa Recon, etc.).
// ─────────────────────────────────────────
class AppActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  const AppActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : AppTheme.textLight;
    return MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: '$title. $subtitle',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    AppHaptics.selection();
                    onTap();
                  }
                : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.surface2,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.78),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: BoxDecoration(
                      color: effectiveColor.withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm + 2),
                    ),
                    child: Icon(icon,
                        color: effectiveColor, size: AppIconSize.md - 2),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.chevron_right,
                      color: AppTheme.textLight,
                      size: AppIconSize.md,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ANALYTICS CARD
// Titled card for chart / list content. Used in the dashboard's
// "Analytics" section (Income vs Expenses, Top Contributors, etc.).
// ─────────────────────────────────────────
class AppAnalyticsCard extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsets padding;

  const AppAnalyticsCard({
    super.key,
    required this.title,
    required this.content,
    this.padding = const EdgeInsets.all(AppSpacing.lg + 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.72),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg - 2),
          content,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// STATE WIDGETS — loading / empty / error / offline
// A single source of truth for "there's nothing to show."
// Calm, descriptive microcopy. Linear/Stripe tone.
// ─────────────────────────────────────────

/// Centered icon + title + body + optional CTA, wrapped in a single
/// Semantics block so TalkBack reads it as one coherent announcement.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;
  final String? semanticLabel;
  final Color? tint;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.semanticLabel,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final accent = tint ?? AppTheme.primary;
    final label =
        semanticLabel ?? ([title, if (message != null) message!].join('. '));

    return Center(
      child: Semantics(
        container: true,
        label: label,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.18),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: AppIconSize.xl,
                  color: accent,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppTheme.headline,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  style: AppTheme.body.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xl),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error state with an optional retry CTA.
/// Default copy is generic on purpose — the screen can pass a custom
/// [title] / [message] via the dedicated constructor if needed.
class AppErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final String title;
  final String message;
  final IconData icon;

  const AppErrorState({
    super.key,
    this.error,
    this.onRetry,
    this.title = 'Something went wrong.',
    this.message =
        "We couldn't load this. Check your connection and try again.",
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: icon,
      tint: AppTheme.danger,
      title: title,
      message: message,
      semanticLabel: '$title. $message',
      action: onRetry == null
          ? null
          : ElevatedButton.icon(
              onPressed: () {
                AppHaptics.medium();
                onRetry!();
              },
              icon: const Icon(Icons.refresh_rounded, size: AppIconSize.sm),
              label: const Text('Try again'),
            ),
    );
  }
}

/// Offline state. Pass [onRetry] to wire a "Retry" button.
class AppOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;
  const AppOfflineState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.cloud_off_outlined,
      tint: AppTheme.textSecondary,
      title: "You're offline.",
      message: 'Showing your last saved data. Reconnect to sync this group.',
      semanticLabel: "You're offline. Showing your last saved data.",
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: () {
                AppHaptics.medium();
                onRetry!();
              },
              icon: const Icon(Icons.refresh_rounded, size: AppIconSize.sm),
              label: const Text('Try again'),
            ),
    );
  }
}

// ─────────────────────────────────────────
// SCREEN SCAFFOLD — safe area + refresh + padding
// ─────────────────────────────────────────
class AppScreenScaffold extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool fillHeight;

  const AppScreenScaffold({
    super.key,
    required this.child,
    this.onRefresh,
    this.padding = AppSpacing.pagePadding,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.controller,
    this.fillHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      physics: physics,
      controller: controller,
      padding: padding,
      child: child,
    );

    if (onRefresh == null) return scroll;

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface2,
      onRefresh: onRefresh!,
      child: scroll,
    );
  }
}

// ─────────────────────────────────────────
// LIST VIEW — one widget for loading / empty / error / offline / ready
// Use this for simple ListView bodies. Sliver-based screens keep their
// existing CustomScrollView structure and use AppEmptyState / ListSkeleton
// directly inside SliverFillRemaining.
// ─────────────────────────────────────────
enum AppListStatus { loading, empty, error, offline, ready }

class AppListView<T> extends StatelessWidget {
  final AppListStatus status;
  final List<T> items;
  final Widget Function(T item, int index) itemBuilder;
  final AppEmptyState? empty;
  final Object? error;
  final VoidCallback? onRetry;
  final Widget? loading;
  final EdgeInsets padding;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final bool refreshable;
  final Future<void> Function()? onRefresh;
  final Widget? separator;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const AppListView({
    super.key,
    required this.status,
    required this.items,
    required this.itemBuilder,
    this.empty,
    this.error,
    this.onRetry,
    this.loading,
    this.padding = AppSpacing.pagePadding,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.refreshable = false,
    this.onRefresh,
    this.separator,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AppListStatus.loading:
        return loading ?? const ListSkeleton();
      case AppListStatus.empty:
        return empty ??
            const AppEmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nothing here yet',
              message: 'When you add something, it will show up here.',
            );
      case AppListStatus.error:
        return AppErrorState(error: error, onRetry: onRetry);
      case AppListStatus.offline:
        return AppOfflineState(onRetry: onRetry);
      case AppListStatus.ready:
        if (items.isEmpty) {
          return empty ??
              const AppEmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing here yet',
                message: 'When you add something, it will show up here.',
              );
        }
        final list = ListView.separated(
          physics: physics,
          controller: controller,
          keyboardDismissBehavior: keyboardDismissBehavior,
          padding: padding,
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(items[index], index),
          separatorBuilder: (context, _) =>
              separator ?? const SizedBox(height: AppSpacing.md),
        );
        if (!refreshable || onRefresh == null) return list;
        return RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface2,
          onRefresh: onRefresh!,
          child: list,
        );
    }
  }
}
