import 'package:flutter/material.dart';

import '../../../core/models/notification_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  String _selectedTab = 'All';
  final bool _isLoading = false;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final appState = AppStateScope.of(context);
    final allNotifications = appState.notifications;
    final unreadCount = appState.unreadNotificationCount;

    // Apply Filter
    final filteredNotifications = allNotifications.where((notif) {
      if (_selectedTab == 'Unread') return !notif.isRead;
      if (_selectedTab == 'Bookings') return notif.type == NotificationType.booking;
      if (_selectedTab == 'Messages') return notif.type == NotificationType.message;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Notification Center', style: AppTypography.heading(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                appState.markAllNotificationsAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.darkPrimaryBurgundy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    content: const Text('All notifications marked as read!'),
                  ),
                );
              },
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.accentGold),
              label: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(context)
          : _hasError
              ? _buildErrorState(context)
              : Column(
                  children: [
                    // Category Filter Pills Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: ['All', 'Unread', 'Bookings', 'Messages'].map((tab) {
                            final isSelected = _selectedTab == tab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(tab == 'Unread' && unreadCount > 0 ? 'Unread ($unreadCount)' : tab),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedTab = tab;
                                  });
                                },
                                backgroundColor: cardBg,
                                selectedColor: primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: isSelected ? primaryColor : borderColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Notification List View
                    Expanded(
                      child: filteredNotifications.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notif = filteredNotifications[index];
                                return _buildNotificationTile(context, notif, appState);
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationModel notif, dynamic appState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = notif.isRead
        ? (isDark ? AppColors.darkCardBg : AppColors.warmIvory)
        : (isDark ? AppColors.primaryBurgundy.withValues(alpha: 0.25) : Colors.amber.shade50.withValues(alpha: 0.5));
    final borderColor = notif.isRead
        ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
        : AppColors.accentGold.withValues(alpha: 0.5);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        appState.markNotificationAsRead(notif.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.primaryBurgundy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.accentGold),
            SizedBox(width: 6),
            Text('Mark Read', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notif.isRead) {
            appState.markNotificationAsRead(notif.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: notif.isRead ? 1.0 : 1.3),
            boxShadow: [
              if (!notif.isRead)
                BoxShadow(
                  color: AppColors.accentGold.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notif.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: notif.iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(notif.icon, size: 20, color: notif.iconColor),
              ),

              const SizedBox(width: 14),

              // Title, Body & Timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTypography.subtitle(context).copyWith(
                              fontSize: 15,
                              fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          notif.timestamp,
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notif.message,
                      style: AppTypography.description(context).copyWith(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              if (!notif.isRead) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.accentGold),
          const SizedBox(height: 14),
          Text('No Notifications Available', style: AppTypography.subtitle(context).copyWith(fontSize: 17)),
          const SizedBox(height: 6),
          Text('You are all caught up! Check back later for updates.', style: AppTypography.description(context, isSecondary: true)),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accentGold),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text('Failed to load notifications', style: AppTypography.subtitle(context)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => setState(() => _hasError = false),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
