import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/app_version_info.dart';

class AppVersionService {
  static const String _assetPath = 'assets/config/app_version.json';

  Future<AppVersionInfo> loadVersionInfo() async {
    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return AppVersionInfo.fromJson(jsonMap);
    } catch (e, stackTrace) {
      debugPrint('Error loading app version config from $_assetPath: $e\n$stackTrace');
      // Return safe fallback or rethrow based on caller preference
      return AppVersionInfo.fallback;
    }
  }
}
