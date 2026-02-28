# App Lifecycle Service

Lokasi: `lib/config/lifecycle/app_lifecycle_service.dart`

## Overview

Global observer untuk mengelola perilaku app saat berpindah antara **foreground** dan **background**. Didaftarkan sebagai permanent singleton di `main.dart`.

```dart
Get.put(AppLifecycleService(), permanent: true);
```

---

## Lifecycle States

| State | Kapan | Aksi Otomatis |
|---|---|---|
| `resumed` | App kembali ke foreground | MQTT reconnect + panggil resume callbacks |
| `paused` | App masuk background | MQTT disconnect + panggil pause callbacks |
| `inactive` | App visible tapi tidak menerima input (dialog, split screen) | Log saja |
| `detached` | App di-terminate | MQTT disconnect |

### Alur

```
User minimize app
    │
    ▼  paused
MQTT.disconnect()  ← hemat baterai
Firebase tetap jalan  ← SDK handle sendiri

User buka app kembali
    │
    ▼  resumed
MQTT.connect()  ← reconnect
onResumeCallbacks()  ← refresh data
```

---

## Callback Registration

Controller bisa mendaftarkan fungsi yang otomatis dipanggil saat app resume atau pause.

### Mendaftarkan Callback

```dart
class HomeController extends BaseController {
  late final AppLifecycleService _lifecycle;

  @override
  void onInit() {
    super.onInit();
    _lifecycle = Get.find<AppLifecycleService>();
    _lifecycle.addOnResumeCallback(_refreshData);
  }

  @override
  void onClose() {
    _lifecycle.removeOnResumeCallback(_refreshData);
    super.onClose();
  }

  void _refreshData() {
    fetchBanners(); // dipanggil otomatis saat app resume
  }
}
```

### API

| Method | Deskripsi |
|---|---|
| `addOnResumeCallback(VoidCallback)` | Daftarkan fungsi yang dipanggil saat app resume |
| `removeOnResumeCallback(VoidCallback)` | Hapus callback resume |
| `addOnPauseCallback(VoidCallback)` | Daftarkan fungsi yang dipanggil saat app pause |
| `removeOnPauseCallback(VoidCallback)` | Hapus callback pause |

### Observable State

```dart
final lifecycle = Get.find<AppLifecycleService>();

Obx(() {
  // React to lifecycle changes
  if (lifecycle.currentState.value == AppLifecycleState.paused) {
    return Text('App sedang di background');
  }
  return Text('App aktif');
});
```

---

## Catatan

- **Firebase** tidak perlu di-handle di sini — SDK Firebase tetap berjalan di background secara native
- **MQTT** di-disconnect untuk hemat baterai, karena MQTT client aktif terus-menerus makan resource
- Selalu **hapus callback di `onClose()`** untuk mencegah memory leak
