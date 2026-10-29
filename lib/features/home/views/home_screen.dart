import 'package:flutter/material.dart';

import '../../../core/data/mock_data.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/add_cards_carousel.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/luxury_header.dart';
import '../../../core/widgets/popular_service_card.dart';
import '../../../core/widgets/trending_vendor_card.dart';
import '../../../core/widgets/vendor_filter_bottom_sheet.dart';
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
    final flashCards = appState.flashCards.isNotEmpty
        ? appState.flashCards
        : MockData.flashCards;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: RefreshIndicator(
          color: AppColors.accentGold,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          onRefresh: () async {
            await appState.refreshHome();
            await appState.refreshProfile();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  isFilterActive: appState.isHomeFilterActive,
                  onFilterTap: () => _openFilterSheet(context, appState),
                ),
              ),

              if (flashCards.isNotEmpty) ...[
                const SizedBox(height: 14),
                AddCardsCarousel(
                  cards: flashCards,
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
              ],

              if (appState.categories.isNotEmpty) ...[
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Categories',
                        style: AppTypography.subtitle(context).copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigateToTab?.call(1),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Explore All',
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
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: appState.categories.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final cat = isAll ? null : appState.categories[index - 1];
                      final catId = isAll ? 'all' : cat!.id;
                      final catTitle = isAll ? 'All' : cat!.title;
                      final isSelected = appState.homeSelectedCategoryId == catId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(catTitle),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                          selectedColor: AppColors.accentGold,
                          backgroundColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.transparent
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          onSelected: (_) => appState.selectHomeCategory(catId),
                        ),
                      );
                    },
                  ),
                ),
              ],

              if (appState.popularServices.isNotEmpty) ...[
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
              ],

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

              if (appState.homeSelectedDate != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_available_rounded, size: 14, color: AppColors.accentGold),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Available on ${appState.homeSelectedDate!.day}/${appState.homeSelectedDate!.month}/${appState.homeSelectedDate!.year} • ${displayVendors.length} vendors',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGold),
                          ),
                        ),
                        InkWell(
                          onTap: () => appState.setHomeDateFilter(null),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              if (appState.isLoadingInitial || appState.isLoadingVendors)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.accentGold),
                  ),
                )
              else if (displayVendors.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 48,
                          color: AppColors.accentGold.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          appState.homeSelectedDate != null
                              ? 'No vendors available on this date'
                              : 'No vendors found',
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle(context).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appState.homeSelectedDate != null
                              ? 'Try picking another day or clear the date filter to see all vendors.'
                              : 'Change your search or category filter to discover more verified vendors.',
                          textAlign: TextAlign.center,
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 13),
                        ),
                        if (appState.isHomeFilterActive) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => appState.resetHomeFilters(),
                            icon: const Icon(Icons.refresh_rounded, size: 14),
                            label: const Text('Reset All Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentGold,
                              side: const BorderSide(color: AppColors.accentGold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
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
    ),
  );
  }

  void _openFilterSheet(BuildContext context, dynamic appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return VendorFilterBottomSheet(
          currentMinPrice: appState.homeMinPrice,
          currentMaxPrice: appState.homeMaxPrice,
          currentMinRating: appState.homeMinRating,
          currentSortBy: appState.homeSortBy,
          currentSelectedDate: appState.homeSelectedDate,
          onApply: ({required minPrice, required maxPrice, required minRating, required sortBy, selectedDate}) {
            appState.applyHomeFilters(
              minPrice: minPrice,
              maxPrice: maxPrice,
              minRating: minRating,
              sortBy: sortBy,
              selectedDate: selectedDate,
            );
          },
          onReset: () {
            appState.resetHomeFilters();
          },
        );
      },
    );
  }
}
