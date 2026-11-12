import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../firebase_options.dart';
import 'auth_service.dart';
import 'auth_storage_service.dart';

class FcmPush {
  final String type;
  final Map<String, String> data;
  final bool opened;
  final String? title;
  final String? body;

  const FcmPush({
    required this.type,
    required this.data,
    required this.opened,
    this.title,
    this.body,
  });
}

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

  static const _alertsChannel = MethodChannel('onedestiny/notifications');

  final StreamController<FcmPush> _events = StreamController<FcmPush>.broadcast();
  final List<FcmPush> _buffer = [];

  bool _isInitialized = false;

  Stream<FcmPush> get events => _events.stream;

  /// Subscribes and replays pushes that arrived before the UI was listening.
  StreamSubscription<FcmPush> listen(void Function(FcmPush event) onData) {
    final subscription = _events.stream.listen(onData);
    final pending = List<FcmPush>.of(_buffer);
    _buffer.clear();
    for (final event in pending) {
      onData(event);
    }
    return subscription;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        }
      } catch (e) {
        debugPrint('[FCM] Firebase already initialized or error: $e');
      }

      if (Firebase.apps.isEmpty) {
        debugPrint('[FCM UserApp] Firebase not initialized. Skipping FCM setup.');
        return;
      }

      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

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

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final push = _fromMessage(message, opened: false);
        debugPrint('[FCM Foreground UserApp] ${push.type} | ${push.title}');
        _emit(push);
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          unawaited(_showAndroidAlert(push.title, push.body));
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final push = _fromMessage(message, opened: true);
        debugPrint('[FCM App Opened UserApp] ${push.data}');
        _emit(push);
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _emit(_fromMessage(initial, opened: true));
      }

      messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('[FCM Token Refreshed UserApp] $newToken');
        await _uploadToken(newToken);
      });

      _isInitialized = true;
      final token = await messaging.getToken();
      debugPrint('[FCM UserApp] Current Token: $token');
      if (token != null && token.isNotEmpty) {
        await _uploadToken(token);
      }
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

  FcmPush _fromMessage(RemoteMessage message, {required bool opened}) {
    final data = message.data.map((key, value) => MapEntry(key, value.toString()));
    final type = (data['type'] ?? data['Type'] ?? '').toLowerCase();
    return FcmPush(
      type: type.isEmpty ? 'general' : type,
      data: data,
      opened: opened,
      title: message.notification?.title ?? data['title'] ?? data['senderName'],
      body: message.notification?.body ?? data['body'],
    );
  }

  void _emit(FcmPush event) {
    if (!_events.hasListener) {
      _buffer.add(event);
      return;
    }
    _events.add(event);
  }

  Future<void> _uploadToken(String token) async {
    final authToken = await AuthStorageService.instance.getToken();
    if (authToken == null || authToken.isEmpty) return;
    await AuthService.instance.updateFcmToken(token);
  }

  Future<void> _showAndroidAlert(String? title, String? body) async {
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) return;
    try {
      await _alertsChannel.invokeMethod('show', {
        'title': title ?? 'OneDestiny',
        'body': body ?? '',
      });
    } catch (e) {
      debugPrint('[FCM UserApp] Foreground alert failed: $e');
    }
  }
}
