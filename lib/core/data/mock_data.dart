import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/flash_card_model.dart';
import '../models/help_policy_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../models/vendor_model.dart';

class MockData {
  static const List<FlashCardModel> flashCards = [
    FlashCardModel(
      id: 'fc_1',
      title: '30% OFF Stage Decor',
      subtitle: 'Luxury floral & LED setups',
      discountTag: '30% OFF',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_2',
    ),
    FlashCardModel(
      id: 'fc_2',
      title: 'Free Pre-Wedding Shoot',
      subtitle: 'Book full wedding package today',
      discountTag: 'SPECIAL DEAL',
      imageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_1',
    ),
    FlashCardModel(
      id: 'fc_3',
      title: 'Grand Buffet Specials',
      subtitle: 'Complimentary dessert counter',
      discountTag: 'POPULAR',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_3',
    ),
    FlashCardModel(
      id: 'fc_4',
      title: 'VIP DJ & Laser Show',
      subtitle: '20% OFF weekday bookings',
      discountTag: '20% OFF',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_5',
    ),
    FlashCardModel(
      id: 'fc_5',
      title: 'Bridal Makeover Offer',
      subtitle: 'Free trial makeup included',
      discountTag: 'HOT DEAL',
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_6',
    ),
    FlashCardModel(
      id: 'fc_6',
      title: 'Palace Venue Booking',
      subtitle: 'Flat ₹25,000 instant cashback',
      discountTag: 'LIMITED',
      imageUrl: 'https://images.unsplash.com/photo-1545232979-fbf5963d13a2?auto=format&fit=crop&w=800&q=80',
      targetCategoryId: 'cat_7',
    ),
  ];


  static const List<CategoryModel> categories = [
    CategoryModel(id: 'cat_1', title: 'Photography', icon: Icons.camera_alt_outlined),
    CategoryModel(id: 'cat_2', title: 'Decoration', icon: Icons.auto_awesome_outlined),
    CategoryModel(id: 'cat_3', title: 'Catering', icon: Icons.restaurant_outlined),
    CategoryModel(id: 'cat_4', title: 'Wedding', icon: Icons.favorite_border_rounded),
    CategoryModel(id: 'cat_5', title: 'DJ', icon: Icons.headphones_outlined),
    CategoryModel(id: 'cat_6', title: 'Makeup', icon: Icons.face_retouching_natural_outlined),
    CategoryModel(id: 'cat_7', title: 'Venue', icon: Icons.location_city_outlined),
    CategoryModel(id: 'cat_8', title: 'Flowers', icon: Icons.local_florist_outlined),
    CategoryModel(id: 'cat_9', title: 'Mehendi', icon: Icons.brush_outlined),
    CategoryModel(id: 'cat_10', title: 'Printing', icon: Icons.print_outlined),
    CategoryModel(id: 'cat_11', title: 'Cars', icon: Icons.directions_car_outlined),
    CategoryModel(id: 'cat_12', title: 'More', icon: Icons.grid_view_outlined),
  ];

  static const List<ServiceModel> popularServices = [
    ServiceModel(
      id: 'srv_1',
      title: 'Wedding Package',
      icon: Icons.favorite_outline,
      lightBgColor: Color(0xFFEFF6FF),
    ),
    ServiceModel(
      id: 'srv_2',
      title: 'Birthday Planner',
      icon: Icons.cake_outlined,
      lightBgColor: Color(0xFFFEF3C7),
    ),
    ServiceModel(
      id: 'srv_3',
      title: 'Corporate Events',
      icon: Icons.business_center_outlined,
      lightBgColor: Color(0xFFF3E8FF),
    ),
    ServiceModel(
      id: 'srv_4',
      title: 'Baby Shower',
      icon: Icons.child_care_outlined,
      lightBgColor: Color(0xFFFCE7F3),
    ),
    ServiceModel(
      id: 'srv_5',
      title: 'House Warming',
      icon: Icons.home_work_outlined,
      lightBgColor: Color(0xFFDCFCE7),
    ),
  ];

