import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../data/mock_data.dart';
import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/chat_model.dart';
import '../models/flash_card_model.dart';
import '../models/service_model.dart';
import '../models/user_profile_model.dart';
import '../models/vendor_detail_models.dart';
import '../models/vendor_model.dart';
import '../network/api_response.dart';
import '../services/api_service.dart';
import '../services/auth_storage_service.dart';

abstract class AppRepository {
  Future<List<FlashCardModel>> getFlashCards();
  Future<List<CategoryModel>> getCategories();
  Future<List<ServiceModel>> getPopularServices();
  Future<List<VendorModel>> getNearbyVendors({String? city, String? categoryId, String? search});
  Future<List<VendorModel>> getTrendingVendors({String? city, String? categoryId});
  Future<List<VendorModel>> searchVendors({
    String? query,
    String? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  });
  Future<VendorFullProfile?> getVendorProfile(int vendorId);
  Future<List<VendorServiceItem>> getVendorServices(int vendorId);
  Future<List<VendorPortfolioItem>> getVendorPortfolio(int vendorId);
  Future<List<VendorReviewItem>> getVendorReviews(int vendorId);
  Future<ApiResponse<String>> sendVendorInquiry({
    required int vendorId,
    required String message,
    DateTime? eventDate,
    String? eventType,
    int? guestCount,
    double? budget,
  });
  Future<ApiResponse<BookingModel>> bookVendor({
    required int vendorId,
    required DateTime eventDate,
    String? location,
    String? notes,
    int? guestCount,
    double? budget,
  });
  Future<ApiResponse<VendorReviewItem>> submitVendorReview({
    required int vendorId,
    required int rating,
    required String comment,
  });
  Future<List<BookingModel>> getBookings();
  Future<BookingModel?> getBookingDetail(int bookingId);
  Future<ApiResponse<BookingModel>> cancelBooking(int bookingId, {String? reason});
  Future<List<ChatConversationModel>> getConversations();
  Future<List<ChatMessageModel>> getMessages(String conversationId, {int? vendorId});
  Future<ChatMessageModel?> sendMessage({
    int? conversationId,
    int? vendorId,
    required String text,
  });
  Future<UserProfileModel> getUserProfile();
  Future<ApiResponse<UserProfileModel>> updateUserProfile({
    required String name,
    required String email,
    String? mobile,
  });
}

class ApiAppRepository implements AppRepository {
  @override
  Future<List<FlashCardModel>> getFlashCards() async {
    return [];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final res = await ApiService.instance.get<List<CategoryModel>>(
        url: ApiConfig.categories,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return <CategoryModel>[];
        },
        requiresAuth: false,
      );

