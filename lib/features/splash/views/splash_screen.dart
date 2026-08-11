import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../main/views/main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const SplashScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();

    // Automatically navigate after splash animation (2.5s)
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainNavigationScreen(themeModeNotifier: widget.themeModeNotifier),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final logoWidth = (screenSize.width * 0.72).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: AppColors.darkBurgundy,
      body: Stack(
        children: [
          // Background Luxury Linear Gradient & Radial Glow
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.1),
                radius: 1.2,
                colors: [
                  Color(0xFF5E0B24),
                  Color(0xFF380514),
                  Color(0xFF1F020A),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),

          // Decorative Gold Pattern Lines (Top & Bottom Ambient Overlay)
          Positioned(
            top: -screenSize.width * 0.25,
            right: -screenSize.width * 0.25,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.12 * _glowAnimation.value,
                  child: Container(
                    width: screenSize.width * 0.8,
                    height: screenSize.width * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentGold, width: 1.5),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -screenSize.width * 0.3,
            left: -screenSize.width * 0.3,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.1 * _glowAnimation.value,
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: screenSize.width * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentGold, width: 1.2),
                    ),
                  ),
                );
              },
            ),
          ),

          // Centered Animated Logo Content
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gold Infinity Emblem & Title Logo
                        Container(
                          width: logoWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Image.asset(
                            'assets/images/one_destiny_logo_transparent.png',
                            width: logoWidth,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback to original logo if transparent PNG asset loading falls back
                              return Image.asset(
                                'assets/images/one_destiny_logo.png',
                                width: logoWidth,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Subtle Gold Pulse Progress Bar
                        SizedBox(
                          width: 48,
                          height: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentGold.withValues(alpha: _glowAnimation.value),
                              ),
                              backgroundColor: AppColors.accentGold.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
