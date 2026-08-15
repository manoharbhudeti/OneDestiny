import 'package:flutter/material.dart';
import '../../../core/models/booking_model.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/booking_calendar_widget.dart';
import '../../chat/views/chat_detail_screen.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late BookingModel _currentBooking;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = AppStateScope.of(context);
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final isAcceptedOrConfirmed = _currentBooking.status == 'CONFIRMED' ||
        _currentBooking.status == 'VENDOR ACCEPTED' ||
        _currentBooking.status == 'IN PROGRESS';

    // Mock vendor blocked and booked dates for calendar demonstration
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
      appBar: AppBar(
        title: Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Card Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _currentBooking.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.primaryBurgundy.withValues(alpha: 0.2),
                        child: const Icon(Icons.storefront_rounded, color: AppColors.accentGold, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _currentBooking.title,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(_currentBooking.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentBooking.category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.accentGold),
                            const SizedBox(width: 4),
                            Text(
                              _currentBooking.location,
                              style: TextStyle(fontSize: 12, color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Request Workflow Timeline Tracker
            Text(
              'Request Workflow',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusTimeline(isDark),
            const SizedBox(height: 22),

            // Vendor Availability & Blocked Dates Calendar
            Text(
              'Vendor Availability Calendar',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dates marked in red or burgundy are blocked by vendor or already booked.',
              style: TextStyle(fontSize: 12, color: secondaryTextColor),
            ),
            const SizedBox(height: 12),
            BookingCalendarWidget(
              initialDate: now,
              bookedDates: bookedDates,
              blockedDates: blockedDates,
              onDateSelected: (date) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Selected date: ${date.day}/${date.month}/${date.year}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // Event & Booking Details Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Details Summary',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Booking Ref ID', _currentBooking.id, primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 10),
                  _buildDetailRow('Event Date', _currentBooking.dateLabel, primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 10),
                  _buildDetailRow('Event Location', _currentBooking.location, primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 10),
                  _buildDetailRow('Estimated Amount', _currentBooking.amount, AppColors.accentGold, secondaryTextColor, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Direct Chat Action Button (Active when vendor accepts)
            if (isAcceptedOrConfirmed)
              ElevatedButton.icon(
                onPressed: () {
                  final vendor = appState.vendorById(_currentBooking.vendorId);
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
                icon: const Icon(Icons.chat_bubble_rounded, color: Colors.black),
                label: const Text(
                  'Chat with Vendor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),

            if (isAcceptedOrConfirmed) const SizedBox(height: 14),

            // Cancel / Modify Request Button
            OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              label: const Text(
                'Cancel Booking Request',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.redAccent),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.primaryBurgundy.withValues(alpha: 0.15);
    Color text = AppColors.primaryBurgundy;

    if (status == 'CONFIRMED' || status == 'VENDOR ACCEPTED') {
      bg = AppColors.success.withValues(alpha: 0.15);
      text = AppColors.success;
    } else if (status == 'REQUESTED' || status == 'WAITING FOR VENDOR') {
      bg = AppColors.warning.withValues(alpha: 0.15);
      text = AppColors.warning;
    } else if (status == 'CANCELLED') {
      bg = Colors.red.withValues(alpha: 0.15);
      text = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(bool isDark) {
    final steps = [
      {'title': 'Requested', 'done': true},
      {'title': 'Vendor Reviewing', 'done': true},
      {'title': 'Vendor Accepted', 'done': _currentBooking.status == 'CONFIRMED' || _currentBooking.status == 'VENDOR ACCEPTED'},
      {'title': 'Confirmed', 'done': _currentBooking.status == 'CONFIRMED'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          final isDone = step['done'] as bool;
          final isLast = idx == steps.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? AppColors.accentGold : Colors.grey.withValues(alpha: 0.3),
                        ),
                        child: Icon(
                          isDone ? Icons.check_rounded : Icons.hourglass_empty_rounded,
                          size: 14,
                          color: isDone ? (isDark ? Colors.black : Colors.white) : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? AppColors.accentGold : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 20,
                    height: 2,
                    color: isDone ? AppColors.accentGold : Colors.grey.withValues(alpha: 0.3),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color textColor, Color labelColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: labelColor)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking Request?'),
        content: const Text('Are you sure you want to cancel this booking request? The vendor will be notified.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentBooking = BookingModel(
                  id: _currentBooking.id,
                  vendorId: _currentBooking.vendorId,
                  title: _currentBooking.title,
                  category: _currentBooking.category,
                  dateLabel: _currentBooking.dateLabel,
                  location: _currentBooking.location,
                  amount: _currentBooking.amount,
                  status: 'CANCELLED',
                  imageUrl: _currentBooking.imageUrl,
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking request cancelled.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
