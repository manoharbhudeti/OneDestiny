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
