import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/chat_model.dart';
import '../models/flash_card_model.dart';
import '../models/service_model.dart';
import '../models/user_profile_model.dart';
import '../models/vendor_model.dart';
import '../repositories/app_repository.dart';
import '../services/auth_storage_service.dart';
import '../services/location_service.dart';

class AppState extends ChangeNotifier {
  AppState({AppRepository? repository}) : _repository = repository ?? ApiAppRepository() {
    _flashCards = List<FlashCardModel>.of(MockData.flashCards);
    _categories = List<CategoryModel>.of(MockData.categories);
    _popularServices = List<ServiceModel>.of(MockData.popularServices);
    _nearbyVendors = List<VendorModel>.of(MockData.nearbyVendors);
    _trendingVendors = List<VendorModel>.of(MockData.trendingVendors);
    _profile = const UserProfileModel(
      name: 'User',
      mobile: '+91 98765 43210',
      email: 'user@onedestiny.in',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      notificationsEnabled: true,
    );
    _bookings = [];
    _conversations = [];

    // Trigger initial async data fetch from backend
    loadInitialData();
  }

  final AppRepository _repository;

  List<FlashCardModel> _flashCards = [];
  List<CategoryModel> _categories = [];
  List<ServiceModel> _popularServices = [];
  List<VendorModel> _nearbyVendors = [];
  List<VendorModel> _trendingVendors = [];
  UserProfileModel _profile = const UserProfileModel(
    name: 'User',
    mobile: '',
    email: '',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    notificationsEnabled: true,
  );
  List<BookingModel> _bookings = [];
  List<ChatConversationModel> _conversations = [];
  final Map<String, List<ChatMessageModel>> _messagesByConversation = {};

  bool _isLoadingInitial = true;
  bool _isLoadingVendors = false;
  bool _isLoadingBookings = false;
  bool _isLoadingChat = false;

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
  bool get isLoadingInitial => _isLoadingInitial;
  bool get isLoadingVendors => _isLoadingVendors;
  bool get isLoadingBookings => _isLoadingBookings;
  bool get isLoadingChat => _isLoadingChat;

  String get greeting => 'Hello, ${_profile.name} 👋';
  String get homeSelectedCategoryId => _homeSelectedCategoryId;
  String get exploreSelectedCategory => _exploreSelectedCategory;

  double get exploreMinPrice => _exploreMinPrice;
  double get exploreMaxPrice => _exploreMaxPrice;
  double get exploreMinRating => _exploreMinRating;
  String get exploreSortBy => _exploreSortBy;

  List<VendorModel> get allVendors {
    final map = <String, VendorModel>{};
    for (final v in _trendingVendors) {
      map[v.id] = v;
    }
    for (final v in _nearbyVendors) {
      map[v.id] = v;
    }
    return map.values.toList();
  }

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