      if (res.success && res.data != null && res.data!.isNotEmpty) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getCategories Error] $e');
    }
    return [];
  }

  @override
  Future<List<ServiceModel>> getPopularServices() async {
    return [];
  }

  @override
  Future<List<VendorModel>> getNearbyVendors({String? city, String? categoryId, String? search}) async {
    return searchVendors(
      city: city,
      categoryId: categoryId,
      query: search,
      sortBy: 'nearby',
    );
  }

  @override
  Future<List<VendorModel>> getTrendingVendors({String? city, String? categoryId}) async {
    return searchVendors(
      city: city,
      categoryId: categoryId,
      sortBy: 'popular',
    );
  }

  @override
  Future<List<VendorModel>> searchVendors({
    String? query,
    String? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (query != null && query.trim().isNotEmpty) {
        queryParams['search'] = query.trim();
      }
      if (categoryId != null && categoryId != 'all' && categoryId != 'All') {
        final parsedCatId = int.tryParse(categoryId);
        if (parsedCatId != null) {
          queryParams['categoryId'] = parsedCatId.toString();
        }
      }
      if (city != null && city.trim().isNotEmpty && !city.toLowerCase().contains('all')) {
        queryParams['city'] = city.trim();
      }
      if (minPrice != null && minPrice > 0) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null && maxPrice < 500000) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      if (minRating != null && minRating > 0) {
        queryParams['minRating'] = minRating.toString();
      }
      if (sortBy != null) {
        queryParams['sortBy'] = sortBy;
      }

      final favorites = await AuthStorageService.instance.getFavoriteVendorIds();

      final paged = await ApiService.instance.getPaged<VendorModel>(
        url: ApiConfig.clientVendors,
        queryParams: queryParams,
        fromJsonItem: (json) {
          final map = json as Map<String, dynamic>;
          final id = map['id']?.toString() ?? '';
          return VendorModel.fromJson(map, isFavorite: favorites.contains(id));
        },
        requiresAuth: false,
      );

      return paged.items;
    } catch (e) {
      debugPrint('[ApiAppRepository searchVendors Error] $e');
      return [];
    }
  }

  @override
  Future<VendorFullProfile?> getVendorProfile(int vendorId) async {
    try {
      final res = await ApiService.instance.get<VendorFullProfile>(
        url: ApiConfig.clientVendorProfile(vendorId),
        fromJsonT: (json) => VendorFullProfile.fromJson(json as Map<String, dynamic>),
        requiresAuth: false,
      );
      if (res.success && res.data != null) {
        return res.data;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getVendorProfile Error] $e');
    }
    return null;
  }

  @override
  Future<List<VendorServiceItem>> getVendorServices(int vendorId) async {
    try {
      final res = await ApiService.instance.get<List<VendorServiceItem>>(
        url: ApiConfig.clientVendorServices(vendorId),
        fromJsonT: (json) {
          if (json is List) {
            return json.map((e) => VendorServiceItem.fromJson(e as Map<String, dynamic>)).toList();
          }
          return <VendorServiceItem>[];
        },
        requiresAuth: false,
      );
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getVendorServices Error] $e');
    }
    return [];
  }

  @override
  Future<List<VendorPortfolioItem>> getVendorPortfolio(int vendorId) async {
    try {
      final res = await ApiService.instance.get<List<VendorPortfolioItem>>(
        url: ApiConfig.clientVendorPortfolio(vendorId),
        fromJsonT: (json) {
          if (json is List) {
            return json.map((e) => VendorPortfolioItem.fromJson(e as Map<String, dynamic>)).toList();
          }
          return <VendorPortfolioItem>[];
        },
        requiresAuth: false,
      );
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getVendorPortfolio Error] $e');
    }
    return [];
  }

  @override
  Future<List<VendorReviewItem>> getVendorReviews(int vendorId) async {
    try {
      final res = await ApiService.instance.get<List<VendorReviewItem>>(
        url: ApiConfig.clientVendorReviews(vendorId),
        fromJsonT: (json) {
          if (json is List) {
            return json.map((e) => VendorReviewItem.fromJson(e as Map<String, dynamic>)).toList();
          }
          return <VendorReviewItem>[];
        },
        requiresAuth: false,
      );
      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getVendorReviews Error] $e');
    }
    return [];
  }

  @override
  Future<ApiResponse<String>> sendVendorInquiry({
    required int vendorId,
    required String message,
    DateTime? eventDate,
    String? eventType,
    int? guestCount,
    double? budget,
  }) async {
    return await ApiService.instance.post<String>(
      url: ApiConfig.clientVendorInquire(vendorId),
      body: {
        'message': message,
        'eventDate': eventDate?.toIso8601String(),
        'eventType': eventType,
        'guestCount': guestCount,
        'budget': budget,
      },
      fromJsonT: (json) => json is String ? json : 'Inquiry sent successfully.',
      requiresAuth: true,
    );
  }

  @override
  Future<ApiResponse<BookingModel>> bookVendor({
    required int vendorId,
    required DateTime eventDate,
    String? location,
    String? notes,
    int? guestCount,
    double? budget,
  }) async {
    return await ApiService.instance.post<BookingModel>(
      url: ApiConfig.clientVendorBook(vendorId),
      body: {
        'eventType': 'Wedding',
        'eventDate': eventDate.toIso8601String(),
        'venue': location,
        'notes': notes,
      },
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          if (json.containsKey('bookingId')) {
            final bId = json['bookingId'].toString();
            return BookingModel(
              id: bId,
              vendorId: vendorId.toString(),
              title: 'Booking #$bId',
              category: 'Wedding Service',
              dateLabel: '${eventDate.day}/${eventDate.month}/${eventDate.year}',
              location: location ?? 'Pending location',
              amount: budget != null ? '₹${budget.toInt()}' : 'Pending quote',
              status: 'PENDING',
              imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=400&q=80',
            );
          }
          return BookingModel.fromJson(json);
        }
        return BookingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          vendorId: vendorId.toString(),
          title: 'Vendor Booking',
          category: 'Wedding Service',
          dateLabel: '${eventDate.day}/${eventDate.month}/${eventDate.year}',
          location: location ?? 'Pending location',
          amount: budget != null ? '₹${budget.toInt()}' : 'Pending quote',
          status: 'PENDING',
          imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=400&q=80',
        );
      },
      requiresAuth: true,
    );
  }

  @override
  Future<ApiResponse<VendorReviewItem>> submitVendorReview({
    required int vendorId,
    required int rating,
    required String comment,
  }) async {
    return await ApiService.instance.post<VendorReviewItem>(
      url: ApiConfig.clientVendorReview(vendorId),
      body: {
        'rating': rating,
        'comment': comment,
      },
      fromJsonT: (json) => VendorReviewItem.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    try {
      final paged = await ApiService.instance.getPaged<BookingModel>(
        url: ApiConfig.clientBookings,
        fromJsonItem: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
        requiresAuth: true,
      );

      return paged.items;
    } catch (e) {
      debugPrint('[ApiAppRepository getBookings Error] $e');
      return [];
    }
  }

  @override
  Future<BookingModel?> getBookingDetail(int bookingId) async {
    try {
      final res = await ApiService.instance.get<BookingModel>(
        url: ApiConfig.clientBookingDetail(bookingId),
        fromJsonT: (json) => BookingModel.fromJson(json as Map<String, dynamic>),
        requiresAuth: true,
      );
      if (res.success && res.data != null) {
        return res.data;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getBookingDetail Error] $e');
    }
    return null;
  }

  @override
  Future<ApiResponse<BookingModel>> cancelBooking(int bookingId, {String? reason}) async {
    return await ApiService.instance.post<BookingModel>(
      url: ApiConfig.clientBookingCancel(bookingId),
      body: null,
      fromJsonT: (json) {
        if (json is Map<String, dynamic>) {
          return BookingModel.fromJson(json);
        }
        return BookingModel(
          id: bookingId.toString(),
          vendorId: '',
          title: 'Booking #$bookingId',
          category: 'Event Service',
          dateLabel: 'Cancelled',
          location: '',
          amount: '',
          status: 'CANCELLED',
          imageUrl: '',
        );
      },
      requiresAuth: true,
    );
  }

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final res = await ApiService.instance.get<List<ChatConversationModel>>(
        url: ApiConfig.chatConversations,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return <ChatConversationModel>[];
        },
        requiresAuth: true,
      );

      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getConversations Error] $e');
    }
    return [];
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId, {int? vendorId}) async {
    try {
      final currentUserId = await AuthStorageService.instance.getUserId();
      final queryParams = <String, String>{};
      final parsedConvId = int.tryParse(conversationId);
      final partyId = vendorId ?? parsedConvId;
      if (partyId != null) {
        queryParams['otherPartyId'] = partyId.toString();
      }

      final res = await ApiService.instance.get<List<ChatMessageModel>>(
        url: ApiConfig.chatMessages,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        fromJsonT: (json) {
          if (json is Map<String, dynamic> && json.containsKey('items')) {
            final items = json['items'] as List;
            return items.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>, currentUserId: currentUserId)).toList();
          }
          if (json is List) {
            return json.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>, currentUserId: currentUserId)).toList();
          }
          return <ChatMessageModel>[];
        },
        requiresAuth: true,
      );

      if (res.success && res.data != null) {
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getMessages Error] $e');
    }
    return [];
  }

  @override
  Future<ChatMessageModel?> sendMessage({
    int? conversationId,
    int? vendorId,
    required String text,
  }) async {
    try {
      final currentUserId = await AuthStorageService.instance.getUserId();
      final recipientId = vendorId ?? conversationId;
      final res = await ApiService.instance.post<ChatMessageModel>(
        url: ApiConfig.chatSend,
        body: {
          if (recipientId != null) 'recipientVendorProfileId': recipientId,
          'content': text,
        },
        fromJsonT: (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>, currentUserId: currentUserId),
        requiresAuth: true,
      );

      if (res.success && res.data != null) {
        return res.data;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository sendMessage Error] $e');
    }
    return null;
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    final saved = await AuthStorageService.instance.getSavedProfile();

    try {
      final res = await ApiService.instance.get<UserProfileModel>(
        url: ApiConfig.accountProfile,
        fromJsonT: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
        requiresAuth: true,
      );
      if (res.success && res.data != null && res.data!.name.isNotEmpty && res.data!.name != 'User') {
        await AuthStorageService.instance.updateProfile(
          name: res.data!.name,
          email: res.data!.email,
          mobile: res.data!.mobile,
          avatarUrl: res.data!.avatarUrl,
          notificationsEnabled: res.data!.notificationsEnabled,
        );
        return res.data!;
      }
    } catch (e) {
      debugPrint('[ApiAppRepository getUserProfile Error] $e');
    }

    if (saved != null) {
      return saved;
    }

    return const UserProfileModel(
      name: 'User',
      mobile: '',
      email: '',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      notificationsEnabled: true,
    );
  }

  @override
  Future<ApiResponse<UserProfileModel>> updateUserProfile({
    required String name,
    required String email,
    String? mobile,
  }) async {
    final res = await ApiService.instance.put<UserProfileModel>(
      url: ApiConfig.accountProfile,
      body: {
        'fullName': name,
        'email': email,
        'phone': mobile,
      },
      fromJsonT: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );

    if (res.success) {
      await AuthStorageService.instance.updateProfile(
        name: name,
        email: email,
        mobile: mobile,
      );
    }

    return res;
  }
}

