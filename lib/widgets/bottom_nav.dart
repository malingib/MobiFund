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
      decoration: BoxDecoration(
        color: AppTheme.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(Icons.dashboard_outlined, Icons.dashboard, 0),
              _navItem(Icons.people_outline, Icons.people, 1),
              // Center FAB
              _centerFab(),
              _navItem(Icons.apps_outlined, Icons.apps, 2),
              _navItem(Icons.settings_outlined, Icons.settings, 3),
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
              color: AppTheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _navItem(IconData inactiveIcon, IconData activeIcon, int idx) {
    final active = idx == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          onTap(idx);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? activeIcon : inactiveIcon,
                color: active ? AppTheme.primary : AppTheme.textLight,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
