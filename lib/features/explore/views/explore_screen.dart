import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/vendor_card.dart';
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
            children: [
              const SizedBox(height: 10),
              CustomSearchBar(
                onChanged: appState.updateExploreSearch,
                onFilterTap: () => _openFilterSheet(context, appState),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Expanded(
                child: filteredVendors.isEmpty
                    ? Center(
                        child: Text(
                          'No vendors found',
                          style: AppTypography.subtitle(context),
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
        return ExploreFilterBottomSheet(
          currentMinPrice: appState.exploreMinPrice,
          currentMaxPrice: appState.exploreMaxPrice,
          currentMinRating: appState.exploreMinRating,
          currentSortBy: appState.exploreSortBy,
          onApply: ({required minPrice, required maxPrice, required minRating, required sortBy}) {
            appState.applyExploreFilters(
              minPrice: minPrice,
              maxPrice: maxPrice,
              minRating: minRating,
              sortBy: sortBy,
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

class ExploreFilterBottomSheet extends StatefulWidget {
  final double currentMinPrice;
  final double currentMaxPrice;
  final double currentMinRating;
  final String currentSortBy;
  final Function({
    required double minPrice,
    required double maxPrice,
    required double minRating,
    required String sortBy,
  }) onApply;
  final VoidCallback onReset;

  const ExploreFilterBottomSheet({
    super.key,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentMinRating,
    required this.currentSortBy,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<ExploreFilterBottomSheet> createState() => _ExploreFilterBottomSheetState();
}

class _ExploreFilterBottomSheetState extends State<ExploreFilterBottomSheet> {
  late RangeValues _priceRange;
  late double _selectedMinRating;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(widget.currentMinPrice, widget.currentMaxPrice);
    _selectedMinRating = widget.currentMinRating;
    _selectedSortBy = widget.currentSortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort Vendors',
                style: AppTypography.heading(context).copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () {
                  widget.onReset();
                  Navigator.pop(context);
                },
                child: const Text('Reset All', style: TextStyle(color: AppColors.error, fontSize: 13)),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // Price Range Section
          Text(
            'Starting Price Range',
            style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_priceRange.start.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentGold)),
              Text('₹${_priceRange.end.toInt()}+', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentGold)),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 500000,
            divisions: 100,
            activeColor: AppColors.accentGold,
            inactiveColor: isDark ? Colors.white12 : Colors.grey.shade300,
            labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),

          const SizedBox(height: 14),

          // Star Rating Section
          Text(
            'Minimum Rating',
            style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                final isSelected = _selectedMinRating == rating;
                final label = rating == 0.0 ? 'Any' : '$rating★ & up';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: AppColors.accentGold,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMinRating = rating);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Sort Options
          Text(
            'Sort By',
            style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('popular', 'Recommended'),
              _sortChip('price_low_high', 'Price: Low to High'),
              _sortChip('price_high_low', 'Price: High to Low'),
              _sortChip('rating_high', 'Top Rated'),
            ],
          ),

          const SizedBox(height: 20),

          // Apply CTA Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  minRating: _selectedMinRating,
                  sortBy: _selectedSortBy,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentGold : AppColors.primaryBurgundy,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _sortChip(String value, String label) {
    final isSelected = _selectedSortBy == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentGold,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedSortBy = value);
      },
    );
  }
}

