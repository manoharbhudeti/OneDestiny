import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/chat_model.dart';
import '../models/flash_card_model.dart';
import '../models/service_model.dart';
import '../models/user_profile_model.dart';
import '../models/vendor_model.dart';
import '../repositories/app_repository.dart';
import '../services/location_service.dart';

class AppState extends ChangeNotifier {
  AppState({AppRepository? repository}) : _repository = repository ?? MockAppRepository() {
    _flashCards = _repository.getFlashCards();
    _categories = _repository.getCategories();
    _popularServices = _repository.getPopularServices();
    _nearbyVendors = _repository.getNearbyVendors();
    _trendingVendors = _repository.getTrendingVendors();
    _profile = _repository.getUserProfile();
    _bookings = _repository.getBookings();
    _conversations = _repository.getConversations();
  }

  final AppRepository _repository;

  late final List<FlashCardModel> _flashCards;
  late final List<CategoryModel> _categories;
  late final List<ServiceModel> _popularServices;
  late List<VendorModel> _nearbyVendors;
  late List<VendorModel> _trendingVendors;
  late UserProfileModel _profile;
  late List<BookingModel> _bookings;
  late List<ChatConversationModel> _conversations;
  final Map<String, List<ChatMessageModel>> _messagesByConversation = {};

  String _homeSelectedCategoryId = 'all';
  String _homeSearchQuery = '';
  String _exploreSelectedCategory = 'All';
  String _exploreSearchQuery = '';
  String _chatSearchQuery = '';
  String _activeLocation = 'Hyderabad, India';

  // Explore Filter Parameters
  double _exploreMinPrice = 0.0;
  double _exploreMaxPrice = 500000.0;
  double _exploreMinRating = 0.0;
  String _exploreSortBy = 'popular';

  List<FlashCardModel> get flashCards => List.unmodifiable(_flashCards);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ServiceModel> get popularServices => List.unmodifiable(_popularServices);
  List<VendorModel> get nearbyVendors => List.unmodifiable(_nearbyVendors);
  List<VendorModel> get trendingVendors => List.unmodifiable(_trendingVendors);
  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  UserProfileModel get profile => _profile;
  String get activeLocation => _activeLocation;
  int get conversationCount => _conversations.length;

  String get greeting => 'Hello, ${_profile.name} 👋';
  String get homeSelectedCategoryId => _homeSelectedCategoryId;
  String get exploreSelectedCategory => _exploreSelectedCategory;

  double get exploreMinPrice => _exploreMinPrice;
  double get exploreMaxPrice => _exploreMaxPrice;
  double get exploreMinRating => _exploreMinRating;
  String get exploreSortBy => _exploreSortBy;

  List<VendorModel> get allVendors => [..._nearbyVendors, ..._trendingVendors];

  List<VendorModel> get favoriteVendors =>
      allVendors.where((vendor) => vendor.isFavorite).toList(growable: false);

  List<VendorModel> get filteredTrendingVendors {
    return _trendingVendors.where((vendor) {
      return _matchesQuery(vendor, _homeSearchQuery) && _matchesCategoryId(vendor, _homeSelectedCategoryId);
    }).toList(growable: false);
  }

  List<VendorModel> get filteredExploreVendors {
    final list = allVendors.where((vendor) {
      final matchesQuery = _matchesQuery(vendor, _exploreSearchQuery);
      final matchesCat = _matchesCategoryName(vendor, _exploreSelectedCategory);
      final matchesPrice = vendor.startingPrice >= _exploreMinPrice && vendor.startingPrice <= _exploreMaxPrice;
      final matchesRating = vendor.rating >= _exploreMinRating;
      return matchesQuery && matchesCat && matchesPrice && matchesRating;
    }).toList();

    if (_exploreSortBy == 'price_low_high') {
      list.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
    } else if (_exploreSortBy == 'price_high_low') {
      list.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
    } else if (_exploreSortBy == 'rating_high') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return List.unmodifiable(list);
  }

  void applyExploreFilters({
    required double minPrice,
    required double maxPrice,
    required double minRating,
    required String sortBy,
  }) {
    _exploreMinPrice = minPrice;
    _exploreMaxPrice = maxPrice;
    _exploreMinRating = minRating;
    _exploreSortBy = sortBy;
    notifyListeners();
  }

  void resetExploreFilters() {
    _exploreMinPrice = 0.0;
    _exploreMaxPrice = 500000.0;
    _exploreMinRating = 0.0;
    _exploreSortBy = 'popular';
    notifyListeners();
  }


