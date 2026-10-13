class VendorModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distanceKm;
  final double startingPrice;
  final String location;
  final String imageUrl;
  final bool isTrending;
  final bool isFavorite;
  final List<String> availableDays;
  final List<String> blockedDates;

  const VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distanceKm,
    required this.startingPrice,
    required this.location,
    required this.imageUrl,
    this.isTrending = false,
    this.isFavorite = false,
    this.availableDays = const [],
    this.blockedDates = const [],
  });

  factory VendorModel.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    final coverImg = json['coverPhotoUrl']?.toString() ??
        json['coverImageUrl']?.toString() ??
        json['photoUrl']?.toString() ??
        json['logoUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

    final blocked = (json['blockedDates'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    final days = (json['availableDays'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const <String>[];

    return VendorModel(
      id: json['id']?.toString() ?? '',
      name: json['businessName']?.toString() ?? json['name']?.toString() ?? '',
      category: json['categoryName']?.toString() ?? json['category']?.toString() ?? 'General',
      rating: (json['averageRating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          4.8,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 2.5,
      startingPrice: (json['startingPrice'] as num?)?.toDouble() ?? 0.0,
      location: json['baseLocation']?.toString() ?? json['location']?.toString() ?? 'India',
      imageUrl: coverImg.isNotEmpty
          ? coverImg
          : 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
      isTrending: json['isFeatured'] as bool? ?? json['isTrending'] as bool? ?? false,
      isFavorite: isFavorite,
      availableDays: days,
      blockedDates: blocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'distanceKm': distanceKm,
      'startingPrice': startingPrice,
      'location': location,
      'imageUrl': imageUrl,
      'isTrending': isTrending,
      'isFavorite': isFavorite,
      'availableDays': availableDays,
      'blockedDates': blockedDates,
    };
  }

  VendorModel copyWith({
    String? id,
    String? name,
    String? category,
    double? rating,
    double? distanceKm,
    double? startingPrice,
    String? location,
    String? imageUrl,
    bool? isTrending,
    bool? isFavorite,
    List<String>? availableDays,
    List<String>? blockedDates,
  }) {
    return VendorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      distanceKm: distanceKm ?? this.distanceKm,
      startingPrice: startingPrice ?? this.startingPrice,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isTrending: isTrending ?? this.isTrending,
      isFavorite: isFavorite ?? this.isFavorite,
      availableDays: availableDays ?? this.availableDays,
      blockedDates: blockedDates ?? this.blockedDates,
    );
  }

  /// Checks if the vendor is available on a specific date/day.
  /// If [date] is null, returns true (meaning unfiltered, vendor should show).
  bool isAvailableOnDate(DateTime? date) {
    if (date == null) return true;

    final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    // If date is in blocked dates, vendor is unavailable
    for (final blocked in blockedDates) {
      if (blocked.startsWith(dateKey)) {
        return false;
      }
    }

    // If specific available days are configured, verify weekday
    if (availableDays.isNotEmpty) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final targetDay = weekdays[date.weekday - 1].toLowerCase();
      final isDayAllowed = availableDays.any((d) => d.toLowerCase() == targetDay);
      if (!isDayAllowed) {
        return false;
      }
    }

    return true;
  }

  bool get isAvailableToday => isAvailableOnDate(DateTime.now());

  String get formattedPrice {
    final priceString = startingPrice.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = priceString.length - 1; i >= 0; i--) {
      buffer.write(priceString[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    return 'Starts ₹${buffer.toString().split('').reversed.join('')}';
  }
}