  static const List<VendorModel> nearbyVendors = [
    VendorModel(
      id: 'v_1',
      name: 'Lens & Light Studio',
      category: 'Photography',
      rating: 4.9,
      distanceKm: 2.0,
      startingPrice: 18000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
      isFavorite: true,
    ),
    VendorModel(
      id: 'v_2',
      name: 'Aura Stage Decorators',
      category: 'Decoration',
      rating: 4.8,
      distanceKm: 3.5,
      startingPrice: 25000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
    ),
    VendorModel(
      id: 'v_3',
      name: 'Royal Culinary Caterers',
      category: 'Catering',
      rating: 4.9,
      distanceKm: 1.8,
      startingPrice: 32000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80',
    ),
    VendorModel(
      id: 'v_4',
      name: 'Glamour Touch Makeup',
      category: 'Makeup',
      rating: 4.7,
      distanceKm: 4.1,
      startingPrice: 12000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=800&q=80',
    ),
    VendorModel(
      id: 'v_5',
      name: 'Sonic Bass DJ & Sound',
      category: 'DJ',
      rating: 4.8,
      distanceKm: 5.0,
      startingPrice: 15000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=800&q=80',
    ),
    VendorModel(
      id: 'v_6',
      name: 'Floral Symphony',
      category: 'Flowers',
      rating: 4.9,
      distanceKm: 2.4,
      startingPrice: 10000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=800&q=80',
    ),
  ];

  static const List<VendorModel> trendingVendors = [
    VendorModel(
      id: 'tv_1',
      name: 'Destiny Grand Wedding Planners',
      category: 'Wedding Planning',
      rating: 5.0,
      distanceKm: 1.2,
      startingPrice: 150000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=1200&q=80',
      isTrending: true,
      isFavorite: true,
    ),
    VendorModel(
      id: 'tv_2',
      name: 'Imperial Palace & Lawns',
      category: 'Venue',
      rating: 4.9,
      distanceKm: 4.5,
      startingPrice: 95000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1545232979-fbf5963d13a2?auto=format&fit=crop&w=1200&q=80',
      isTrending: true,
    ),
    VendorModel(
      id: 'tv_3',
      name: 'Velocity Luxury Event Cars',
      category: 'Cars',
      rating: 4.8,
      distanceKm: 3.0,
      startingPrice: 22000,
      location: 'Hyderabad',
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
      isTrending: true,
    ),
  ];

  static const List<ReviewModel> reviews = [
    ReviewModel(
      id: 'rev_1',
      vendorId: 'tv_1',
      userName: 'Ananya Sharma',
      userAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      date: 'Aug 14, 2026',
      reviewText: 'Destiny Grand organized our wedding reception flawlessly! The stage floral arrangements and lighting were breathtaking. Highly recommend their VIP package.',
      photos: [
        'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=800&q=80',
      ],
      isVerifiedBooking: true,
    ),
    ReviewModel(
      id: 'rev_2',
      vendorId: 'tv_1',
      userName: 'Vikram Reddy',
      userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      rating: 5.0,
      date: 'Jul 28, 2026',
      reviewText: 'Extremely professional team. They managed 500+ guests without a single hiccup. Punctual, courteous, and high attention to detail.',
      photos: [
        'https://images.unsplash.com/photo-1545232979-fbf5963d13a2?auto=format&fit=crop&w=800&q=80',
      ],
      isVerifiedBooking: true,
    ),
    ReviewModel(
      id: 'rev_3',
      vendorId: 'v_1',
      userName: 'Rohan Mehta',
      userAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      rating: 4.9,
      date: 'Aug 02, 2026',
      reviewText: 'Lens & Light Studio captured our pre-wedding and main event photography beautifully. The album quality and cinematic teaser were outstanding!',
      photos: [
        'https://images.unsplash.com/photo-1537633552985-df8429e8048b?auto=format&fit=crop&w=800&q=80',
      ],
      isVerifiedBooking: true,
    ),
    ReviewModel(
      id: 'rev_4',
      vendorId: 'v_3',
      userName: 'Priya Verma',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      rating: 4.8,
      date: 'Jul 19, 2026',
      reviewText: 'Royal Culinary Caterers provided extraordinary North Indian & South Indian fusion items. All guests praised the live counters and dessert display.',
      photos: [
        'https://images.unsplash.com/photo-1555244162-803834f70033?auto=format&fit=crop&w=800&q=80',
      ],
      isVerifiedBooking: true,
    ),
  ];

