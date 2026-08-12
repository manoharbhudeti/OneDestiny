import 'package:flutter/material.dart';

import '../../../core/models/vendor_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../chat/views/chat_detail_screen.dart';

class VendorDetailScreen extends StatelessWidget {
  final VendorModel vendor;

  const VendorDetailScreen({
    super.key,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final currentVendor = appState.vendorById(vendor.id) ?? vendor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    currentVendor.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.accentGold, size: 42),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentVendor.category.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentVendor.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.heading(context, customColor: Colors.white).copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                tooltip: currentVendor.isFavorite ? 'Remove favorite' : 'Save vendor',
                onPressed: () => AppStateScope.read(context).toggleFavorite(currentVendor.id),
                icon: Icon(
                  currentVendor.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: currentVendor.isFavorite ? AppColors.accentGold : Colors.white,
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  Row(
                    children: [
                      _InfoPill(icon: Icons.star_rounded, label: currentVendor.rating.toStringAsFixed(1)),
                      const SizedBox(width: 10),
                      _InfoPill(icon: Icons.location_on_outlined, label: '${currentVendor.distanceKm} km'),
                      const SizedBox(width: 10),
                      Expanded(child: _InfoPill(icon: Icons.currency_rupee_rounded, label: currentVendor.formattedPrice)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Overview', style: AppTypography.subtitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    '${currentVendor.name} offers premium ${currentVendor.category.toLowerCase()} services for weddings, birthdays, corporate events, and private celebrations around ${currentVendor.location}.',
                    style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Text('Packages', style: AppTypography.subtitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _PackageTile(
                    title: 'Essential',
                    subtitle: 'Core service coverage with standard coordination',
                    price: currentVendor.formattedPrice,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 10),
                  _PackageTile(
                    title: 'Premium',
                    subtitle: 'Priority planning, custom styling, and dedicated support',
                    price: 'Custom quote',
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                  ),
                  const SizedBox(height: 24),
                  Text('Why customers choose this vendor', style: AppTypography.subtitle(context).copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _FeatureRow(icon: Icons.verified_rounded, text: 'Verified portfolio and consistent customer ratings'),
                  _FeatureRow(icon: Icons.event_available_rounded, text: 'Booking request flow ready for event date planning'),
                  _FeatureRow(icon: Icons.chat_bubble_outline_rounded, text: 'Direct conversation channel with vendor team'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final conversation = AppStateScope.read(context).conversationForVendor(currentVendor);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(conversationId: conversation.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: AppColors.accentGold.withValues(alpha: 0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppStateScope.read(context).createBookingForVendor(currentVendor);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkPrimaryBurgundy,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        content: Text('Booking request created for ${currentVendor.name}.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentGold),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.description(context).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color surfaceColor;
  final Color borderColor;

  const _PackageTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.surfaceColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: AppColors.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitle(context).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(price, style: AppTypography.subtitle(context, customColor: Theme.of(context).colorScheme.primary).copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTypography.description(context))),
        ],
      ),
    );
  }
}
