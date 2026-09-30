import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../config/mqtt/mqtt_service.dart';
import '../../utils/helper/logger.dart';

/// Global App Lifecycle Observer.
///
/// Mendaftarkan dirinya sebagai [WidgetsBindingObserver] untuk mendengarkan
/// perubahan lifecycle app (resumed, paused, inactive, detached).
///
/// Tanggung jawab utama:
/// - **MQTT**: Disconnect saat app masuk background, reconnect saat resume
/// - **Firebase**: Tetap berjalan di background (handled oleh Firebase SDK sendiri)
/// - Menyediakan callback opsional untuk controller yang ingin react terhadap lifecycle
///
/// Cara pakai:
/// ```dart
/// // Di main.dart — sudah otomatis di-register
/// Get.put(AppLifecycleService(), permanent: true);
/// ```
class AppLifecycleService extends GetxController with WidgetsBindingObserver {
  /// Status lifecycle saat ini (observable)
  final Rx<AppLifecycleState> currentState = AppLifecycleState.resumed.obs;

  /// Callbacks yang akan dipanggil saat app kembali ke foreground (resumed).
  /// Controller bisa mendaftarkan callback refresh data di sini.
  final List<VoidCallback> _onResumeCallbacks = [];

  /// Callbacks yang akan dipanggil saat app masuk ke background (paused).
  final List<VoidCallback> _onPauseCallbacks = [];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    LoggerHelper.i('AppLifecycle: ✅ Observer registered');
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _onResumeCallbacks.clear();
    _onPauseCallbacks.clear();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    currentState.value = state;
    LoggerHelper.d('AppLifecycle: State → $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.inactive:
        _onAppInactive();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      default:
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  LIFECYCLE HANDLERS
  // ═══════════════════════════════════════════════════════════

  /// App kembali ke foreground
  void _onAppResumed() {
    LoggerHelper.i('AppLifecycle: ▶️ App Resumed');

    // ── Reconnect MQTT ──
    _reconnectMqtt();

    // ── Notify semua registered callbacks ──
    for (final callback in _onResumeCallbacks) {
      callback();
    }

    // Firebase tetap running — tidak perlu re-init
    // FCM background handler sudah handle pesan saat di background
  }

  /// App masuk ke background
  void _onAppPaused() {
    LoggerHelper.i('AppLifecycle: ⏸️ App Paused');

    // ── Disconnect MQTT untuk hemat baterai ──
    _disconnectMqtt();

    // ── Notify semua registered callbacks ──
    for (final callback in _onPauseCallbacks) {
      callback();
    }

    // Firebase tetap running di background (SDK handle sendiri)
  }

  /// App masih visible tapi tidak menerima input (dialog, split screen)
  void _onAppInactive() {
    LoggerHelper.d('AppLifecycle: 💤 App Inactive');
    // Biasanya tidak perlu action apa-apa
  }

  /// App di-terminate
  void _onAppDetached() {
    LoggerHelper.d('AppLifecycle: 🛑 App Detached');
    _disconnectMqtt();
  }

  // ═══════════════════════════════════════════════════════════
  //  MQTT LIFECYCLE
  // ═══════════════════════════════════════════════════════════

  void _reconnectMqtt() {
    try {
      final mqtt = Get.find<MqttService>();
      if (!mqtt.isConnected) {
        LoggerHelper.i('AppLifecycle: 🔄 Reconnecting MQTT...');
        mqtt.connect();
      }
    } catch (_) {
      // MqttService belum di-register atau belum connect sebelumnya
    }
  }

  void _disconnectMqtt() {
    try {
      final mqtt = Get.find<MqttService>();
      if (mqtt.isConnected) {
        LoggerHelper.i('AppLifecycle: ⏹️ Disconnecting MQTT...');
        mqtt.disconnect();
      }
    } catch (_) {
      // MqttService belum di-register
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  CALLBACK REGISTRATION
  // ═══════════════════════════════════════════════════════════

  /// Daftarkan callback yang dipanggil saat app kembali ke foreground.
  ///
  /// ```dart
  /// final lifecycle = Get.find<AppLifecycleService>();
  /// lifecycle.addOnResumeCallback(fetchBanners);
  /// ```
  void addOnResumeCallback(VoidCallback callback) {
    if (!_onResumeCallbacks.contains(callback)) {
      _onResumeCallbacks.add(callback);
    }
  }

  /// Hapus callback resume.
  void removeOnResumeCallback(VoidCallback callback) {
    _onResumeCallbacks.remove(callback);
  }

  /// Daftarkan callback yang dipanggil saat app masuk ke background.
  void addOnPauseCallback(VoidCallback callback) {
    if (!_onPauseCallbacks.contains(callback)) {
      _onPauseCallbacks.add(callback);
    }
  }

  /// Hapus callback pause.
  void removeOnPauseCallback(VoidCallback callback) {
    _onPauseCallbacks.remove(callback);
  }
}
