import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/views/login_screen.dart';
import '../models/service_item_data.dart';

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
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _ambientController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Master Phase Controller (5.6 Seconds Total Cinematic Flow)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    );

    // Continuous Ambient Motion Controller (8 Seconds Repeat Loop)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    _mainController.forward();
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
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          final scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final maxRadius = math.min(screenSize.width, screenSize.height) * (isSmallScreen ? 0.35 : 0.38);

    return Scaffold(
      backgroundColor: AppColors.darkBurgundy,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _ambientController]),
        builder: (context, child) {
          final progress = _mainController.value;
          final ambientValue = _ambientController.value;

          // Phase 1: Logo Intro Fade & Scale (0.00 -> 0.14)
          final logoIntroFade = _calcInterval(progress, 0.00, 0.12, Curves.easeOut);
          final logoIntroScale = _calcInterval(progress, 0.00, 0.14, Curves.easeOutBack, startVal: 0.85, endVal: 1.0);

          // Phase 4: Convergence (0.68 -> 0.82)
          final convergenceProgress = _calcInterval(progress, 0.68, 0.82, Curves.easeInOutCubic);

          // Phase 4/5: Center Bloom Glow Expansion during convergence (0.68 -> 0.85)
          final bloomGlow = _calcInterval(progress, 0.68, 0.85, Curves.easeOutQuad, startVal: 1.0, endVal: 2.5);

          // Phase 5: Tagline Reveal (0.80 -> 0.92)
          final taglineFade = _calcInterval(progress, 0.80, 0.92, Curves.easeOut);
          final taglineSlide = _calcInterval(progress, 0.80, 0.92, Curves.easeOutCubic, startVal: 16.0, endVal: 0.0);

          // Phase 6: Exit Zoom & Fade (0.92 -> 1.00)
          final exitFade = 1.0 - _calcInterval(progress, 0.92, 1.00, Curves.easeIn);
          final exitScale = _calcInterval(progress, 0.92, 1.00, Curves.easeInCubic, startVal: 1.0, endVal: 1.12);

          return Opacity(
            opacity: exitFade.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: exitScale,
              child: Stack(
                children: [
                  // 1. Luxury Dark Burgundy & Gold Depth Gradient Background
                  Positioned.fill(
                    child: _LuxuryBackground(
                      bloomGlow: bloomGlow,
                      ambientValue: ambientValue,
                    ),
                  ),

                  // 2. Ambient Gold Particle Dust Painter
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AmbientParticlePainter(
                        ambientValue: ambientValue,
                        glowFactor: bloomGlow,
                      ),
                    ),
                  ),

                  // 3. Floating Orbital Decorative Background Rings
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _OrbitalRingsPainter(
                        maxRadius: maxRadius,
                        ambientValue: ambientValue,
                        convergenceFactor: convergenceProgress,
                      ),
                    ),
                  ),

                  // 4. Sequential & Floating 3D Service Badges (Phase 2, 3, 4)
                  ..._buildServiceBadges(
                    screenSize: screenSize,
                    maxRadius: maxRadius,
                    progress: progress,
                    ambientValue: ambientValue,
                    convergenceProgress: convergenceProgress,
                  ),

                  // 5. Central OneDestiny Logo & Tagline Reveal (Phase 1, 4, 5)
                  Center(
                    child: Transform.scale(
                      scale: logoIntroScale,
                      child: Opacity(
                        opacity: logoIntroFade.clamp(0.0, 1.0),
                        child: _CentralLogoSection(
                          logoWidth: (screenSize.width * 0.65).clamp(220.0, 380.0),
                          bloomGlow: bloomGlow,
                          taglineFade: taglineFade,
                          taglineSlide: taglineSlide,
                          mainProgress: progress,
                        ),
                      ),
                    ),
                  ),

                  // 6. Skip Button for instantaneous access
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 12,
                    right: 20,
                    child: Opacity(
                      opacity: _calcInterval(progress, 0.15, 0.30, Curves.easeIn),
                      child: TextButton(
                        onPressed: _navigateToHome,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black26,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: AppColors.accentGold.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'SKIP',
                              style: TextStyle(
                                color: AppColors.accentGoldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.accentGoldLight,
                            ),
                          ],
                        ),
                      ),
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

  /// Calculates clamped interval interpolation with smooth curves
  double _calcInterval(
    double current,
    double begin,
    double end,
    Curve curve, {
    double startVal = 0.0,
    double endVal = 1.0,
  }) {
    if (current <= begin) return startVal;
    if (current >= end) return endVal;
    final normalized = (current - begin) / (end - begin);
    final curved = curve.transform(normalized.clamp(0.0, 1.0));
    return startVal + (endVal - startVal) * curved;
  }

  /// Builds the 9 floating 3D service badges with staggered entry and convergence math
  List<Widget> _buildServiceBadges({
    required Size screenSize,
    required double maxRadius,
    required double progress,
    required double ambientValue,
    required double convergenceProgress,
  }) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final services = SplashServiceData.services;

    // Staggered entry intervals across Phase 2 (0.14 -> 0.52)
    const phase2Start = 0.14;
    const phase2End = 0.52;
    final durationPerItem = (phase2End - phase2Start) / services.length;

    return List.generate(services.length, (index) {
      final item = services[index];

      // Entry timing for this item
      final itemBegin = phase2Start + index * durationPerItem * 0.65;
      final itemEnd = math.min(itemBegin + 0.18, phase2End);

      // Entry interpolation
      final entryProgress = _calcInterval(progress, itemBegin, itemEnd, Curves.easeOutBack);
      final opacityProgress = _calcInterval(progress, itemBegin, itemBegin + 0.08, Curves.easeOut);

      // Orbital angle calculation with gentle ambient drift
      final currentAngle = item.baseAngle + (ambientValue * 2 * math.pi * 0.03);

      // Base radius scaled for device screen
      final baseRadius = maxRadius * item.orbitRadiusMultiplier;

      // Current orbital radius (converges to center in Phase 4)
      final currentRadius = baseRadius * (1.0 - convergenceProgress);

      // Floating sine wave offset (Phase 3 continuous feel)
      final floatX = math.sin(ambientValue * 2 * math.pi + index * 0.7) * 7.0;
      final floatY = math.cos(ambientValue * 2 * math.pi * 0.8 + index * 0.9) * 7.0;

      // Final target orbital position
      final orbitalX = center.dx + math.cos(currentAngle) * currentRadius + floatX;
      final orbitalY = center.dy + math.sin(currentAngle) * currentRadius + floatY;

      // Off-screen entry origin
      final entryOriginX = center.dx + item.entryOffset.dx * maxRadius * 1.6;
      final entryOriginY = center.dy + item.entryOffset.dy * maxRadius * 1.6;

      // Current interpolated screen position
      final posX = entryOriginX + (orbitalX - entryOriginX) * entryProgress;
      final posY = entryOriginY + (orbitalY - entryOriginY) * entryProgress;

      // Convergence scale & opacity fade out
      final convergenceScale = 1.0 - (0.75 * convergenceProgress);
      final convergenceOpacity = math.pow(1.0 - convergenceProgress, 1.6).toDouble();

      // Combined scale & opacity
      final totalScale = (0.5 + 0.5 * entryProgress) * item.depth * convergenceScale;
      final totalOpacity = (opacityProgress * convergenceOpacity).clamp(0.0, 1.0);

      if (totalOpacity <= 0.001) return const SizedBox.shrink();

      // 3D Perspective Rotation (Tilt effect)
      final tiltX = math.sin(ambientValue * 2 * math.pi + index) * 0.12 * (1.0 - convergenceProgress);
      final tiltY = math.cos(ambientValue * 2 * math.pi + index) * 0.12 * (1.0 - convergenceProgress);

      final transformMatrix = Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateX(tiltX)
        ..rotateY(tiltY);

      return Positioned(
        left: posX - 52,
        top: posY - 28,
        child: Opacity(
          opacity: totalOpacity,
          child: Transform(
            transform: transformMatrix,
            alignment: Alignment.center,
            child: Transform.scale(
              scale: totalScale,
              child: _ServiceIconBadge(item: item),
            ),
          ),
        ),
      );
    });
  }
}

