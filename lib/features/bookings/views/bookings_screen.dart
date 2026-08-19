import 'package:flutter/material.dart';

import '../../../core/models/booking_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/booking_calendar_widget.dart';
import '../../chat/views/chat_detail_screen.dart';
import 'booking_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with AutomaticKeepAliveClientMixin {
  bool _showCalendar = false;
  String _selectedStatusFilter = 'ALL';

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allBookings = appState.bookings;

    final filteredBookings = allBookings.where((b) {
      if (_selectedStatusFilter == 'ALL') return true;
      return b.status == _selectedStatusFilter;
    }).toList();

    final now = DateTime.now();
    final bookedDates = {
      DateTime(now.year, now.month, 24),
      DateTime(now.year, now.month, 25),
    };
    final blockedDates = {
      DateTime(now.year, now.month, 10),
      DateTime(now.year, now.month, 15),
      DateTime(now.year, now.month, 18),
    };

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('My Bookings & Requests', style: AppTypography.heading(context)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: _showCalendar ? 'Hide Calendar' : 'Show Vendor Calendar',
            icon: Icon(
              _showCalendar ? Icons.view_list_rounded : Icons.calendar_month_rounded,
              color: AppColors.accentGold,
            ),
            onPressed: () {
              setState(() {
                _showCalendar = !_showCalendar;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accentGold,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          onRefresh: () => appState.refreshBookings(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vendor Calendar Highlight View (Toggleable)
              if (_showCalendar) ...[
                Text(
                  'Vendor Availability Calendar',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dates highlighted in burgundy or red are blocked by vendors or already booked.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                BookingCalendarWidget(
                  initialDate: now,
                  bookedDates: bookedDates,
                  blockedDates: blockedDates,
                  onDateSelected: (date) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Inspecting vendor availability for: ${date.day}/${date.month}/${date.year}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Filter Tabs Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('ALL', 'All Requests', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('REQUESTED', 'Requested', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('CONFIRMED', 'Confirmed', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('COMPLETED', 'Completed', isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bookings List
              filteredBookings.isEmpty
                  ? Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: Text(
                        'No bookings match selected filter',
                        style: AppTypography.subtitle(context),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return _BookingCard(booking: booking);
                      },
                    ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildFilterChip(String statusKey, String label, bool isDark) {
    final isSelected = _selectedStatusFilter == statusKey;
    final activeBg = isDark ? AppColors.accentGold : AppColors.primaryBurgundy;
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inactiveText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatusFilter = statusKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeBg : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightDivider;
    final isConfirmed = booking.status == 'CONFIRMED' || booking.status == 'VENDOR ACCEPTED';
    final statusColor = isConfirmed ? AppColors.success : AppColors.warning;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingDetailScreen(booking: booking),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    booking.imageUrl,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.primaryBurgundy.withValues(alpha: 0.2),
                      child: const Icon(Icons.storefront_rounded, color: AppColors.accentGold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.title, style: AppTypography.subtitle(context)),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${booking.dateLabel} • ${booking.location}',
                        style: AppTypography.description(context, isSecondary: true),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.status.replaceAll('_', ' '),
                              style: AppTypography.description(context).copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              booking.amount,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.description(context, customColor: AppColors.accentGold).copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold),
              ],
            ),
            if (isConfirmed) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Vendor Accepted Request',
                    style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final vendor = appState.vendorById(booking.vendorId);
                      final conversation = vendor != null
                          ? appState.conversationForVendor(vendor)
                          : appState.filteredConversations.first;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(conversationId: conversation.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 14, color: Colors.black),
                    label: const Text(
                      'Chat',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
