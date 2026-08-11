import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OneDestinyApp());
}

class OneDestinyApp extends StatefulWidget {
  const OneDestinyApp({super.key});

  @override
  State<OneDestinyApp> createState() => _OneDestinyAppState();
}

class _OneDestinyAppState extends State<OneDestinyApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'OneDestiny',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: SplashScreen(themeModeNotifier: _themeModeNotifier),
        );
      },
    );
  }
}
