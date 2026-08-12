import 'package:flutter/material.dart';
import '../models/vendor_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pressable_card.dart';

class VendorCard extends StatefulWidget {
  final VendorModel vendor;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;

  const VendorCard({
    super.key,
    required this.vendor,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> with SingleTickerProviderStateMixin {
  late bool _isFavorite;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.vendor.isFavorite;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VendorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vendor.isFavorite != widget.vendor.isFavorite) {
      _isFavorite = widget.vendor.isFavorite;
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    if (_isFavorite) {
      _heartController.forward().then((_) => _heartController.reverse());
    }

    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!(_isFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return PressableCard(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 115,
                    width: double.infinity,
                    child: Image.network(
                      widget.vendor.imageUrl,
                      fit: BoxFit.cover,
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedOpacity(
                          opacity: frame == null ? 0 : 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: child,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: isDark ? const Color(0xFF222222) : const Color(0xFFF4ECE8),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.0),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Rating Tag (Top Left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.vendor.rating.toStringAsFixed(1),
                          style: AppTypography.description(context).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite Button (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: ScaleTransition(
                      scale: _heartScale,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: _isFavorite ? primaryColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.subtitle(context),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '${widget.vendor.distanceKm} km away • ${widget.vendor.location}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.description(context, isSecondary: true).copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      widget.vendor.formattedPrice,
                      style: AppTypography.subtitle(
                        context,
                        customColor: primaryColor,
                      ).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
