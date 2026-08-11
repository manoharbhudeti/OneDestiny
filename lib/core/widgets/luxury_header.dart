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

  const LuxuryHeader({
    super.key,
    this.greeting = 'Hello, Manohar 👋',
    this.location = 'Hyderabad, India',
    this.avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    this.onThemeToggle,
    this.onProfileTap,
    this.onNavigateToTab,
    this.onLocationChanged,
  });

  @override
  State<LuxuryHeader> createState() => _LuxuryHeaderState();
}

class _LuxuryHeaderState extends State<LuxuryHeader> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isAvatarPressed = false;
  bool _isGreetingPressed = false;
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
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              opacity: 0.12,
              child: CustomPaint(
                size: const Size(180, 180),
                painter: GoldLineArtPainter(color: AppColors.accentGold),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Bar: Gold Logo on Top Left, Actions on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic Responsive Top-Left Logo (Prominent Compact Luxury Sizing)
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: (MediaQuery.of(context).size.width * 0.65).clamp(160.0, 280.0),
                          maxHeight: 64,
                        ),
                        child: Image.asset(
                          'assets/images/one_destiny_logo_transparent.png',
                          height: 60,
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/one_destiny_logo.png',
                            height: 60,
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),

                    // Actions Row (Theme Toggle & Profile Avatar)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: widget.onThemeToggle,
                          icon: Icon(
                            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: AppColors.accentGold,
                            size: 22,
                          ),
                          tooltip: 'Toggle Theme',
                        ),
                        const SizedBox(width: 4),

                        // Interactive Profile Avatar with Hero Animation & Ripple Feedback
                        GestureDetector(
                          onTapDown: (_) => setState(() => _isAvatarPressed = true),
                          onTapUp: (_) => setState(() => _isAvatarPressed = false),
                          onTapCancel: () => setState(() => _isAvatarPressed = false),
                          child: AnimatedScale(
                            scale: _isAvatarPressed ? 0.92 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Hero(
                              tag: 'user-avatar',
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: widget.onProfileTap,
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accentGold,
                                        width: 1.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.25),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        widget.avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                          backgroundColor: Colors.white24,
                                          child: Icon(Icons.person_outline, color: Colors.white),
                                        ),
                                      ),
                                    ),
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

                const SizedBox(height: 2),

                // Expandable Greeting Section Below Brand Bar
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: _toggleExpansion,
                    onHighlightChanged: (isHighlighted) {
                      setState(() => _isGreetingPressed = isHighlighted);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedScale(
                      scale: _isGreetingPressed ? 0.98 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          widget.greeting,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.heading(context, customColor: Colors.white).copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      RotationTransition(
                                        turns: _iconTurns,
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.accentGold,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  InkWell(
                                    onTap: _openLocationPicker,
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 14,
                                            color: AppColors.accentGold,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _activeLocation,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.description(
                                                context,
                                                customColor: Colors.white.withValues(alpha: 0.85),
                                              ).copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.arrow_drop_down_rounded,
                                            color: AppColors.accentGold,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // EXPANDABLE USER INFORMATION PANEL
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.fastOutSlowIn,
                  alignment: Alignment.topCenter,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Divider(
                              color: AppColors.accentGold.withValues(alpha: 0.3),
                              height: 1,
                            ),
                            const SizedBox(height: 14),

                            // Welcome Back Banner
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, Manohar!',
                                  style: AppTypography.subtitle(context, customColor: Colors.white).copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your luxury event management portal',
                                  style: AppTypography.description(context, customColor: Colors.white70).copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Stats Counter Cards
                            Row(
                              children: [
                                _buildStatCard(
                                  context,
                                  count: '2',
                                  label: 'Bookings',
                                  icon: Icons.event_available_rounded,
                                  onTap: () {
                                    if (widget.onNavigateToTab != null) {
                                      widget.onNavigateToTab!(2);
                                      _toggleExpansion();
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  context,
                                  count: '3',
                                  label: 'Active Chats',
                                  icon: Icons.mark_chat_unread_rounded,
                                  onTap: () {
                                    if (widget.onNavigateToTab != null) {
                                      widget.onNavigateToTab!(3);
                                      _toggleExpansion();
                                    }
                                  },
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  context,
                                  count: '12',
                                  label: 'Saved Vendors',
                                  icon: Icons.favorite_rounded,
                                  onTap: () {},
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Quick Shortcuts Row
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildShortcutItem(
                                    context,
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Events',
                                    onTap: () {
                                      if (widget.onNavigateToTab != null) {
                                        widget.onNavigateToTab!(2);
                                        _toggleExpansion();
                                      }
                                    },
                                  ),
                                  _buildShortcutItem(
                                    context,
                                    icon: Icons.support_agent_rounded,
                                    label: 'Concierge',
                                    onTap: () {
                                      if (widget.onNavigateToTab != null) {
                                        widget.onNavigateToTab!(3);
                                        _toggleExpansion();
                                      }
                                    },
                                  ),
                                  _buildShortcutItem(
                                    context,
                                    icon: Icons.card_giftcard_rounded,
                                    label: 'Rewards',
                                    onTap: () {},
                                  ),
                                  _buildShortcutItem(
                                    context,
                                    icon: Icons.settings_rounded,
                                    label: 'Settings',
                                    onTap: () {
                                      if (widget.onProfileTap != null) {
                                        widget.onProfileTap!();
                                        _toggleExpansion();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildStatCard(
    BuildContext context, {
    required String count,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
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
                      count,
                      style: AppTypography.heading(context, customColor: Colors.white).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.description(context, customColor: Colors.white.withValues(alpha: 0.8)).copyWith(
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

  Widget _buildShortcutItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.accentGold),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.description(context, customColor: Colors.white).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

