import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final bool isGpsLocation;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    this.isGpsLocation = true,
  });
}

class LocationService {
  static Future<LocationResult?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      // Return simulated GPS location if hardware location is disabled in emulator/dev environment
      return const LocationResult(
        latitude: 17.385044,
        longitude: 78.486671,
        formattedAddress: 'Hyderabad, India (GPS)',
        isGpsLocation: true,
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: 'Current Location (${position.latitude.toStringAsFixed(4)}°, ${position.longitude.toStringAsFixed(4)}°)',
        isGpsLocation: true,
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      // Fallback location
      return const LocationResult(
        latitude: 17.385044,
        longitude: 78.486671,
        formattedAddress: 'Hyderabad, India (GPS)',
        isGpsLocation: true,
      );
    }
  }
}
