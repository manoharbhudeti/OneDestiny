import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon;

  const CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final title = json['name']?.toString() ?? json['title']?.toString() ?? '';
    final id = json['id']?.toString() ?? 'cat_${title.toLowerCase()}';
    final icon = _mapCategoryIcon(title, json['iconName']?.toString());

    return CategoryModel(
      id: id,
      title: title,
      icon: icon,
    );
  }

  static IconData _mapCategoryIcon(String title, String? iconName) {
    final lower = title.toLowerCase();
    if (lower.contains('photo') || lower.contains('camera')) {
      return Icons.camera_alt_outlined;
    } else if (lower.contains('decor') || lower.contains('flower') || lower.contains('stage')) {
      return Icons.celebration_outlined;
    } else if (lower.contains('cater') || lower.contains('food') || lower.contains('dining')) {
      return Icons.restaurant_menu_outlined;
    } else if (lower.contains('makeup') || lower.contains('beauty') || lower.contains('hair') || lower.contains('salon')) {
      return Icons.face_retouching_natural_outlined;
    } else if (lower.contains('dj') || lower.contains('music') || lower.contains('sound') || lower.contains('audio')) {
      return Icons.music_note_outlined;
    } else if (lower.contains('venue') || lower.contains('hall') || lower.contains('resort') || lower.contains('hotel')) {
      return Icons.location_city_outlined;
    } else if (lower.contains('plan') || lower.contains('event') || lower.contains('coordination')) {
      return Icons.event_available_outlined;
    } else if (lower.contains('invit') || lower.contains('card') || lower.contains('gift')) {
      return Icons.card_giftcard_outlined;
    } else if (lower.contains('mehendi') || lower.contains('henna') || lower.contains('art')) {
      return Icons.brush_outlined;
    } else if (lower.contains('jewel') || lower.contains('attire') || lower.contains('wear') || lower.contains('fashion')) {
      return Icons.diamond_outlined;
    }
    return Icons.star_border_rounded;
  }
}
