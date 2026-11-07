import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_destiny_customer_app/core/models/vendor_model.dart';
import 'package:one_destiny_customer_app/core/models/vendor_detail_models.dart';
import 'package:one_destiny_customer_app/core/models/booking_model.dart';
import 'package:one_destiny_customer_app/core/network/api_response.dart';
import 'package:one_destiny_customer_app/core/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('VendorModel Booking Status Parsing Tests', () {
    test('VendorModel.fromJson parses bookingStatus, bookingId, and computes hasActiveBooking for Pending', () {
      final json = {
        'id': 101,
        'businessName': 'Grand Moments Photography',
        'categoryName': 'Photography',
        'baseLocation': 'Hyderabad',
        'averageRating': 4.9,
        'startingPrice': 30000.0,
        'bookingStatus': 'Pending',
        'bookingId': 55,
        'hasActiveBooking': true,
      };

      final vendor = VendorModel.fromJson(json);

      expect(vendor.id, '101');
      expect(vendor.name, 'Grand Moments Photography');
      expect(vendor.bookingStatus, 'Pending');
      expect(vendor.bookingId, 55);
      expect(vendor.hasActiveBooking, isTrue);
    });

    test('VendorModel.fromJson parses Confirmed booking as hasActiveBooking true', () {
      final json = {
        'id': 102,
        'businessName': 'Royal Decor',
        'categoryName': 'Decorators',
        'baseLocation': 'Bangalore',
        'averageRating': 4.7,
        'startingPrice': 50000.0,
        'bookingStatus': 'Confirmed',
        'bookingId': 72,
        'hasActiveBooking': true,
      };

      final vendor = VendorModel.fromJson(json);

      expect(vendor.bookingStatus, 'Confirmed');
      expect(vendor.bookingId, 72);
      expect(vendor.hasActiveBooking, isTrue);
    });

    test('VendorModel.fromJson computes hasActiveBooking false when bookingStatus is null', () {
      final json = {
        'id': 103,
        'businessName': 'Star Caterers',
        'categoryName': 'Catering',
        'baseLocation': 'Chennai',
        'averageRating': 4.5,
        'startingPrice': 400.0,
        'bookingStatus': null,
        'bookingId': null,
        'hasActiveBooking': false,
      };

      final vendor = VendorModel.fromJson(json);

      expect(vendor.bookingStatus, isNull);
      expect(vendor.bookingId, isNull);
      expect(vendor.hasActiveBooking, isFalse);
    });

    test('VendorModel.fromJson parses Cancelled booking as hasActiveBooking false', () {
      final json = {
        'id': 104,
        'businessName': 'DJ Nights',
        'categoryName': 'DJ & Sound',
        'baseLocation': 'Goa',
        'averageRating': 4.6,
        'startingPrice': 15000.0,
        'bookingStatus': 'Cancelled',
        'bookingId': 80,
        'hasActiveBooking': false,
      };

      final vendor = VendorModel.fromJson(json);

      expect(vendor.bookingStatus, 'Cancelled');
      expect(vendor.bookingId, 80);
      expect(vendor.hasActiveBooking, isFalse);
    });

    test('VendorModel.toJson and copyWith preserve bookingStatus and hasActiveBooking', () {
      final vendor = VendorModel(
        id: '1',
        name: 'V1',
        category: 'Cat',
        rating: 4.5,
        distanceKm: 2.0,
        startingPrice: 1000.0,
        location: 'Loc',
        imageUrl: 'url',
        bookingStatus: 'Pending',
        bookingId: 10,
        hasActiveBooking: true,
      );

      final json = vendor.toJson();
      expect(json['bookingStatus'], 'Pending');
      expect(json['bookingId'], 10);
      expect(json['hasActiveBooking'], isTrue);

      final updated = vendor.copyWith(bookingStatus: 'Confirmed');
      expect(updated.bookingStatus, 'Confirmed');
      expect(updated.hasActiveBooking, isTrue);
    });
  });

  group('VendorFullProfile Booking Status Parsing Tests', () {
    test('VendorFullProfile.fromJson parses bookingStatus and hasActiveBooking', () {
      final json = {
        'id': 201,
        'businessName': 'Floral Elegance',
        'categoryName': 'Florist',
        'description': 'Beautiful florals',
        'startingPrice': 15000.0,
        'averageRating': 4.8,
        'totalReviews': 24,
        'baseLocation': 'Mumbai',
        'coverImageUrl': 'https://example.com/cover.jpg',
        'bookingStatus': 'Pending',
        'bookingId': 99,
        'hasActiveBooking': true,
      };

      final profile = VendorFullProfile.fromJson(json);

      expect(profile.id, 201);
      expect(profile.businessName, 'Floral Elegance');
      expect(profile.bookingStatus, 'Pending');
      expect(profile.bookingId, 99);
      expect(profile.hasActiveBooking, isTrue);
    });
  });

  group('AppState Duplicate Booking Prevention Tests', () {
    test('hasActiveBookingForVendor returns true when pending booking exists', () {
      final appState = AppState();

      // Initially no bookings
      expect(appState.hasActiveBookingForVendor('vendor_1'), isFalse);
    });

    test('createBookingForVendor does not duplicate when vendor hasActiveBooking is true', () async {
      final appState = AppState();

      final vendorWithBooking = VendorModel(
        id: '999',
        name: 'Booked Vendor',
        category: 'Music',
        rating: 4.8,
        distanceKm: 3.0,
        startingPrice: 20000.0,
        location: 'Delhi',
        imageUrl: 'https://example.com/music.jpg',
        bookingStatus: 'Pending',
        bookingId: 123,
        hasActiveBooking: true,
      );

      final result = await appState.createBookingForVendor(vendorWithBooking);
      expect(result, isTrue);

      // Verify no duplicate booking was created in AppState._bookings
      final matchingBookings = appState.bookings.where((b) => b.vendorId == '999');
      expect(matchingBookings.length, 0);
    });
  });
}