class MockAppRepository implements AppRepository {
  static const String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

  @override
  Future<List<FlashCardModel>> getFlashCards() async => List<FlashCardModel>.of(MockData.flashCards);

  @override
  Future<List<CategoryModel>> getCategories() async => List<CategoryModel>.of(MockData.categories);

  @override
  Future<List<ServiceModel>> getPopularServices() async => List<ServiceModel>.of(MockData.popularServices);

  @override
  Future<List<VendorModel>> getNearbyVendors({String? city, String? categoryId, String? search}) async =>
      List<VendorModel>.of(MockData.nearbyVendors);

  @override
  Future<List<VendorModel>> getTrendingVendors({String? city, String? categoryId}) async =>
      List<VendorModel>.of(MockData.trendingVendors);

  @override
  Future<List<VendorModel>> searchVendors({
    String? query,
    String? categoryId,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    int page = 1,
    int pageSize = 20,
  }) async {
    return List<VendorModel>.of(MockData.nearbyVendors);
  }

  @override
  Future<VendorFullProfile?> getVendorProfile(int vendorId) async => null;

  @override
  Future<List<VendorServiceItem>> getVendorServices(int vendorId) async => [];

  @override
  Future<List<VendorPortfolioItem>> getVendorPortfolio(int vendorId) async => [];

