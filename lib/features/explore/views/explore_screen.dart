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
                onFilterTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Advanced filters coming soon.')),
                  );
                },
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
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
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
}
