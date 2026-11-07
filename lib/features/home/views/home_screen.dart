import '../../../core/ui_states/ui_states.dart';
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

              if (NetworkStateHandler.instance.isSlowNetwork)
                SlowNetworkWidget.banner(
                  onCancel: () => appState.refreshHome(),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SkeletonLoaderCard.vendorCardList(count: 3),
                )
              else if (appState.vendorsError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ErrorStateWidget(
                    customMessage: appState.vendorsError,
                    onRetry: () => appState.refreshHome(),
                  ),
                )
              else if (displayVendors.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: (appState.isHomeFilterActive || appState.homeSearchQuery.isNotEmpty)
                      ? NoSearchResultsWidget(
                          searchQuery: appState.homeSearchQuery,
                          onClearFilters: () => appState.resetHomeFilters(),
                        )
                      : EmptyStateWidget(
                          title: 'No Vendors Available',
                          description: 'There are no active vendors in ${appState.activeLocation} for this category yet.',
                          icon: Icons.storefront_outlined,
                          primaryActionLabel: 'Refresh Vendors',
                          onPrimaryAction: () => appState.refreshHome(),
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
                          if (vendor.hasActiveBooking) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'A booking request already exists with ${vendor.name} (${vendor.bookingStatus ?? "Pending"}).',
                                  style: AppTypography.description(context),
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                            return;
                          }
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
