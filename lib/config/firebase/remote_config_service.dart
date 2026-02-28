import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';

import '../../utils/helper/logger.dart';

/// Service untuk mengelola Firebase Remote Config.
///
/// Default keys yang dibaca:
/// - `maintenance_mode` (bool) — Apakah app sedang dalam mode maintenance
/// - `maintenance_message` (String) — Pesan maintenance untuk ditampilkan ke user
///
/// Cara pakai:
/// ```dart
/// final rc = Get.find<RemoteConfigService>();
/// if (rc.isMaintenanceMode) {
///   // Tampilkan halaman maintenance
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

  /// Fetch interval — default 1 jam untuk production,
  /// 0 detik untuk debug agar langsung fetch.
  Duration fetchInterval = const Duration(hours: 1);

  /// Shortcut getter
  bool get isMaintenanceMode => maintenanceMode.value;

  @override
  void onInit() {
    super.onInit();
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  /// Inisialisasi Remote Config dengan default values dan fetch pertama.
  Future<void> init({Duration? minimumFetchInterval}) async {
    try {
      // Set defaults
      await _remoteConfig.setDefaults({
        _keyMaintenanceMode: false,
        _keyMaintenanceMessage:
            'Aplikasi sedang dalam maintenance. Silakan coba lagi nanti.',
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

      // Listen to real-time updates (jika tersedia)
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

  /// Fetch data terbaru dari server dan activate.
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

  /// Sync remote values ke observable fields.
  void _syncValues() {
    maintenanceMode.value = _remoteConfig.getBool(_keyMaintenanceMode);
    maintenanceMessage.value = _remoteConfig.getString(_keyMaintenanceMessage);

    LoggerHelper.d(
      'RemoteConfig: maintenance_mode=${maintenanceMode.value}, '
      'maintenance_message="${maintenanceMessage.value}"',
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  GENERIC GETTERS (untuk key custom tambahan)
  // ═══════════════════════════════════════════════════════════

  /// Membaca value String dari key tertentu.
  String getString(String key) => _remoteConfig.getString(key);

  /// Membaca value bool dari key tertentu.
  bool getBool(String key) => _remoteConfig.getBool(key);

  /// Membaca value int dari key tertentu.
  int getInt(String key) => _remoteConfig.getInt(key);

  /// Membaca value double dari key tertentu.
  double getDouble(String key) => _remoteConfig.getDouble(key);
}
