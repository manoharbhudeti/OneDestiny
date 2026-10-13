import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/vendor_card.dart';
import '../../../core/widgets/vendor_filter_bottom_sheet.dart';
import '../../vendor_detail/views/vendor_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final filteredVendors = appState.filteredExploreVendors;
    final categories = ['All', ...appState.categories.map((category) => category.title)]
        .where((category) => category != 'More')
        .toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Explore Vendors', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomSearchBar(
                onChanged: appState.updateExploreSearch,
                isFilterActive: appState.isExploreFilterActive,
                onFilterTap: () => _openFilterSheet(context, appState),
              ),

              if (appState.exploreSelectedDate != null) ...[
                const SizedBox(height: 8),
                Container(
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
                          'Available on ${appState.exploreSelectedDate!.day}/${appState.exploreSelectedDate!.month}/${appState.exploreSelectedDate!.year} • ${filteredVendors.length} vendors',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentGold),
                        ),
                      ),
                      InkWell(
                        onTap: () => appState.setExploreDateFilter(null),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text('Clear', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categories.map((cat) {
                    final isSelected = appState.exploreSelectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: AppTypography.description(context).copyWith(
                          fontSize: 12,
                          color: isSelected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        checkmarkColor: isDark ? Colors.black : Colors.white,
                        selectedColor: primaryColor,
                        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                        ),
                        onSelected: (_) => appState.selectExploreCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filteredVendors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy_rounded,
                              size: 48,
                              color: AppColors.accentGold.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              appState.exploreSelectedDate != null
                                  ? 'No vendors available on this date'
                                  : 'No vendors found',
                              style: AppTypography.subtitle(context),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appState.exploreSelectedDate != null
                                  ? 'Vendors who are booked on this date are hidden. Select another date or clear the day filter.'
                                  : 'Change your search or filters to discover more vendors.',
                              textAlign: TextAlign.center,
                              style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                            ),
                            if (appState.isExploreFilterActive) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => appState.resetExploreFilters(),
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
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredVendors.length,
                        itemBuilder: (context, index) {
                          final vendor = filteredVendors[index];
                          return VendorCard(
                            vendor: vendor,
                            onFavoriteToggle: (_) => AppStateScope.read(context).toggleFavorite(vendor.id),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VendorDetailScreen(vendor: vendor),
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

  void _openFilterSheet(BuildContext context, dynamic appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return VendorFilterBottomSheet(
          currentMinPrice: appState.exploreMinPrice,
          currentMaxPrice: appState.exploreMaxPrice,
          currentMinRating: appState.exploreMinRating,
          currentSortBy: appState.exploreSortBy,
          currentSelectedDate: appState.exploreSelectedDate,
          onApply: ({required minPrice, required maxPrice, required minRating, required sortBy, selectedDate}) {
            appState.applyExploreFilters(
              minPrice: minPrice,
              maxPrice: maxPrice,
              minRating: minRating,
              sortBy: sortBy,
              selectedDate: selectedDate,
            );
          },
          onReset: () {
            appState.resetExploreFilters();
          },
        );
      },
    );
  }
}

typedef ExploreFilterBottomSheet = VendorFilterBottomSheet;


