import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Push Notification Service Boilerplate
/// Uses Supabase backend to store device tokens to route messages.
/// 
/// Note: To fully run this, you must configure 'firebase_messaging' and OneSignal/Firebase
/// at the native Android/iOS app level (google-services.json / GoogleService-Info.plist).
class PushNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Call this when the user logs in or enables notifications
  Future<void> registerDeviceToken() async {
    try {
      if (kIsWeb) return; // Push tokens differ largely on web; usually service worker based.

      // 1. In a real environment, you'd request permission first:
      // final messaging = FirebaseMessaging.instance;
      // await messaging.requestPermission();
      
      // 2. Fetch the device token from APNS or FCM:
      // final token = await messaging.getToken();
      
      const dummyToken = "fcm-token-xyz-123"; 

      // 3. Store in Supabase against the currentUser
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_devices').upsert({
        'user_id': user.id,
        'fcm_token': dummyToken,
        'platform': defaultTargetPlatform.name,
        'last_active': DateTime.now().toIso8601String(),
      });
      
      debugPrint("📱 Device token securely registered.");
    } catch (e) {
      debugPrint("Push Notification Registration Error: $e");
    }
  }

  /// Remove device token on logout or user disabling logic
  Future<void> removeDeviceToken() async {
     try {
       final user = _supabase.auth.currentUser;
       if (user == null) return;

       await _supabase
           .from('user_devices')
           .delete()
           .eq('user_id', user.id);
       debugPrint("🔕 Device token removed.");
     } catch (e) {
        debugPrint("Push Notification Deletion Error: $e");
     }
  }

  /// Handle incoming foreground messages and parse routing
  void initializeListeners() {
    // Boilerplate for foreground processing using Firebase
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.notification != null) {
    //     debugPrint('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }
}
