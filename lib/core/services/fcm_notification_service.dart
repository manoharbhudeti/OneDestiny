import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';
import 'auth_service.dart';
import 'auth_storage_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  debugPrint('[FCM Background UserApp] Message received: ${message.messageId} | ${message.notification?.title}');
}

class FcmNotificationService {
  FcmNotificationService._();
  static final FcmNotificationService instance = FcmNotificationService._();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize Firebase if not already initialized
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      } catch (e) {
        debugPrint('[FCM] Firebase already initialized or error: $e');
      }

      // 2. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Request permissions
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM UserApp] Permission status: ${settings.authorizationStatus}');

      // 4. Set foreground notification presentation options
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 5. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM Foreground UserApp] Title: ${message.notification?.title}, Body: ${message.notification?.body}');
      });

      // 6. Handle notification click when app is in background/terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM App Opened UserApp] Data: ${message.data}');
      });

      // 7. Handle token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM Token Refreshed UserApp] $newToken');
        final token = await AuthStorageService.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await AuthService.instance.updateFcmToken(newToken);
        }
      });

      _isInitialized = true;
      debugPrint('[FCM UserApp] Initialized successfully.');
    } catch (e) {
      debugPrint('[FCM UserApp] Initialization failed: $e');
    }
  }

  /// Get active FCM token safely
  Future<String?> getToken() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM UserApp] Current Token: $token');
      return token;
    } catch (e) {
      debugPrint('[FCM UserApp] Error fetching token: $e');
      return null;
    }
  }

  /// Delete FCM token (e.g. on logout)
  Future<void> deleteToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('[FCM UserApp] Error deleting token: $e');
    }
  }
}
