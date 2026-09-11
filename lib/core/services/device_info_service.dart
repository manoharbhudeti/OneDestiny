import 'dart:async';
import 'dart:io' show Platform, NetworkInterface, InternetAddressType;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DeviceDetails {
  final String deviceName;
  final String deviceOs;
  final String? ipAddress;

  const DeviceDetails({
    required this.deviceName,
    required this.deviceOs,
    this.ipAddress,
  });

  Map<String, dynamic> toMap() => {
        'deviceName': deviceName,
        'deviceOs': deviceOs,
        'ipAddress': ipAddress,
      };

  @override
  String toString() =>
      'DeviceDetails(deviceName: $deviceName, deviceOs: $deviceOs, ipAddress: $ipAddress)';
}

class DeviceInfoService {
  DeviceInfoService._();
  static final DeviceInfoService instance = DeviceInfoService._();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  DeviceDetails? _cachedDetails;
  String? _cachedIp;

  /// Get cached device details or fetch them if not yet available
  Future<DeviceDetails> getDeviceDetails({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDetails != null) {
      return _cachedDetails!;
    }

    String deviceName = 'Mobile Device';
    String deviceOs = 'Mobile';

    try {
      if (kIsWeb) {
        final web = await _deviceInfoPlugin.webBrowserInfo;
        final browser = web.browserName.name;
        deviceName = 'Web Browser ($browser)';
        deviceOs = 'Web (${web.platform ?? 'Unknown'})';
      } else if (Platform.isAndroid) {
        final android = await _deviceInfoPlugin.androidInfo;
        var brand = android.brand.trim();
        if (brand.isNotEmpty) {
          brand = brand[0].toUpperCase() + brand.substring(1);
        }
        final model = android.model.trim();
        if (model.toLowerCase().startsWith(brand.toLowerCase())) {
          deviceName = model;
        } else if (brand.isNotEmpty && model.isNotEmpty) {
          deviceName = '$brand $model';
        } else if (model.isNotEmpty) {
          deviceName = model;
        } else {
          deviceName = 'Android Device';
        }

        final release = android.version.release.trim();
        final sdk = android.version.sdkInt;
        deviceOs = 'Android $release (SDK $sdk)';
      } else if (Platform.isIOS) {
        final ios = await _deviceInfoPlugin.iosInfo;
        final name = ios.name.trim();
        final model = ios.model.trim();
        if (name.isNotEmpty && !name.toLowerCase().contains('unknown')) {
          deviceName = name;
        } else if (model.isNotEmpty) {
          deviceName = model;
        } else {
          deviceName = 'iPhone';
        }
        deviceOs = '${ios.systemName} ${ios.systemVersion}';
      } else if (Platform.isLinux) {
        final linux = await _deviceInfoPlugin.linuxInfo;
        deviceName = linux.name;
        deviceOs = 'Linux ${linux.versionId ?? ''}'.trim();
      } else if (Platform.isMacOS) {
        final mac = await _deviceInfoPlugin.macOsInfo;
        deviceName = mac.computerName;
        deviceOs = 'macOS ${mac.osRelease}';
      } else if (Platform.isWindows) {
        final win = await _deviceInfoPlugin.windowsInfo;
        deviceName = win.computerName;
        deviceOs = 'Windows ${win.productName}';
      }
    } catch (e) {
      debugPrint('[DeviceInfoService] Failed to read platform info: $e');
    }

    final ip = await getIpAddress(forceRefresh: forceRefresh);

    _cachedDetails = DeviceDetails(
      deviceName: deviceName,
      deviceOs: deviceOs,
      ipAddress: ip,
    );

    return _cachedDetails!;
  }

  /// Get client public IP with fast timeout and multiple fallbacks
  Future<String?> getIpAddress({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedIp != null && _cachedIp!.isNotEmpty) {
      return _cachedIp;
    }

    // Try primary public IP provider: ipify
    try {
      final res = await http
          .get(Uri.parse('https://api.ipify.org'))
          .timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        _cachedIp = res.body.trim();
        return _cachedIp;
      }
    } catch (_) {}

    // Fallback 1: icanhazip
    try {
      final res = await http
          .get(Uri.parse('https://icanhazip.com'))
          .timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        _cachedIp = res.body.trim();
        return _cachedIp;
      }
    } catch (_) {}

    // Fallback 2: Local network interface IPv4 (for offline / local LAN)
    if (!kIsWeb) {
      try {
        final interfaces = await NetworkInterface.list(
          type: InternetAddressType.IPv4,
          includeLoopback: false,
        );
        for (final iface in interfaces) {
          for (final addr in iface.addresses) {
            if (!addr.isLoopback && addr.address.isNotEmpty) {
              _cachedIp = addr.address;
              return _cachedIp;
            }
          }
        }
      } catch (_) {}
    }

    return _cachedIp;
  }
}