  Future<void> loadInitialData() async {
    _isLoadingInitial = true;
    notifyListeners();

    try {
      // 1. Saved location & profile from local storage
      final savedLoc = await AuthStorageService.instance.getSavedLocation();
      if (savedLoc != null && savedLoc.isNotEmpty) {
        _activeLocation = savedLoc;
      }

      // 2. Fetch categories, flash cards, popular services
      final catsFuture = _repository.getCategories();
      final flashCardsFuture = _repository.getFlashCards();
      final popularServicesFuture = _repository.getPopularServices();
      final profileFuture = _repository.getUserProfile();
      final bookingsFuture = _repository.getBookings();
      final conversationsFuture = _repository.getConversations();
      final trendingFuture = _repository.getTrendingVendors();
      final nearbyFuture = _repository.getNearbyVendors();

      final results = await Future.wait([
        catsFuture,
        flashCardsFuture,
        popularServicesFuture,
        profileFuture,
        bookingsFuture,
        conversationsFuture,
        trendingFuture,
        nearbyFuture,
      ]);

      _categories = results[0] as List<CategoryModel>;
      _flashCards = results[1] as List<FlashCardModel>;
      _popularServices = results[2] as List<ServiceModel>;
      _profile = results[3] as UserProfileModel;
      _bookings = results[4] as List<BookingModel>;
      _conversations = results[5] as List<ChatConversationModel>;
      _trendingVendors = results[6] as List<VendorModel>;
      _nearbyVendors = results[7] as List<VendorModel>;

      // Check favorites
      final favorites = await AuthStorageService.instance.getFavoriteVendorIds();
      _trendingVendors = _trendingVendors.map((v) => v.copyWith(isFavorite: favorites.contains(v.id))).toList();
      _nearbyVendors = _nearbyVendors.map((v) => v.copyWith(isFavorite: favorites.contains(v.id))).toList();
    } catch (e) {
      debugPrint('[AppState loadInitialData Error] $e');
    } finally {
      _isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> refreshHome() async {
    _isLoadingVendors = true;
    notifyListeners();
    try {
      final trending = await _repository.getTrendingVendors();
      final nearby = await _repository.getNearbyVendors();
      final favorites = await AuthStorageService.instance.getFavoriteVendorIds();

      _trendingVendors = trending.map((v) => v.copyWith(isFavorite: favorites.contains(v.id))).toList();
      _nearbyVendors = nearby.map((v) => v.copyWith(isFavorite: favorites.contains(v.id))).toList();
    } catch (e) {
      debugPrint('[AppState refreshHome Error] $e');
    } finally {
      _isLoadingVendors = false;
      notifyListeners();
    }
  }

  Future<void> refreshBookings() async {
    _isLoadingBookings = true;
    notifyListeners();
    try {
      _bookings = await _repository.getBookings();
    } catch (e) {
      debugPrint('[AppState refreshBookings Error] $e');
    } finally {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }

  Future<void> refreshConversations() async {
    _isLoadingChat = true;
    notifyListeners();
    try {
      _conversations = await _repository.getConversations();
    } catch (e) {
      debugPrint('[AppState refreshConversations Error] $e');
    } finally {
      _isLoadingChat = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _profile = await _repository.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('[AppState refreshProfile Error] $e');
    }
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
    if (_messagesByConversation.containsKey(conversationId)) {
      return List.unmodifiable(_messagesByConversation[conversationId]!);
    }

    // Trigger async load
    _fetchMessagesAsync(conversationId);
    return const [];
  }

  Future<void> _fetchMessagesAsync(String conversationId) async {
    final parsedConvId = int.tryParse(conversationId);
    final msgs = await _repository.getMessages(conversationId, vendorId: parsedConvId);
    _messagesByConversation[conversationId] = msgs;
    notifyListeners();
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

  Future<void> updateProfile({
    required String name,
    required String email,
    String? mobile,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      mobile: mobile ?? _profile.mobile,
    );
    notifyListeners();

    await _repository.updateUserProfile(name: name, email: email, mobile: mobile);
  }

  Future<void> updateProfileAvatar(String avatarUrl) async {
    _profile = _profile.copyWith(avatarUrl: avatarUrl);
    notifyListeners();
    await AuthStorageService.instance.updateProfile(avatarUrl: avatarUrl);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _profile = _profile.copyWith(notificationsEnabled: enabled);
    notifyListeners();
    await AuthStorageService.instance.updateProfile(notificationsEnabled: enabled);
  }

  Future<void> updateLocation(LocationResult result) async {
    _activeLocation = result.formattedAddress;
    notifyListeners();
    await AuthStorageService.instance.saveLocation(result.formattedAddress);
  }

  Future<void> toggleFavorite(String vendorId) async {
    _nearbyVendors = _toggleFavoriteInList(_nearbyVendors, vendorId);
    _trendingVendors = _toggleFavoriteInList(_trendingVendors, vendorId);
    notifyListeners();

    final favorites = await AuthStorageService.instance.getFavoriteVendorIds();
    if (favorites.contains(vendorId)) {
      favorites.remove(vendorId);
    } else {
      favorites.add(vendorId);
    }
    await AuthStorageService.instance.saveFavoriteVendorIds(favorites);
  }

  Future<bool> createBookingForVendor(
    VendorModel vendor, {
    DateTime? eventDate,
    String? location,
    String? notes,
    int? guestCount,
    double? budget,
  }) async {
    final parsedVendorId = int.tryParse(vendor.id);
    final bookingDate = eventDate ?? DateTime.now().add(const Duration(days: 30));

    if (parsedVendorId != null) {
      final res = await _repository.bookVendor(
        vendorId: parsedVendorId,
        eventDate: bookingDate,
        location: location ?? vendor.location,
        notes: notes,
        guestCount: guestCount,
        budget: budget ?? vendor.startingPrice,
      );

      if (res.success && res.data != null) {
        _bookings = [res.data!, ..._bookings];
        notifyListeners();
        return true;
      }
    }

    // Fallback local booking insertion
    final exists = _bookings.any((booking) => booking.vendorId == vendor.id);
    if (exists) return true;

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
    return true;
  }

  Future<bool> cancelBooking(String bookingId, {String? reason}) async {
    final parsedId = int.tryParse(bookingId);
    if (parsedId != null) {
      final res = await _repository.cancelBooking(parsedId, reason: reason);
      if (res.success && res.data != null) {
        _bookings = _bookings.map((b) => b.id == bookingId ? res.data! : b).toList();
        notifyListeners();
        return true;
      }
    }

    _bookings = _bookings.map((b) {
      if (b.id != bookingId) return b;
      return b.copyWith(status: 'CANCELLED');
    }).toList();
    notifyListeners();
    return true;
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

  Future<void> sendMessage(String conversationId, String text, {int? vendorId}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final parsedConvId = int.tryParse(conversationId);
    final messages = List<ChatMessageModel>.of(_messagesByConversation[conversationId] ?? []);

    final localMsg = ChatMessageModel(
      id: '${conversationId}_m${messages.length + 1}',
      conversationId: conversationId,
      text: trimmed,
      time: 'Now',
      isMine: true,
    );
    messages.add(localMsg);
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

    // Send to backend API
    await _repository.sendMessage(
      conversationId: parsedConvId,
      vendorId: vendorId,
      text: trimmed,
    );
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
