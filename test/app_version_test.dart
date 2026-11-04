import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_destiny_customer_app/core/models/app_version_info.dart';
import 'package:one_destiny_customer_app/core/services/app_version_service.dart';
import 'package:one_destiny_customer_app/core/theme/app_theme.dart';
import 'package:one_destiny_customer_app/features/profile/views/about_onedestiny_screen.dart';

class _FakeAppVersionService extends AppVersionService {
  final AppVersionInfo info;
  _FakeAppVersionService(this.info);

  @override
  Future<AppVersionInfo> loadVersionInfo() async => info;
}

void main() {
  group('AppVersionInfo and Development Team Tests', () {
    test('AppVersionInfo.fromJson correctly parses development team from JSON', () {
      final jsonFile = File('assets/config/app_version.json');
      expect(jsonFile.existsSync(), isTrue);

      final jsonMap = json.decode(jsonFile.readAsStringSync()) as Map<String, dynamic>;
      final info = AppVersionInfo.fromJson(jsonMap);

      expect(info.developedBy, 'Ekame Technologies');
      expect(info.developers.length, 2);

      expect(info.developers[0].name, 'Manohar');
      expect(info.developers[0].role, 'Developer');

      expect(info.developers[1].name, 'Datta');
      expect(info.developers[1].role, 'Developer');
    });

    testWidgets('AboutOneDestinyScreen renders Development Team and developers list', (tester) async {
      final fakeInfo = AppVersionInfo(
        version: 'V 04.11.26',
        build: 28,
        releaseDate: '2026-11-04',
        forceUpdate: false,
        minimumSupportedVersion: 'V 24.8.26',
        developedBy: 'Ekame Technologies',
        developers: const [
          DeveloperInfo(name: 'Manohar', role: 'Developer'),
          DeveloperInfo(name: 'Datta', role: 'Developer'),
        ],
        releaseNotes: const ['Bug fixes and improvements'],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AboutOneDestinyScreen(
            versionService: _FakeAppVersionService(fakeInfo),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Development Team header
      expect(find.text('Development Team'), findsOneWidget);

      // Verify developer names and roles
      expect(find.text('Manohar'), findsOneWidget);
      expect(find.text('Datta'), findsOneWidget);
      expect(find.text('Developer'), findsNWidgets(2));
      expect(find.text('Ekame Technologies'), findsOneWidget);
    });
  });
}

