import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import '../config/api_config.dart';
import '../network/api_response.dart';
import 'api_service.dart';
import 'auth_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String msg91WidgetId = '36656f6b4e79333236353235';
  static const String msg91AuthToken = '466881TQOgsU8Xoj6a927f7aP1';

  void initMsg91Widget({String? widgetId, String? authToken}) {
    OTPWidget.initializeWidget(
      widgetId ?? msg91WidgetId,
      authToken ?? msg91AuthToken,
    );
  }

  String get _deviceOs {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isLinux) return 'Linux';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isWindows) return 'Windows';
    } catch (_) {}
    return 'Mobile';
  }

  /// Send OTP using MSG91 OTP Widget SDK
  Future<ApiResponse<String>> sendMsg91Otp(String phone) async {
    try {
      initMsg91Widget();
      var clean = phone.replaceAll(RegExp(r'[^\d]'), '');
      if (clean.length == 10) {
        clean = '91$clean';
      }

      final response = await OTPWidget.sendOTP({
        'identifier': clean,
      });

      if (response == null) {
        return ApiResponse<String>.fail('Empty response from MSG91 OTP service.');
      }

      final type = response['type']?.toString().toLowerCase();
      final status = response['status']?.toString().toLowerCase();
      final isSuccess = type == 'success' || status == 'success';

      if (isSuccess) {
        final reqId = response['reqId']?.toString() ??
            response['message']?.toString() ??
            response['data']?['reqId']?.toString() ??
            '';
        return ApiResponse<String>.ok(
          reqId,
          response['message']?.toString() ?? 'OTP sent successfully.',
        );
      }

      final errMsg = response['message']?.toString() ??
          response['errors']?.toString() ??
          'Failed to send OTP.';
      return ApiResponse<String>.fail(errMsg);
    } catch (e) {
      debugPrint('[MSG91 SendOTP Error] $e');
      return ApiResponse<String>.fail('Error sending OTP: $e');
    }
  }

  /// Verify OTP directly with MSG91 widget SDK and obtain the access token
  Future<ApiResponse<String>> verifyMsg91Otp({
    required String reqId,
    required String otp,
  }) async {
    try {
      initMsg91Widget();
      final response = await OTPWidget.verifyOTP({
        'reqId': reqId,
        'otp': otp,
      });

      if (response == null) {
        return ApiResponse<String>.fail('Empty response from MSG91 verification.');
      }

      final type = response['type']?.toString().toLowerCase();
      final status = response['status']?.toString().toLowerCase();
      final isSuccess = type == 'success' || status == 'success';

      if (isSuccess) {
        final accessToken = response['access-token']?.toString() ??
            response['accessToken']?.toString() ??
            response['token']?.toString() ??
            response['data']?['access-token']?.toString() ??
            response['message']?.toString() ??
            '';
        return ApiResponse<String>.ok(accessToken, 'OTP verified successfully.');
      }

      final errMsg = response['message']?.toString() ??
          response['errors']?.toString() ??
          'Invalid OTP code.';
      return ApiResponse<String>.fail(errMsg);
    } catch (e) {
      debugPrint('[MSG91 VerifyOTP Error] $e');
      return ApiResponse<String>.fail('Error verifying OTP: $e');
    }
  }

  /// Retry sending OTP using MSG91 widget SDK
  Future<ApiResponse<String>> retryMsg91Otp({
    required String reqId,
    int? retryChannel,
  }) async {
    try {
      initMsg91Widget();
      final body = <String, dynamic>{
        'reqId': reqId,
        if (retryChannel != null) 'retryChannel': retryChannel,
      };

      final response = await OTPWidget.retryOTP(body);
      if (response == null) {
        return ApiResponse<String>.fail('Empty response from MSG91 retry.');
      }

      final type = response['type']?.toString().toLowerCase();
      final status = response['status']?.toString().toLowerCase();
      final isSuccess = type == 'success' || status == 'success';

      if (isSuccess) {
        final msg = response['message']?.toString() ?? 'OTP resent successfully.';
        return ApiResponse<String>.ok(msg, msg);
      }

      final errMsg = response['message']?.toString() ??
          response['errors']?.toString() ??
          'Failed to resend OTP.';
      return ApiResponse<String>.fail(errMsg);
    } catch (e) {
      debugPrint('[MSG91 RetryOTP Error] $e');
      return ApiResponse<String>.fail('Error resending OTP: $e');
    }
  }

  /// Exchange verified MSG91 access token with OneDestiny backend for user session & JWT
  Future<ApiResponse<Map<String, dynamic>>> verifyMsg91TokenWithBackend(
    String accessToken, {
    bool createIfNotExists = true,
    String role = 'User',
  }) async {
    final res = await ApiService.instance.post<Map<String, dynamic>>(
      url: ApiConfig.verifyMsg91Token,
      body: {
        'accessToken': accessToken,
        'deviceName': 'OneDestiny Customer App',
        'deviceOs': _deviceOs,
        'createIfNotExists': createIfNotExists,
        'role': role,
      },
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      requiresAuth: false,
    );

    if (res.success && res.data != null) {
      await _saveAuthResponse(res.data!);
    }

    return res;
  }

  /// Full flow: Verify OTP with MSG91 and exchange token with backend
  Future<ApiResponse<Map<String, dynamic>>> loginWithMsg91Otp({
    required String reqId,
    required String otp,
    bool createIfNotExists = true,
  }) async {
    final verifyRes = await verifyMsg91Otp(reqId: reqId, otp: otp);
    if (!verifyRes.success || verifyRes.data == null || verifyRes.data!.isEmpty) {
      return ApiResponse<Map<String, dynamic>>.fail(
        verifyRes.errors.isNotEmpty
            ? verifyRes.errors.first
            : (verifyRes.message.isNotEmpty ? verifyRes.message : 'Invalid OTP code.'),
      );
    }

    return await verifyMsg91TokenWithBackend(
      verifyRes.data!,
      createIfNotExists: createIfNotExists,
    );
  }

  Future<ApiResponse<String>> sendPhoneOtp(String phone) async {
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    final res = await ApiService.instance.post<String>(
      url: ApiConfig.phoneSendOtp,
      body: {
        'phone': formattedPhone,
      },
      fromJsonT: (json) => json is String ? json : json['message']?.toString() ?? 'OTP sent',
      requiresAuth: false,
    );

    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPhoneOtp(String phone, String otp) async {
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    final res = await ApiService.instance.post<Map<String, dynamic>>(
      url: ApiConfig.phoneVerifyOtp,
      body: {
        'phone': formattedPhone,
        'otp': otp,
        'deviceName': 'Flutter Client',
        'deviceOs': _deviceOs,
      },
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      requiresAuth: false,
    );

    if (res.success && res.data != null) {
      await _saveAuthResponse(res.data!);
    }

    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiService.instance.post<Map<String, dynamic>>(
      url: ApiConfig.login,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'deviceName': 'Flutter Client',
        'deviceOs': _deviceOs,
      },
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      requiresAuth: false,
    );

    if (res.success && res.data != null) {
      await _saveAuthResponse(res.data!);
    }

    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    final res = await ApiService.instance.post<Map<String, dynamic>>(
      url: ApiConfig.signup,
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': formattedPhone,
        'password': password,
        'role': 'User',
      },
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      requiresAuth: false,
    );

    if (res.success && res.data != null) {
      final token = res.data!['accessToken']?.toString();
      if (token != null && token.isNotEmpty) {
        await _saveAuthResponse(res.data!);
      }
    }

    return res;
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final res = await ApiService.instance.post<Map<String, dynamic>>(
      url: ApiConfig.verifyEmail,
      body: {
        'email': email.trim().toLowerCase(),
        'otp': otp,
        'deviceName': 'Flutter Client',
        'deviceOs': _deviceOs,
      },
      fromJsonT: (json) => json is Map<String, dynamic> ? json : <String, dynamic>{},
      requiresAuth: false,
    );

    if (res.success && res.data != null) {
      await _saveAuthResponse(res.data!);
    }

    return res;
  }

  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await ApiService.instance.post<String>(
      url: ApiConfig.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      fromJsonT: (json) => json is String ? json : 'Password updated successfully.',
      requiresAuth: true,
    );
  }

  Future<void> logout() async {
    await AuthStorageService.instance.clearAuth();
  }

  Future<void> _saveAuthResponse(Map<String, dynamic> data) async {
    final token = data['accessToken']?.toString() ?? '';
    final user = data['user'] as Map<String, dynamic>? ?? {};

    final userId = user['id'] as int? ?? 0;
    final name = user['name']?.toString() ?? 'User';
    final email = user['email']?.toString() ?? '';
    final phone = user['phone']?.toString();
    final role = user['role']?.toString() ?? 'User';
    final avatarUrl = user['profileImageUrl']?.toString();

    if (token.isNotEmpty) {
      await AuthStorageService.instance.saveAuthData(
        token: token,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        role: role,
        avatarUrl: avatarUrl,
      );
    }
  }
}
