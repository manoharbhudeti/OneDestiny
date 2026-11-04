import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../theme/ui_state_style.dart';

/// State 1 — Reusable Empty State Widget.
///
/// Displayed when a collection or screen has no content yet, without any error.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Widget? customIllustration;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.customIllustration,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(
      horizontal: UiStateStyle.defaultHorizontalPadding,
      vertical: UiStateStyle.defaultVerticalPadding,
    ),
  });

  /// Specialized constructor for Bookings screen when empty.
  factory EmptyStateWidget.noBookings({
    required VoidCallback onExploreVendors,
    String? title,
    String? description,
  }) =>
      EmptyStateWidget(
        title: title ?? 'No Bookings Yet',
        description: description ??
            'Your upcoming celebration bookings will appear here once you connect with verified vendors.',
        icon: Icons.calendar_month_outlined,
        primaryActionLabel: 'Explore Vendors',
        onPrimaryAction: onExploreVendors,
      );

  /// Specialized constructor for Chat screen when empty.
  factory EmptyStateWidget.noConversations({
    required VoidCallback onFindVendors,
  }) =>
      EmptyStateWidget(
        title: 'No Conversations',
        description:
            'Start a direct chat with event vendors to discuss pricing, portfolios, and celebration dates.',
        icon: Icons.chat_bubble_outline_rounded,
        primaryActionLabel: 'Find Vendors',
        onPrimaryAction: onFindVendors,
      );

  /// Specialized constructor for Saved Favorites screen when empty.
  factory EmptyStateWidget.noFavorites({
    required VoidCallback onBrowseVendors,
  }) =>
      EmptyStateWidget(
        title: 'No Saved Vendors',
        description:
            'Tap the heart icon on any vendor profile or card to save your top event choices here.',
        icon: Icons.favorite_border_rounded,
        primaryActionLabel: 'Discover Vendors',
        onPrimaryAction: onBrowseVendors,
      );

  /// Specialized constructor for Notifications center when empty.
  factory EmptyStateWidget.noNotifications() => const EmptyStateWidget(
        title: 'All Caught Up!',
        description:
            'You have no new notifications right now. Check back later for booking updates and offers.',
        icon: Icons.notifications_none_rounded,
      );

  /// Specialized constructor for Vendor app: No booking requests.
  factory EmptyStateWidget.vendorNoRequests({
    required VoidCallback onCompleteProfile,
  }) =>
      EmptyStateWidget(
        title: 'No Booking Requests Yet',
        description:
            'New customer inquiries and booking dates will appear here once your profile is live and verified.',
        icon: Icons.event_note_rounded,
        primaryActionLabel: 'Complete Your Profile',
        onPrimaryAction: onCompleteProfile,
      );

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = accentColor ?? AppColors.accentGold;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Visual Artwork / Icon
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                width: UiStateStyle.iconContainerSize,
                height: UiStateStyle.iconContainerSize,
                decoration: UiStateStyle.iconContainerDecoration(
                  context,
                  accentColor: effectiveAccent,
                ),
                child: Icon(
                  icon ?? Icons.inbox_outlined,
                  size: UiStateStyle.iconSize,
                  color: effectiveAccent,
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
                description,
                textAlign: TextAlign.center,
                style: UiStateStyle.descriptionStyle(context),
              ),
            ),

            if (primaryActionLabel != null && onPrimaryAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onPrimaryAction,
                style: UiStateStyle.primaryButtonStyle(context),
                child: Text(primaryActionLabel!),
              ),
            ],

            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onSecondaryAction,
                style: UiStateStyle.secondaryButtonStyle(context),
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

