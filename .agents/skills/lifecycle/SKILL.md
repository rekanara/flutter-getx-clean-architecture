# Skill: App Lifecycle Service

Panduan menggunakan `AppLifecycleService` untuk menjalankan callback saat app di-resume atau di-pause.

---

## AppLifecycleService Overview

`lib/config/lifecycle/app_lifecycle_service.dart`

- GetxController + `WidgetsBindingObserver` (permanent)
- On **resumed**: reconnect MQTT → fire `onResumeCallbacks`
- On **paused**: disconnect MQTT → fire `onPauseCallbacks`
- On **detached**: disconnect MQTT
- Controller register/remove callback via method

---

## Mengakses Service

```dart
final lifecycleService = Get.find<AppLifecycleService>();
```

---

## Register Callback Resume

Gunakan untuk refresh data saat user kembali ke app:

```dart
class HomeController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    fetchBanners(); // fetch awal

    // Register callback resume
    Get.find<AppLifecycleService>().addOnResumeCallback(_onAppResumed);
  }

  @override
  void onClose() {
    // PENTING: hapus callback saat controller di-dispose
    Get.find<AppLifecycleService>().removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  void _onAppResumed() {
    // Dipanggil otomatis saat app di-resume dari background
    fetchBanners();
    LoggerHelper.d('App resumed — refreshing banners');
  }
}
```

---

## Register Callback Pause

```dart
class VideoController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    Get.find<AppLifecycleService>().addOnPauseCallback(_onAppPaused);
    Get.find<AppLifecycleService>().addOnResumeCallback(_onAppResumed);
  }

  @override
  void onClose() {
    Get.find<AppLifecycleService>().removeOnPauseCallback(_onAppPaused);
    Get.find<AppLifecycleService>().removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  void _onAppPaused() {
    videoPlayer.pause(); // pause video saat app ke background
  }

  void _onAppResumed() {
    videoPlayer.play(); // resume video saat app kembali
  }
}
```

---

## Lifecycle States

```dart
// AppLifecycleState dari Flutter SDK
// yang di-handle oleh AppLifecycleService:

AppLifecycleState.resumed   → MQTT reconnect + onResumeCallbacks
AppLifecycleState.paused    → MQTT disconnect + onPauseCallbacks
AppLifecycleState.detached  → MQTT disconnect
AppLifecycleState.inactive  → (tidak di-handle khusus)
```

---

## MQTT Auto-Reconnect

Saat app resume dari background:
1. `AppLifecycleService` deteksi `resumed` state
2. Cek MQTT connection status
3. Jika disconnected → `mqtt.connect()` otomatis
4. Setelah connect → `mqtt.restoreSubscriptions()` (pulihkan topic yang tersimpan)
5. Fire `onResumeCallbacks`

Tidak perlu implement reconnect secara manual di controller.

---

## Pattern di Controller

```dart
class DashboardController extends BaseController {
  late final AppLifecycleService _lifecycle;

  DashboardController() {
    _lifecycle = Get.find<AppLifecycleService>();
  }

  @override
  void onInit() {
    super.onInit();
    _lifecycle.addOnResumeCallback(_refresh);
    _lifecycle.addOnPauseCallback(_cleanup);
    _fetchAll();
  }

  @override
  void onClose() {
    _lifecycle.removeOnResumeCallback(_refresh);
    _lifecycle.removeOnPauseCallback(_cleanup);
    super.onClose();
  }

  void _refresh() {
    LoggerHelper.d('DashboardController: app resumed');
    _fetchAll();
  }

  void _cleanup() {
    LoggerHelper.d('DashboardController: app paused');
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      fetchStats(),
      fetchNotifications(),
    ]);
  }
}
```

---

## Checklist

```
[ ] Daftarkan callback di onInit()
[ ] HAPUS callback di onClose() — cegah memory leak
[ ] Tidak perlu handle MQTT connect/disconnect — sudah otomatis
[ ] Gunakan named method reference (bukan lambda) agar removeCallback bekerja
[ ] onResumeCallback untuk: refresh data, start audio/video, dll
[ ] onPauseCallback untuk: pause media, stop timer, dll
```
