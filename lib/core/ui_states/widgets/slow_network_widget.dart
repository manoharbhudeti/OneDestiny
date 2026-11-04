import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 5 — Slow Network State Widget / Banner.
///
/// Informs the user when an operation is taking longer than expected without
/// alarming them, providing an optional safe Cancel action.
class SlowNetworkWidget extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onCancel;
  final bool isBanner;

  const SlowNetworkWidget({
    super.key,
    this.title = 'Taking a little longer...',
    this.description =
        "Your connection seems slow. We're still working on loading your celebration details.",
    this.onCancel,
    this.isBanner = false,
  });

  /// Banner presentation for embedding at the top or bottom of a screen.
  factory SlowNetworkWidget.banner({
    VoidCallback? onCancel,
    String? message,
  }) =>
      SlowNetworkWidget(
        isBanner: true,
        description: message ??
            "Network is taking longer than expected. Still retrieving details...",
        onCancel: onCancel,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isBanner) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF261D10) : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFF92400E),
                ),
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onCancel,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.accentGoldLight
                          : AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiStateStyle.defaultHorizontalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withValues(alpha: isDark ? 0.18 : 0.10),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  width: 1.4,
                ),
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 34,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.accentGold,
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onCancel,
                style: UiStateStyle.secondaryButtonStyle(context),
                child: const Text('Cancel Request'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

