# Permissions

Lokasi: `lib/config/permissions/permissions.dart`

## Overview

Handler terpusat untuk meminta izin (permissions) dari user menggunakan package `permission_handler`.

---

## Inisialisasi

```dart
final permissions = PermissionHandler();
await permissions.init();
```

`init()` meminta izin berikut secara berurutan (semua optional — app tetap jalan jika ditolak):

1. **Notification** — untuk push notification
2. **Location** — untuk fitur berbasis lokasi
3. **Camera** — untuk foto/video

---

## Permission yang Tersedia

| Method | Permission | Deskripsi |
|---|---|---|
| `requestNotificationPermission()` | `Permission.notification` | Izin notifikasi |
| `requestLocationPermission()` | `Permission.locationWhenInUse` | Izin lokasi (saat app aktif) |
| `requestStoragePermission()` | `Permission.storage` | Izin storage (opsional, tidak di-init) |
| `requestCameraPermission()` | `Permission.camera` | Izin kamera |

---

## Alur Request Permission

```
Cek status → Granted?
    │            ✅ → Selesai
    ▼  
  Denied? → Request → Granted?
    │                    ✅ → Selesai
    ▼
Permanently Denied? → Buka App Settings (dialog)
```

---

## Cara Pakai Manual

```dart
final permissions = PermissionHandler();

// Request satu permission
bool granted = await permissions.requestCameraPermission();
if (granted) {
  // buka kamera
} else {
  // tampilkan pesan
}

// Request storage (tidak termasuk di init)
bool storageGranted = await permissions.requestStoragePermission();
```

---

## Permanently Denied

Jika user menolak permission secara permanen, `PermissionHandler` otomatis:

1. Menampilkan dialog via `OpenSetting`
2. Mengarahkan user ke **App Settings** untuk mengaktifkan izin secara manual

---

## Konfigurasi Platform

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (`Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Kami membutuhkan akses kamera untuk mengambil foto.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Kami membutuhkan lokasi untuk fitur terdekat.</string>
```