  @override
  Future<List<VendorReviewItem>> getVendorReviews(int vendorId) async => [];

  @override
  Future<ApiResponse<String>> sendVendorInquiry({
    required int vendorId,
    required String message,
    DateTime? eventDate,
    String? eventType,
    int? guestCount,
    double? budget,
  }) async => ApiResponse.ok('Inquiry sent successfully');

  @override
  Future<ApiResponse<BookingModel>> bookVendor({
    required int vendorId,
    required DateTime eventDate,
    String? location,
    String? notes,
    int? guestCount,
    double? budget,
  }) async {
    return ApiResponse.ok(
      BookingModel(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        vendorId: vendorId.toString(),
        title: 'Vendor Booking',
        category: 'Event Service',
        dateLabel: 'Oct 24, 2026',
        location: location ?? 'Hyderabad',
        amount: '₹50,000',
        status: 'REQUESTED',
        imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=200&q=80',
      ),
    );
  }

  @override
  Future<ApiResponse<VendorReviewItem>> submitVendorReview({
    required int vendorId,
    required int rating,
    required String comment,
  }) async {
    return ApiResponse.ok(
      VendorReviewItem(
        id: 1,
        clientName: 'Client',
        rating: rating.toDouble(),
        comment: comment,
        createdAt: 'Just now',
      ),
    );
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    return [
      const BookingModel(
        id: 'b_1',
        vendorId: 'tv_1',
        title: 'Destiny Grand Wedding',
        category: 'Wedding Planning',
        dateLabel: 'Oct 24, 2026',
        location: 'Hyderabad',
        amount: '₹1,50,000',
        status: 'CONFIRMED',
        imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=200&q=80',
      ),
    ];
  }

