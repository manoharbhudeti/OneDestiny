import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 8 — Session Expired Dialog & Controller.
///
/// Intercepts HTTP 401 responses, securely clears stored tokens,
/// and presents a non-dismissible luxury modal redirecting to Login.
class SessionExpiredDialog extends StatelessWidget {
  final VoidCallback onLoginAgain;

  const SessionExpiredDialog({
    super.key,
    required this.onLoginAgain,
  });

  /// Displays the modal dialog safely using the provided context or global navigator.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLoginAgain,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: SessionExpiredDialog(
          onLoginAgain: () {
            Navigator.of(dialogContext).pop();
            onLoginAgain();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Security Lock Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryBurgundy.withValues(alpha: isDark ? 0.25 : 0.12),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.lock_clock_rounded,
                size: 36,
                color: AppColors.accentGold,
              ),
            ),

            const SizedBox(height: 18),

            // Headline
            Text(
              'Your Session Has Expired',
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context).copyWith(fontSize: 17),
            ),

            const SizedBox(height: 8),

            // Explanation
            Text(
              'For your security, your session has timed out. Please sign in again to continue managing your bookings.',
              textAlign: TextAlign.center,
              style: UiStateStyle.descriptionStyle(context),
            ),

            const SizedBox(height: 22),

            // Login Again CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLoginAgain,
                style: UiStateStyle.primaryButtonStyle(context),
                child: const Text('Login Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
