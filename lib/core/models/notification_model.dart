import 'package:flutter/material.dart';

enum NotificationType {
  booking,
  message,
  status,
  account,
  offer,
}

@immutable
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationType type;
  final bool isRead;
  final IconData icon;
  final Color iconColor;
  final String? actionRoute;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    required this.icon,
    required this.iconColor,
    this.actionRoute,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? timestamp,
    NotificationType? type,
    bool? isRead,
    IconData? icon,
    Color? iconColor,
    String? actionRoute,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      actionRoute: actionRoute ?? this.actionRoute,
    );
  }
}
