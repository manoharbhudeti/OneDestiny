import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/data/mock_data.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_storage_service.dart';
import 'core/ui_states/ui_states.dart';
import 'features/auth/views/login_screen.dart';
import 'features/favorites/views/favorites_screen.dart';
import 'features/help_policies/views/help_policies_screen.dart';
import 'features/main/views/main_navigation_screen.dart';
import 'features/profile/views/about_onedestiny_screen.dart';
import 'features/vendor_detail/views/vendor_detail_screen.dart';
import 'core/services/fcm_notification_service.dart';
import 'core/state/app_state.dart';
import 'core/state/app_state_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/views/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('[Main] Firebase initialization: $e');
  }

  try {
    await AnalyticsService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] Analytics initialization failed: $e');
  }

  try {
    await FcmNotificationService.instance.initialize();
  } catch (e) {
    debugPrint('[Main] FCM initialization failed: $e');
  }

  runApp(const OneDestinyApp());
}

class OneDestinyApp extends StatefulWidget {
  const OneDestinyApp({super.key});

  @override
  State<OneDestinyApp> createState() => _OneDestinyAppState();
}

class _OneDestinyAppState extends State<OneDestinyApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppState _appState;
  StreamSubscription<void>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    final initialTheme = Uri.base.queryParameters['theme']?.toLowerCase() == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
    _themeModeNotifier.value = initialTheme;
    _sessionSubscription = NetworkStateHandler.instance.sessionExpiredStream.listen((_) async {
      await AuthStorageService.instance.clearAuth();
      _handleSessionExpired();
    });
  }

  Widget _getInitialScreen() {
    final query = Uri.base.queryParameters;
    final screen = query['screen']?.toLowerCase();
    switch (screen) {
      case 'home':
        return MainNavigationScreen(themeModeNotifier: _themeModeNotifier, initialIndex: 0);
      case 'explore':
        return MainNavigationScreen(themeModeNotifier: _themeModeNotifier, initialIndex: 1);
      case 'bookings':
        return MainNavigationScreen(themeModeNotifier: _themeModeNotifier, initialIndex: 2);
      case 'chat':
        return MainNavigationScreen(themeModeNotifier: _themeModeNotifier, initialIndex: 3);
      case 'profile':
        return MainNavigationScreen(themeModeNotifier: _themeModeNotifier, initialIndex: 4);
      case 'about':
        return const AboutOneDestinyScreen();
      case 'vendor':
        return VendorDetailScreen(vendor: MockData.trendingVendors.first);
      case 'favorites':
        return const FavoritesScreen();
      case 'help':
        return const HelpPoliciesScreen();
      case 'login':
        return LoginScreen(themeModeNotifier: _themeModeNotifier);
      default:
        return SplashScreen(themeModeNotifier: _themeModeNotifier);
    }
  }

    void _handleSessionExpired() {
    if (!mounted) return;
    final navContext = _navigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    SessionExpiredDialog.show(
      navContext,
      onLoginAgain: () {
        NetworkStateHandler.instance.resetSessionExpiredGuard();
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(themeModeNotifier: _themeModeNotifier),
          ),
          (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _themeModeNotifier.dispose();
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return AppStateScope(
          appState: _appState,
          child: MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'OneDestiny',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentThemeMode,
            navigatorObservers: [
              if (AnalyticsService.instance.observer case final observer?)
                observer,
            ],
            home: _getInitialScreen(),
          ),
        );
      },
    );
  }
}
