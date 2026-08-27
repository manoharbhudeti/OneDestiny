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
  });

  factory VendorModel.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    final coverImg = json['coverImageUrl']?.toString() ??
        json['logoUrl']?.toString() ??
        json['imageUrl']?.toString() ??
        '';

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
    );
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
    );
  }

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
