import 'package:flutter/material.dart';

class FlashCardModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? discountTag;
  final String? targetCategoryId;
  final Color? accentColor;

  const FlashCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.discountTag,
    this.targetCategoryId,
    this.accentColor,
  });
}
