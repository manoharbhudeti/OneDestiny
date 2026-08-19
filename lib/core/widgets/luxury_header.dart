import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'location_picker_sheet.dart';

class LuxuryHeader extends StatefulWidget {
  final String greeting;
  final String location;
  final String avatarUrl;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onProfileTap;
  final ValueChanged<int>? onNavigateToTab;
  final ValueChanged<LocationResult>? onLocationChanged;
  final int bookingCount;
  final int activeChatCount;
  final int savedVendorCount;

  const LuxuryHeader({
    super.key,
    this.greeting = 'Hello, Manohar 👋',
    this.location = 'Hyderabad, India',
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    this.onThemeToggle,
    this.onProfileTap,
    this.onNavigateToTab,
    this.onLocationChanged,
    this.bookingCount = 0,
    this.activeChatCount = 0,
    this.savedVendorCount = 0,
  });

  @override
  State<LuxuryHeader> createState() => _LuxuryHeaderState();
}

class _LuxuryHeaderState extends State<LuxuryHeader> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isAvatarPressed = false;
  late String _activeLocation;

  late final AnimationController _expandController;
  late final Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _activeLocation = widget.location;
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconTurns = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: Curves.fastOutSlowIn,
      ),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LuxuryHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _activeLocation = widget.location;
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _openLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerBottomSheet(
        currentSelection: _activeLocation,
        onLocationSelected: (locationResult) {
          setState(() {
            _activeLocation = locationResult.formattedAddress;
          });
          widget.onLocationChanged?.call(locationResult);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = isDark ? AppColors.darkSurface : primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Gold Line Art Graphic Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.10,
              child: CustomPaint(
                size: const Size(140, 140),
                painter: GoldLineArtPainter(color: AppColors.accentGold),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Fixed Compact Row: Logo + Greeting + Location on Left, Actions on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Logo + Greeting & Location side by side
                    Expanded(
                      child: Row(
                        children: [
                          // Sharp Logo without tagline
                          Image.asset(
                            'assets/images/one_destiny_logo_transparent.png',
                            height: 46,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/one_destiny_logo.png',
                              height: 46,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Hello Manohar & Location dropdown right beside logo
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: _toggleExpansion,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.greeting,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.heading(context, customColor: Colors.white).copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      RotationTransition(
                                        turns: _iconTurns,
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.accentGold,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                InkWell(
                                  onTap: _openLocationPicker,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 12,
                                        color: AppColors.accentGold,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          _activeLocation,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.description(
                                            context,
                                            customColor: Colors.white.withValues(alpha: 0.85),
                                          ).copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: AppColors.accentGold,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Actions Row: Notifications Bell, Dynamic Animated Theme Toggle & Profile Avatar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Notification Bell Icon with Badge Indicator
                        Stack(
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () => _showNotificationsSheet(context),
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.accentGold,
                                size: 22,
                              ),
                              tooltip: 'Notifications',
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),

                        // Dynamic Animated Theme Switcher Icon
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 380),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return RotationTransition(
                              turns: Tween<double>(begin: 0.25, end: 1.0).animate(animation),
                              child: ScaleTransition(scale: animation, child: child),
                            );
                          },
                          child: IconButton(
                            key: ValueKey<bool>(isDark),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: widget.onThemeToggle,
                            icon: Icon(
                              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                              color: AppColors.accentGold,
                              size: 20,
                            ),
                            tooltip: 'Toggle Theme',
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Interactive Profile Avatar
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isAvatarPressed = true),
                          onTapUp: (_) => setState(() => _isAvatarPressed = false),
                          onTapCancel: () => setState(() => _isAvatarPressed = false),
                          child: AnimatedScale(
                            scale: _isAvatarPressed ? 0.92 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: widget.onProfileTap,
                                customBorder: const CircleBorder(),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.accentGold,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _buildHeaderAvatarImage(widget.avatarUrl),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // EXPANDABLE USER SUMMARY & STATS PANEL
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Divider(
                              color: AppColors.accentGold.withValues(alpha: 0.3),
                              height: 1,
                            ),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quick Summary',
                                  style: AppTypography.subtitle(context, customColor: Colors.white).copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                InkWell(
                                  onTap: widget.onProfileTap,
                                  child: const Text(
                                    'View Profile ›',
                                    style: TextStyle(
                                      color: AppColors.accentGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Stats Counter Cards
                            Row(
                              children: [
                                _buildHeaderStatCard(
                                  context,
                                  title: 'Bookings',
                                  value: '${widget.bookingCount}',
                                  icon: Icons.calendar_month_rounded,
                                  onTap: () {
                                    _toggleExpansion();
                                    widget.onNavigateToTab?.call(2);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderStatCard(
                                  context,
                                  title: 'Active Chats',
                                  value: '${widget.activeChatCount}',
                                  icon: Icons.chat_bubble_rounded,
                                  onTap: () {
                                    _toggleExpansion();
                                    widget.onNavigateToTab?.call(3);
                                  },
                                ),
                                const SizedBox(width: 8),
                                _buildHeaderStatCard(
                                  context,
                                  title: 'Saved Vendors',
                                  value: '${widget.savedVendorCount}',
                                  icon: Icons.favorite_rounded,
                                  onTap: () {
                                    _toggleExpansion();
                                    widget.onNavigateToTab?.call(1);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 14, color: AppColors.accentGold),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: AppTypography.heading(context, customColor: Colors.white).copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.description(context, customColor: Colors.white.withValues(alpha: 0.85)).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAvatarImage(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person_outline, color: Colors.white, size: 18),
        ),
      );
    } else if (url.startsWith('data:image/')) {
      try {
        final base64Str = url.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline, color: Colors.white, size: 18),
          ),
        );
      } catch (_) {
        return const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person_outline, color: Colors.white, size: 18),
        );
      }
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person_outline, color: Colors.white, size: 18),
        ),
      );
    }
  }

  void _showNotificationsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.accentGold.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: AppColors.accentGold, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: AppTypography.heading(context).copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notifications marked as read'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Mark all as read', style: TextStyle(color: AppColors.accentGold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    _buildNotificationCard(
                      context,
                      title: 'Booking Confirmed 🎉',
                      message: 'Your booking for Royal Palace Resort & Convention has been confirmed.',
                      time: '10m ago',
                      icon: Icons.check_circle_rounded,
                      iconColor: AppColors.success,
                      isUnread: true,
                    ),
                    _buildNotificationCard(
                      context,
                      title: 'Exclusive Offer 💎',
                      message: 'Get 20% off on all Luxury Catering services this weekend.',
                      time: '1h ago',
                      icon: Icons.local_offer_rounded,
                      iconColor: AppColors.accentGold,
                      isUnread: true,
                    ),
                    _buildNotificationCard(
                      context,
                      title: 'New Message 💬',
                      message: 'Grand Ballroom Decor: "Hello Manohar, we have updated your layout proposal."',
                      time: '3h ago',
                      icon: Icons.chat_rounded,
                      iconColor: AppColors.primaryBurgundy,
                      isUnread: false,
                    ),
                    _buildNotificationCard(
                      context,
                      title: 'Reminder 📅',
                      message: 'Your event consultation is scheduled for tomorrow at 3:00 PM.',
                      time: '1d ago',
                      icon: Icons.event_rounded,
                      iconColor: Colors.blueAccent,
                      isUnread: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isUnread,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread
            ? (isDark ? AppColors.primaryBurgundy.withValues(alpha: 0.25) : AppColors.warmIvory)
            : (isDark ? AppColors.darkCardBg : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.accentGold.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      time,
                      style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTypography.description(context).copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/// Subtle Gold Vector Line Art Painter (Rings, Vines, Mandalas)
class GoldLineArtPainter extends CustomPainter {
  final Color color;

  GoldLineArtPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width * 0.7, size.height * 0.3);
    canvas.drawCircle(center, 40, paint);
    canvas.drawCircle(center, 65, paint);
    canvas.drawCircle(center, 90, paint);

    final path = Path();
    path.moveTo(0, size.height);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.7,
      size.width * 0.6,
      size.height * 0.9,
      size.width,
      size.height * 0.2,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
