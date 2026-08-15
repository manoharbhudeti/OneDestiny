import 'package:flutter/material.dart';

class AppColors {
  // Centralized Primary Palette (Default: Luxury Burgundy & Gold)
  static const Color primaryBurgundy = Color(0xFF6B1028);
  static const Color darkBurgundy = Color(0xFF4A081C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFF3E5AB);
  
  // Theme Color Aliases
  static const Color lightPrimary = primaryBurgundy;
  static const Color darkPrimary = accentGold;
  static const Color lightAccent = accentGold;
  static const Color darkAccent = accentGold;

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFFFF8F4);
  static const Color lightSurface = Color(0xFFFFFDFB);
  static const Color warmIvory = Color(0xFFFFFDFB);
  static const Color lightTextPrimary = Color(0xFF1D1D1D);
  static const Color lightTextSecondary = Color(0xFF686868);
  static const Color lightBorder = Color(0xFFE8D8D2);
  static const Color lightDivider = Color(0xFFF0E4DE);

  // Pitch Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkCardBg = Color(0xFF1C1C1C);
  static const Color darkPrimaryBurgundy = Color(0xFF9E2A4B);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF2A2A2A);

  // Functional Accent Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color ratingStar = Color(0xFFD4AF37);
}