  List<ChatConversationModel> get filteredConversations {
    if (_chatSearchQuery.trim().isEmpty) return List.unmodifiable(_conversations);
    final query = _chatSearchQuery.toLowerCase().trim();
    return _conversations.where((conversation) {
      return conversation.vendorName.toLowerCase().contains(query) ||
          conversation.vendorCategory.toLowerCase().contains(query) ||
          conversation.lastMessage.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  List<ChatMessageModel> messagesFor(String conversationId) {
    return List.unmodifiable(
      _messagesByConversation.putIfAbsent(
        conversationId,
        () => _repository.getMessages(conversationId),
      ),
    );
  }

  VendorModel? vendorById(String vendorId) {
    for (final vendor in allVendors) {
      if (vendor.id == vendorId) return vendor;
    }
    return null;
  }

  ChatConversationModel? conversationById(String conversationId) {
    for (final conversation in _conversations) {
      if (conversation.id == conversationId) return conversation;
    }
    return null;
  }

  void selectHomeCategory(String categoryId) {
    _homeSelectedCategoryId = categoryId;
    notifyListeners();
  }

  void updateHomeSearch(String query) {
    _homeSearchQuery = query;
    notifyListeners();
  }

  void selectExploreCategory(String category) {
    _exploreSelectedCategory = category;
    notifyListeners();
  }

  void updateExploreSearch(String query) {
    _exploreSearchQuery = query;
    notifyListeners();
  }

  void updateChatSearch(String query) {
    _chatSearchQuery = query;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String email,
    String? mobile,
  }) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      mobile: mobile ?? _profile.mobile,
    );
    notifyListeners();
  }

  void updateProfileAvatar(String avatarUrl) {
    _profile = _profile.copyWith(avatarUrl: avatarUrl);
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _profile = _profile.copyWith(notificationsEnabled: enabled);
    notifyListeners();
  }

  void updateLocation(LocationResult result) {
    _activeLocation = result.formattedAddress;
    notifyListeners();
  }

  void toggleFavorite(String vendorId) {
    _nearbyVendors = _toggleFavoriteInList(_nearbyVendors, vendorId);
    _trendingVendors = _toggleFavoriteInList(_trendingVendors, vendorId);
    notifyListeners();
  }

  void createBookingForVendor(VendorModel vendor) {
    final exists = _bookings.any((booking) => booking.vendorId == vendor.id);
    if (exists) return;

    _bookings = [
      BookingModel(
        id: 'b_${_bookings.length + 1}',
        vendorId: vendor.id,
        title: vendor.name,
        category: vendor.category,
        dateLabel: 'Pending date',
        location: vendor.location,
        amount: vendor.formattedPrice.replaceFirst('Starts ', ''),
        status: 'REQUESTED',
        imageUrl: vendor.imageUrl,
      ),
      ..._bookings,
    ];
    notifyListeners();
  }

  ChatConversationModel conversationForVendor(VendorModel vendor) {
    final existing = _conversations.where((conversation) => conversation.vendorId == vendor.id);
    if (existing.isNotEmpty) return existing.first;

    final conversation = ChatConversationModel(
      id: 'c_${_conversations.length + 1}',
      vendorId: vendor.id,
      vendorName: vendor.name,
      vendorCategory: vendor.category,
      lastMessage: 'Conversation started with ${vendor.name}.',
      time: 'Now',
      unreadCount: 0,
      avatarUrl: vendor.imageUrl,
    );
    _conversations = [conversation, ..._conversations];
    notifyListeners();
    return conversation;
  }

  void sendMessage(String conversationId, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final messages = List<ChatMessageModel>.of(messagesFor(conversationId));
    messages.add(
      ChatMessageModel(
        id: '${conversationId}_m${messages.length + 1}',
        conversationId: conversationId,
        text: trimmed,
        time: 'Now',
        isMine: true,
      ),
    );
    _messagesByConversation[conversationId] = messages;
    _conversations = _conversations.map((conversation) {
      if (conversation.id != conversationId) return conversation;
      return conversation.copyWith(
        lastMessage: trimmed,
        time: 'Now',
        unreadCount: 0,
      );
    }).toList(growable: false);
    notifyListeners();
  }

  bool _matchesQuery(VendorModel vendor, String query) {
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return true;
    return vendor.name.toLowerCase().contains(normalizedQuery) ||
        vendor.category.toLowerCase().contains(normalizedQuery) ||
        vendor.location.toLowerCase().contains(normalizedQuery);
  }

  bool _matchesCategoryId(VendorModel vendor, String categoryId) {
    if (categoryId == 'all') return true;
    final category = _categories.where((item) => item.id == categoryId);
    if (category.isEmpty) return true;
    return _matchesCategoryName(vendor, category.first.title);
  }

  bool _matchesCategoryName(VendorModel vendor, String categoryName) {
    if (categoryName == 'All') return true;
    final category = categoryName.toLowerCase();
    return vendor.category.toLowerCase().contains(category);
  }

  List<VendorModel> _toggleFavoriteInList(List<VendorModel> vendors, String vendorId) {
    return vendors.map((vendor) {
      if (vendor.id != vendorId) return vendor;
      return vendor.copyWith(isFavorite: !vendor.isFavorite);
    }).toList(growable: false);
  }
}