/// Luxury Background with Depth Radial Glow
class _LuxuryBackground extends StatelessWidget {
  final double bloomGlow;
  final double ambientValue;

  const _LuxuryBackground({
    required this.bloomGlow,
    required this.ambientValue,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = math.sin(ambientValue * 2 * math.pi) * 0.05;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.05 + pulse),
          radius: 1.1 + (bloomGlow - 1.0) * 0.4,
          colors: [
            Color.lerp(const Color(0xFF6B1028), const Color(0xFF8A1535), bloomGlow - 1.0)!,
            const Color(0xFF380514),
            const Color(0xFF1B0209),
          ],
          stops: const [0.0, 0.65, 1.0],
        ),
      ),
    );
  }
}

/// Central Logo & Tagline Reveal Section
class _CentralLogoSection extends StatelessWidget {
  final double logoWidth;
  final double bloomGlow;
  final double taglineFade;
  final double taglineSlide;
  final double mainProgress;

  const _CentralLogoSection({
    required this.logoWidth,
    required this.bloomGlow,
    required this.taglineFade,
    required this.taglineSlide,
    required this.mainProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Golden Aura Bloom Halo around Logo
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: logoWidth * 0.85,
              height: logoWidth * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.25 * bloomGlow),
                    blurRadius: 40 * bloomGlow,
                    spreadRadius: 10 * bloomGlow,
                  ),
                ],
              ),
            ),

            // OneDestiny Brand Emblem Logo Image
            Image.asset(
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
          ],
        ),

        const SizedBox(height: 18),

        // Tagline & Luxury Gold Shimmer Divider (Phase 5 Reveal)
        Transform.translate(
          offset: Offset(0, taglineSlide),
          child: Opacity(
            opacity: taglineFade.clamp(0.0, 1.0),
            child: Column(
              children: [
                // Gold Accent Line
                Container(
                  width: 50,
                  height: 2,
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

                const SizedBox(height: 12),

                // Luxury Wedding Tagline
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Every wedding service, together in OneDestiny.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF3E5AB), // Light Champagne Gold
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.8,
                      height: 1.3,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Glassmorphic Luxury Service Badge Unit
class _ServiceIconBadge extends StatelessWidget {
  final SplashServiceItem item;

  const _ServiceIconBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xCC2B0410), // Translucent Luxury Burgundy Surface
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.18),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Gold Ring Badge Container for Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentGoldLight.withValues(alpha: 0.3),
                  AppColors.primaryBurgundy.withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Icon(
              item.icon,
              size: 16,
              color: AppColors.accentGoldLight,
            ),
          ),

          const SizedBox(height: 4),

          // Service Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFF8F4),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for Decorative Orbital Background Rings
class _OrbitalRingsPainter extends CustomPainter {
  final double maxRadius;
  final double ambientValue;
  final double convergenceFactor;

  _OrbitalRingsPainter({
    required this.maxRadius,
    required this.ambientValue,
    required this.convergenceFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final opacityMultiplier = (1.0 - convergenceFactor).clamp(0.0, 1.0);

    if (opacityMultiplier <= 0.01) return;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final ringRadii = [
      maxRadius * 0.72,
      maxRadius * 0.90,
    ];

    for (int i = 0; i < ringRadii.length; i++) {
      final r = ringRadii[i] * (1.0 - convergenceFactor * 0.8);
      ringPaint.color = AppColors.accentGold.withValues(
        alpha: (0.07 + (i * 0.04)) * opacityMultiplier,
      );
      canvas.drawCircle(center, r, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingsPainter oldDelegate) {
    return oldDelegate.ambientValue != ambientValue ||
        oldDelegate.convergenceFactor != convergenceFactor ||
        oldDelegate.maxRadius != maxRadius;
  }
}

/// Custom Painter for Ambient Gold Particles Floating in Background
class _AmbientParticlePainter extends CustomPainter {
  final double ambientValue;
  final double glowFactor;

  _AmbientParticlePainter({
    required this.ambientValue,
    required this.glowFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for stable particle coordinates

    const particleCount = 28;
    for (int i = 0; i < particleCount; i++) {
      final rx = random.nextDouble() * size.width;
      final ry = random.nextDouble() * size.height;
      final baseSize = 1.2 + random.nextDouble() * 2.2;
      final speed = 0.5 + random.nextDouble() * 1.5;

      // Floating oscillation
      final dy = math.sin((ambientValue * speed * 2 * math.pi) + i) * 12;
      final dx = math.cos((ambientValue * speed * 2 * math.pi) + i) * 8;

      final p = Offset(rx + dx, ry + dy);
      final alpha = (0.12 + 0.18 * math.sin((ambientValue * 2 * math.pi * speed) + i)) * glowFactor;

      particlePaint.color = AppColors.accentGoldLight.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(p, baseSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlePainter oldDelegate) {
    return oldDelegate.ambientValue != ambientValue || oldDelegate.glowFactor != glowFactor;
  }
}
