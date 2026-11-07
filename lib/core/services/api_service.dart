import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/api_response.dart';
import '../ui_states/utils/error_message_mapper.dart';
import '../ui_states/utils/network_state_handler.dart';
import 'auth_storage_service.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 12);
  static const Duration slowRequestThreshold = Duration(seconds: 4);

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await AuthStorageService.instance.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>({
    required String url,
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJsonT,
    bool requiresAuth = true,
  }) async {
    Timer? slowTimer;
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParams,
        });
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      debugPrint('[API GET] $uri');

      slowTimer = Timer(slowRequestThreshold, () {
        NetworkStateHandler.instance.setSlowNetwork(true);
      });

      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(true);
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API GET Timeout] $url');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail(
        'Connection timed out. Please check your internet connection.',
        'Request Timeout',
        408,
      );
    } on SocketException catch (e) {
      debugPrint('[API GET SocketException] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(false);
      return ApiResponse<T>.fail(
        'Unable to connect to server. Please check your connection.',
        'No Internet',
        0,
      );
    } catch (e) {
      debugPrint('[API GET Error] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail(
        ErrorMessageMapper.map(e),
        'Request Failed',
      );
    } finally {
      slowTimer?.cancel();
    }
  }

  Future<PagedResponse<T>> getPaged<T>({
    required String url,
    Map<String, String>? queryParams,
    required T Function(dynamic json) fromJsonItem,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...queryParams,
        });
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      debugPrint('[API GET Paged] $uri');

      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      debugPrint('[API GET Paged Response ${response.statusCode}] ${response.body}');
      NetworkStateHandler.instance.setConnectivity(true);

      if (response.statusCode == 401) {
        NetworkStateHandler.instance.notifySessionExpired();
        return const PagedResponse();
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return PagedResponse<T>.fromJson(decoded, fromJsonItem);
        }
      }
      return const PagedResponse();
    } on SocketException {
      NetworkStateHandler.instance.setConnectivity(false);
      return const PagedResponse();
    } catch (e) {
      debugPrint('[API GET Paged Error] $url: $e');
      return const PagedResponse();
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String url,
    dynamic body,
    T Function(dynamic json)? fromJsonT,
    bool requiresAuth = true,
  }) async {
    Timer? slowTimer;
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;

      debugPrint('[API POST] $uri | Body: $encodedBody');

      slowTimer = Timer(slowRequestThreshold, () {
        NetworkStateHandler.instance.setSlowNetwork(true);
      });

      final response = await _client
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(true);
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API POST Timeout] $url');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail(
        'Connection timed out. Please try again.',
        'Request Timeout',
        408,
      );
    } on SocketException catch (e) {
      debugPrint('[API POST SocketException] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(false);
      return ApiResponse<T>.fail(
        'Unable to connect to server. Please check your connection.',
        'No Internet',
        0,
      );
    } catch (e) {
      debugPrint('[API POST Error] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail(
        ErrorMessageMapper.map(e),
        'Request Failed',
      );
    } finally {
      slowTimer?.cancel();
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String url,
    dynamic body,
    T Function(dynamic json)? fromJsonT,
    bool requiresAuth = true,
  }) async {
    Timer? slowTimer;
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;

      debugPrint('[API PUT] $uri | Body: $encodedBody');

      slowTimer = Timer(slowRequestThreshold, () {
        NetworkStateHandler.instance.setSlowNetwork(true);
      });

      final response = await _client
          .put(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(true);
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API PUT Timeout] $url');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail('Connection timed out. Please try again.', 'Request Timeout', 408);
    } on SocketException catch (e) {
      debugPrint('[API PUT SocketException] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      NetworkStateHandler.instance.setConnectivity(false);
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.', 'No Internet', 0);
    } catch (e) {
      debugPrint('[API PUT Error] $url: $e');
      NetworkStateHandler.instance.setSlowNetwork(false);
      return ApiResponse<T>.fail(ErrorMessageMapper.map(e), 'Request Failed');
    } finally {
      slowTimer?.cancel();
    }
  }

  Future<ApiResponse<T>> delete<T>({
    required String url,
    T Function(dynamic json)? fromJsonT,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      debugPrint('[API DELETE] $uri');

      final response = await _client.delete(uri, headers: headers).timeout(_timeout);
      NetworkStateHandler.instance.setConnectivity(true);
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API DELETE Timeout] $url');
      return ApiResponse<T>.fail('Connection timed out. Please try again.', 'Request Timeout', 408);
    } on SocketException catch (e) {
      debugPrint('[API DELETE SocketException] $url: $e');
      NetworkStateHandler.instance.setConnectivity(false);
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.', 'No Internet', 0);
    } catch (e) {
      debugPrint('[API DELETE Error] $url: $e');
      return ApiResponse<T>.fail(ErrorMessageMapper.map(e), 'Request Failed');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJsonT,
  ) {
    debugPrint('[API Response ${response.statusCode}] ${response.body}');

    // Intercept 401 Session Expiration centrally
    if (response.statusCode == 401) {
      NetworkStateHandler.instance.notifySessionExpired();
      return ApiResponse<T>.fail(
        'Your session has expired. Please sign in again.',
        'Session Expired',
        401,
      );
    }

    try {
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse<T>.ok(null as T, 'Success', response.statusCode);
        } else {
          return ApiResponse<T>.fail(
            ErrorMessageMapper.map(null, statusCode: response.statusCode),
            'Request Failed',
            response.statusCode,
          );
        }
      }

      final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('success') || decoded.containsKey('data')) {
          return ApiResponse<T>.fromJson(decoded, fromJsonT, statusCode: response.statusCode);
        } else {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            final parsed = fromJsonT != null ? fromJsonT(decoded) : decoded as T;
            return ApiResponse<T>.ok(parsed, 'Success', response.statusCode);
          } else {
            final msg = decoded['message']?.toString() ??
                decoded['title']?.toString() ??
                ErrorMessageMapper.map(null, statusCode: response.statusCode);
            return ApiResponse<T>.fail(msg, 'Request Failed', response.statusCode);
          }
        }
      } else if (decoded is List) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final parsed = fromJsonT != null ? fromJsonT(decoded) : decoded as T;
          return ApiResponse<T>.ok(parsed, 'Success', response.statusCode);
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.ok(decoded as T, 'Success', response.statusCode);
      }

      return ApiResponse<T>.fail(
        ErrorMessageMapper.map(null, statusCode: response.statusCode),
        'Request Failed',
        response.statusCode,
      );
    } catch (e) {
      debugPrint('[API Parse Error] $e');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.ok(null as T, 'Success', response.statusCode);
      }
      return ApiResponse<T>.fail(
        'Failed to process server response.',
        'Response Error',
        response.statusCode,
      );
    }
  }
}
