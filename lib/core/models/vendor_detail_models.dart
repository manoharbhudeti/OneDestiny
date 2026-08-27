class VendorServiceItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final int? durationMinutes;
  final bool isCustomQuote;

  const VendorServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.durationMinutes,
    this.isCustomQuote = false,
  });

  factory VendorServiceItem.fromJson(Map<String, dynamic> json) {
    return VendorServiceItem(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] as int?,
      isCustomQuote: json['isCustomQuote'] as bool? ?? false,
    );
  }

  String get formattedPrice {
    if (isCustomQuote || price <= 0) return 'Custom Quote';
    return '₹${price.toInt()}';
  }
}

class VendorPortfolioItem {
  final int id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String? eventType;
  final String? eventDate;

  const VendorPortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    this.eventType,
    this.eventDate,
  });

  factory VendorPortfolioItem.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['imageUrls'] as List<dynamic>? ?? [];
    return VendorPortfolioItem(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrls: rawUrls.map((e) => e.toString()).toList(),
      eventType: json['eventType']?.toString(),
      eventDate: json['eventDate']?.toString(),
    );
  }
}

class VendorReviewItem {
  final int id;
  final String clientName;
  final String? clientAvatarUrl;
  final double rating;
  final String comment;
  final String createdAt;
  final String? vendorReply;
  final String? replyDate;

  const VendorReviewItem({
    required this.id,
    required this.clientName,
    this.clientAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.vendorReply,
    this.replyDate,
  });

  factory VendorReviewItem.fromJson(Map<String, dynamic> json) {
    return VendorReviewItem(
      id: json['id'] as int? ?? 0,
      clientName: json['clientName']?.toString() ?? 'Client',
      clientAvatarUrl: json['clientAvatarUrl']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      vendorReply: json['vendorReply']?.toString(),
      replyDate: json['replyDate']?.toString(),
    );
  }
}

class VendorFullProfile {
  final int id;
  final String businessName;
  final String categoryName;
  final String description;
  final double startingPrice;
  final double averageRating;
  final int totalReviews;
  final String baseLocation;
  final String imageUrl;
  final bool isVerified;
  final String? businessPhone;
  final String? businessEmail;
  final List<String> serviceCities;
  final List<VendorServiceItem> services;
  final List<VendorPortfolioItem> portfolio;
  final List<VendorReviewItem> recentReviews;

  const VendorFullProfile({
    required this.id,
    required this.businessName,
    required this.categoryName,
    required this.description,
    required this.startingPrice,
    required this.averageRating,
    required this.totalReviews,
    required this.baseLocation,
    required this.imageUrl,
    this.isVerified = false,
    this.businessPhone,
    this.businessEmail,
    this.serviceCities = const [],
    this.services = const [],
    this.portfolio = const [],
    this.recentReviews = const [],
  });

  factory VendorFullProfile.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'] as List<dynamic>? ?? [];
    final rawPortfolio = json['portfolio'] as List<dynamic>? ?? [];
    final rawReviews = json['recentReviews'] as List<dynamic>? ?? [];
    final rawCities = json['serviceCities'] as List<dynamic>? ?? [];

    final coverImg = json['coverImageUrl']?.toString() ?? json['logoUrl']?.toString() ?? '';

    return VendorFullProfile(
      id: json['id'] as int? ?? 0,
      businessName: json['businessName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      startingPrice: (json['startingPrice'] as num?)?.toDouble() ?? 0.0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      baseLocation: json['baseLocation']?.toString() ?? '',
      imageUrl: coverImg.isNotEmpty
          ? coverImg
          : 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
      isVerified: json['isVerified'] as bool? ?? false,
      businessPhone: json['businessPhone']?.toString(),
      businessEmail: json['businessEmail']?.toString(),
      serviceCities: rawCities.map((e) => e.toString()).toList(),
      services: rawServices.map((e) => VendorServiceItem.fromJson(e as Map<String, dynamic>)).toList(),
      portfolio: rawPortfolio.map((e) => VendorPortfolioItem.fromJson(e as Map<String, dynamic>)).toList(),
      recentReviews: rawReviews.map((e) => VendorReviewItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
