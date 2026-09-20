import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/services/analytics_service.dart';
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
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
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
