import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Centralized style constants and helper builders for all UI states.
class UiStateStyle {
  UiStateStyle._();

  static const double defaultHorizontalPadding = 24.0;
  static const double defaultVerticalPadding = 32.0;
  static const double iconContainerSize = 88.0;
  static const double iconSize = 44.0;
  static const double cardBorderRadius = 18.0;

  /// Decorative background circle for icons with theme-adaptive styling.
  static BoxDecoration iconContainerDecoration(
    BuildContext context, {
    Color? accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = accentColor ?? AppColors.accentGold;
    return BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.16 : 0.10),
      shape: BoxShape.circle,
      border: Border.all(
        color: color.withValues(alpha: isDark ? 0.35 : 0.25),
        width: 1.5,
      ),
    );
  }

  /// Title text style with responsive sizing and contrast.
  static TextStyle titleStyle(BuildContext context, {Color? color}) {
    return AppTypography.heading(context, customColor: color).copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );
  }

  /// Description/body text style with multi-line readability.
  static TextStyle descriptionStyle(BuildContext context, {Color? color}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return AppTypography.description(context, customColor: color ?? defaultColor)
        .copyWith(
      fontSize: 13.5,
      height: 1.45,
    );
  }

  /// Primary button style matching OneDestiny luxury burgundy & gold aesthetics.
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: AppTypography.buttonText(context).copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Secondary/Outlined button style.
  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: BorderSide(
        color: AppColors.accentGold.withValues(alpha: 0.8),
        width: 1.2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: AppTypography.buttonText(context, color: primary).copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

