import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../config/mqtt/mqtt_service.dart';
import '../../utils/helper/logger.dart';

/// Global App Lifecycle Observer.
///
/// Registers itself as [WidgetsBindingObserver] to listen for
/// app lifecycle changes (resumed, paused, inactive, detached).
///
/// Main responsibilities:
/// - **MQTT**: Disconnect when app goes to background, reconnect on resume
/// - **Firebase**: Keeps running in background (handled by Firebase SDK)
/// - Provides optional callbacks for controllers reacting to lifecycle changes
///
/// Usage:
/// ```dart
/// // In main.dart — automatically registered
/// Get.put(AppLifecycleService(), permanent: true);
/// ```
class AppLifecycleService extends GetxController with WidgetsBindingObserver {
  /// Current lifecycle state (observable)
  final Rx<AppLifecycleState> currentState = AppLifecycleState.resumed.obs;

  /// Callbacks invoked when app returns to foreground (resumed).
  /// Controllers can register data refresh callbacks here.
  final List<VoidCallback> _onResumeCallbacks = [];

  /// Callbacks invoked when app goes to background (paused).
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

  /// App returns to foreground
  void _onAppResumed() {
    LoggerHelper.i('AppLifecycle: ▶️ App Resumed');

    // ── Reconnect MQTT ──
    _reconnectMqtt();

    // ── Notify all registered callbacks ──
    for (final callback in _onResumeCallbacks) {
      callback();
    }

    // Firebase keeps running — no re-init needed
    // FCM background handler already handles background messages
  }

  /// App goes to background
  void _onAppPaused() {
    LoggerHelper.i('AppLifecycle: ⏸️ App Paused');

    // ── Disconnect MQTT to save battery ──
    _disconnectMqtt();

    // ── Notify all registered callbacks ──
    for (final callback in _onPauseCallbacks) {
      callback();
    }

    // Firebase keeps running in background (SDK handles it)
  }

  /// App is still visible but not receiving input (dialog, split screen)
  void _onAppInactive() {
    LoggerHelper.d('AppLifecycle: 💤 App Inactive');
    // Usually no action needed
  }

  /// App is terminated
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
      // MqttService not registered or not connected yet
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
      // MqttService not registered
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  CALLBACK REGISTRATION
  // ═══════════════════════════════════════════════════════════

  /// Register callback to be invoked when app returns to foreground.
  /// ```dart
  /// final lifecycle = Get.find<AppLifecycleService>();
  /// lifecycle.addOnResumeCallback(fetchBanners);
  /// ```
  void addOnResumeCallback(VoidCallback callback) {
    if (!_onResumeCallbacks.contains(callback)) {
      _onResumeCallbacks.add(callback);
    }
  }

  /// Remove resume callback.
  void removeOnResumeCallback(VoidCallback callback) {
    _onResumeCallbacks.remove(callback);
  }

  /// Register callback to be invoked when app goes to background.
  void addOnPauseCallback(VoidCallback callback) {
    if (!_onPauseCallbacks.contains(callback)) {
      _onPauseCallbacks.add(callback);
    }
  }

  /// Remove pause callback.
  void removeOnPauseCallback(VoidCallback callback) {
    _onPauseCallbacks.remove(callback);
  }
}
