import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/network/api_response.dart';
import 'package:one_destiny_customer_app/core/models/vendor_model.dart';

void main() {
  test('PagedResponse correctly parses API response nested inside data.items', () {
    final apiJson = {
      'success': true,
      'data': {
        'items': [
          {
            'id': 1,
            'businessName': 'Shutter Stories',
            'categoryName': 'Wedding Photography',
            'baseLocation': 'Mumbai, Maharashtra',
            'averageRating': 4.8,
            'startingPrice': 25000.0,
          },
          {
            'id': 2,
            'businessName': 'Sri photography',
            'categoryName': 'Wedding Photography',
            'baseLocation': 'Kakinada, Andhra Pradesh',
            'averageRating': 0.0,
            'startingPrice': 45000.0,
          },
        ],
        'totalCount': 2,
        'page': 1,
        'pageSize': 20,
        'totalPages': 1,
        'hasNextPage': false,
        'hasPreviousPage': false,
      },
      'message': 'Success',
      'errors': [],
    };

    final paged = PagedResponse<VendorModel>.fromJson(
      apiJson,
      (item) => VendorModel.fromJson(item as Map<String, dynamic>),
    );

    expect(paged.items.length, 2);
    expect(paged.totalCount, 2);
    expect(paged.items[0].name, 'Shutter Stories');
    expect(paged.items[1].name, 'Sri photography');
    expect(paged.items[1].location, 'Kakinada, Andhra Pradesh');
  });

  test('PagedResponse also handles legacy or unnested items list', () {
    final legacyJson = {
      'items': [
        {
          'id': 10,
          'businessName': 'Decor Art',
          'categoryName': 'Decoration',
        },
      ],
      'totalCount': 1,
      'page': 1,
      'pageSize': 20,
    };

    final paged = PagedResponse<VendorModel>.fromJson(
      legacyJson,
      (item) => VendorModel.fromJson(item as Map<String, dynamic>),
    );

    expect(paged.items.length, 1);
    expect(paged.items[0].name, 'Decor Art');
  });
}
