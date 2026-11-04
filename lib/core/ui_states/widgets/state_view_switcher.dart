import 'package:flutter/material.dart';
import '../models/ui_state.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'no_internet_widget.dart';
import 'no_search_results_widget.dart';
import 'permission_denied_widget.dart';
import 'skeleton_shimmer.dart';
import 'slow_network_widget.dart';

/// Declarative switcher widget that consumes a [UiState] and builds the
/// appropriate UI state component, keeping business and view logic separated.
class StateViewSwitcher<T> extends StatelessWidget {
  final UiState<T> state;
  final Widget Function(BuildContext context, T data) onSuccess;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context)? onEmpty;
  final Widget Function(BuildContext context, String message, int? statusCode)?
      onError;
  final Widget Function(BuildContext context)? onNoInternet;
  final Widget Function(BuildContext context)? onSlowNetwork;
  final Widget Function(BuildContext context)? onNoResults;
  final Widget Function(BuildContext context)? onPermissionDenied;
  final VoidCallback? onRetry;
  final VoidCallback? onClearFilters;

  const StateViewSwitcher({
    super.key,
    required this.state,
    required this.onSuccess,
    this.onLoading,
    this.onEmpty,
    this.onError,
    this.onNoInternet,
    this.onSlowNetwork,
    this.onNoResults,
    this.onPermissionDenied,
    this.onRetry,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case UiStatus.initial:
      case UiStatus.loading:
        if (onLoading != null) return onLoading!(context);
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: SkeletonShimmer(
              child: SkeletonBlock(
                width: double.infinity,
                height: 180,
                borderRadius: 16,
              ),
            ),
          ),
        );

      case UiStatus.empty:
        if (onEmpty != null) return onEmpty!(context);
        return EmptyStateWidget(
          title: 'Nothing Here Yet',
          description: state.errorMessage ??
              'There is no information to display at this moment.',
          onPrimaryAction: onRetry,
          primaryActionLabel: onRetry != null ? 'Refresh' : null,
        );

      case UiStatus.noInternet:
        if (onNoInternet != null) return onNoInternet!(context);
        return NoInternetWidget(
          onRetry: onRetry,
          title: state.errorTitle ?? "You're Offline!",
          description: state.errorMessage ??
              'Please check your internet connection and try again.',
        );

      case UiStatus.slowNetwork:
        if (onSlowNetwork != null) return onSlowNetwork!(context);
        return SlowNetworkWidget(
          title: state.errorTitle ?? 'Taking a little longer...',
          description: state.errorMessage ??
              'Your connection seems slow. We are still attempting to load.',
          onCancel: onRetry,
        );

      case UiStatus.noResults:
        if (onNoResults != null) return onNoResults!(context);
        return NoSearchResultsWidget(
          title: state.errorTitle ?? 'No Matching Results',
          description: state.errorMessage ??
              'No items match your selected filters or keywords.',
          onClearFilters: onClearFilters,
        );

      case UiStatus.permissionDenied:
        if (onPermissionDenied != null) return onPermissionDenied!(context);
        return PermissionDeniedWidget(
          title: state.errorTitle ?? 'Permission Required',
          description: state.errorMessage ??
              'Please grant permission to proceed with this feature.',
          onRetryRequest: onRetry,
        );

      case UiStatus.error:
      case UiStatus.sessionExpired:
        if (onError != null) {
          return onError!(
            context,
            state.errorMessage ?? 'An error occurred.',
            state.statusCode,
          );
        }
        return ErrorStateWidget(
          title: state.errorTitle,
          customMessage: state.errorMessage,
          statusCode: state.statusCode,
          onRetry: onRetry,
        );

      case UiStatus.success:
        if (state.data != null) {
          return onSuccess(context, state.data as T);
        }
        if (onEmpty != null) return onEmpty!(context);
        return const SizedBox.shrink();
    }
  }
}

