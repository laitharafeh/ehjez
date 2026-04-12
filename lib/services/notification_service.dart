import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Top-level handler required by Firebase for background messages.
// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  // Firebase is already initialized at this point.
  // No UI work here — the system will show the notification automatically.
  debugPrint('[FCM background] ${message.notification?.title}');
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _supabase = Supabase.instance.client;

  // Local notifications plugin — used to show FCM messages while app is open.
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'ehjez_strikes',
    'Strike Warnings',
    description: 'Notifications about no-show strikes on your account.',
    importance: Importance.high,
  );

  /// Call once from main() after Firebase.initializeApp().
  static Future<void> initialize() async {
    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Request permission (required on iOS; harmless on Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // Show FCM notifications as banners when the app is in the foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle taps on notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  /// Call this after the user has authenticated to register the FCM token.
  /// Safe to call multiple times — uses upsert.
  static Future<void> registerToken() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final phone = user.phone;
      if (phone == null || phone.isEmpty) return;

      // On iOS, the APNs token may not be ready immediately after launch.
      // Wait for it before asking FCM for its token.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 2));
        }
        if (apnsToken == null) {
          debugPrint('[FCM] APNs token unavailable after retries — skipping token registration');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token == null) return;

      await _upsertToken(phone, token);

      // Keep the token fresh if Firebase rotates it
      _messaging.onTokenRefresh.listen((newToken) => _upsertToken(phone, newToken));

      debugPrint('[FCM] Token registered for $phone');
    } catch (e) {
      // Never crash the app over notification setup
      debugPrint('[FCM] registerToken error: $e');
    }
  }

  static Future<void> _upsertToken(String phone, String token) async {
    await _supabase.from('device_tokens').upsert({
      'phone': phone,
      'token': token,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
