import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 6 — No Search Results State Widget.
///
/// Displayed when a search or filter query succeeds but returns 0 matching results.
class NoSearchResultsWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? searchQuery;
  final List<String> suggestions;
  final VoidCallback? onClearFilters;
  final String clearFiltersLabel;
  final VoidCallback? onModifySearch;
  final String modifySearchLabel;

  const NoSearchResultsWidget({
    super.key,
    this.title = 'No Vendors Found',
    this.description =
        'We couldn\'t find any matching vendors for your current search criteria or filters.',
    this.searchQuery,
    this.suggestions = const [
      'Try searching with a broader keyword',
      'Select a different celebration date',
      'Expand your city or location radius',
      'Remove active price or rating filters',
    ],
    this.onClearFilters,
    this.clearFiltersLabel = 'Clear All Filters',
    this.onModifySearch,
    this.modifySearchLabel = 'Modify Search',
  });

  /// Specialized for vendor application when no booking requests match filters.
  factory NoSearchResultsWidget.vendorBookings({
    required VoidCallback onClearFilters,
  }) =>
      NoSearchResultsWidget(
        title: 'No Matching Bookings',
        description: 'No customer booking requests match your selected filters.',
        suggestions: const [
          'Switch status tabs to view all requests',
          'Clear date range filters',
        ],
        onClearFilters: onClearFilters,
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: UiStateStyle.defaultHorizontalPadding,
          vertical: UiStateStyle.defaultVerticalPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Illustration Icon
            Container(
              width: UiStateStyle.iconContainerSize,
              height: UiStateStyle.iconContainerSize,
              decoration: UiStateStyle.iconContainerDecoration(
                context,
                accentColor: AppColors.accentGold,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: UiStateStyle.iconSize,
                color: AppColors.accentGold,
              ),
            ),

            const SizedBox(height: 20),

            // Headline
            Text(
              title,
              textAlign: TextAlign.center,
              style: UiStateStyle.titleStyle(context),
            ),

            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                searchQuery != null && searchQuery!.isNotEmpty
                    ? 'No results found matching "$searchQuery". Check your spelling or try different filters.'
                    : description,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),

            // Helpful Suggestions Box
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181818) : const Color(0xFFF9F5F3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder.withValues(alpha: 0.6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accentGoldLight : AppColors.primaryBurgundy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...suggestions.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(
                                item,
                                style: UiStateStyle.descriptionStyle(context).copyWith(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 22),

            // Clear Filters Action
            if (onClearFilters != null)
              ElevatedButton.icon(
                onPressed: onClearFilters,
                style: UiStateStyle.primaryButtonStyle(context),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: Text(clearFiltersLabel),
              ),

            // Modify Search Action
            if (onModifySearch != null) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onModifySearch,
                style: UiStateStyle.secondaryButtonStyle(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(modifySearchLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