  static const List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif_1',
      title: 'Booking Confirmed 🎉',
      message: 'Your booking request for Destiny Grand Wedding Planners has been officially confirmed.',
      timestamp: '10m ago',
      type: NotificationType.booking,
      isRead: false,
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF22C55E),
    ),
    NotificationModel(
      id: 'notif_2',
      title: 'Exclusive Offer 💎',
      message: 'Get flat 20% OFF on all Luxury Stage Decoration packages booked this week.',
      timestamp: '1h ago',
      type: NotificationType.offer,
      isRead: false,
      icon: Icons.local_offer_rounded,
      iconColor: Color(0xFFD4AF37),
    ),
    NotificationModel(
      id: 'notif_3',
      title: 'New Vendor Message 💬',
      message: 'Lens & Light Studio sent you an updated photo shooting itinerary.',
      timestamp: '3h ago',
      type: NotificationType.message,
      isRead: true,
      icon: Icons.chat_rounded,
      iconColor: Color(0xFF6B1028),
    ),
    NotificationModel(
      id: 'notif_4',
      title: 'Event Reminder 📅',
      message: 'Your venue consultation for Imperial Palace is scheduled for tomorrow at 4:00 PM.',
      timestamp: '1d ago',
      type: NotificationType.status,
      isRead: true,
      icon: Icons.event_rounded,
      iconColor: Colors.blueAccent,
    ),
  ];

  static const List<FaqItem> faqs = [
    FaqItem(
      question: 'Does OneDestiny handle payments or refunds directly?',
      answer: 'No. OneDestiny serves strictly as a bridge platform connecting customers with event vendors. OneDestiny does NOT process or handle financial transactions directly. All payments, deposits, and refunds are managed directly between the customer and the vendor.',
      category: 'Payments',
    ),
    FaqItem(
      question: 'Should I pay an advance deposit upfront before confirmation?',
      answer: 'CRITICAL SAFETY ADVISORY: Do NOT make any advance or upfront payment to any vendor without first receiving a formal booking confirmation from the vendor through OneDestiny.',
      category: 'Safety',
    ),
    FaqItem(
      question: 'How do I request a custom event quote from a vendor?',
      answer: 'Navigate to the vendor\'s detail page, select the desired package, and tap "Chat" or "Book Now". You can specify your event date, guest count, and venue location to receive an itemized quote.',
      category: 'Bookings',
    ),
    FaqItem(
      question: 'How are refund disputes handled?',
      answer: 'Because OneDestiny does not collect or hold user payments, all refund requests must be resolved directly with the vendor as per their specific cancellation agreement.',
      category: 'Payments',
    ),
    FaqItem(
      question: 'How does OneDestiny Concierge Support assist users?',
      answer: 'Our concierge team assists with communication, vendor verification, and dispute mediation. However, OneDestiny does not issue monetary refunds directly.',
      category: 'Support',
    ),
  ];

  static const List<CancellationTier> cancellationTiers = [
    CancellationTier(
      timeframe: '7+ Days Before Event',
      refundPercentage: 'Vendor Policy Terms',
      description: 'Subject to individual vendor refund terms. Refund claims must be submitted directly to the vendor.',
    ),
    CancellationTier(
      timeframe: '3 - 6 Days Before Event',
      refundPercentage: 'Partial Vendor Terms',
      description: 'Vendor may retain partial deposit based on their resource preparation costs.',
    ),
    CancellationTier(
      timeframe: 'Less than 48 Hours',
      refundPercentage: 'Non-refundable',
      description: 'Advance deposits are typically non-refundable within 48 hours of event execution.',
    ),
  ];

  static const List<PolicySection> policySections = [
    PolicySection(
      title: 'Financial Disclaimer & Platform Role',
      content: 'OneDestiny is an intermediary bridge platform connecting customers with event service vendors.',
      bulletPoints: [
        'OneDestiny does NOT directly process, hold, or handle any financial transactions between customers and vendors.',
        'OneDestiny is not responsible for issuing monetary refunds or managing payment disbursements.',
        'All financial agreements, advance payments, and refund claims are strictly between the customer and vendor.',
      ],
    ),
    PolicySection(
      title: 'Upfront Payment Safety Advisory',
      content: 'Customer awareness regarding advance payment safety:',
      bulletPoints: [
        'DO NOT make any advance payment or financial transfer upfront without explicit vendor booking confirmation.',
        'Always verify date availability and event package terms before sending payments.',
        'Report any vendor demanding unauthorized offline payments to OneDestiny support immediately.',
      ],
    ),
    PolicySection(
      title: 'Dispute Handling & Mediation',
      content: 'OneDestiny provides communication assistance and mediation guidance for booking disputes.',
      bulletPoints: [
        'Step 1: Contact OneDestiny support via Profile > Help & Policies if a dispute arises.',
        'Step 2: Our concierge team reviews event details and facilitates communication between customer and vendor.',
        'Step 3: Direct resolution is established in accordance with the vendor\'s agreed cancellation policy.',
      ],
    ),
    PolicySection(
      title: 'Terms of Service & Privacy',
      content: 'By using OneDestiny, you acknowledge our platform role and privacy commitments.',
      bulletPoints: [
        'OneDestiny is a listing and discovery marketplace platform.',
        'User contact information is shared only with confirmed booked vendors.',
        'Users are responsible for verifying vendor agreements prior to making financial transfers.',
      ],
    ),
  ];
}