  @override
  Future<BookingModel?> getBookingDetail(int bookingId) async {
    final list = await getBookings();
    return list.first;
  }

  @override
  Future<ApiResponse<BookingModel>> cancelBooking(int bookingId, {String? reason}) async {
    final list = await getBookings();
    return ApiResponse.ok(list.first.copyWith(status: 'CANCELLED'));
  }

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    return [
      const ChatConversationModel(
        id: 'c_1',
        vendorId: 'v_1',
        vendorName: 'Lens & Light Studio',
        vendorCategory: 'Photography',
        lastMessage: 'Sure Manohar! We have Oct 24th available for your wedding shoot.',
        time: '10:42 AM',
        unreadCount: 2,
        avatarUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=200&q=80',
      ),
      const ChatConversationModel(
        id: 'c_2',
        vendorId: 'tv_1',
        vendorName: 'Destiny Grand Wedding',
        vendorCategory: 'Wedding Planning',
        lastMessage: 'The stage floral decor layout proposal has been sent to your email.',
        time: 'Yesterday',
        unreadCount: 1,
        avatarUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=200&q=80',
      ),
      const ChatConversationModel(
        id: 'c_3',
        vendorId: 'v_3',
        vendorName: 'Royal Culinary Caterers',
        vendorCategory: 'Catering',
        lastMessage: 'We can arrange a menu tasting session this Saturday at 4 PM.',
        time: 'Aug 1',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=200&q=80',
      ),
      const ChatConversationModel(
        id: 'c_4',
        vendorId: 'v_5',
        vendorName: 'Sonic Bass DJ & Sound',
        vendorCategory: 'DJ Services',
        lastMessage: 'Thanks for booking! Playlist preferences received.',
        time: 'Jul 28',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=200&q=80',
      ),
    ];
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId, {int? vendorId}) async {
    final convs = await getConversations();
    final match = convs.where((c) => c.id == conversationId);
    final vendorName = match.isNotEmpty ? match.first.vendorName : 'Vendor';

    return [
      ChatMessageModel(
        id: '${conversationId}_m1',
        conversationId: conversationId,
        text: 'Hi, I am planning an event and want to understand your availability and packages.',
        time: '10:18 AM',
        isMine: true,
      ),
      ChatMessageModel(
        id: '${conversationId}_m2',
        conversationId: conversationId,
        text: 'Hello, thanks for reaching out to $vendorName. Please share your event date and guest count.',
        time: '10:22 AM',
        isMine: false,
      ),
      ChatMessageModel(
        id: '${conversationId}_m3',
        conversationId: conversationId,
        text: 'The event is planned for Oct 24, 2026 in Hyderabad. Around 450 guests.',
        time: '10:34 AM',
        isMine: true,
      ),
      ChatMessageModel(
        id: '${conversationId}_m4',
        conversationId: conversationId,
        text: 'That date is available. I can prepare a premium quote with decor, logistics, and add-on options.',
        time: '10:42 AM',
        isMine: false,
      ),
    ];
  }

  @override
  Future<ChatMessageModel?> sendMessage({
    int? conversationId,
    int? vendorId,
    required String text,
  }) async {
    return ChatMessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId?.toString() ?? 'c_1',
      text: text,
      time: 'Now',
      isMine: true,
    );
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    return const UserProfileModel(
      name: 'Manohar',
      mobile: '+91 98765 43210',
      email: 'manohar@onedestiny.com',
      avatarUrl: _avatarUrl,
      notificationsEnabled: true,
    );
  }

  @override
  Future<ApiResponse<UserProfileModel>> updateUserProfile({
    required String name,
    required String email,
    String? mobile,
  }) async {
    return ApiResponse.ok(
      UserProfileModel(
        name: name,
        email: email,
        mobile: mobile ?? '+91 98765 43210',
        avatarUrl: _avatarUrl,
        notificationsEnabled: true,
      ),
    );
  }
}
