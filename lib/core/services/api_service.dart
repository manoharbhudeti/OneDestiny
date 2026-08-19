import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../network/api_response.dart';
import 'auth_storage_service.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();
  static const Duration _timeout = Duration(seconds: 10);

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await AuthStorageService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>({
    required String url,
    Map<String, String>? queryParams,
    T Function(dynamic json)? fromJsonT,
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
      debugPrint('[API GET] $uri');

      final response = await _client.get(uri, headers: headers).timeout(_timeout);
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API GET Timeout] $url');
      return ApiResponse<T>.fail('Connection timed out. Please try again.');
    } on SocketException catch (e) {
      debugPrint('[API GET SocketException] $url: $e');
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.');
    } catch (e) {
      debugPrint('[API GET Error] $url: $e');
      return ApiResponse<T>.fail('An error occurred: $e');
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
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return PagedResponse<T>.fromJson(decoded, fromJsonItem);
        }
      }
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
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;

      debugPrint('[API POST] $uri | Body: $encodedBody');

      final response = await _client
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API POST Timeout] $url');
      return ApiResponse<T>.fail('Connection timed out. Please try again.');
    } on SocketException catch (e) {
      debugPrint('[API POST SocketException] $url: $e');
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.');
    } catch (e) {
      debugPrint('[API POST Error] $url: $e');
      return ApiResponse<T>.fail('An error occurred: $e');
    }
  }

  Future<ApiResponse<T>> put<T>({
    required String url,
    dynamic body,
    T Function(dynamic json)? fromJsonT,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url);
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;

      debugPrint('[API PUT] $uri | Body: $encodedBody');

      final response = await _client
          .put(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API PUT Timeout] $url');
      return ApiResponse<T>.fail('Connection timed out. Please try again.');
    } on SocketException catch (e) {
      debugPrint('[API PUT SocketException] $url: $e');
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.');
    } catch (e) {
      debugPrint('[API PUT Error] $url: $e');
      return ApiResponse<T>.fail('An error occurred: $e');
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
      return _handleResponse<T>(response, fromJsonT);
    } on TimeoutException {
      debugPrint('[API DELETE Timeout] $url');
      return ApiResponse<T>.fail('Connection timed out. Please try again.');
    } on SocketException catch (e) {
      debugPrint('[API DELETE SocketException] $url: $e');
      return ApiResponse<T>.fail('Unable to connect to server. Please check your connection.');
    } catch (e) {
      debugPrint('[API DELETE Error] $url: $e');
      return ApiResponse<T>.fail('An error occurred: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? fromJsonT,
  ) {
    debugPrint('[API Response ${response.statusCode}] ${response.body}');

    try {
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return ApiResponse<T>.ok(null as T, 'Success');
        } else {
          return ApiResponse<T>.fail('Request failed with status: ${response.statusCode}');
        }
      }

      final dynamic decoded = json.decode(utf8.decode(response.bodyBytes));

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('success') || decoded.containsKey('data')) {
          return ApiResponse<T>.fromJson(decoded, fromJsonT);
        } else {
          if (response.statusCode >= 200 && response.statusCode < 300) {
            final parsed = fromJsonT != null ? fromJsonT(decoded) : decoded as T;
            return ApiResponse<T>.ok(parsed);
          } else {
            final msg = decoded['message']?.toString() ??
                decoded['title']?.toString() ??
                'Request failed (${response.statusCode})';
            return ApiResponse<T>.fail(msg);
          }
        }
      } else if (decoded is List) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final parsed = fromJsonT != null ? fromJsonT(decoded) : decoded as T;
          return ApiResponse<T>.ok(parsed);
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.ok(decoded as T);
      }

      return ApiResponse<T>.fail('Request failed (${response.statusCode})');
    } catch (e) {
      debugPrint('[API Parse Error] $e');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse<T>.ok(null as T);
      }
      return ApiResponse<T>.fail('Failed to process server response.');
    }
  }
}
