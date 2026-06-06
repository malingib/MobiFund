import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ZenLipaBrandMark extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final CrossAxisAlignment alignment;

  const ZenLipaBrandMark({
    super.key,
    this.size = 88,
    this.showWordmark = true,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final markSize = size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: markSize,
          height: markSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryDark, AppTheme.primary, AppTheme.accent],
              stops: [0.0, 0.68, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(markSize * 0.32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: markSize * 0.72,
                height: markSize * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                ),
              ),
              Container(
                width: markSize * 0.54,
                height: markSize * 0.54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.volunteer_activism_rounded,
                color: Colors.white,
                size: markSize * 0.38,
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: alignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ZenLipa',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: markSize * 0.34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Church and chama finance',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: markSize * 0.13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
