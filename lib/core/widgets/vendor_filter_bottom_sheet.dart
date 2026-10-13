import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

import 'booking_calendar_widget.dart';

/// Comprehensive filter and sorting bottom sheet supporting Price,
/// Minimum Rating, Sorting, and Day/Date Availability criteria.
class VendorFilterBottomSheet extends StatefulWidget {
  final double currentMinPrice;
  final double currentMaxPrice;
  final double currentMinRating;
  final String currentSortBy;
  final DateTime? currentSelectedDate;
  final Function({
    required double minPrice,
    required double maxPrice,
    required double minRating,
    required String sortBy,
    DateTime? selectedDate,
  }) onApply;
  final VoidCallback onReset;

  const VendorFilterBottomSheet({
    super.key,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentMinRating,
    required this.currentSortBy,
    this.currentSelectedDate,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<VendorFilterBottomSheet> createState() => _VendorFilterBottomSheetState();
}

class _VendorFilterBottomSheetState extends State<VendorFilterBottomSheet> {
  late RangeValues _priceRange;
  late double _selectedMinRating;
  late String _selectedSortBy;
  DateTime? _selectedDate;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(widget.currentMinPrice, widget.currentMaxPrice);
    _selectedMinRating = widget.currentMinRating;
    _selectedSortBy = widget.currentSortBy;
    _selectedDate = widget.currentSelectedDate;

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    if (_selectedDate != null && !_isSameDay(_selectedDate!, now) && !_isSameDay(_selectedDate!, tomorrow)) {
      _showCalendar = true;
    }
  }

  String _formatDateShort(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sheet Title & Reset
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.accentGold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Filter & Sort Vendors',
                      style: AppTypography.heading(context).copyWith(fontSize: 18),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.error),
                  label: const Text('Reset All', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                ),
              ],
            ),
            const Divider(height: 20),

            // ==========================================
            // 1. DAY / DATE AVAILABILITY CRITERIA
            // ==========================================
            Row(
              children: [
                const Icon(Icons.event_available_rounded, color: AppColors.accentGold, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Availability Day / Date',
                  style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Show vendors available on your chosen date. Unavailable vendors are hidden when a date is selected.',
              style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Any Day (Unfiltered)
                ChoiceChip(
                  label: const Text('Any Day (All)'),
                  selected: _selectedDate == null,
                  selectedColor: AppColors.accentGold,
                  labelStyle: TextStyle(
                    color: _selectedDate == null ? Colors.black : (isDark ? Colors.white : Colors.black87),
                    fontWeight: _selectedDate == null ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDate = null;
                        _showCalendar = false;
                      });
                    }
                  },
                ),

                // Today
                ChoiceChip(
                  label: Text('Today (${_weekdayName(now.weekday)})'),
                  selected: _selectedDate != null && _isSameDay(_selectedDate!, now),
                  selectedColor: AppColors.accentGold,
                  labelStyle: TextStyle(
                    color: (_selectedDate != null && _isSameDay(_selectedDate!, now))
                        ? Colors.black
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: (_selectedDate != null && _isSameDay(_selectedDate!, now))
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDate = now;
                      });
                    }
                  },
                ),

                // Tomorrow
                ChoiceChip(
                  label: Text('Tomorrow (${_weekdayName(tomorrow.weekday)})'),
                  selected: _selectedDate != null && _isSameDay(_selectedDate!, tomorrow),
                  selectedColor: AppColors.accentGold,
                  labelStyle: TextStyle(
                    color: (_selectedDate != null && _isSameDay(_selectedDate!, tomorrow))
                        ? Colors.black
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: (_selectedDate != null && _isSameDay(_selectedDate!, tomorrow))
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDate = tomorrow;
                      });
                    }
                  },
                ),

                // Custom Date / Calendar
                ChoiceChip(
                  avatar: Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: (_showCalendar || (_selectedDate != null && !_isSameDay(_selectedDate!, now) && !_isSameDay(_selectedDate!, tomorrow)))
                        ? Colors.black
                        : AppColors.accentGold,
                  ),
                  label: Text(
                    _selectedDate != null && !_isSameDay(_selectedDate!, now) && !_isSameDay(_selectedDate!, tomorrow)
                        ? _formatDateShort(_selectedDate!)
                        : 'Calendar 📅',
                  ),
                  selected: _showCalendar || (_selectedDate != null && !_isSameDay(_selectedDate!, now) && !_isSameDay(_selectedDate!, tomorrow)),
                  selectedColor: AppColors.accentGold,
                  labelStyle: TextStyle(
                    color: (_showCalendar || (_selectedDate != null && !_isSameDay(_selectedDate!, now) && !_isSameDay(_selectedDate!, tomorrow)))
                        ? Colors.black
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _showCalendar = selected;
                    });
                  },
                ),
              ],
            ),

            // Inline Luxury Booking Calendar Widget
            if (_showCalendar) ...[
              const SizedBox(height: 12),
              BookingCalendarWidget(
                initialDate: _selectedDate ?? now,
                selectedDate: _selectedDate,
                disablePastDates: true,
                showLegend: false,
                padding: const EdgeInsets.all(12),
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ],

            if (_selectedDate != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Filtering for: ${_formatDateShort(_selectedDate!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() {
                        _selectedDate = null;
                        _showCalendar = false;
                      }),
                      child: const Icon(Icons.close_rounded, size: 14, color: AppColors.accentGold),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ==========================================
            // 2. PRICE RANGE
            // ==========================================
            Text(
              'Starting Price Range',
              style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('₹${_priceRange.start.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentGold)),
                Text('₹${_priceRange.end.toInt()}+',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentGold)),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 500000,
              divisions: 100,
              activeColor: AppColors.accentGold,
              inactiveColor: isDark ? Colors.white12 : Colors.grey.shade300,
              labels: RangeLabels('₹${_priceRange.start.toInt()}', '₹${_priceRange.end.toInt()}'),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),

            const SizedBox(height: 14),

            // ==========================================
            // 3. MINIMUM RATING
            // ==========================================
            Text(
              'Minimum Rating',
              style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                  final isSelected = _selectedMinRating == rating;
                  final label = rating == 0.0 ? 'Any' : '$rating★ & up';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppColors.accentGold,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMinRating = rating);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // ==========================================
            // 4. SORT BY
            // ==========================================
            Text(
              'Sort By',
              style: AppTypography.subtitle(context).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sortChip('popular', 'Recommended'),
                _sortChip('price_low_high', 'Price: Low to High'),
                _sortChip('price_high_low', 'Price: High to Low'),
                _sortChip('rating_high', 'Top Rated'),
              ],
            ),

            const SizedBox(height: 22),

            // ==========================================
            // 5. APPLY CTA BUTTON
            // ==========================================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    minPrice: _priceRange.start,
                    maxPrice: _priceRange.end,
                    minRating: _selectedMinRating,
                    sortBy: _selectedSortBy,
                    selectedDate: _selectedDate,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.accentGold : AppColors.primaryBurgundy,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('APPLY FILTERS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String value, String label) {
    final isSelected = _selectedSortBy == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentGold,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedSortBy = value);
      },
    );
  }
}
