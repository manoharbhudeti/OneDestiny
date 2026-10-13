import 'package:flutter/material.dart';

/// Represents a single service arrangement required for an event
/// (e.g. Photography, Stage Decor, Catering, Bridal Makeup for a Marriage).
class EventArrangement {
  final String id;
  final String title;
  final String categoryName;
  final IconData icon;
  final String description;

  const EventArrangement({
    required this.id,
    required this.title,
    required this.categoryName,
    required this.icon,
    this.description = '',
  });

  factory EventArrangement.fromJson(Map<String, dynamic> json) {
    return EventArrangement(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? json['category']?.toString() ?? '',
      icon: _mapArrangementIcon(json['categoryName']?.toString() ?? json['title']?.toString() ?? ''),
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryName': categoryName,
        'description': description,
      };

  static IconData _mapArrangementIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('photo') || lower.contains('camera')) {
      return Icons.camera_alt_outlined;
    } else if (lower.contains('decor') || lower.contains('stage') || lower.contains('mandap')) {
      return Icons.celebration_outlined;
    } else if (lower.contains('cater') || lower.contains('food') || lower.contains('feast')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('makeup') || lower.contains('bridal') || lower.contains('beauty')) {
      return Icons.face_retouching_natural_outlined;
    } else if (lower.contains('venue') || lower.contains('hall') || lower.contains('resort')) {
      return Icons.location_city_outlined;
    } else if (lower.contains('dj') || lower.contains('music') || lower.contains('sound')) {
      return Icons.headphones_outlined;
    } else if (lower.contains('mehendi') || lower.contains('henna')) {
      return Icons.brush_outlined;
    } else if (lower.contains('car') || lower.contains('vintage')) {
      return Icons.directions_car_outlined;
    } else if (lower.contains('cake') || lower.contains('sweet')) {
      return Icons.cake_outlined;
    } else if (lower.contains('pandit') || lower.contains('pooja')) {
      return Icons.temple_hindu_outlined;
    }
    return Icons.star_border_rounded;
  }
}

/// Represents an event type displayed dynamically on the Home screen
/// (e.g., Marriage, Birthday, Engagement, Baby Shower, Corporate Gala).
class EventModel {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String? badge;
  final String startingPriceText;
  final List<EventArrangement> arrangements;
  final List<String> vendorIds;

  const EventModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    this.badge,
    this.startingPriceText = '',
    required this.arrangements,
    this.vendorIds = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final arrList = (json['arrangements'] as List<dynamic>?)
            ?.map((e) => EventArrangement.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final vIds = (json['vendorIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return EventModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      badge: json['badge']?.toString(),
      startingPriceText: json['startingPriceText']?.toString() ?? '',
      arrangements: arrList,
      vendorIds: vIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'description': description,
        'imageUrl': imageUrl,
        'badge': badge,
        'startingPriceText': startingPriceText,
        'arrangements': arrangements.map((e) => e.toJson()).toList(),
        'vendorIds': vendorIds,
      };
}
