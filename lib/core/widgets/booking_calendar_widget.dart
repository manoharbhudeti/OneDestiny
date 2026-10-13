import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BookingCalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? selectedDate;
  final Set<DateTime> blockedDates;
  final Set<DateTime> bookedDates;
  final Function(DateTime)? onDateSelected;
  final bool disablePastDates;
  final bool showLegend;
  final EdgeInsets padding;

  const BookingCalendarWidget({
    super.key,
    required this.initialDate,
    this.selectedDate,
    this.blockedDates = const {},
    this.bookedDates = const {},
    this.onDateSelected,
    this.disablePastDates = true,
    this.showLegend = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  State<BookingCalendarWidget> createState() => _BookingCalendarWidgetState();
}

class _BookingCalendarWidgetState extends State<BookingCalendarWidget> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final init = widget.selectedDate ?? widget.initialDate;
    _currentMonth = DateTime(init.year, init.month, 1);
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(covariant BookingCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        _selectedDate = widget.selectedDate;
        if (widget.selectedDate != null) {
          _currentMonth = DateTime(widget.selectedDate!.year, widget.selectedDate!.month, 1);
        }
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isBlocked(DateTime date) {
    return widget.blockedDates.any((d) => _isSameDay(d, date));
  }

  bool _isBooked(DateTime date) {
    return widget.bookedDates.any((d) => _isSameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7; // 0 = Sun
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Month & Year Selector Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, color: primaryTextColor),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, color: primaryTextColor),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Days of Week Header
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentGold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Monthly Days Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: firstWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              final dayNumber = index - firstWeekday + 1;
              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isPast = date.isBefore(todayMidnight);
              final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
              final isBlocked = _isBlocked(date);
              final isBooked = _isBooked(date);

              Color bgColor = Colors.transparent;
              Color textColor = primaryTextColor;
              Border? border;

              if (isSelected) {
                bgColor = AppColors.accentGold;
                textColor = Colors.black;
              } else if (isPast && widget.disablePastDates) {
                textColor = isDark ? Colors.white24 : Colors.black26;
              } else if (isBooked) {
                bgColor = AppColors.primaryBurgundy.withValues(alpha: 0.2);
                textColor = AppColors.primaryBurgundy;
                border = Border.all(color: AppColors.primaryBurgundy, width: 1.2);
              } else if (isBlocked) {
                bgColor = Colors.red.withValues(alpha: 0.15);
                textColor = Colors.redAccent;
              }

              return InkWell(
                onTap: (isPast && widget.disablePastDates)
                    ? null
                    : () {
                        setState(() {
                          _selectedDate = date;
                        });
                        widget.onDateSelected?.call(date);
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: border,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: textColor,
                          decoration: isBlocked && !isSelected ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (isBooked && !isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (widget.showLegend) ...[
            const SizedBox(height: 14),

            // Legend Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(AppColors.accentGold, 'Selected'),
                _buildLegendItem(AppColors.primaryBurgundy, 'Vendor Booked'),
                _buildLegendItem(Colors.redAccent, 'Blocked Date'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
