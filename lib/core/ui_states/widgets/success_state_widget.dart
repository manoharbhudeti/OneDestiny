import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 10 — Reusable Success State Widget & Dialog.
///
/// Provides rewarding visual confirmation with a smooth checkmark animation
/// and clear next-step action buttons.
class SuccessStateWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? extraContent;

  const SuccessStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.extraContent,
  });

  /// Factory for Booking Request Confirmation.
  factory SuccessStateWidget.bookingCreated({
    required String vendorName,
    required VoidCallback onViewBookings,
    required VoidCallback onBackToHome,
  }) =>
      SuccessStateWidget(
        title: 'Request Sent Successfully!',
        description:
            'Your booking request has been submitted to $vendorName. You can track its status and chat directly under Bookings.',
        primaryActionLabel: 'View in Bookings',
        onPrimaryAction: onViewBookings,
        secondaryActionLabel: 'Back to Home',
        onSecondaryAction: onBackToHome,
      );

  /// Shows the success widget as an elegant modal bottom sheet or dialog.
  static Future<void> showSheet(
    BuildContext context, {
    required String title,
    required String description,
    String? primaryActionLabel,
    VoidCallback? onPrimaryAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.25),
            ),
          ),
          child: SuccessStateWidget(
            title: title,
            description: description,
            primaryActionLabel: primaryActionLabel,
            onPrimaryAction: () {
              Navigator.of(sheetContext).pop();
              onPrimaryAction?.call();
            },
            secondaryActionLabel: secondaryActionLabel,
            onSecondaryAction: () {
              Navigator.of(sheetContext).pop();
              onSecondaryAction?.call();
            },
          ),
        );
      },
    );
  }

  @override
  State<SuccessStateWidget> createState() => _SuccessStateWidgetState();
}

class _SuccessStateWidgetState extends State<SuccessStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated Checkmark
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.14),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.5),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Headline
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context).copyWith(fontSize: 19),
            ),

            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                widget.description,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),

            if (widget.extraContent != null) ...[
              const SizedBox(height: 16),
              widget.extraContent!,
            ],

            if (widget.primaryActionLabel != null &&
                widget.onPrimaryAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onPrimaryAction,
                  style: UiStateStyle.primaryButtonStyle(context),
                  child: Text(widget.primaryActionLabel!),
                ),
              ),
            ],

            if (widget.secondaryActionLabel != null &&
                widget.onSecondaryAction != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onSecondaryAction,
                  style: UiStateStyle.secondaryButtonStyle(context),
                  child: Text(widget.secondaryActionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

