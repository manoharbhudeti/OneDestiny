import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'skeleton_shimmer.dart';

/// Pre-built skeleton layouts that match the exact shape and dimensions of
/// OneDestiny's cards, preventing layout shift and visual jumps.
class SkeletonLoaderCard extends StatelessWidget {
  final Widget child;

  const SkeletonLoaderCard({super.key, required this.child});

  /// Skeleton for horizontal or vertical vendor preview card.
  static Widget vendorCard({double width = 280, double height = 260}) {
    return SkeletonShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightBorder.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: const SkeletonBlock(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBlock(width: 140, height: 16, borderRadius: 4),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBlock(width: 90, height: 12, borderRadius: 4),
                      SkeletonBlock(width: 45, height: 12, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBlock(width: 110, height: 14, borderRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton list for Home Screen trending vendors.
  static Widget vendorCardList({int count = 3, double height = 270}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => vendorCard(),
      ),
    );
  }

  /// Skeleton grid for Explore Screen vendor discovery.
  static Widget vendorGrid({int count = 6}) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: count,
      itemBuilder: (_, __) => vendorCard(width: double.infinity, height: 240),
    );
  }

  /// Skeleton for Booking history list tiles.
  static Widget bookingList({int count = 4}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => SkeletonShimmer(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.lightBorder.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const SkeletonBlock(width: 72, height: 72, borderRadius: 12),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBlock(width: 150, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 100, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBlock(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              const SkeletonBlock(width: 65, height: 24, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton for Chat conversations list.
  static Widget conversationList({int count = 5}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => SkeletonShimmer(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.lightBorder.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const SkeletonBlock.circle(size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonBlock(width: 130, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    SkeletonBlock(width: 200, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const SkeletonBlock(width: 40, height: 10, borderRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => child;
}

