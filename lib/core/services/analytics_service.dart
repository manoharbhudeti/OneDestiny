import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Centralized service to manage Google Analytics tracking via Firebase Analytics.
/// This enables event tracking, user properties, and conversion tracking for Google Ads.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  /// Safe getter for FirebaseAnalytics instance, avoiding exceptions when Firebase is not initialized (e.g., during tests).
  FirebaseAnalytics? get _analytics {
    if (Firebase.apps.isEmpty) {
      return null;
    }
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('[AnalyticsService] FirebaseAnalytics unavailable: $e');
      return null;
    }
  }

  /// Route observer to automatically log screen views when navigation occurs.
  NavigatorObserver? get observer {
    final analytics = _analytics;
    if (analytics == null) return null;
    return FirebaseAnalyticsObserver(analytics: analytics);
  }

  /// Initialize Google Analytics settings and record the app open event.
  Future<void> initialize() async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setAnalyticsCollectionEnabled(true);
      await analytics.logAppOpen();
      debugPrint('[AnalyticsService] Google Analytics initialized successfully.');
    } catch (e) {
      debugPrint('[AnalyticsService] Error initializing analytics: $e');
    }
  }

  /// Sets the unique user identifier in Google Analytics.
  Future<void> setUserId(String? userId) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserId(id: userId);
      debugPrint('[AnalyticsService] User ID set: $userId');
    } catch (e) {
      debugPrint('[AnalyticsService] Error setting user ID: $e');
    }
  }

  /// Sets a custom user property (e.g., user role, customer tier).
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('[AnalyticsService] Error setting user property $name: $e');
    }
  }

  /// Track when a user logs in. Highly valuable for Google Ads conversion tracking.
  Future<void> logLogin({String loginMethod = 'phone_otp'}) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logLogin(loginMethod: loginMethod);
      debugPrint('[AnalyticsService] Logged login with method: $loginMethod');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging login: $e');
    }
  }

  /// Track when a new user signs up. Highly valuable for Google Ads conversion tracking.
  Future<void> logSignUp({String signUpMethod = 'phone_otp'}) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logSignUp(signUpMethod: signUpMethod);
      debugPrint('[AnalyticsService] Logged sign up with method: $signUpMethod');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging sign up: $e');
    }
  }

  /// Track manual screen views.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('[AnalyticsService] Logged screen view: $screenName');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging screen view: $e');
    }
  }

  /// Track search queries entered by the user.
  Future<void> logSearch({required String searchTerm}) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logSearch(searchTerm: searchTerm);
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging search: $e');
    }
  }

  /// Track when a user views a service or vendor detail page.
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    String? itemCategory,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
          ),
        ],
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging view item: $e');
    }
  }

  /// Track when a user selects a service or category.
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging select content: $e');
    }
  }

  /// Track when a user initiates a booking checkout.
  Future<void> logBookingInitiated({
    required String serviceId,
    required String serviceName,
    double? price,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logEvent(
        name: 'begin_checkout',
        parameters: {
          'item_id': serviceId,
          'item_name': serviceName,
          if (price != null) 'value': price,
          if (price != null) 'currency': 'INR',
        },
      );
      debugPrint('[AnalyticsService] Logged begin_checkout for $serviceName');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging booking initiation: $e');
    }
  }

  /// Track when a booking is confirmed and paid. Primary conversion event for Google Ads.
  Future<void> logBookingCompleted({
    required String bookingId,
    required String serviceName,
    double? amount,
    String currency = 'INR',
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logPurchase(
        transactionId: bookingId,
        value: amount,
        currency: currency,
        items: [
          AnalyticsEventItem(
            itemId: bookingId,
            itemName: serviceName,
            price: amount,
          ),
        ],
      );
      // Also log explicit custom conversion event
      await analytics.logEvent(
        name: 'booking_completed',
        parameters: {
          'booking_id': bookingId,
          'service_name': serviceName,
          if (amount != null) 'value': amount,
          'currency': currency,
        },
      );
      debugPrint('[AnalyticsService] Logged booking_completed for $bookingId');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging booking completed: $e');
    }
  }

  /// Track any custom event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    final analytics = _analytics;
    if (analytics == null) return;

    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('[AnalyticsService] Logged event: $name');
    } catch (e) {
      debugPrint('[AnalyticsService] Error logging event $name: $e');
    }
  }
}
