import 'dart:async';
import 'dart:io';

/// Sanitizes exceptions, HTTP status codes, and server errors into clean,
/// human-readable messages without exposing stack traces or internals.
class ErrorMessageMapper {
  ErrorMessageMapper._();

  /// Converts any error object into a user-facing explanation.
  static String map(dynamic error, {int? statusCode}) {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return 'The request could not be processed. Please check your information.';
        case 401:
          return 'Your session has expired. Please log in again to continue.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'The requested resource or vendor was not found.';
        case 408:
          return 'The connection timed out while contacting the server.';
        case 409:
          return 'This operation conflicts with an existing record. Please review and try again.';
        case 422:
          return 'Some of the provided details are invalid. Please check your input.';
        case 429:
          return 'Too many requests. Please wait a moment before trying again.';
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Our servers are momentarily unavailable. Our engineering team has been alerted.';
      }
    }

    if (error == null) {
      return 'An unexpected issue occurred. Please try again.';
    }

    if (error is TimeoutException) {
      return 'The connection timed out. Please check your internet connection.';
    }

    if (error is SocketException) {
      return 'Unable to reach the server. Please verify your connection.';
    }

    if (error is FormatException) {
      return 'Received an unexpected response format from the server.';
    }

    final raw = error.toString().trim();

    // Strip common exception prefixes if present
    var sanitized = raw
        .replaceAll(RegExp(r'^Exception:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^Error:\s*', caseSensitive: false), '');

    // Never leak technical stack traces, database schema, or SQL errors
    if (sanitized.contains('SqlException') ||
        sanitized.contains('Postgre') ||
        sanitized.contains('ORA-') ||
        sanitized.contains('SELECT ') ||
        sanitized.contains('INSERT ') ||
        sanitized.contains('stack trace') ||
        sanitized.contains('NullPointerException') ||
        sanitized.contains('Unhandled Exception')) {
      return 'A system error occurred. Please try again later.';
    }

    if (sanitized.isEmpty) {
      return 'An unexpected error occurred. Please try again.';
    }

    return sanitized;
  }
}
