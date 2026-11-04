import 'package:flutter/foundation.dart';

/// Semantic UI State status enum covering all standard application states.
enum UiStatus {
  initial,
  loading,
  success,
  empty,
  error,
  noInternet,
  slowNetwork,
  noResults,
  permissionDenied,
  sessionExpired,
}

/// Generic, immutable UI state wrapper for reactive UI presentation.
@immutable
class UiState<T> {
  final UiStatus status;
  final T? data;
  final String? errorMessage;
  final String? errorTitle;
  final Object? errorDetails;
  final int? statusCode;

  const UiState._({
    required this.status,
    this.data,
    this.errorMessage,
    this.errorTitle,
    this.errorDetails,
    this.statusCode,
  });

  /// Factory for the initial state before any action is taken.
  factory UiState.initial([T? initialData]) => UiState._(
        status: UiStatus.initial,
        data: initialData,
      );

  /// Factory for active loading/processing state.
  factory UiState.loading([T? previousData]) => UiState._(
        status: UiStatus.loading,
        data: previousData,
      );

  /// Factory for successful completion with result data.
  factory UiState.success(T data) => UiState._(
        status: UiStatus.success,
        data: data,
      );

  /// Factory for an empty collection or no-content state.
  factory UiState.empty({String? message}) => UiState._(
        status: UiStatus.empty,
        errorMessage: message,
      );

  /// Factory for generic error state.
  factory UiState.error({
    required String message,
    String? title,
    Object? details,
    int? statusCode,
    T? previousData,
  }) =>
      UiState._(
        status: UiStatus.error,
        data: previousData,
        errorMessage: message,
        errorTitle: title,
        errorDetails: details,
        statusCode: statusCode,
      );

  /// Factory for disconnected internet state.
  factory UiState.noInternet({T? previousData}) => UiState._(
        status: UiStatus.noInternet,
        data: previousData,
        errorTitle: "You're Offline",
        errorMessage:
            'Please check your Wi-Fi or mobile data connection and try again.',
      );

  /// Factory for slow network / delayed request state.
  factory UiState.slowNetwork({T? previousData}) => UiState._(
        status: UiStatus.slowNetwork,
        data: previousData,
        errorTitle: 'Taking a Little Longer...',
        errorMessage:
            'Your network seems slow. We are still attempting to complete your request.',
      );

  /// Factory for successful queries that yielded zero results.
  factory UiState.noResults({String? query, T? previousData}) => UiState._(
        status: UiStatus.noResults,
        data: previousData,
        errorTitle: 'No Matching Results',
        errorMessage: query != null && query.isNotEmpty
            ? 'We couldn\'t find any results matching "$query".'
            : 'No matching items were found for your current filter criteria.',
      );

  /// Factory for denied or permanently denied device permissions.
  factory UiState.permissionDenied({
    required String permissionName,
    bool isPermanentlyDenied = false,
  }) =>
      UiState._(
        status: UiStatus.permissionDenied,
        errorTitle: '$permissionName Access Required',
        errorMessage: isPermanentlyDenied
            ? 'Access was permanently denied. Please enable it in system settings to use this feature.'
            : 'Please grant $permissionName permission to proceed with this action.',
      );

  /// Factory for authentication session expiration (HTTP 401).
  factory UiState.sessionExpired() => const UiState._(
        status: UiStatus.sessionExpired,
        errorTitle: 'Session Expired',
        errorMessage: 'For your security, please sign in again to continue.',
      );

  bool get isInitial => status == UiStatus.initial;
  bool get isLoading => status == UiStatus.loading;
  bool get isSuccess => status == UiStatus.success;
  bool get isEmpty => status == UiStatus.empty;
  bool get isError => status == UiStatus.error;
  bool get isNoInternet => status == UiStatus.noInternet;
  bool get isSlowNetwork => status == UiStatus.slowNetwork;
  bool get isNoResults => status == UiStatus.noResults;
  bool get isPermissionDenied => status == UiStatus.permissionDenied;
  bool get isSessionExpired => status == UiStatus.sessionExpired;

  bool get hasData => data != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiState<T> &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          data == other.data &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, data, errorMessage);
}

