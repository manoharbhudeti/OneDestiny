import 'package:flutter/material.dart';
import '../../../core/models/vendor_detail_models.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'portfolio_gallery_viewer.dart';

class VendorPortfolioSection extends StatefulWidget {
  final List<VendorPortfolioItem> albums;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const VendorPortfolioSection({
    super.key,
    required this.albums,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<VendorPortfolioSection> createState() => _VendorPortfolioSectionState();
}

class _VendorPortfolioSectionState extends State<VendorPortfolioSection> {
  // -1 indicates "All Albums", 0..N-1 indicates specific album index
  int _selectedFilterIndex = -1;

  int get _totalPhotos {
    return widget.albums.fold(0, (sum, album) => sum + album.photoCount);
  }

  void _openGallery(BuildContext context, VendorPortfolioItem album, int initialIndex) {
    final mediaList = album.photoMedia.isNotEmpty
        ? album.photoMedia
        : album.allImageUrls
            .asMap()
            .entries
            .map((e) => VendorPortfolioMedia(id: e.key, url: e.value))
            .toList();

    if (mediaList.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PortfolioGalleryViewerScreen(
          albumTitle: album.title,
          albumDescription: album.description,
          media: mediaList,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.accentGold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Portfolio Albums',
                  style: AppTypography.subtitle(context).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!widget.isLoading && widget.albums.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${widget.albums.length} ${widget.albums.length == 1 ? 'Album' : 'Albums'} • $_totalPhotos Photos',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Browse authentic work and photo galleries organized by album',
          style: AppTypography.description(context, isSecondary: true)
              .copyWith(fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Main Content Area
        if (widget.isLoading)
          _buildLoadingSkeleton(context, surfaceColor, borderColor)
        else if (widget.errorMessage != null && widget.albums.isEmpty)
          _buildErrorState(context, surfaceColor, borderColor)
        else if (widget.albums.isEmpty)
          _buildEmptyState(context, surfaceColor, borderColor)
        else ...[
          // Album Tabs / Filter Chips (if multiple albums)
          if (widget.albums.length > 1) ...[
            _buildAlbumFilterChips(context, primaryColor, borderColor),
            const SizedBox(height: 18),
          ],

          // Album items
          if (_selectedFilterIndex == -1)
            // Show all albums sequentially
            ...widget.albums.map((album) => _buildAlbumCard(
                  context,
                  album,
                  surfaceColor,
                  borderColor,
                ))
          else if (_selectedFilterIndex >= 0 &&
              _selectedFilterIndex < widget.albums.length)
            // Show selected album
            _buildAlbumCard(
              context,
              widget.albums[_selectedFilterIndex],
              surfaceColor,
              borderColor,
              isExpandedView: true,
            ),
        ],
      ],
    );
  }

  Widget _buildAlbumFilterChips(
    BuildContext context,
    Color primaryColor,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // "All Albums" chip
          _buildChip(
            label: 'All Albums ($_totalPhotos)',
            isSelected: _selectedFilterIndex == -1,
            primaryColor: primaryColor,
            borderColor: borderColor,
            isDark: isDark,
            onTap: () => setState(() => _selectedFilterIndex = -1),
          ),
          const SizedBox(width: 8),

          // Individual album chips
          ...widget.albums.asMap().entries.map((entry) {
            final idx = entry.key;
            final album = entry.value;
            final isSelected = _selectedFilterIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: '${album.isFeatured ? '★ ' : ''}${album.title} (${album.photoCount})',
                isSelected: isSelected,
                primaryColor: primaryColor,
                borderColor: borderColor,
                isDark: isDark,
                onTap: () => setState(() => _selectedFilterIndex = idx),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required Color borderColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.darkCardBg : AppColors.warmIvory),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(
    BuildContext context,
    VendorPortfolioItem album,
    Color surfaceColor,
    Color borderColor, {
    bool isExpandedView = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photos = album.photoMedia.isNotEmpty
        ? album.photoMedia
        : album.allImageUrls
            .asMap()
            .entries
            .map((e) => VendorPortfolioMedia(id: e.key, url: e.value))
            .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Title & Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            album.title,
                            style: AppTypography.subtitle(context).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (album.isFeatured) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '★ FEATURED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (album.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        album.description.trim(),
                        maxLines: isExpandedView ? 4 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.description(context, isSecondary: true)
                            .copyWith(fontSize: 12.5),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Photo count tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  '${photos.length} ${photos.length == 1 ? 'photo' : 'photos'}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Photos Grid
          if (photos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: const Center(
                child: Text(
                  'No photos uploaded to this album yet',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else
            _buildPhotoGrid(context, album, photos, borderColor),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid(
    BuildContext context,
    VendorPortfolioItem album,
    List<VendorPortfolioMedia> photos,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];

        return GestureDetector(
          onTap: () => _openGallery(context, album, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'portfolio_media_${photo.id}_${photo.displayUrl}',
                    child: Image.network(
                      photo.displayUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 22,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  if (photo.isCoverPhoto)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded,
                                color: AppColors.accentGold, size: 10),
                            SizedBox(width: 2),
                            Text(
                              'COVER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? Colors.white12 : Colors.grey.shade200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 140,
                height: 18,
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 18,
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: List.generate(
              6,
              (_) => Container(
                decoration: BoxDecoration(
                  color: placeholderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 44,
            color: AppColors.accentGold,
          ),
          const SizedBox(height: 12),
          Text(
            'No Portfolio Albums Yet',
            style: AppTypography.subtitle(context).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This vendor hasn\'t published portfolio albums yet.',
            textAlign: TextAlign.center,
            style: AppTypography.description(context, isSecondary: true)
                .copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 38,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          Text(
            widget.errorMessage ?? 'Unable to load portfolio albums.',
            textAlign: TextAlign.center,
            style: AppTypography.description(context).copyWith(fontSize: 13),
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
