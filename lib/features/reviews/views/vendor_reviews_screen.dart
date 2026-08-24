import 'package:flutter/material.dart';

import '../../../core/models/review_model.dart';
import '../../../core/models/vendor_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class VendorReviewsScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorReviewsScreen({
    super.key,
    required this.vendor,
  });

  @override
  State<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends State<VendorReviewsScreen> {
  String _selectedFilter = 'All';
  final bool _isLoading = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final appState = AppStateScope.of(context);
    final allReviews = appState.reviewsForVendor(widget.vendor.id);

    // Apply Filter
    final filteredReviews = allReviews.where((review) {
      if (_selectedFilter == '5 Stars') return review.rating >= 4.8;
      if (_selectedFilter == '4 Stars') return review.rating >= 3.8 && review.rating < 4.8;
      if (_selectedFilter == 'With Photos') return review.photos.isNotEmpty;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Ratings & Reviews', style: AppTypography.heading(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _hasError
              ? _buildErrorState(context)
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Vendor Header Bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.vendor.imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 52,
                                height: 52,
                                color: isDark ? AppColors.darkSurface : Colors.grey.shade300,
                                child: const Icon(Icons.storefront_rounded, color: AppColors.accentGold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.vendor.name,
                                  style: AppTypography.subtitle(context).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${widget.vendor.category} • ${widget.vendor.location}',
                                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Overall Rating Summary Header
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Big Rating Score Column
                          Column(
                            children: [
                              Text(
                                widget.vendor.rating.toStringAsFixed(1),
                                style: AppTypography.heading(context).copyWith(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentGold,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.ratingStar,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${allReviews.length} Verified Reviews',
                                style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Container(width: 1, height: 90, color: borderColor),
                          const SizedBox(width: 20),

                          // Rating Distribution Breakdown Bars
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingBar(context, '5', 0.85),
                                _buildRatingBar(context, '4', 0.12),
                                _buildRatingBar(context, '3', 0.03),
                                _buildRatingBar(context, '2', 0.00),
                                _buildRatingBar(context, '1', 0.00),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Filter Chips Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['All', '5 Stars', '4 Stars', 'With Photos'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              backgroundColor: cardBg,
                              selectedColor: primaryColor,
                              checkmarkColor: AppColors.accentGold,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? primaryColor : borderColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Review Cards List or Empty State
                    if (filteredReviews.isEmpty)
                      _buildEmptyState(context)
                    else
                      ...filteredReviews.map((review) => _buildReviewCard(context, review, cardBg, borderColor)),
                  ],
                ),
    );
  }

  Widget _buildRatingBar(BuildContext context, String star, double percentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(star, style: AppTypography.description(context).copyWith(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.ratingStar),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                color: AppColors.accentGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewModel review, Color cardBg, Color borderColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review.userAvatarUrl),
                backgroundColor: isDark ? AppColors.darkSurface : Colors.grey.shade200,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.userName,
                            style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedBooking) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 11, color: AppColors.success),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.date,
                      style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Rating Chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingStar),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentGold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review Body Text
          Text(
            review.reviewText,
            style: AppTypography.description(context).copyWith(fontSize: 13, height: 1.45),
          ),

          // Customer Uploaded Photos Thumbnail Carousel
          if (review.photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: review.photos.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photoUrl = review.photos[index];
                  return GestureDetector(
                    onTap: () => _openPhotoLightbox(context, photoUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        photoUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openPhotoLightbox(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(photoUrl, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.rate_review_outlined, size: 54, color: AppColors.accentGold),
            const SizedBox(height: 12),
            Text('No Reviews Match Your Filter', style: AppTypography.subtitle(context)),
            const SizedBox(height: 4),
            Text('Try switching filters to view customer reviews', style: AppTypography.description(context, isSecondary: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accentGold),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load reviews', style: AppTypography.subtitle(context)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _hasError = false),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
