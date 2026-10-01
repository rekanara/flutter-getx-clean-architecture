import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import '../../utils/helper/logger.dart';

/// Service to manage Firebase Remote Config.
///
/// Default keys read:
/// - `maintenance_mode` (bool) — Whether the app is in maintenance mode
/// - `maintenance_message` (String) — Maintenance message to show to the user
///
/// Usage:
/// ```dart
/// final rc = Get.find<RemoteConfigService>();
/// if (rc.isMaintenanceMode) {
///   // Show maintenance page
/// }
/// ```
class RemoteConfigService extends GetxController {
  late final FirebaseRemoteConfig _remoteConfig;

  // ── Default Keys ──
  static const String _keyMaintenanceMode = 'maintenance_mode';
  static const String _keyMaintenanceMessage = 'maintenance_message';

  // ── Observable Values ──
  final RxBool maintenanceMode = false.obs;
  final RxString maintenanceMessage = ''.obs;

  /// Fetch interval — default 1 hour for production,
  /// 0 seconds for debug to fetch immediately.
  Duration fetchInterval = const Duration(hours: 1);

  /// Shortcut getter
  bool get isMaintenanceMode => maintenanceMode.value;

  @override
  void onInit() {
    super.onInit();
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  /// Initialize Remote Config with default values and initial fetch.
  Future<void> init({Duration? minimumFetchInterval}) async {
    try {
      // Set defaults
      await _remoteConfig.setDefaults({
        _keyMaintenanceMode: false,
        _keyMaintenanceMessage: 'The application is currently in maintenance. Please try again later.',
      });

      // Configure
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 30),
          minimumFetchInterval: minimumFetchInterval ?? fetchInterval,
        ),
      );

      // Fetch & activate
      await fetchAndActivate();

      // Listen to real-time updates (if available)
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        _syncValues();
        LoggerHelper.i('RemoteConfig: 🔄 Real-time update received');
      });

      LoggerHelper.i('RemoteConfig: ✅ Initialized');
    } catch (e, stack) {
      LoggerHelper.e('RemoteConfig: ❌ Init failed', e, stack);
    }
  }

  /// Fetch the latest data from the server and activate.
  Future<bool> fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      _syncValues();
      LoggerHelper.d('RemoteConfig: Fetch & Activate → $activated');
      return activated;
    } catch (e) {
      LoggerHelper.w('RemoteConfig: Fetch failed — $e');
      return false;
    }
  }

  /// Sync remote values to observable fields.
  void _syncValues() {
    maintenanceMode.value = _remoteConfig.getBool(_keyMaintenanceMode);
    maintenanceMessage.value = _remoteConfig.getString(_keyMaintenanceMessage);

    LoggerHelper.d(
      'RemoteConfig: maintenance_mode=${maintenanceMode.value}, '
      'maintenance_message="${maintenanceMessage.value}"',
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  GENERIC GETTERS (for additional custom keys)
  // ═══════════════════════════════════════════════════════════

  /// Read String value from a specific key.
  String getString(String key) => _remoteConfig.getString(key);

  /// Read bool value from a specific key.
  bool getBool(String key) => _remoteConfig.getBool(key);

  /// Read int value from a specific key.
  int getInt(String key) => _remoteConfig.getInt(key);

  /// Read double value from a specific key.
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
