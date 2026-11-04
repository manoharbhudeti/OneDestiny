import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/models/vendor_detail_models.dart';
import 'package:one_destiny_customer_app/features/vendor_detail/widgets/portfolio_gallery_viewer.dart';
import 'package:one_destiny_customer_app/features/vendor_detail/widgets/vendor_portfolio_section.dart';

void main() {
  group('VendorPortfolioItem & VendorPortfolioMedia Models', () {
    test('Correctly parses backend VendorPortfolioDto and PortfolioMediaDto', () {
      final backendJson = {
        'id': 12,
        'title': 'Grand Wedding Highlights',
        'description': 'Celebration rituals and candid portraits.',
        'coverImageUrl': 'https://s3.example.com/cover.jpg',
        'presignedCoverImageUrl': 'https://s3.example.com/presigned-cover.jpg',
        'isFeatured': true,
        'media': [
          {
            'id': 101,
            'key': 'vendors/12/photos/img1.jpg',
            'url': 'https://s3.example.com/img1.jpg',
            'presignedUrl': 'https://s3.example.com/presigned-img1.jpg',
            'mediaType': 'photo',
            'isCoverPhoto': true,
            'isGallery': true,
            'sortOrder': 0,
          },
          {
            'id': 102,
            'key': 'vendors/12/photos/img2.jpg',
            'url': 'https://s3.example.com/img2.jpg',
            'presignedUrl': 'https://s3.example.com/presigned-img2.jpg',
            'mediaType': 'photo',
            'isCoverPhoto': false,
            'isGallery': true,
            'sortOrder': 1,
          },
          {
            'id': 103,
            'key': 'vendors/12/videos/vid1.mp4',
            'url': 'https://s3.example.com/vid1.mp4',
            'presignedUrl': 'https://s3.example.com/presigned-vid1.mp4',
            'mediaType': 'video',
            'isCoverPhoto': false,
            'isGallery': false,
            'sortOrder': 2,
          },
        ],
      };

      final album = VendorPortfolioItem.fromJson(backendJson);

      expect(album.id, 12);
      expect(album.title, 'Grand Wedding Highlights');
      expect(album.description, 'Celebration rituals and candid portraits.');
      expect(album.isFeatured, true);
      expect(album.displayCoverUrl, 'https://s3.example.com/presigned-cover.jpg');

      expect(album.media.length, 3);
      expect(album.media[0].displayUrl, 'https://s3.example.com/presigned-img1.jpg');
      expect(album.media[0].isCoverPhoto, true);
      expect(album.media[0].isPhoto, true);
      expect(album.media[0].isVideo, false);

      expect(album.media[2].isVideo, true);
      expect(album.media[2].isPhoto, false);

      // Photos filter excludes videos
      expect(album.photoMedia.length, 2);
      expect(album.photoCount, 2);
      expect(album.allImageUrls, [
        'https://s3.example.com/presigned-img1.jpg',
        'https://s3.example.com/presigned-img2.jpg',
      ]);
    });

    test('Handles legacy format with imageUrls gracefully', () {
      final legacyJson = {
        'id': 5,
        'title': 'Reception Night',
        'description': 'Stage and decor photography.',
        'imageUrls': [
          'https://images.unsplash.com/photo-1.jpg',
          'https://images.unsplash.com/photo-2.jpg',
        ],
      };

      final album = VendorPortfolioItem.fromJson(legacyJson);

      expect(album.id, 5);
      expect(album.title, 'Reception Night');
      expect(album.allImageUrls.length, 2);
      expect(album.photoCount, 2);
      expect(album.media.length, 2);
      expect(album.displayCoverUrl, 'https://images.unsplash.com/photo-1.jpg');
    });
  });

  group('VendorPortfolioSection Widget', () {
    final sampleAlbums = [
      const VendorPortfolioItem(
        id: 1,
        title: 'Ceremony Highlights',
        description: 'Varmala and rituals.',
        isFeatured: true,
        media: [
          VendorPortfolioMedia(
            id: 11,
            url: 'https://images.unsplash.com/photo-1.jpg',
            isCoverPhoto: true,
          ),
          VendorPortfolioMedia(
            id: 12,
            url: 'https://images.unsplash.com/photo-2.jpg',
          ),
        ],
      ),
      const VendorPortfolioItem(
        id: 2,
        title: 'Pre-Wedding Shoot',
        description: 'Outdoor portraits.',
        isFeatured: false,
        media: [
          VendorPortfolioMedia(
            id: 21,
            url: 'https://images.unsplash.com/photo-3.jpg',
          ),
        ],
      ),
    ];

    testWidgets('Renders album titles, photo count badges, and chips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VendorPortfolioSection(
                albums: sampleAlbums,
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Portfolio Albums'), findsOneWidget);
      expect(find.text('2 Albums • 3 Photos'), findsOneWidget);
      expect(find.text('Ceremony Highlights'), findsWidgets);
      expect(find.text('Pre-Wedding Shoot'), findsWidgets);
      expect(find.text('All Albums (3)'), findsOneWidget);
      expect(find.text('★ FEATURED'), findsOneWidget);
    });

    testWidgets('Filtering by individual album switches display', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: VendorPortfolioSection(
                albums: sampleAlbums,
                isLoading: false,
              ),
            ),
          ),
        ),
      );

      // Tap on "Pre-Wedding Shoot" chip
      final chipFinder = find.text('Pre-Wedding Shoot (1)');
      expect(chipFinder, findsOneWidget);
      await tester.tap(chipFinder);
      await tester.pumpAndSettle();

      // Only Pre-Wedding Shoot album card is shown
      expect(find.text('Pre-Wedding Shoot'), findsWidgets);
      expect(find.text('Outdoor portraits.'), findsOneWidget);
    });

    testWidgets('Renders empty state when albums list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VendorPortfolioSection(
              albums: [],
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('No Portfolio Albums Yet'), findsOneWidget);
      expect(find.text("This vendor hasn't published portfolio albums yet."), findsOneWidget);
    });
  });

  group('PortfolioGalleryViewerScreen Widget', () {
    testWidgets('Renders gallery with album title and photo counter', (tester) async {
      const media = [
        VendorPortfolioMedia(id: 1, url: 'https://example.com/p1.jpg'),
        VendorPortfolioMedia(id: 2, url: 'https://example.com/p2.jpg'),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: PortfolioGalleryViewerScreen(
            albumTitle: 'Royal Sangeet',
            albumDescription: 'Energetic dance moments',
            media: media,
            initialIndex: 0,
          ),
        ),
      );

      expect(find.text('Royal Sangeet'), findsOneWidget);
      expect(find.text('1 of 2'), findsOneWidget);
      expect(find.text('Energetic dance moments'), findsOneWidget);
    });
  });
}
