import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onCenterTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCenterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface2.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.border.withValues(alpha: 0.82)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.dashboard_outlined, Icons.dashboard, 'Home', 0),
              _navItem(Icons.people_outline, Icons.people, 'Members', 1),
              _centerFab(),
              _navItem(Icons.apps_outlined, Icons.apps, 'Modules', 2),
              _navItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Reports', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerFab() {
    return GestureDetector(
      onTap: () {
        AppHaptics.medium();
        if (onCenterTap != null) {
          onCenterTap!();
        } else {
          onTap(2);
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }

  Widget _navItem(
      IconData inactiveIcon, IconData activeIcon, String label, int idx) {
    final active = idx == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          onTap(idx);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? activeIcon : inactiveIcon,
                color: active ? AppTheme.primary : AppTheme.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
