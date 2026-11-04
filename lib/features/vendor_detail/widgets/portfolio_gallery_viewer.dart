import 'package:flutter/material.dart';
import '../../../core/models/vendor_detail_models.dart';
import '../../../core/theme/app_colors.dart';

class PortfolioGalleryViewerScreen extends StatefulWidget {
  final String albumTitle;
  final String? albumDescription;
  final List<VendorPortfolioMedia> media;
  final int initialIndex;

  const PortfolioGalleryViewerScreen({
    super.key,
    required this.albumTitle,
    this.albumDescription,
    required this.media,
    this.initialIndex = 0,
  });

  @override
  State<PortfolioGalleryViewerScreen> createState() =>
      _PortfolioGalleryViewerScreenState();
}

class _PortfolioGalleryViewerScreenState
    extends State<PortfolioGalleryViewerScreen> {
  late int _currentIndex;
  late final PageController _pageController;
  final ScrollController _thumbScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.media.isEmpty ? 0 : widget.media.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbScrollController.dispose();
    super.dispose();
  }

  void _onThumbnailTapped(int index) {
    if (index == _currentIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  void _autoScrollThumbnails(int index) {
    if (!_thumbScrollController.hasClients) return;
    const itemWidth = 60.0;
    final targetOffset = (index * itemWidth) - 120.0;
    _thumbScrollController.animateTo(
      targetOffset.clamp(0.0, _thumbScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMedia = widget.media.isNotEmpty;
    final currentItem = hasMedia ? widget.media[_currentIndex] : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main Swiper / Zoomable photo area
          if (!hasMedia)
            const Center(
              child: Text(
                'No media available in this album',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: widget.media.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _autoScrollThumbnails(index);
              },
              itemBuilder: (context, index) {
                final mediaItem = widget.media[index];
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Hero(
                      tag: 'portfolio_media_${mediaItem.id}_${mediaItem.displayUrl}',
                      child: Image.network(
                        mediaItem.displayUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              color: AppColors.accentGold,
                              strokeWidth: 2.5,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(24),
                          color: Colors.black26,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.broken_image_rounded,
                                  color: Colors.white54, size: 54),
                              SizedBox(height: 12),
                              Text(
                                'Unable to load photo',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.albumTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (hasMedia) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${_currentIndex + 1} of ${widget.media.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (currentItem != null && currentItem.isCoverPhoto)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'COVER',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar (Description + Thumbnails)
          if (hasMedia)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.95),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.albumDescription != null &&
                          widget.albumDescription!.trim().isNotEmpty) ...[
                        Text(
                          widget.albumDescription!.trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (widget.media.length > 1)
                        SizedBox(
                          height: 54,
                          child: ListView.separated(
                            controller: _thumbScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.media.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              final isSelected = i == _currentIndex;
                              final thumbItem = widget.media[i];
                              return GestureDetector(
                                onTap: () => _onThumbnailTapped(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.accentGold
                                          : Colors.white.withValues(alpha: 0.25),
                                      width: isSelected ? 2.2 : 1.0,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      thumbItem.displayUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade900,
                                        child: const Icon(
                                            Icons.image_not_supported_rounded,
                                            size: 18,
                                            color: Colors.white38),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
