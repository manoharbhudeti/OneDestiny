import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// State 2C — Full-Screen Branded Loading Indicator.
///
/// Used for initial data hydration, authentication checks, and critical transitions.
class FullScreenLoader extends StatefulWidget {
  final String? message;
  final bool isTransparent;

  const FullScreenLoader({
    super.key,
    this.message = 'Loading OneDestiny...',
    this.isTransparent = false,
  });

  @override
  State<FullScreenLoader> createState() => _FullScreenLoaderState();
}

class _FullScreenLoaderState extends State<FullScreenLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.isTransparent
        ? Colors.black54
        : (isDark ? AppColors.darkBackground : AppColors.lightBackground);

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/images/one_destiny_logo_transparent.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.accentGold,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: AppColors.accentGold,
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: AppTypography.description(context).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

