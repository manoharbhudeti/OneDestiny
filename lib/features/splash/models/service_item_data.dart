import 'package:flutter/material.dart';

class SplashServiceItem {
  final String id;
  final String title;
  final IconData icon;
  final double baseAngle; // angle around the circle in radians
  final double orbitRadiusMultiplier; // multiplier relative to calculated max radius
  final double depth; // 0.6 (far) to 1.0 (near)
  final Offset entryOffset; // normalized direction vector for entrance

  const SplashServiceItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.baseAngle,
    required this.orbitRadiusMultiplier,
    required this.depth,
    required this.entryOffset,
  });
}

class SplashServiceData {
  static const List<SplashServiceItem> services = [
    SplashServiceItem(
      id: 'photography',
      title: 'Wedding Photography',
      icon: Icons.camera_alt_rounded,
      baseAngle: -1.57, // Top (12 o'clock)
      orbitRadiusMultiplier: 0.82,
      depth: 1.0,
      entryOffset: Offset(0, -1.2),
    ),
    SplashServiceItem(
      id: 'videography',
      title: 'Wedding Videography',
      icon: Icons.videocam_rounded,
      baseAngle: 1.57, // Bottom (6 o'clock)
      orbitRadiusMultiplier: 0.85,
      depth: 0.95,
      entryOffset: Offset(0, 1.2),
    ),
    SplashServiceItem(
      id: 'makeup',
      title: 'Makeup Artists',
      icon: Icons.face_retouching_natural_rounded,
      baseAngle: -2.5, // Top Left (~10 o'clock)
      orbitRadiusMultiplier: 0.92,
      depth: 0.85,
      entryOffset: Offset(-1.2, -0.6),
    ),
    SplashServiceItem(
      id: 'catering',
      title: 'Catering',
      icon: Icons.restaurant_rounded,
      baseAngle: 2.5, // Bottom Left (~7:30 o'clock)
      orbitRadiusMultiplier: 0.88,
      depth: 0.88,
      entryOffset: Offset(-1.2, 0.6),
    ),
    SplashServiceItem(
      id: 'decoration',
      title: 'Decoration',
      icon: Icons.auto_awesome_rounded,
      baseAngle: 0.6, // Bottom Right (~4:30 o'clock)
      orbitRadiusMultiplier: 0.90,
      depth: 0.9,
      entryOffset: Offset(1.2, 0.6),
    ),
    SplashServiceItem(
      id: 'venue',
      title: 'Venue',
      icon: Icons.location_city_rounded,
      baseAngle: -0.6, // Top Right (~2 o'clock)
      orbitRadiusMultiplier: 0.95,
      depth: 0.92,
      entryOffset: Offset(1.2, -0.6),
    ),
    SplashServiceItem(
      id: 'event_planning',
      title: 'Event Planning',
      icon: Icons.event_available_rounded,
      baseAngle: -0.05, // Mid Right (~3 o'clock)
      orbitRadiusMultiplier: 0.72,
      depth: 0.8,
      entryOffset: Offset(1.3, 0),
    ),
    SplashServiceItem(
      id: 'pandits',
      title: 'Pandits',
      icon: Icons.spa_rounded,
      baseAngle: 3.14, // Mid Left (~9 o'clock)
      orbitRadiusMultiplier: 0.72,
      depth: 0.82,
      entryOffset: Offset(-1.3, 0),
    ),
    SplashServiceItem(
      id: 'mehendi',
      title: 'Mehendi Artists',
      icon: Icons.palette_rounded,
      baseAngle: -1.05, // Upper Right Inner (~1 o'clock)
      orbitRadiusMultiplier: 0.68,
      depth: 0.78,
      entryOffset: Offset(0.8, -1.0),
    ),
  ];
}
