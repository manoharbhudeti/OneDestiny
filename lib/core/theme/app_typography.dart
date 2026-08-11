import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  /// Large Title (SemiBold, ~20-22sp)
  static TextStyle heading(BuildContext context, {Color? customColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: customColor ?? defaultColor,
      height: 1.25,
    );
  }

  /// Section Title (Medium, ~15-16sp)
  static TextStyle subtitle(BuildContext context, {Color? customColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    return GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: customColor ?? defaultColor,
      height: 1.3,
    );
  }

  /// Body / Caption (Regular, ~13sp)
  static TextStyle description(BuildContext context, {bool isSecondary = false, Color? customColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: customColor ?? (isSecondary ? secondaryColor : primaryColor),
      height: 1.4,
    );
  }

  /// Button Text (SemiBold, ~14sp)
  static TextStyle buttonText(BuildContext context, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white,
      letterSpacing: 0.2,
    );
  }
}
