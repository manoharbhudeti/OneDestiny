import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Default backend base URL.
  /// For Android emulator, localhost is 10.0.2.2.
  /// For iOS simulator, web, or desktop, localhost is 127.0.0.1 / localhost.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5005';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5005';
      }
    } catch (_) {}
    return 'http://localhost:5005';
  }

  static String _baseUrl = defaultBaseUrl;
  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    _baseUrl = trimmed;
  }

  // Auth endpoints
  static String get phoneSendOtp => '$_baseUrl/api/auth/phone/send-otp';
  static String get phoneVerifyOtp => '$_baseUrl/api/auth/phone/verify-otp';
  static String get login => '$_baseUrl/api/auth/login';
  static String get signup => '$_baseUrl/api/auth/signup';
  static String get verifyEmail => '$_baseUrl/api/auth/verify-email';
  static String get changePassword => '$_baseUrl/api/auth/change-password';
  static String get sessions => '$_baseUrl/api/auth/sessions';

  // Categories
  static String get categories => '$_baseUrl/api/categories';
  static String categoryById(int id) => '$_baseUrl/api/categories/$id';

  // Client / Vendors
  static String get clientVendors => '$_baseUrl/api/client/vendors';
  static String clientVendorProfile(int id) => '$_baseUrl/api/client/vendors/$id';
  static String clientVendorServices(int id) => '$_baseUrl/api/client/vendors/$id/services';
  static String clientVendorPortfolio(int id) => '$_baseUrl/api/client/vendors/$id/portfolio';
  static String clientVendorReviews(int id) => '$_baseUrl/api/client/vendors/$id/reviews';
  static String clientVendorInquire(int id) => '$_baseUrl/api/client/vendors/$id/inquire';
  static String clientVendorBook(int id) => '$_baseUrl/api/client/vendors/$id/book';
  static String clientVendorReview(int id) => '$_baseUrl/api/client/vendors/$id/review';

  // Client Bookings
  static String get clientBookings => '$_baseUrl/api/client/bookings';
  static String clientBookingDetail(int id) => '$_baseUrl/api/client/bookings/$id';
  static String clientBookingCancel(int id) => '$_baseUrl/api/client/bookings/$id/cancel';
  static String clientBookingCreatePaymentOrder(int id) => '$_baseUrl/api/client/bookings/$id/create-payment-order';
  static String clientBookingVerifyPayment(int id) => '$_baseUrl/api/client/bookings/$id/verify-payment';

  // Chat
  static String get chatConversations => '$_baseUrl/api/chat/conversations';
  static String get chatMessages => '$_baseUrl/api/chat/messages';
  static String get chatSend => '$_baseUrl/api/chat/send';
  static String get chatRead => '$_baseUrl/api/chat/read';

  // Locations
  static String get states => '$_baseUrl/api/locations/states';
  static String get cities => '$_baseUrl/api/locations/cities';
  static String get areas => '$_baseUrl/api/locations/areas';

  // Account
  static String get accountProfile => '$_baseUrl/api/account/profile';
  static String get accountDeactivate => '$_baseUrl/api/account/deactivate';
  static String get accountDelete => '$_baseUrl/api/account';
}
