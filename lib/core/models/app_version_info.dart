import 'package:flutter/foundation.dart';

@immutable
class DeveloperInfo {
  final String name;
  final String? role;
  final String? url;

  const DeveloperInfo({
    required this.name,
    this.role,
    this.url,
  });

  factory DeveloperInfo.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return DeveloperInfo(
        name: json['name'] as String? ?? 'Developer',
        role: json['role'] as String?,
        url: json['url'] as String? ?? json['linkedin'] as String?,
      );
    }
    return DeveloperInfo(name: json.toString());
  }

  bool get hasLink => url != null && url!.trim().isNotEmpty;
}

@immutable
class AppVersionInfo {
  final String version;
  final int build;
  final String releaseDate;
  final bool forceUpdate;
  final String minimumSupportedVersion;
  final String developedBy;
  final List<DeveloperInfo> developers;
  final List<String> releaseNotes;

  const AppVersionInfo({
    required this.version,
    required this.build,
    required this.releaseDate,
    required this.forceUpdate,
    required this.minimumSupportedVersion,
    required this.developedBy,
    required this.developers,
    required this.releaseNotes,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    List<DeveloperInfo> devList = [];

    if (json['developers'] is List) {
      devList = (json['developers'] as List)
          .map((item) => DeveloperInfo.fromJson(item))
          .toList();
    } else if (json['Developed By'] != null || json['developedBy'] != null) {
      final devStr = (json['Developed By'] ?? json['developedBy']).toString();
      final names = devStr.split(RegExp(r'\s*&\s*|\s*,\s*'));
      devList = names.map((name) {
        final cleanName = name.trim();
        if (cleanName.toLowerCase().contains('manohar')) {
          return const DeveloperInfo(
            name: 'Manohar',
            role: 'Lead Developer',
            url: 'https://www.linkedin.com/in/manoharbhudeti/',
          );
        }
        return DeveloperInfo(name: cleanName, role: 'Developer');
      }).toList();
    }

    if (devList.isEmpty) {
      devList = const [
        DeveloperInfo(
          name: 'Manohar',
          role: 'Lead Developer',
          url: 'https://www.linkedin.com/in/manoharbhudeti/',
        ),
        DeveloperInfo(name: 'Datta', role: 'Developer'),
      ];
    }

    return AppVersionInfo(
      version: json['version'] as String? ?? 'V 24.8.26',
      build: (json['build'] as num?)?.toInt() ?? 27,
      releaseDate: json['releaseDate'] as String? ?? '2026-08-24',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      minimumSupportedVersion: json['minimumSupportedVersion'] as String? ?? 'V 24.8.26',
      developedBy: json['developedBy'] as String? ??
          json['Developed By'] as String? ??
          'Manohar & Datta',
      developers: devList,
      releaseNotes: (json['releaseNotes'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  /// Safe date formatter: Converts "2026-08-24" to "24 August 2026"
  String get formattedReleaseDate {
    try {
      final parts = releaseDate.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.parse(parts[1]);
        final dayInt = int.parse(parts[2]);

        const monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];

        if (monthInt >= 1 && monthInt <= 12) {
          final monthStr = monthNames[monthInt - 1];
          return '$dayInt $monthStr $year';
        }
      }
    } catch (_) {
      // Fallback if parsing fails
    }
    return releaseDate;
  }

  /// Default fallback instance in case JSON fails to load
  static const AppVersionInfo fallback = AppVersionInfo(
    version: 'V 24.8.26',
    build: 27,
    releaseDate: '2026-08-24',
    forceUpdate: false,
    minimumSupportedVersion: 'V 24.8.26',
    developedBy: 'Manohar & Datta',
    developers: [
      DeveloperInfo(
        name: 'Manohar',
        role: 'Lead Developer',
        url: 'https://www.linkedin.com/in/manoharbhudeti/',
      ),
      DeveloperInfo(name: 'Datta', role: 'Developer'),
    ],
    releaseNotes: [
      'Added Ratings & Reviews',
      'Improved Notification Center',
      'Added Help & Policies',
      'Improved application performance',
      'Fixed minor bugs and UI issues',
    ],
  );
}
