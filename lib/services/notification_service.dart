import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void showSnackbar(
    BuildContext context, {
    required String message,
    bool isError = false,
    bool isSuccess = false,
    bool isInfo = false,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    final color = isError
        ? AppTheme.danger
        : isSuccess
            ? AppTheme.success
            : isInfo
                ? AppTheme.primary
                : AppTheme.textPrimary;

    final defaultIcon = isError
        ? Icons.error_outline
        : isSuccess
            ? Icons.check_circle_outline
            : isInfo
                ? Icons.info_outline
                : Icons.notifications_none;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('No ScaffoldMessenger found for snackbar: $message');
      return;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon ?? defaultIcon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
    );
  }

  void showSuccess(BuildContext context, String message) {
    showSnackbar(context, message: message, isSuccess: true);
  }

  void showError(BuildContext context, String message) {
    showSnackbar(context, message: message, isError: true);
  }

  void showInfo(BuildContext context, String message) {
    showSnackbar(context, message: message, isInfo: true);
  }
}
