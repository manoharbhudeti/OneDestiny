import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// State 9 — Reusable Form Validation Feedback Wrapper & Validators.
///
/// Wraps text inputs and custom form elements with immediate, accessible inline
/// visual feedback (borders, hint helpers, error captions, and checkmarks).
class FormFieldFeedback extends StatelessWidget {
  final Widget child;
  final String? errorMessage;
  final String? helperText;
  final bool isValid;
  final bool isInteracted;

  const FormFieldFeedback({
    super.key,
    required this.child,
    this.errorMessage,
    this.helperText,
    this.isValid = false,
    this.isInteracted = false,
  });

  /// Common input validation helper functions.
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length != 10) {
      return 'Please enter a valid 10-digit mobile number.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validateOtp(String? value, [int expectedLength = 6]) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required.';
    }
    final clean = value.replaceAll(RegExp(r'\D'), '');
    if (clean.length != expectedLength) {
      return 'Please enter the complete $expectedLength-digit code.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirm) {
    if (confirm == null || confirm.isEmpty) {
      return 'Please confirm your password.';
    }
    if (password != confirm) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? validatePositiveNumber(String? value, [String fieldName = 'Amount']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    final num = double.tryParse(value.trim());
    if (num == null || num <= 0) {
      return 'Please enter a valid positive number.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showError = isInteracted && errorMessage != null && errorMessage!.isNotEmpty;
    final showSuccess = isInteracted && isValid && (errorMessage == null || errorMessage!.isEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (showError) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (showSuccess && helperText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 14,
                color: AppColors.success,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  helperText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null && helperText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

