import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// State 2B — Inline Loading Button.
///
/// Prevents duplicate submissions and displays an integrated spinner
/// while preserving exact button dimensions.
class InlineLoadingButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isOutlined;

  const InlineLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50.0,
    this.borderRadius = 14.0,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bg = backgroundColor ?? (isOutlined ? Colors.transparent : primary);
    final fg = foregroundColor ?? (isOutlined ? primary : Colors.white);

    final borderSide = isOutlined
        ? BorderSide(color: AppColors.accentGold.withValues(alpha: 0.8), width: 1.4)
        : BorderSide.none;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: isOutlined
              ? Colors.transparent
              : bg.withValues(alpha: 0.65),
          disabledForegroundColor: fg.withValues(alpha: 0.65),
          elevation: isOutlined ? 0 : 0.5,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('spinner'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? AppColors.accentGold : Colors.white,
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.buttonText(context, color: fg),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

