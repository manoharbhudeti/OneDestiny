import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/theme/app_theme.dart';
import 'package:one_destiny_customer_app/core/ui_states/ui_states.dart';

void main() {
  group('UI States Validation & Unit Tests', () {
    test('ErrorMessageMapper sanitizes technical exceptions into user-friendly messages', () {
      // Technical SQL or schema leak
      const sqlError = 'SqlException: Table dbo.Vendors not found in database connection pool';
      expect(ErrorMessageMapper.map(sqlError), 'A system error occurred. Please try again later.');

      // Technical 500 error
      expect(
        ErrorMessageMapper.map('Server exception', statusCode: 500),
        'Our servers are momentarily unavailable. Our engineering team has been alerted.',
      );

      // Technical 401 error
      expect(
        ErrorMessageMapper.map('Unauthorized', statusCode: 401),
        'Your session has expired. Please log in again to continue.',
      );

      // Technical 404 error
      expect(
        ErrorMessageMapper.map('Not found', statusCode: 404),
        'The requested resource or vendor was not found.',
      );

      // Socket / Network failure
      final socketErr = const SocketException('Connection refused');
      expect(
        ErrorMessageMapper.map(socketErr),
        'Unable to reach the server. Please verify your connection.',
      );

      // Format / JSON parse error
      const parseErr = FormatException('Unexpected character at line 1');
      expect(
        ErrorMessageMapper.map(parseErr),
        'Received an unexpected response format from the server.',
      );
    });

    test('FormFieldFeedback validation helpers validate correctly', () {
      // Phone
      expect(FormFieldFeedback.validatePhone(''), 'Mobile number is required.');
      expect(FormFieldFeedback.validatePhone('12345'), 'Please enter a valid 10-digit mobile number.');
      expect(FormFieldFeedback.validatePhone('9876543210'), isNull);

      // Email
      expect(FormFieldFeedback.validateEmail(''), 'Email address is required.');
      expect(FormFieldFeedback.validateEmail('invalid-email'), 'Please enter a valid email address.');
      expect(FormFieldFeedback.validateEmail('user@onedestiny.com'), isNull);

      // OTP
      expect(FormFieldFeedback.validateOtp(''), 'OTP is required.');
      expect(FormFieldFeedback.validateOtp('123', 6), 'Please enter the complete 6-digit code.');
      expect(FormFieldFeedback.validateOtp('123456', 6), isNull);
      expect(FormFieldFeedback.validateOtp('1234', 4), isNull);

      // Password
      expect(FormFieldFeedback.validatePassword(''), 'Password is required.');
      expect(FormFieldFeedback.validatePassword('12345'), 'Password must be at least 6 characters.');
      expect(FormFieldFeedback.validatePassword('secret123'), isNull);

      // Confirm Password
      expect(FormFieldFeedback.validateConfirmPassword('pass123', 'different'), 'Passwords do not match.');
      expect(FormFieldFeedback.validateConfirmPassword('pass123', 'pass123'), isNull);
    });

    test('NetworkStateHandler singleton handles streams and broadcast', () async {
      final handler = NetworkStateHandler.instance;
      handler.resetSessionExpiredGuard();
      expect(handler.isSessionExpiredTriggered, isFalse);

      bool sessionExpiredReceived = false;
      final sub = handler.sessionExpiredStream.listen((_) {
        sessionExpiredReceived = true;
      });

      handler.notifySessionExpired();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(sessionExpiredReceived, isTrue);
      expect(handler.isSessionExpiredTriggered, isTrue);

      // Second notification should be suppressed until reset
      sessionExpiredReceived = false;
      handler.notifySessionExpired();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(sessionExpiredReceived, isFalse);

      // Reset
      handler.resetSessionExpiredGuard();
      expect(handler.isSessionExpiredTriggered, isFalse);
      await sub.cancel();
    });
  });

  group('UI States Widget Rendering Tests', () {
    Widget createTestApp(Widget child, {bool isDark = false}) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(body: child),
      );
    }

    testWidgets('State 1 — EmptyStateWidget renders title, description, and CTA', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(
        createTestApp(
          EmptyStateWidget.noBookings(
            onExploreVendors: () => actionTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No Bookings Yet'), findsOneWidget);
      expect(find.text('Explore Vendors'), findsOneWidget);

      await tester.tap(find.text('Explore Vendors'));
      expect(actionTapped, isTrue);
    });

    testWidgets('State 2A — SkeletonLoaderCard renders shimmer placeholders', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          SkeletonLoaderCard.vendorCardList(count: 2),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SkeletonShimmer), findsWidgets);
      expect(find.byType(SkeletonBlock), findsWidgets);
    });

    testWidgets('State 2B — InlineLoadingButton renders normal state and spinner state', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        createTestApp(
          InlineLoadingButton(
            label: 'Submit Booking',
            isLoading: false,
            onPressed: () => pressed = true,
          ),
        ),
      );

      expect(find.text('Submit Booking'), findsOneWidget);
      await tester.tap(find.text('Submit Booking'));
      expect(pressed, isTrue);

      // When loading, spinner renders and clicks are disabled
      pressed = false;
      await tester.pumpWidget(
        createTestApp(
          InlineLoadingButton(
            label: 'Submit Booking',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit Booking'), findsNothing);
    });

    testWidgets('State 2C — FullScreenLoader renders message and progress', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const FullScreenLoader(message: 'Securing your session...'),
        ),
      );
      await tester.pump();

      expect(find.text('Securing your session...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('State 3 — ErrorStateWidget renders sanitized title, message and triggers retry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        createTestApp(
          ErrorStateWidget(
            error: 'SqlException: Syntax error in SQL query',
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pump();

      // Ensure raw SQL is NOT displayed to the user
      expect(find.textContaining('SqlException'), findsNothing);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('State 4 — NoInternetWidget renders 2D vector artwork and retry CTA', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        createTestApp(
          NoInternetWidget(
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text("You're Offline!"), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('State 5 — SlowNetworkWidget renders banner and inline modes', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(
        createTestApp(
          SlowNetworkWidget.banner(
            onCancel: () => cancelled = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Network is taking longer than expected'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });

    testWidgets('State 6 — NoSearchResultsWidget renders query, suggestions and clear filters CTA', (tester) async {
      bool cleared = false;
      await tester.pumpWidget(
        createTestApp(
          NoSearchResultsWidget(
            searchQuery: 'NonExistentVendor999',
            onClearFilters: () => cleared = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No Vendors Found'), findsOneWidget);
      expect(find.textContaining('NonExistentVendor999'), findsOneWidget);
      expect(find.text('Clear All Filters'), findsOneWidget);

      await tester.tap(find.text('Clear All Filters'));
      expect(cleared, isTrue);
    });

    testWidgets('State 7 — PermissionDeniedWidget renders location and photos rationale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PermissionDeniedWidget.location(isPermanentlyDenied: true),
        ),
      );
      await tester.pump();

      expect(find.text('Location Access Required'), findsOneWidget);
      expect(find.text('Open Settings'), findsOneWidget);
    });

    testWidgets('State 8 — SessionExpiredDialog renders non-dismissible luxury modal and login CTA', (tester) async {
      bool loginTapped = false;
      await tester.pumpWidget(
        createTestApp(
          SessionExpiredDialog(
            onLoginAgain: () => loginTapped = true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Your Session Has Expired'), findsOneWidget);
      expect(find.text('Login Again'), findsOneWidget);

      await tester.tap(find.text('Login Again'));
      expect(loginTapped, isTrue);
    });

    testWidgets('State 9 — FormFieldFeedback renders helper text, error message, and borders', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const FormFieldFeedback(
            errorMessage: 'Please enter a valid 10-digit mobile number.',
            isInteracted: true,
            child: TextField(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Please enter a valid 10-digit mobile number.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('State 10 — SuccessStateWidget renders animated checkmark and primary/secondary CTAs', (tester) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;
      await tester.pumpWidget(
        createTestApp(
          SuccessStateWidget.bookingCreated(
            vendorName: 'Royal Orchid Decor',
            onViewBookings: () => primaryTapped = true,
            onBackToHome: () => secondaryTapped = true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500)); // checkmark animation

      expect(find.text('Request Sent Successfully!'), findsOneWidget);
      expect(find.textContaining('Royal Orchid Decor'), findsOneWidget);
      expect(find.text('View in Bookings'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      await tester.tap(find.text('View in Bookings'));
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('Back to Home'));
      expect(secondaryTapped, isTrue);
    });

    testWidgets('StateViewSwitcher transitions between loading, error, empty, and success content', (tester) async {
      final uiState = UiState<List<String>>.loading();

      await tester.pumpWidget(
        createTestApp(
          StateViewSwitcher<List<String>>(
            state: uiState,
            onLoading: (context) => const Text('Loading Data...'),
            onError: (context, error, code) => Text('Error: $error'),
            onEmpty: (context) => const Text('No Data Found'),
            onSuccess: (context, data) => Text('Data: ${data.join(', ')}'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Loading Data...'), findsOneWidget);

      // Transition to error
      await tester.pumpWidget(
        createTestApp(
          StateViewSwitcher<List<String>>(
            state: UiState<List<String>>.error(message: 'Network failed'),
            onLoading: (context) => const Text('Loading Data...'),
            onError: (context, error, code) => Text('Error: $error'),
            onEmpty: (context) => const Text('No Data Found'),
            onSuccess: (context, data) => Text('Data: ${data.join(', ')}'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Error: Network failed'), findsOneWidget);

      // Transition to content
      await tester.pumpWidget(
        createTestApp(
          StateViewSwitcher<List<String>>(
            state: UiState<List<String>>.success(['Item 1', 'Item 2']),
            onLoading: (context) => const Text('Loading Data...'),
            onError: (context, error, code) => Text('Error: $error'),
            onEmpty: (context) => const Text('No Data Found'),
            onSuccess: (context, data) => Text('Data: ${data.join(', ')}'),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Data: Item 1, Item 2'), findsOneWidget);
    });
  });
}
