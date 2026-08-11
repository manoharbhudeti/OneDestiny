import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String title;
  final IconData icon;
  final Color lightBgColor;

  const ServiceModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.lightBgColor,
  });
}
