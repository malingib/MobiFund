import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// M-Pesa Daraja API Service
///
/// Production-ready approach:
/// - STK initiation happens server-side (Supabase Edge Function) to keep secrets off-device.
/// - Callback updates are handled by another Edge Function (`mpesa-callback`).
class MpesaService {
  /// Initiate STK Push
  ///
  /// [phoneNumber] - Customer phone number (254XXXXXXXXX)
  /// [amount] - Amount to charge
  /// [accountReference] - Account reference (e.g., member ID)
  /// [transactionDesc] - Transaction description
  /// [orgId] - Organization to attribute transaction to
  /// [memberId] - Optional member id to pre-link
  static Future<MpesaResult> stkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
    required String orgId,
    String? memberId,
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'mpesa-stk-push',
        body: {
          'org_id': orgId,
          'member_id': memberId,
          'phone': phoneNumber,
          'amount': amount,
          'account_reference': accountReference,
          'transaction_desc': transactionDesc,
        },
      );

      final data = res.data as Map?;
      if (res.status == 200 && data != null && data['success'] == true) {
        debugPrint('M-Pesa STK Push initiated: ${data['checkoutRequestId']}');
        return MpesaResult(
          success: true,
          checkoutRequestId: data['checkoutRequestId']?.toString(),
          merchantRequestId: data['merchantRequestId']?.toString(),
          message: data['message']?.toString() ??
              'STK Push sent. Please enter PIN on your phone.',
        );
      } else {
        debugPrint('M-Pesa STK Push failed: ${res.data}');
        return MpesaResult(
          success: false,
          message: (data?['error']?.toString()) ??
              (data?['message']?.toString()) ??
              'STK Push failed',
        );
      }
    } catch (e) {
      debugPrint('M-Pesa STK Push error: $e');
      return MpesaResult(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  /// Normalize phone number to M-Pesa format (254XXXXXXXXX)
  static String normalizePhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'[\s\-\+]'), '');
    
    if (clean.startsWith('254') && clean.length == 12) {
      return clean;
    } else if (clean.startsWith('0') && clean.length == 10) {
      return '254${clean.substring(1)}';
    } else if (clean.length == 9) {
      return '254$clean';
    }
    
    return clean;
  }
}

/// M-Pesa transaction result
class MpesaResult {
  final bool success;
  final String? checkoutRequestId;
  final String? merchantRequestId;
  final String message;

  MpesaResult({
    required this.success,
    this.checkoutRequestId,
    this.merchantRequestId,
    required this.message,
  });
}

/// M-Pesa status query result
class MpesaStatusResult {
  final bool success;
  final String status;
  final String message;
  final double? amount;
  final String? mpesaReceiptNumber;
  final String? transactionDate;
  final String? phoneNumber;

  MpesaStatusResult({
    required this.success,
    required this.status,
    required this.message,
    this.amount,
    this.mpesaReceiptNumber,
    this.transactionDate,
    this.phoneNumber,
  });
}
