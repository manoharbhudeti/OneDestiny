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

class VendorPortfolioMedia {
  final int id;
  final String key;
  final String url;
  final String presignedUrl;
  final String mediaType;
  final bool isCoverPhoto;
  final bool isGallery;
  final int sortOrder;

  const VendorPortfolioMedia({
    required this.id,
    this.key = '',
    required this.url,
    this.presignedUrl = '',
    this.mediaType = 'photo',
    this.isCoverPhoto = false,
    this.isGallery = false,
    this.sortOrder = 0,
  });

  String get displayUrl {
    if (presignedUrl.isNotEmpty) return presignedUrl;
    return url;
  }

  bool get isVideo => mediaType.toLowerCase() == 'video';
  bool get isPhoto => !isVideo;

  factory VendorPortfolioMedia.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['url']?.toString() ?? json['presignedUrl']?.toString() ?? '';
    final rawPresigned = json['presignedUrl']?.toString() ?? json['url']?.toString() ?? '';
    return VendorPortfolioMedia(
      id: json['id'] as int? ?? 0,
      key: json['key']?.toString() ?? '',
      url: rawUrl,
      presignedUrl: rawPresigned,
      mediaType: json['mediaType']?.toString() ?? 'photo',
      isCoverPhoto: json['isCoverPhoto'] as bool? ?? false,
      isGallery: json['isGallery'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'url': url,
    'presignedUrl': presignedUrl,
    'mediaType': mediaType,
    'isCoverPhoto': isCoverPhoto,
    'isGallery': isGallery,
    'sortOrder': sortOrder,
  };
}

class VendorPortfolioItem {
  final int id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final String? presignedCoverImageUrl;
  final bool isFeatured;
  final List<VendorPortfolioMedia> media;
  final List<String> imageUrls;
  final String? eventType;
  final String? eventDate;

  const VendorPortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    this.coverImageUrl,
    this.presignedCoverImageUrl,
    this.isFeatured = false,
    this.media = const [],
    this.imageUrls = const [],
    this.eventType,
    this.eventDate,
  });

  String? get displayCoverUrl {
    if (presignedCoverImageUrl != null && presignedCoverImageUrl!.isNotEmpty) {
      return presignedCoverImageUrl;
    }
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      return coverImageUrl;
    }
    final coverMedia = media.where((m) => m.isCoverPhoto && m.displayUrl.isNotEmpty);
    if (coverMedia.isNotEmpty) {
      return coverMedia.first.displayUrl;
    }
    if (media.isNotEmpty && media.first.displayUrl.isNotEmpty) {
      return media.first.displayUrl;
    }
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return null;
  }

  List<VendorPortfolioMedia> get photoMedia =>
      media.where((m) => m.isPhoto && m.displayUrl.isNotEmpty).toList();

  List<String> get allImageUrls {
    final urlsFromMedia = photoMedia.map((m) => m.displayUrl).toList();
    if (urlsFromMedia.isNotEmpty) return urlsFromMedia;
    return imageUrls.where((u) => u.isNotEmpty).toList();
  }

  int get photoCount => allImageUrls.length;

  factory VendorPortfolioItem.fromJson(Map<String, dynamic> json) {
    final rawMedia = json['media'] as List<dynamic>? ?? [];
    final mediaList = rawMedia
        .whereType<Map<String, dynamic>>()
        .map((m) => VendorPortfolioMedia.fromJson(m))
        .toList();

    final rawUrls = json['imageUrls'] as List<dynamic>? ?? [];
    final legacyUrls = rawUrls.map((e) => e.toString()).toList();

    final cover = json['presignedCoverImageUrl']?.toString() ?? json['coverImageUrl']?.toString();

    final effectiveMedia = mediaList.isNotEmpty
        ? mediaList
        : legacyUrls
            .asMap()
            .entries
            .map((e) => VendorPortfolioMedia(id: e.key + 1, url: e.value, presignedUrl: e.value))
            .toList();

    final effectiveUrls = legacyUrls.isNotEmpty
        ? legacyUrls
        : effectiveMedia.where((m) => m.isPhoto).map((m) => m.displayUrl).toList();

    return VendorPortfolioItem(
      id: json['id'] as int? ?? 0,
      title: json['title']?.toString() ?? 'Portfolio Album',
      description: json['description']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString(),
      presignedCoverImageUrl: cover,
      isFeatured: json['isFeatured'] as bool? ?? false,
      media: effectiveMedia,
      imageUrls: effectiveUrls,
      eventType: json['eventType']?.toString(),
      eventDate: json['eventDate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'coverImageUrl': coverImageUrl,
    'presignedCoverImageUrl': presignedCoverImageUrl,
    'isFeatured': isFeatured,
    'media': media.map((m) => m.toJson()).toList(),
    'imageUrls': imageUrls,
    'eventType': eventType,
    'eventDate': eventDate,
  };
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
