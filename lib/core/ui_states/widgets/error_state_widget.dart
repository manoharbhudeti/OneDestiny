import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';
import '../utils/error_message_mapper.dart';

/// State 3 — Reusable Error State Widget.
///
/// Communicates failed operations cleanly and safely, without exposing
/// raw exceptions, SQL statements, or stack traces.
class ErrorStateWidget extends StatefulWidget {
  final String? title;
  final dynamic error;
  final int? statusCode;
  final String? customMessage;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;
  final EdgeInsetsGeometry padding;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.error,
    this.statusCode,
    this.customMessage,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.onSecondaryAction,
    this.secondaryActionLabel = 'Go Back',
    this.padding = const EdgeInsets.symmetric(
      horizontal: UiStateStyle.defaultHorizontalPadding,
      vertical: UiStateStyle.defaultVerticalPadding,
    ),
  });

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isRetrying) return;
    setState(() => _isRetrying = true);
    try {
      widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sanitizedMessage = widget.customMessage ??
        ErrorMessageMapper.map(widget.error, statusCode: widget.statusCode);

    final effectiveTitle = widget.title ??
        (widget.statusCode == 403
            ? 'Access Restricted'
            : widget.statusCode != null && widget.statusCode! >= 500
                ? 'Server Temporarily Unavailable'
                : 'Oops! Something Went Wrong');

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Indicator
            Container(
              width: UiStateStyle.iconContainerSize,
              height: UiStateStyle.iconContainerSize,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: isDark ? 0.18 : 0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: isDark ? 0.4 : 0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: UiStateStyle.iconSize,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 20),

            // Headline
            Text(
              effectiveTitle,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context),
            ),

            const SizedBox(height: 8),

            // Description / Sanitized message
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                sanitizedMessage,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),

            if (widget.onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isRetrying ? null : _handleRetry,
                style: UiStateStyle.primaryButtonStyle(context),
                icon: _isRetrying
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(widget.retryLabel),
              ),
            ],

            if (widget.onSecondaryAction != null &&
                widget.secondaryActionLabel != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: widget.onSecondaryAction,
                style: UiStateStyle.secondaryButtonStyle(context),
                child: Text(widget.secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

