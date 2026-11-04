import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_storage_service.dart';
import 'core/ui_states/ui_states.dart';
import 'features/auth/views/login_screen.dart';
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
    _sessionSubscription = NetworkStateHandler.instance.sessionExpiredStream.listen((_) async {
      await AuthStorageService.instance.clearAuth();
      _handleSessionExpired();
    });
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
            home: SplashScreen(themeModeNotifier: _themeModeNotifier),
          ),
        );
      },
    );
  }
}
