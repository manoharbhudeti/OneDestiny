import '../data/mock_data.dart';
import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/chat_model.dart';
import '../models/flash_card_model.dart';
import '../models/service_model.dart';
import '../models/user_profile_model.dart';
import '../models/vendor_model.dart';

abstract class AppRepository {
  List<FlashCardModel> getFlashCards();
  List<CategoryModel> getCategories();
  List<ServiceModel> getPopularServices();
  List<VendorModel> getNearbyVendors();
  List<VendorModel> getTrendingVendors();
  UserProfileModel getUserProfile();
  List<BookingModel> getBookings();
  List<ChatConversationModel> getConversations();
  List<ChatMessageModel> getMessages(String conversationId);
}

class MockAppRepository implements AppRepository {
  static const String _avatarUrl =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80';

  @override
  List<FlashCardModel> getFlashCards() => List<FlashCardModel>.of(MockData.flashCards);

  @override
  List<CategoryModel> getCategories() => List<CategoryModel>.of(MockData.categories);

  @override
  List<ServiceModel> getPopularServices() => List<ServiceModel>.of(MockData.popularServices);

  @override
  List<VendorModel> getNearbyVendors() => List<VendorModel>.of(MockData.nearbyVendors);

  @override
  List<VendorModel> getTrendingVendors() => List<VendorModel>.of(MockData.trendingVendors);

  @override
  UserProfileModel getUserProfile() {
    return const UserProfileModel(
      name: 'Manohar',
      mobile: '+91 98765 43210',
      email: 'manohar@onedestiny.com',
      avatarUrl: _avatarUrl,
      notificationsEnabled: true,
    );
  }

  @override
  List<BookingModel> getBookings() {
    return const [
      BookingModel(
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
  List<ChatConversationModel> getConversations() {
    return const [
      ChatConversationModel(
        id: 'c_1',
        vendorId: 'v_1',
        vendorName: 'Lens & Light Studio',
        vendorCategory: 'Photography',
        lastMessage: 'Sure Manohar! We have Oct 24th available for your wedding shoot.',
        time: '10:42 AM',
        unreadCount: 2,
        avatarUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=200&q=80',
      ),
      ChatConversationModel(
        id: 'c_2',
        vendorId: 'tv_1',
        vendorName: 'Destiny Grand Wedding',
        vendorCategory: 'Wedding Planning',
        lastMessage: 'The stage floral decor layout proposal has been sent to your email.',
        time: 'Yesterday',
        unreadCount: 1,
        avatarUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=200&q=80',
      ),
      ChatConversationModel(
        id: 'c_3',
        vendorId: 'v_3',
        vendorName: 'Royal Culinary Caterers',
        vendorCategory: 'Catering',
        lastMessage: 'We can arrange a menu tasting session this Saturday at 4 PM.',
        time: 'Aug 1',
        unreadCount: 0,
        avatarUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=200&q=80',
      ),
      ChatConversationModel(
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
  List<ChatMessageModel> getMessages(String conversationId) {
    final vendorName = getConversations()
        .firstWhere((conversation) => conversation.id == conversationId)
        .vendorName;

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
        text: 'Hello Manohar, thanks for reaching out to $vendorName. Please share your event date and guest count.',
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
}
