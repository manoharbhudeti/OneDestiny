import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/vendor_model.dart';
import '../models/service_model.dart';
import '../models/flash_card_model.dart';

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

  static List<VendorModel> nearbyVendors = [
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

  static List<VendorModel> trendingVendors = [
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
}
