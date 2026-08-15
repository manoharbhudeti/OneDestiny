import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SplashScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // 5.5-Second Cinematic Splash Sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    _controller.forward();
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(themeModeNotifier: widget.themeModeNotifier),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calcInterval(
    double current,
    double begin,
    double end,
    Curve curve,
  ) {
    if (current <= begin) return 0.0;
    if (current >= end) return 1.0;
    final normalized = (current - begin) / (end - begin);
    return curve.transform(normalized.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoWidth = (screenSize.width * 0.65).clamp(220.0, 360.0);

    return Scaffold(
      backgroundColor: AppColors.darkBurgundy,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          // 1. Clean Logo Zoom-in Animation (0.00 -> 0.40)
          final logoScaleProgress = _calcInterval(progress, 0.0, 0.38, Curves.easeOutBack);
          final logoScale = 0.80 + 0.20 * logoScaleProgress;
          final logoOpacity = _calcInterval(progress, 0.0, 0.28, Curves.easeOut);

          // 2. Tagline & Dual Gold Lines Staggered Reveal (0.42 -> 0.82)
          final linesProgress = _calcInterval(progress, 0.42, 0.75, Curves.easeOutCubic);
          final taglineOpacity = _calcInterval(progress, 0.48, 0.80, Curves.easeOut);
          final taglineSlideY = (1.0 - _calcInterval(progress, 0.48, 0.82, Curves.easeOutCubic)) * 14.0;

          // 3. Exit Zoom & Fade Out (0.90 -> 1.00)
          final exitFade = 1.0 - _calcInterval(progress, 0.90, 1.00, Curves.easeIn);
          final exitScale = 1.0 + 0.04 * _calcInterval(progress, 0.90, 1.00, Curves.easeIn);

          return Opacity(
            opacity: exitFade.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: exitScale,
              child: Stack(
                children: [
                  // A. Pure Deep Burgundy Background (No Gold Tint Box)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.05),
                          radius: 1.25,
                          colors: [
                            Color(0xFF6B1028), // Primary Deep Burgundy
                            Color(0xFF380514),
                            Color(0xFF160207), // Deep Edge Burgundy
                          ],
                          stops: [0.0, 0.65, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // B. Decorative Gold Filigree Corner Accents (Matches Luxury Home Template)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BurgundyGoldDecorPainter(
                        progress: progress,
                      ),
                    ),
                  ),

                  // C. Central Clean Logo & Framed Tagline Sequence
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Clean Logo Image (No Gold Tint/Flash Box)
                        Transform.scale(
                          scale: logoScale,
                          child: Opacity(
                            opacity: logoOpacity,
                            child: Image.asset(
                              'assets/images/one_destiny_logo_transparent.png',
                              width: logoWidth,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/one_destiny_logo.png',
                                  width: logoWidth,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 2. Tagline Framed Between Two Small Gold Lines
                        Transform.translate(
                          offset: Offset(0, taglineSlideY),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Top Small Gold Line
                              Container(
                                width: 80 * linesProgress,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.accentGoldLight,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tagline Text: "MAKE EVERY CELEBRATION IN ONE PLACE"
                              Opacity(
                                opacity: taglineOpacity.clamp(0.0, 1.0),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                    'MAKE EVERY CELEBRATION IN ONE PLACE',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFF7E7B6), // Light Champagne Gold
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.0,
                                      height: 1.3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 6,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Bottom Small Gold Line
                              Container(
                                width: 80 * linesProgress,
                                height: 1.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(1),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.accentGoldLight,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom Painter for Decorative Gold Lines & Corners (Matches Luxury Home Screen)
class _BurgundyGoldDecorPainter extends CustomPainter {
  final double progress;

  _BurgundyGoldDecorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final linePaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.12 * math.min(1.0, progress * 2.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Corner Filigree Frame Accents
    const padding = 36.0;
    const cornerSize = 28.0;

    // Top-Left Corner
    canvas.drawLine(const Offset(padding, padding), const Offset(padding + cornerSize, padding), linePaint);
    canvas.drawLine(const Offset(padding, padding), const Offset(padding, padding + cornerSize), linePaint);

    // Top-Right Corner
    canvas.drawLine(Offset(width - padding, padding), Offset(width - padding - cornerSize, padding), linePaint);
    canvas.drawLine(Offset(width - padding, padding), Offset(width - padding, padding + cornerSize), linePaint);

    // Bottom-Left Corner
    canvas.drawLine(Offset(padding, height - padding), Offset(padding + cornerSize, height - padding), linePaint);
    canvas.drawLine(Offset(padding, height - padding), Offset(padding, height - padding - cornerSize), linePaint);

    // Bottom-Right Corner
    canvas.drawLine(Offset(width - padding, height - padding), Offset(width - padding - cornerSize, height - padding), linePaint);
    canvas.drawLine(Offset(width - padding, height - padding), Offset(width - padding, height - padding - cornerSize), linePaint);

    // Subtle Soft Orbital Ring in Background
    final ringCenter = Offset(width / 2, height / 2);
    canvas.drawCircle(ringCenter, width * 0.42, linePaint..color = AppColors.accentGold.withValues(alpha: 0.06));
  }

  @override
  bool shouldRepaint(covariant _BurgundyGoldDecorPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
