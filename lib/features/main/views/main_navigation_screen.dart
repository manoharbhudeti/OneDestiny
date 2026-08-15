import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../bookings/views/bookings_screen.dart';
import '../../chat/views/chat_screen.dart';
import '../../explore/views/explore_screen.dart';
import '../../home/views/home_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const MainNavigationScreen({
    super.key,
    required this.themeModeNotifier,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _screens = [
      HomeScreen(
        themeModeNotifier: widget.themeModeNotifier,
        onNavigateToTab: _onTabTapped,
      ),
      const ExploreScreen(),
      const BookingsScreen(),
      const ChatScreen(),
      ProfileScreen(themeModeNotifier: widget.themeModeNotifier),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Footer background: pitch dark surface in dark mode, burgundy in light mode
    final navBgColor = isDark ? AppColors.darkSurface : AppColors.primaryBurgundy;
    // Footer active indicator pill: Gold/Yellow in dark mode, Dark Burgundy in light mode
    final pillColor = isDark ? AppColors.accentGold : AppColors.darkBurgundy;
    final borderColor = isDark ? AppColors.accentGold.withValues(alpha: 0.4) : AppColors.accentGold.withValues(alpha: 0.4);
    
    // Active icon color: Pitch Dark in dark mode (on gold pill), Gold in light mode (on dark burgundy pill)
    final activeColor = isDark ? const Color(0xFF0A0A0A) : AppColors.accentGold;
    final unselectedColor = Colors.white.withValues(alpha: 0.65);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),

      // Floating Premium Bottom Navigation Bar with Continuous Sliding Solid Burgundy Pill Indicator
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          height: 66,
          decoration: BoxDecoration(
            color: navBgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / 5;
                final pillWidth = itemWidth - 6;

                return Stack(
                  children: [
                    // Smooth Animated Sliding Indicator (Rounded Capsule Pill Shape)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      left: _currentIndex * itemWidth + 3,
                      top: 2,
                      bottom: 2,
                      width: pillWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: pillColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Navigation Items Row
                    Row(
                      children: [
                        _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home', activeColor, unselectedColor),
                        _buildNavItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore', activeColor, unselectedColor),
                        _buildNavItem(2, Icons.bookmark_rounded, Icons.bookmark_outline_rounded, 'Bookings', activeColor, unselectedColor),
                        _buildNavItem(3, Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Chat', activeColor, unselectedColor, badgeCount: 2),
                        _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile', activeColor, unselectedColor),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    Color activeColor,
    Color inactiveColor, {
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(20),
        splashColor: activeColor.withValues(alpha: 0.15),
        highlightColor: activeColor.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          transform: Matrix4.translationValues(0, isSelected ? -3 : 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedScale(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastOutSlowIn,
                    scale: isSelected ? 1.08 : 1.0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: Icon(
                        isSelected ? activeIcon : inactiveIcon,
                        key: ValueKey('${index}_$isSelected'),
                        color: isSelected ? activeColor : inactiveColor,
                        size: 21,
                      ),
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -3,
                      right: -6,
                      child: ScaleTransition(
                        scale: _pulseScale,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.fastOutSlowIn,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? 0.2 : 0,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

