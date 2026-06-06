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
      decoration: const BoxDecoration(
        color: AppTheme.surface2,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.6)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? AppTheme.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(
                  active ? activeIcon : inactiveIcon,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
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
