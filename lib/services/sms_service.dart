import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mobiwave SMS Service
/// 
/// Provides SMS functionality using Mobiwave Innovations SMS API
/// Documentation: https://sms.mobiwave.co.ke/api/v3/
class SmsService {
  // Base URL for Mobiwave SMS API
  static const String _baseUrl = 'https://sms.mobiwave.co.ke/api/v3';
  
  // API credentials - Store these securely in production
  static const String _defaultApiKey = 'YOUR_MOBIWAVE_API_KEY';
  static const String _defaultSenderId = 'Mobifund';

  static const String _kApiKeyPref = 'sms_api_key';
  static const String _kSenderIdPref = 'sms_sender_id';

  static String? _apiKey;
  static String? _senderId;

  static Future<void> _ensureLoaded() async {
    if (_apiKey != null && _senderId != null) return;
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_kApiKeyPref) ?? _defaultApiKey;
    _senderId = prefs.getString(_kSenderIdPref) ?? _defaultSenderId;
  }

  /// Send a single SMS message
  /// 
  /// [recipient] - Phone number (with country code, e.g., 254712345678)
  /// [message] - SMS message content
  /// [senderId] - Optional custom sender ID (defaults to 'Mobifund')
  /// 
  /// Returns true if successful, false otherwise
  static Future<SmsResult> sendSms({
    required String recipient,
    required String message,
    String? senderId,
  }) async {
    try {
      await _ensureLoaded();
      final apiKey = _apiKey ?? _defaultApiKey;
      final sid = senderId ?? _senderId ?? _defaultSenderId;

      if (apiKey.contains('YOUR_')) {
        return SmsResult(
          success: false,
          message:
              'SMS is not configured. Add your Mobiwave API key in Settings.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/sms/send'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'recipient': recipient,
          'sender_id': sid,
          'type': 'plain',
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        debugPrint('SMS sent successfully to $recipient');
        return SmsResult(
          success: true,
          messageId: data['data']?['id']?.toString(),
          message: 'SMS sent successfully',
        );
      } else {
        debugPrint('SMS failed: ${data['message'] ?? 'Unknown error'}');
        return SmsResult(
          success: false,
          message: data['message'] ?? 'Failed to send SMS',
        );
      }
    } catch (e) {
      debugPrint('SMS error: $e');
      return SmsResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Send SMS to multiple recipients
  /// 
  /// [recipients] - List of phone numbers
  /// [message] - SMS message content
  /// [senderId] - Optional custom sender ID
  static Future<SmsResult> sendBulkSms({
    required List<String> recipients,
    required String message,
    String? senderId,
  }) async {
    if (recipients.isEmpty) {
      return SmsResult(
        success: false,
        message: 'No recipients provided',
      );
    }

    try {
      await _ensureLoaded();
      final apiKey = _apiKey ?? _defaultApiKey;
      final sid = senderId ?? _senderId ?? _defaultSenderId;

      if (apiKey.contains('YOUR_')) {
        return SmsResult(
          success: false,
          message:
              'SMS is not configured. Add your Mobiwave API key in Settings.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/sms/send'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'recipient': recipients.join(','),
          'sender_id': sid,
          'type': 'plain',
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        debugPrint('Bulk SMS sent successfully to ${recipients.length} recipients');
        return SmsResult(
          success: true,
          messageId: data['data']?['id']?.toString(),
          message: 'SMS sent to ${recipients.length} recipients',
        );
      } else {
        debugPrint('Bulk SMS failed: ${data['message'] ?? 'Unknown error'}');
        return SmsResult(
          success: false,
          message: data['message'] ?? 'Failed to send bulk SMS',
        );
      }
    } catch (e) {
      debugPrint('Bulk SMS error: $e');
      return SmsResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Send SMS campaign to contact lists
  /// 
  /// [contactListIds] - List of contact list IDs
  /// [message] - SMS message content
  /// [senderId] - Optional custom sender ID
  static Future<SmsResult> sendCampaign({
    required List<String> contactListIds,
    required String message,
    String? senderId,
  }) async {
    if (contactListIds.isEmpty) {
      return SmsResult(
        success: false,
        message: 'No contact lists provided',
      );
    }

    try {
      await _ensureLoaded();
      final apiKey = _apiKey ?? _defaultApiKey;
      final sid = senderId ?? _senderId ?? _defaultSenderId;

      if (apiKey.contains('YOUR_')) {
        return SmsResult(
          success: false,
          message:
              'SMS is not configured. Add your Mobiwave API key in Settings.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/sms/campaign'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'contact_list_id': contactListIds.join(','),
          'sender_id': sid,
          'type': 'plain',
          'message': message,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        debugPrint('Campaign sent successfully to ${contactListIds.length} lists');
        return SmsResult(
          success: true,
          messageId: data['data']?['id']?.toString(),
          message: 'Campaign sent successfully',
        );
      } else {
        debugPrint('Campaign failed: ${data['message'] ?? 'Unknown error'}');
        return SmsResult(
          success: false,
          message: data['message'] ?? 'Failed to send campaign',
        );
      }
    } catch (e) {
      debugPrint('Campaign error: $e');
      return SmsResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Schedule SMS for later delivery
  /// 
  /// [recipient] - Phone number
  /// [message] - SMS message content
  /// [scheduleTime] - DateTime when SMS should be sent
  /// [senderId] - Optional custom sender ID
  static Future<SmsResult> scheduleSms({
    required String recipient,
    required String message,
    required DateTime scheduleTime,
    String? senderId,
  }) async {
    try {
      await _ensureLoaded();
      final apiKey = _apiKey ?? _defaultApiKey;
      final sid = senderId ?? _senderId ?? _defaultSenderId;

      if (apiKey.contains('YOUR_')) {
        return SmsResult(
          success: false,
          message:
              'SMS is not configured. Add your Mobiwave API key in Settings.',
        );
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/sms/send'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'recipient': recipient,
          'sender_id': sid,
          'type': 'plain',
          'message': message,
          'schedule_time': _formatDateTime(scheduleTime),
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        debugPrint('SMS scheduled for ${scheduleTime.toString()}');
        return SmsResult(
          success: true,
          messageId: data['data']?['id']?.toString(),
          message: 'SMS scheduled successfully',
        );
      } else {
        debugPrint('Schedule SMS failed: ${data['message'] ?? 'Unknown error'}');
        return SmsResult(
          success: false,
          message: data['message'] ?? 'Failed to schedule SMS',
        );
      }
    } catch (e) {
      debugPrint('Schedule SMS error: $e');
      return SmsResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Get SMS status by message ID
  static Future<SmsStatusResult> getSmsStatus(String messageId) async {
    try {
      await _ensureLoaded();
      final apiKey = _apiKey ?? _defaultApiKey;
      if (apiKey.contains('YOUR_')) {
        return SmsStatusResult(
          success: false,
          status: 'error',
          message: 'SMS is not configured. Add your Mobiwave API key in Settings.',
        );
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/sms/$messageId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['status'] == 'success') {
        return SmsStatusResult(
          success: true,
          status: data['data']?['status'] ?? 'unknown',
          deliveredAt: data['data']?['delivered_at'],
          message: data['data'],
        );
      } else {
        return SmsStatusResult(
          success: false,
          status: 'error',
          message: data['message'] ?? 'Failed to get status',
        );
      }
    } catch (e) {
      return SmsStatusResult(
        success: false,
        status: 'error',
        message: 'Network error: $e',
      );
    }
  }

  /// Format DateTime to RFC3339 format for API
  static String _formatDateTime(DateTime dt) {
    // Format: Y-m-d H:i (e.g., 2024-01-15 14:30)
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Update API credentials
  static void updateCredentials({
    String? apiKey,
    String? senderId,
  }) {
    // Kept for backward compatibility; prefer saveCredentials().
    if (apiKey != null && apiKey.isNotEmpty) _apiKey = apiKey;
    if (senderId != null && senderId.isNotEmpty) _senderId = senderId;
  }

  static Future<void> saveCredentials({
    required String apiKey,
    required String senderId,
  }) async {
    final sid = senderId.trim();
    if (sid.isNotEmpty && sid.length > 11) {
      throw Exception('Sender ID too long (max 11 characters)');
    }

    _apiKey = apiKey.trim();
    _senderId = sid.isEmpty ? _defaultSenderId : sid;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiKeyPref, _apiKey!);
    await prefs.setString(_kSenderIdPref, _senderId!);
  }
}

/// SMS Result object
class SmsResult {
  final bool success;
  final String? messageId;
  final String message;

  SmsResult({
    required this.success,
    this.messageId,
    required this.message,
  });
}

/// SMS Status Result object
class SmsStatusResult {
  final bool success;
  final String status;
  final String? deliveredAt;
  final dynamic message;

  SmsStatusResult({
    required this.success,
    required this.status,
    this.deliveredAt,
    this.message,
  });
}

/// SMS Templates for common use cases
class SmsTemplates {
  /// Contribution received notification
  static String contributionReceived({
    required String memberName,
    required double amount,
    required DateTime date,
  }) {
    return 'Dear $memberName, we have received your contribution of KES ${amount.toStringAsFixed(2)} on ${_formatDate(date)}. Thank you! - Mobifund';
  }

  /// Expense notification
  static String expenseNotification({
    required String expenseType,
    required double amount,
    required DateTime date,
  }) {
    return 'Expense Alert: KES ${amount.toStringAsFixed(2)} spent on $expenseType on ${_formatDate(date)}. Current balance updated. - Mobifund';
  }

  /// Loan approval notification
  static String loanApproved({
    required String memberName,
    required double amount,
    required DateTime dueDate,
  }) {
    return 'Dear $memberName, your loan of KES ${amount.toStringAsFixed(2)} has been approved. Due date: ${_formatDate(dueDate)}. Please repay on time. - Mobifund';
  }

  /// Merry-Go-Round payout notification
  static String merryGoRoundPayout({
    required String memberName,
    required double amount,
    required int cycle,
  }) {
    return 'Dear $memberName, you have received KES ${amount.toStringAsFixed(2)} from Merry-Go-Round cycle $cycle. Thank you for your participation! - Mobifund';
  }

  /// Meeting reminder
  static String meetingReminder({
    required String meetingType,
    required DateTime dateTime,
    required String location,
  }) {
    return 'Reminder: $meetingType meeting on ${_formatDate(dateTime)} at ${_formatTime(dateTime)} at $location. Your attendance is important. - Mobifund';
  }

  /// Payment received (M-Pesa)
  static String paymentReceived({
    required String memberName,
    required double amount,
    required String mpesaCode,
  }) {
    return 'Dear $memberName, payment of KES ${amount.toStringAsFixed(2)} received. M-Pesa code: $mpesaCode. Thank you! - Mobifund';
  }

  /// Welfare contribution
  static String welfareContribution({
    required String memberName,
    required double amount,
    required String beneficiary,
  }) {
    return 'Dear $memberName, your welfare contribution of KES ${amount.toStringAsFixed(2)} for $beneficiary has been recorded. Thank you for supporting a member in need. - Mobifund';
  }

  /// Low balance alert
  static String lowBalanceAlert({
    required double balance,
    required double threshold,
  }) {
    return 'Alert: Group balance is KES ${balance.toStringAsFixed(2)}, below threshold of KES ${threshold.toStringAsFixed(2)}. Please review finances. - Mobifund';
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}
