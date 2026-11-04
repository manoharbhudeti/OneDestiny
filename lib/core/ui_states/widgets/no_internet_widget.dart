import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 4 — No Internet State Widget.
///
/// Features a custom flat 2D vector illustration of a smartphone with a
/// disconnected network cloud, tailored to OneDestiny's luxury identity.
class NoInternetWidget extends StatefulWidget {
  final VoidCallback? onRetry;
  final String title;
  final String description;
  final EdgeInsetsGeometry padding;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.title = "You're Offline!",
    this.description =
        'It looks like your internet connection is unavailable. Please check your connection and try again.',
    this.padding = const EdgeInsets.symmetric(
      horizontal: UiStateStyle.defaultHorizontalPadding,
      vertical: UiStateStyle.defaultVerticalPadding,
    ),
  });

  @override
  State<NoInternetWidget> createState() => _NoInternetWidgetState();
}

class _NoInternetWidgetState extends State<NoInternetWidget> {
  bool _isChecking = false;

  Future<void> _handleRetry() async {
    if (widget.onRetry == null || _isChecking) return;
    setState(() => _isChecking = true);
    try {
      widget.onRetry!();
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: widget.padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dedicated Flat 2D Vector Illustration
            CustomPaint(
              size: const Size(190, 160),
              painter: _DisconnectedCloudPainter(
                isDark: Theme.of(context).brightness == Brightness.dark,
              ),
            ),

            const SizedBox(height: 24),

            // Headline
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context),
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

            if (widget.onRetry != null) ...[
              const SizedBox(height: 26),
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _handleRetry,
                style: UiStateStyle.primaryButtonStyle(context),
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.wifi_protected_setup_rounded, size: 18),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom 2D Vector Artwork Painter rendering a smartphone, cloud, and disconnected Wi-Fi.
class _DisconnectedCloudPainter extends CustomPainter {
  final bool isDark;

  const _DisconnectedCloudPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Palette
    final phoneBodyColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE8DDDA);
    final phoneScreenColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cloudColor = isDark ? const Color(0xFF282828) : const Color(0xFFF0EBE8);
    final accentBurgundy = AppColors.primaryBurgundy;
    final accentGold = AppColors.accentGold;
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.4 : 0.08);

    // 1. Soft Shadow base
    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.90), width: w * 0.70, height: 18),
      shadowPaint,
    );

    // 2. Minimalist Smartphone (placed at center-left)
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.18, 76, 114),
      const Radius.circular(16),
    );

    // Phone Shadow
    canvas.drawRRect(phoneRect.shift(const Offset(0, 4)), shadowPaint);

    // Phone Chassis
    final phoneBodyPaint = Paint()..color = phoneBodyColor;
    canvas.drawRRect(phoneRect, phoneBodyPaint);

    // Phone Border / Accent
    final phoneBorderPaint = Paint()
      ..color = accentGold.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(phoneRect, phoneBorderPaint);

    // Phone Inner Screen
    final screenRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28 + 5, h * 0.18 + 7, 66, 100),
      const Radius.circular(12),
    );
    canvas.drawRRect(screenRect, Paint()..color = phoneScreenColor);

    // Phone Camera Notch
    final notchPaint = Paint()..color = phoneBodyColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.28 + 38, h * 0.18 + 12), width: 18, height: 4),
        const Radius.circular(2),
      ),
      notchPaint,
    );

    // 3. Floating Cloud Element overlapping Phone Right side
    final cloudPath = Path();
    final cx = w * 0.65;
    final cy = h * 0.44;

    cloudPath.addOval(Rect.fromCircle(center: Offset(cx - 24, cy + 8), radius: 18));
    cloudPath.addOval(Rect.fromCircle(center: Offset(cx + 6, cy - 8), radius: 24));
    cloudPath.addOval(Rect.fromCircle(center: Offset(cx + 30, cy + 8), radius: 18));
    cloudPath.addRect(Rect.fromLTWH(cx - 24, cy + 8, 54, 18));

    // Cloud shadow
    canvas.drawPath(cloudPath.shift(const Offset(0, 3)), shadowPaint);

    // Cloud Body
    final cloudPaint = Paint()..color = cloudColor;
    canvas.drawPath(cloudPath, cloudPaint);

    final cloudBorder = Paint()
      ..color = accentBurgundy.withValues(alpha: isDark ? 0.4 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(cloudPath, cloudBorder);

    // 4. Disconnected Wi-Fi Symbol inside Phone Screen
    final wifiCenter = Offset(w * 0.28 + 38, h * 0.18 + 56);
    final wifiPaint = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.5;

    // Small Wi-Fi Dot
    canvas.drawCircle(wifiCenter + const Offset(0, 10), 2.5, Paint()..color = AppColors.error);

    // Outer Wi-Fi arc
    canvas.drawArc(
      Rect.fromCircle(center: wifiCenter + const Offset(0, 10), radius: 14),
      -math.pi * 0.78,
      math.pi * 0.56,
      false,
      wifiPaint,
    );

    // Middle Wi-Fi arc
    canvas.drawArc(
      Rect.fromCircle(center: wifiCenter + const Offset(0, 10), radius: 8),
      -math.pi * 0.78,
      math.pi * 0.56,
      false,
      wifiPaint,
    );

    // Disconnected Slash / Cross Line
    final slashPaint = Paint()
      ..color = AppColors.error
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      wifiCenter + const Offset(-12, -4),
      wifiCenter + const Offset(12, 16),
      slashPaint,
    );

    // 5. Subtle Signal Orbit Dots in Gold
    final dotPaint = Paint()..color = accentGold.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(w * 0.20, h * 0.35), 3.5, dotPaint);
    canvas.drawCircle(Offset(w * 0.24, h * 0.55), 2.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.30), 3.0, dotPaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.60), 2.2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DisconnectedCloudPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

