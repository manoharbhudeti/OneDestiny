import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../network/api_response.dart';
import 'api_service.dart';
import 'auth_storage_service.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

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
