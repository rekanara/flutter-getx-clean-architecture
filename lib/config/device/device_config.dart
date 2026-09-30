import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

enum DeviceType { mobile, tablet, desktop }

class DeviceConfig {
  // Private constructor
  DeviceConfig._();

  // Singleton instance
  static final DeviceConfig _instance = DeviceConfig._();

  // Getter untuk mengakses instance
  static DeviceConfig get instance => _instance;

  // Inisialisasi DeviceConfig
  Future<void> init() async {
    _info = DeviceInfoPlugin();
    if (kIsWeb) {
      _webDeviceInfo = await _info.webBrowserInfo;
    } else if (GetPlatform.isAndroid) {
      _androidDeviceInfo = await _info.androidInfo;
    } else if (GetPlatform.isIOS) {
      _iosDeviceInfo = await _info.iosInfo;
    }

    detectPlatform();
    Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        // printTime: true,
      ),
      level: Level.info,
    ).i(
      'Device Info: \nDevice:$deviceMake $deviceModel \nOS:$deviceOs \nID:$deviceId',
    );
  }

  static DeviceType getDeviceType(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    if (deviceWidth < 600) {
      return DeviceType.mobile;
    } else if (deviceWidth < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  DeviceInfoPlugin _info = DeviceInfoPlugin();

  /// To get android device info
  AndroidDeviceInfo? _androidDeviceInfo;

  /// To get iOS device info
  IosDeviceInfo? _iosDeviceInfo;

  WebBrowserInfo? _webDeviceInfo;

  final deviceInfoPlugin = DeviceInfoPlugin();

  // platform message for analytics
  String platformMessage = 'Unknown';

  String deviceSize = 'Unknown';

  /// Device id
  String? get deviceId => kIsWeb
      ? _webDeviceInfo?.appVersion!.substring(0, 3)
      : GetPlatform.isAndroid
      ? _androidDeviceInfo?.id
      : _iosDeviceInfo?.identifierForVendor;

  String get deviceOS => kIsWeb
      ? 'Web'
      : GetPlatform.isAndroid
      ? 'Android'
      : 'iOS';

  /// Device make brand
  String? get deviceMake => kIsWeb
      ? _webDeviceInfo?.browserName.name
      : GetPlatform.isAndroid
      ? _androidDeviceInfo?.brand
      : 'Apple';

  /// Device Model
  String? get deviceModel => kIsWeb
      ? _webDeviceInfo?.platform
      : GetPlatform.isAndroid
      ? _androidDeviceInfo?.model
      : _iosDeviceInfo?.utsname.machine;

  /// Device is a type of 1 for Android and 2 for iOS
  String get deviceTypeCode => kIsWeb
      ? '3'
      : GetPlatform.isAndroid
      ? '1'
      : '2';

  /// Device OS
  String get deviceOs => kIsWeb
      ? '${_webDeviceInfo?.appVersion}'
      : GetPlatform.isAndroid
      ? '${_androidDeviceInfo?.version.codename}'
      : '${_iosDeviceInfo?.systemVersion}';

  /// Device mac address
  String? get deviceMacAddress => kIsWeb
      ? 'Web'
      : GetPlatform.isAndroid
      ? _androidDeviceInfo?.hardware
      : GetPlatform.isIOS
      ? _iosDeviceInfo?.model
      : 'Unknown';

  // detect platform for analytics
  void detectPlatform() {
    if (kIsWeb) {
      platformMessage = "Web";
    } else if (Platform.isAndroid) {
      platformMessage = "Android";
    } else if (Platform.isIOS) {
      platformMessage = "iOS";
    } else if (Platform.isFuchsia) {
      platformMessage = "Fuchsia";
    } else {
      platformMessage = "Unknown";
    }

    Logger().i('Platform: $platformMessage');
  }
}
