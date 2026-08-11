import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> _popularCities = [
    {'name': 'Hyderabad', 'lat': 17.3850, 'lng': 78.4867, 'state': 'Telangana'},
    {'name': 'Bangalore', 'lat': 12.9716, 'lng': 77.5946, 'state': 'Karnataka'},
    {'name': 'Mumbai', 'lat': 19.0760, 'lng': 72.8777, 'state': 'Maharashtra'},
    {'name': 'Delhi NCR', 'lat': 28.7041, 'lng': 77.1025, 'state': 'Delhi'},
    {'name': 'Chennai', 'lat': 13.0827, 'lng': 80.2707, 'state': 'Tamil Nadu'},
    {'name': 'Pune', 'lat': 18.5204, 'lng': 73.8567, 'state': 'Maharashtra'},
  ];

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

    return Container(
      decoration: BoxDecoration(
        color: bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 18),

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Event Location',
                style: AppTypography.heading(context).copyWith(fontSize: 19),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Detect GPS Location Button (With Lat/Long Permission Flow)
          InkWell(
            onTap: _isDetectingGps ? null : _handleGpsFetch,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBurgundy),
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: AppColors.darkBurgundy,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDetectingGps ? 'Fetching GPS Coordinates...' : 'Use Current Location (GPS)',
                          style: AppTypography.subtitle(context).copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.accentGold : AppColors.primaryBurgundy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _gpsCoordinatesText ?? 'Automatically fetch Latitude & Longitude',
                          style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.accentGold),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'Popular Event Cities',
            style: AppTypography.subtitle(context).copyWith(fontSize: 14),
          ),

          const SizedBox(height: 12),

          // City Grid Options
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularCities.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: borderColor),
            itemBuilder: (context, index) {
              final city = _popularCities[index];
              final isSelected = widget.currentSelection.contains(city['name'] as String);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                leading: Icon(
                  Icons.location_city_rounded,
                  color: isSelected ? AppColors.accentGold : (isDark ? Colors.white60 : Colors.black54),
                  size: 20,
                ),
                title: Text(
                  city['name'] as String,
                  style: AppTypography.subtitle(context).copyWith(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.accentGold : null,
                  ),
                ),
                subtitle: Text(
                  '${city['state']} • Lat: ${city['lat']}°, Lng: ${city['lng']}°',
                  style: AppTypography.description(context, isSecondary: true).copyWith(fontSize: 11),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 22)
                    : null,
                onTap: () {
                  final selectedResult = LocationResult(
                    latitude: city['lat'] as double,
                    longitude: city['lng'] as double,
                    formattedAddress: '${city['name']}, India',
                    isGpsLocation: false,
                  );
                  widget.onLocationSelected(selectedResult);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
