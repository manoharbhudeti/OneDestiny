import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/network/api_response.dart';
import 'package:one_destiny_customer_app/core/models/user_profile_model.dart';
import 'package:one_destiny_customer_app/core/repositories/app_repository.dart';
import 'package:one_destiny_customer_app/core/state/app_state.dart';
import 'package:one_destiny_customer_app/core/state/app_state_scope.dart';
import 'package:one_destiny_customer_app/features/auth/views/user_onboarding_screen.dart';

class TestAppRepository extends MockAppRepository {
  String? updatedName;
  String? updatedEmail;

  @override
  Future<ApiResponse<UserProfileModel>> updateUserProfile({
    required String name,
    required String email,
    String? mobile,
  }) async {
    updatedName = name;
    updatedEmail = email;
    return ApiResponse.ok(
      UserProfileModel(
        name: name,
        email: email,
        mobile: mobile ?? '',
        avatarUrl: '',
        isUserOnboarded: true,
      ),
    );
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    return const UserProfileModel(
      name: 'User',
      email: '',
      mobile: '',
      avatarUrl: '',
      isUserOnboarded: false,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UserOnboardingScreen renders title, inputs and button', (tester) async {
    final mockRepo = TestAppRepository();
    final appState = AppState(repository: mockRepo);
    final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

    await tester.pumpWidget(
      AppStateScope(
        appState: appState,
        child: MaterialApp(
          home: UserOnboardingScreen(
            themeModeNotifier: themeNotifier,
            phone: '+919876543210',
          ),
        ),
      ),
    );

    expect(find.text('Complete Your Profile'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('UserOnboardingScreen validates empty inputs', (tester) async {
    final mockRepo = TestAppRepository();
    final appState = AppState(repository: mockRepo);
    final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

    await tester.pumpWidget(
      AppStateScope(
        appState: appState,
        child: MaterialApp(
          home: UserOnboardingScreen(
            themeModeNotifier: themeNotifier,
            phone: '+919876543210',
          ),
        ),
      ),
    );

    // Tap CONTINUE with empty inputs
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pump();

    expect(find.text('Full name is required.'), findsOneWidget);
  });

  testWidgets('UserOnboardingScreen submits valid inputs successfully', (tester) async {
    final mockRepo = TestAppRepository();
    final appState = AppState(repository: mockRepo);
    final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

    await tester.pumpWidget(
      AppStateScope(
        appState: appState,
        child: MaterialApp(
          home: UserOnboardingScreen(
            themeModeNotifier: themeNotifier,
            phone: '+919876543210',
          ),
        ),
      ),
    );

    // Enter Full Name and Email
    final nameField = find.widgetWithText(TextField, 'Enter your full name');
    final emailField = find.widgetWithText(TextField, 'Enter your email address');

    await tester.enterText(nameField, 'Aarav Patel');
    await tester.enterText(emailField, 'aarav@example.com');
    await tester.pump();

    // Tap CONTINUE
    await tester.ensureVisible(find.text('CONTINUE'));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(mockRepo.updatedName, 'Aarav Patel');
    expect(mockRepo.updatedEmail, 'aarav@example.com');
  });
}
