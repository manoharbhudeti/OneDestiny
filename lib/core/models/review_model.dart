import 'package:flutter/foundation.dart';

@immutable
class ReviewModel {
  final String id;
  final String vendorId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String date;
  final String reviewText;
  final List<String> photos;
  final bool isVerifiedBooking;

  const ReviewModel({
    required this.id,
    required this.vendorId,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.date,
    required this.reviewText,
    this.photos = const [],
    this.isVerifiedBooking = true,
  });

  ReviewModel copyWith({
    String? id,
    String? vendorId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? date,
    String? reviewText,
    List<String>? photos,
    bool? isVerifiedBooking,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      reviewText: reviewText ?? this.reviewText,
      photos: photos ?? this.photos,
      isVerifiedBooking: isVerifiedBooking ?? this.isVerifiedBooking,
    );
  }
}
