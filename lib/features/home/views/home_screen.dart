import 'package:flutter/material.dart';

import '../../../core/models/category_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/add_cards_carousel.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/luxury_header.dart';
import '../../../core/widgets/popular_service_card.dart';
import '../../../core/widgets/trending_vendor_card.dart';
import '../../vendor_detail/views/vendor_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;
  final ValueChanged<int>? onNavigateToTab;

  const HomeScreen({
    super.key,
    required this.themeModeNotifier,
    this.onNavigateToTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayVendors = appState.filteredTrendingVendors;
    final categories = [
      const CategoryModel(id: 'all', title: 'All', icon: Icons.apps_rounded),
      ...appState.categories,
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LuxuryHeader(
                greeting: appState.greeting,
                location: appState.activeLocation,
                avatarUrl: appState.profile.avatarUrl,
                onThemeToggle: () {
                  widget.themeModeNotifier.value =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
                onProfileTap: () {
                  widget.onNavigateToTab?.call(4);
                },
                onNavigateToTab: widget.onNavigateToTab,
                onLocationChanged: appState.updateLocation,
                bookingCount: appState.bookings.length,
                activeChatCount: appState.conversationCount,
                savedVendorCount: appState.favoriteVendors.length,
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomSearchBar(
                  onChanged: appState.updateHomeSearch,
                  onFilterTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Filter options coming soon!', style: AppTypography.description(context)),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 94,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return CategoryChip(
                      category: cat,
                      isSelected: cat.id == appState.homeSelectedCategoryId,
                      onTap: () => appState.selectHomeCategory(cat.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              AddCardsCarousel(
                cards: appState.flashCards,
                autoScrollInterval: const Duration(milliseconds: 1800),
                onCardTap: (card) {
                  if (card.targetCategoryId != null) {
                    appState.selectHomeCategory(card.targetCategoryId!);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected Offer: ${card.title}', style: AppTypography.description(context)),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popular Services',
                  style: AppTypography.subtitle(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 106,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: appState.popularServices.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final service = appState.popularServices[index];
                    return PopularServiceCard(
                      service: service,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected service: ${service.title}', style: AppTypography.description(context)),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Compact Top Vendors Section with Ratings & Verified Badges
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Top Vendors',
                          style: AppTypography.subtitle(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, color: AppColors.accentGold, size: 16),
                      ],
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateToTab?.call(1),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'See All',
                        style: AppTypography.description(
                          context,
                          customColor: primaryColor,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayVendors.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final vendor = displayVendors[index];
                    return TrendingVendorCard(
                      vendor: vendor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VendorDetailScreen(vendor: vendor),
                          ),
                        );
                      },
                      onBookNowTap: () {
                        AppStateScope.read(context).createBookingForVendor(vendor);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Booking requested for ${vendor.name}', style: AppTypography.description(context)),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
