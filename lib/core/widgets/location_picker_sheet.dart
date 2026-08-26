import 'package:flutter/material.dart';
import '../services/location_backend_service.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LocationPickerBottomSheet extends StatefulWidget {
  final String currentSelection;
  final ValueChanged<LocationResult> onLocationSelected;

  const LocationPickerBottomSheet({
    super.key,
    required this.currentSelection,
    required this.onLocationSelected,
  });

  @override
  State<LocationPickerBottomSheet> createState() => _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState extends State<LocationPickerBottomSheet> {
  bool _isDetectingGps = false;
  String? _gpsCoordinatesText;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _popularCities = [
    {'name': 'Hyderabad', 'lat': 17.3850, 'lng': 78.4867, 'state': 'Telangana'},
    {'name': 'Bengaluru', 'lat': 12.9716, 'lng': 77.5946, 'state': 'Karnataka'},
    {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777, 'state': 'Maharashtra'},
    {'name': 'Delhi NCR', 'lat': 28.7041, 'lng': 77.1025, 'state': 'Delhi'},
    {'name': 'Chennai', 'lat': 13.0827, 'lng': 80.2707, 'state': 'Tamil Nadu'},
    {'name': 'Pune', 'lat': 18.5204, 'lng': 73.8567, 'state': 'Maharashtra'},
    {'name': 'Kolkata', 'lat': 22.5726, 'lng': 88.3639, 'state': 'West Bengal'},
    {'name': 'Jaipur', 'lat': 26.9124, 'lng': 75.7873, 'state': 'Rajasthan'},
    {'name': 'Ahmedabad', 'lat': 23.0225, 'lng': 72.5714, 'state': 'Gujarat'},
    {'name': 'Chandigarh', 'lat': 30.7333, 'lng': 76.7794, 'state': 'Punjab'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBackendCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBackendCities() async {
    try {
      final cities = await LocationBackendService.instance.getCities();
      if (cities.isNotEmpty && mounted) {
        setState(() {
          _popularCities = cities.map((c) => {
            'name': c.name,
            'lat': c.latitude != 0.0 ? c.latitude : 17.3850,
            'lng': c.longitude != 0.0 ? c.longitude : 78.4867,
            'state': c.stateName ?? 'India',
          }).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _handleGpsFetch() async {
    setState(() {
      _isDetectingGps = true;
    });

    final result = await LocationService.getCurrentLocation();

    if (mounted) {
      setState(() {
        _isDetectingGps = false;
      });

      if (result != null) {
        setState(() {
          _gpsCoordinatesText = 'Lat: ${result.latitude.toStringAsFixed(4)}°, Lng: ${result.longitude.toStringAsFixed(4)}°';
        });

        // Pass captured coordinates & location back
        widget.onLocationSelected(result);
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.darkPrimaryBurgundy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.my_location_rounded, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'GPS Location Updated: ${result.latitude.toStringAsFixed(4)}°, ${result.longitude.toStringAsFixed(4)}°',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied. Please select a city manually.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final filteredCities = _searchQuery.trim().isEmpty
        ? _popularCities
        : _popularCities.where((c) {
            final name = (c['name'] as String).toLowerCase();
            final state = (c['state'] as String).toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || state.contains(query);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle Indicator
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Event Location',
                style: AppTypography.heading(context).copyWith(fontSize: 18),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Detect GPS Location Button
          InkWell(
            onTap: _isDetectingGps ? null : _handleGpsFetch,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBurgundy.withValues(alpha: isDark ? 0.3 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentGold.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: _isDetectingGps
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBurgundy),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.darkBurgundy,
                            size: 18,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDetectingGps ? 'Fetching GPS Coordinates...' : 'Use Current Location (GPS)',
                          style: AppTypography.subtitle(context).copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.accentGold : AppColors.primaryBurgundy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _gpsCoordinatesText ?? 'Automatically fetch coordinates & address',
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Search Field for Cities
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search city or state...',
              hintStyle: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.accentGold),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              filled: true,
              fillColor: isDark ? AppColors.darkCardBg : AppColors.warmIvory,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.accentGold, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Cities (${filteredCities.length})',
            style: AppTypography.subtitle(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          // City List inside Expanded
          Expanded(
            child: filteredCities.isEmpty
                ? Center(
                    child: Text(
                      'No matching cities found',
                      style: AppTypography.description(context, isSecondary: true),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredCities.length,
                    separatorBuilder: (context, index) => Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];
                      final isSelected = widget.currentSelection.toLowerCase().contains((city['name'] as String).toLowerCase());

                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        leading: Icon(
                          Icons.location_city_rounded,
                          color: isSelected ? AppColors.accentGold : (isDark ? Colors.white60 : Colors.black54),
                          size: 18,
                        ),
                        title: Text(
                          city['name'] as String,
                          style: AppTypography.subtitle(context).copyWith(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.accentGold : null,
                          ),
                        ),
                        subtitle: Text(
                          city['state'] as String,
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 20)
                            : null,
                        onTap: () {
                          final selectedResult = LocationResult(
                            latitude: (city['lat'] as num).toDouble(),
                            longitude: (city['lng'] as num).toDouble(),
                            formattedAddress: '${city['name']}, ${city['state']}',
                            isGpsLocation: false,
                          );
                          widget.onLocationSelected(selectedResult);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

