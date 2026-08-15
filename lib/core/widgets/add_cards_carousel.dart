import 'dart:async';
import 'package:flutter/material.dart';
import '../models/flash_card_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AddCardsCarousel extends StatefulWidget {
  final List<FlashCardModel> cards;
  final ValueChanged<FlashCardModel>? onCardTap;
  final Duration autoScrollInterval;

  const AddCardsCarousel({
    super.key,
    required this.cards,
    this.onCardTap,
    this.autoScrollInterval = const Duration(milliseconds: 1800),
  });

  @override
  State<AddCardsCarousel> createState() => _AddCardsCarouselState();
}

class _AddCardsCarouselState extends State<AddCardsCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isUserInteracting = false;

  static const int _virtualMultiplier = 1000;

  @override
  void initState() {
    super.initState();
    final initialPage = widget.cards.isNotEmpty
        ? (widget.cards.length * (_virtualMultiplier ~/ 2))
        : 0;
    _currentIndex = widget.cards.isNotEmpty ? initialPage % widget.cards.length : 0;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: 0.92,
    );

    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _stopAutoScroll();
    if (widget.cards.length <= 1) return;

    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (_isUserInteracting || !mounted) return;
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
    _timer = null;
  }

  void _onUserInteractionStart() {
    _isUserInteracting = true;
    _stopAutoScroll();
  }

  void _onUserInteractionEnd() {
    _isUserInteracting = false;
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: "Add Cards"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A',
                style: AppTypography.subtitle(context).copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Exclusive Deals',
                    style: AppTypography.description(
                      context,
                      customColor: AppColors.accentGold,
                    ).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Large Single-Card Automatic & Manual Carousel
        Listener(
          onPointerDown: (_) => _onUserInteractionStart(),
          onPointerUp: (_) => _onUserInteractionEnd(),
          onPointerCancel: (_) => _onUserInteractionEnd(),
          child: SizedBox(
            height: 185,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentIndex = pageIndex % widget.cards.length;
                });
              },
              itemBuilder: (context, index) {
                final card = widget.cards[index % widget.cards.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _SingleLargeAddCardItem(
                    card: card,
                    isDark: isDark,
                    onTap: () => widget.onCardTap?.call(card),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cards.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive
                    ? AppColors.accentGold
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SingleLargeAddCardItem extends StatelessWidget {
  final FlashCardModel card;
  final bool isDark;
  final VoidCallback onTap;

  const _SingleLargeAddCardItem({
    required this.card,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.network(
                    card.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined, color: AppColors.accentGold, size: 36),
                      ),
                    ),
                  ),
                ),

                // Dark Multi-Stop Gradient Overlay for High Readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 1.0],
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.black.withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Content Overlay
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Pill Badge
                      if (card.discountTag != null)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              card.discountTag!,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Bottom Content: Title, Subtitle & Action Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  card.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    height: 1.25,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  card.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.black,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
