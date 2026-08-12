import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/vendor_card.dart';
import '../../vendor_detail/views/vendor_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoriteVendors = appState.favoriteVendors;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Saved Favorites', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: favoriteVendors.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text('No saved vendors yet', style: AppTypography.subtitle(context)),
                  ],
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.75,
                ),
                itemCount: favoriteVendors.length,
                itemBuilder: (context, index) {
                  final vendor = favoriteVendors[index];
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
    );
  }
}
