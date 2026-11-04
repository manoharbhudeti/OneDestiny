import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 7 — Permission Denied State Widget.
///
/// Communicates required permissions with a rationale and provides
/// one-tap navigation to system app settings or graceful fallbacks.
class PermissionDeniedWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isPermanentlyDenied;
  final VoidCallback? onRetryRequest;
  final VoidCallback? onManualFallback;
  final String manualFallbackLabel;
  final VoidCallback? onDismiss;

  const PermissionDeniedWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.security_rounded,
    this.isPermanentlyDenied = false,
    this.onRetryRequest,
    this.onManualFallback,
    this.manualFallbackLabel = 'Select Manually',
    this.onDismiss,
  });

  /// Factory for Location permission denial (GPS vendor discovery).
  factory PermissionDeniedWidget.location({
    bool isPermanentlyDenied = false,
    VoidCallback? onRetryRequest,
    VoidCallback? onSelectCityManually,
    VoidCallback? onDismiss,
  }) =>
      PermissionDeniedWidget(
        title: 'Location Access Required',
        description: isPermanentlyDenied
            ? 'Location permissions are disabled in your system settings. Please enable them to discover event vendors near you, or choose your city manually.'
            : 'Allow location access to discover top wedding and celebration vendors nearest to your venue.',
        icon: Icons.location_off_rounded,
        isPermanentlyDenied: isPermanentlyDenied,
        onRetryRequest: onRetryRequest,
        onManualFallback: onSelectCityManually,
        manualFallbackLabel: 'Choose City Manually',
        onDismiss: onDismiss,
      );

  /// Factory for Photo Library / Camera permission denial.
  factory PermissionDeniedWidget.photos({
    bool isCamera = false,
    bool isPermanentlyDenied = false,
    VoidCallback? onDismiss,
  }) =>
      PermissionDeniedWidget(
        title: isCamera ? 'Camera Access Required' : 'Photos Access Required',
        description: isPermanentlyDenied
            ? 'Please grant photo access in device settings to upload review photos and update your profile.'
            : 'Access is needed to pick celebration portfolio images and upload verified review photos.',
        icon: isCamera ? Icons.camera_alt_outlined : Icons.photo_library_outlined,
        isPermanentlyDenied: isPermanentlyDenied,
        onDismiss: onDismiss,
      );

  /// Shows permission denial rationale as a modal bottom sheet.
  static Future<void> showSheet(
    BuildContext context, {
    required Widget child,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.25),
            ),
          ),
          child: child,
        );
      },
    );
  }

  Future<void> _openSettings() async {
    try {
      await openAppSettings();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: UiStateStyle.defaultHorizontalPadding,
          vertical: UiStateStyle.defaultVerticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Permission Icon
            Container(
              width: UiStateStyle.iconContainerSize,
              height: UiStateStyle.iconContainerSize,
              decoration: UiStateStyle.iconContainerDecoration(
                context,
                accentColor: AppColors.accentGold,
              ),
              child: Icon(
                icon,
                size: UiStateStyle.iconSize,
                color: AppColors.accentGold,
              ),
            ),

            const SizedBox(height: 20),

            // Headline
            Text(
              title,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context),
            ),

            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),

            const SizedBox(height: 24),

            // Primary Action: Open Settings if permanently denied, else Request
            ElevatedButton.icon(
              onPressed: isPermanentlyDenied ? _openSettings : (onRetryRequest ?? _openSettings),
              style: UiStateStyle.primaryButtonStyle(context),
              icon: Icon(
                isPermanentlyDenied ? Icons.settings_rounded : Icons.lock_open_rounded,
                size: 16,
              ),
              label: Text(isPermanentlyDenied ? 'Open Settings' : 'Allow Access'),
            ),

            // Secondary: Fallback to manual selection if supported
            if (onManualFallback != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: onManualFallback,
                style: UiStateStyle.secondaryButtonStyle(context),
                icon: const Icon(Icons.touch_app_rounded, size: 16),
                label: Text(manualFallbackLabel),
              ),
            ],

            // Dismiss option
            if (onDismiss != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Not Now',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
