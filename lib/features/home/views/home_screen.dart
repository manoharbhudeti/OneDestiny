import 'package:flutter/material.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/vendor_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/luxury_header.dart';
import '../../../core/widgets/popular_service_card.dart';
import '../../../core/widgets/trending_vendor_card.dart';
import '../../../core/widgets/add_cards_carousel.dart';

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

  String _selectedCategoryId = 'cat_1'; // Default: Photography
  String _searchQuery = '';

  void _onCategorySelected(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  List<VendorModel> get _filteredTrendingVendors {
    if (_searchQuery.isEmpty) return MockData.trendingVendors;
    return MockData.trendingVendors.where((v) {
      return v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final displayTrendingVendors = _filteredTrendingVendors;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LUXURY BRANDED HEADER WITH GOLD LINE ART
              LuxuryHeader(
                greeting: 'Hello, Manohar 👋',
                location: 'Hyderabad, India',
                onThemeToggle: () {
                  widget.themeModeNotifier.value =
                      isDark ? ThemeMode.light : ThemeMode.dark;
                },
                onProfileTap: () {
                  widget.onNavigateToTab?.call(4);
                },
                onNavigateToTab: widget.onNavigateToTab,
              ),

              const SizedBox(height: 8),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomSearchBar(
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
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

              const SizedBox(height: 12),

              // CATEGORIES SECTION
              SizedBox(
                height: 96,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final cat = MockData.categories[index];
                    return CategoryChip(
                      category: cat,
                      isSelected: cat.id == _selectedCategoryId,
                      onTap: () => _onCategorySelected(cat.id),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ADD CARDS SECTION (SINGLE LARGE CARD AUTOMATIC CAROUSEL + DOTS)
              AddCardsCarousel(
                cards: MockData.flashCards,
                autoScrollInterval: const Duration(milliseconds: 1800),
                onCardTap: (card) {
                  if (card.targetCategoryId != null) {
                    _onCategorySelected(card.targetCategoryId!);
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

              const SizedBox(height: 20),

              // POPULAR SERVICES SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popular Services',
                  style: AppTypography.subtitle(context).copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 110,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.popularServices.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final service = MockData.popularServices[index];
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

              const SizedBox(height: 28),

              // TRENDING VENDORS SECTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Trending Vendors',
                        style: AppTypography.subtitle(context).copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayTrendingVendors.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final vendor = displayTrendingVendors[index];
                    return TrendingVendorCard(
                      vendor: vendor,
                      onBookNowTap: () {
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
