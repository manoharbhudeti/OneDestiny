class ApiConfig {
  ApiConfig._();

  static const String defaultBaseUrl = 'https://api.onedestiny.org';

  static String _baseUrl = defaultBaseUrl;
  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    _baseUrl = trimmed;
  }

  // Legal
  static String get privacyPolicyUrl => '$_baseUrl/privacy-policy';
  static String get termsUrl => '$_baseUrl/terms';

  // Auth endpoints
  static String get phoneSendOtp => '$_baseUrl/api/auth/phone/send-otp';
  static String get phoneVerifyOtp => '$_baseUrl/api/auth/phone/verify-otp';
  static String get verifyMsg91Token => '$_baseUrl/api/auth/msg91/verify';
  static String get phoneFirebaseLogin =>
      '$_baseUrl/api/auth/phone/firebase-login';
  static String get login => '$_baseUrl/api/auth/login';
  static String get signup => '$_baseUrl/api/auth/signup';
  static String get verifyEmail => '$_baseUrl/api/auth/verify-email';
  static String get changePassword => '$_baseUrl/api/auth/change-password';
  static String get sessions => '$_baseUrl/api/auth/sessions';
  static String get logout => '$_baseUrl/api/auth/logout';
  static String get fcmToken => '$_baseUrl/api/auth/fcm-token';
  static String revokeSession(int id) => '$_baseUrl/api/auth/sessions/$id';
  static String get revokeAllSessions => '$_baseUrl/api/auth/sessions/revoke-all';

  // Lead Requests (Broadcast Requirement)
  static String get clientLeadRequests => '$_baseUrl/api/client/lead-requests';
  static String clientLeadRequestById(int id) => '$_baseUrl/api/client/lead-requests/$id';
  static String clientLeadRequestClose(int id) => '$_baseUrl/api/client/lead-requests/$id/close';

  // Quotations
  static String get clientQuotations => '$_baseUrl/api/client/quotations';
  static String clientQuotationById(int id) => '$_baseUrl/api/client/quotations/$id';
  static String clientQuotationAccept(int id) => '$_baseUrl/api/client/quotations/$id/accept';
  static String clientQuotationDecline(int id) => '$_baseUrl/api/client/quotations/$id/decline';

  // Categories
  static String get categories => '$_baseUrl/api/categories';
  static String categoryById(int id) => '$_baseUrl/api/categories/$id';

  // Client / Vendors
  static String get clientVendors => '$_baseUrl/api/client/vendors';
  static String clientVendorProfile(int id) =>
      '$_baseUrl/api/client/vendors/$id';
  static String clientVendorServices(int id) =>
      '$_baseUrl/api/client/vendors/$id/services';
  static String clientVendorPortfolio(int id) =>
      '$_baseUrl/api/client/vendors/$id/portfolio';
  static String clientVendorReviews(int id) =>
      '$_baseUrl/api/client/vendors/$id/reviews';
  static String clientVendorInquire(int id) =>
      '$_baseUrl/api/client/vendors/$id/inquire';
  static String clientVendorBook(int id) =>
      '$_baseUrl/api/client/vendors/$id/book';
  static String clientVendorReview(int id) =>
      '$_baseUrl/api/client/vendors/$id/review';

  // Client Bookings
  static String get clientBookings => '$_baseUrl/api/client/bookings';
  static String clientBookingDetail(int id) =>
      '$_baseUrl/api/client/bookings/$id';
  static String clientBookingCancel(int id) =>
      '$_baseUrl/api/client/bookings/$id/cancel';
  static String clientBookingCreatePaymentOrder(int id) =>
      '$_baseUrl/api/client/bookings/$id/create-payment-order';
  static String clientBookingVerifyPayment(int id) =>
      '$_baseUrl/api/client/bookings/$id/verify-payment';

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
