import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/state/app_state.dart';
import 'package:one_destiny_customer_app/core/state/app_state_scope.dart';
import 'package:one_destiny_customer_app/core/theme/app_theme.dart';
import 'package:one_destiny_customer_app/core/widgets/luxury_header.dart';

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => MockHttpClientRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      MockHttpClientRequest();
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => MockHttpClientResponse();
}

class MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

final List<int> transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  Widget createTestWidget({
    required Size surfaceSize,
    EdgeInsets padding = EdgeInsets.zero,
    Brightness brightness = Brightness.light,
  }) {
    final appState = AppState();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: brightness == Brightness.light
          ? AppTheme.lightTheme
          : AppTheme.darkTheme,
      home: AppStateScope(
        appState: appState,
        child: MediaQuery(
          data: MediaQueryData(
            size: surfaceSize,
            padding: padding,
          ),
          child: Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LuxuryHeader(
                  greeting: 'Hello, Test User 👋',
                  location: 'Hyderabad, India',
                  avatarUrl:
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  bookingCount: 3,
                  activeChatCount: 2,
                  savedVendorCount: 5,
                ),
                const Expanded(
                  child: Center(
                    child: Text('Content Area'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('LuxuryHeader touches top edge and spans full width on narrow mobile (320x640)',
      (WidgetTester tester) async {
    const size = Size(320, 640);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(surfaceSize: size));
    await tester.pumpAndSettle();

    final headerFinder = find.byType(LuxuryHeader);
    expect(headerFinder, findsOneWidget);

    final rect = tester.getRect(headerFinder);
    expect(rect.left, equals(0.0));
    expect(rect.top, equals(0.0));
    expect(rect.width, equals(320.0));
    expect(find.text('Hello, Test User 👋'), findsOneWidget);
    expect(find.text('Hyderabad, India'), findsOneWidget);
  });

  testWidgets('LuxuryHeader handles top notch safe area insets and spans full width (390x844)',
      (WidgetTester tester) async {
    const size = Size(390, 844);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      surfaceSize: size,
      padding: const EdgeInsets.only(top: 47.0),
    ));
    await tester.pumpAndSettle();

    final headerFinder = find.byType(LuxuryHeader);
    expect(headerFinder, findsOneWidget);

    final rect = tester.getRect(headerFinder);
    // Background must touch the very top edge of screen
    expect(rect.top, equals(0.0));
    expect(rect.left, equals(0.0));
    expect(rect.width, equals(390.0));
  });

  testWidgets('LuxuryHeader layout on tablet (768x1024)', (WidgetTester tester) async {
    const size = Size(768, 1024);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(surfaceSize: size));
    await tester.pumpAndSettle();

    final headerFinder = find.byType(LuxuryHeader);
    expect(headerFinder, findsOneWidget);

    final rect = tester.getRect(headerFinder);
    expect(rect.top, equals(0.0));
    expect(rect.left, equals(0.0));
    expect(rect.width, equals(768.0));
  });

  testWidgets('LuxuryHeader layout on desktop (1440x900) and expandable stats test',
      (WidgetTester tester) async {
    const size = Size(1440, 900);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(surfaceSize: size));
    await tester.pumpAndSettle();

    final headerFinder = find.byType(LuxuryHeader);
    expect(headerFinder, findsOneWidget);

    final rect = tester.getRect(headerFinder);
    expect(rect.top, equals(0.0));
    expect(rect.left, equals(0.0));
    expect(rect.width, equals(1440.0));

    // Tap to expand stats panel
    await tester.tap(find.text('Hello, Test User 👋'));
    await tester.pumpAndSettle();

    // Verify stats panel items appear without overflow
    expect(find.text('Quick Summary'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Active Chats'), findsOneWidget);
    expect(find.text('Saved Vendors'), findsOneWidget);
  });
}

