# Skill: Permissions

Panduan request izin platform (notification, location, camera, storage) menggunakan `PermissionHandler`.

---

## PermissionHandler Overview

`lib/config/permissions/permissions.dart`

- `requestNotificationPermission()`
- `requestLocationPermission()`
- `requestCameraPermission()`
- `requestStoragePermission()`
- Jika permanently denied → tampilkan dialog buka app settings via `OpenSetting`

---

## Menggunakan PermissionHandler

```dart
// Tidak perlu inject — method static/singleton
await PermissionHandler.requestNotificationPermission();
await PermissionHandler.requestCameraPermission();
await PermissionHandler.requestLocationPermission();
await PermissionHandler.requestStoragePermission();
```

---

## Kapan Request Permission

```dart
// Di controller atau screen saat pertama kali butuh:
class CameraController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    await PermissionHandler.requestCameraPermission();
    // Setelah ini user sudah di-prompt atau sudah granted
    openCamera();
  }
}
```

---

## Flow Permission

```
requestXxxPermission()
    │
    ▼
status == granted?
    ├─ Yes → lanjutkan
    └─ No → request()
           │
           ▼
       status == granted?
           ├─ Yes → lanjutkan
           └─ No (denied) → stop
                  │
                  ▼
           status == permanentlyDenied?
               └─ Yes → OpenSetting.openSettings() dialog
                         (user harus buka settings manual)
```

---

## Manifest Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Notification (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Location -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Storage (Android < 13) -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Diperlukan untuk menentukan lokasi Anda</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Diperlukan untuk mengambil foto</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Diperlukan untuk mengakses galeri foto</string>
```

---

## OpenSetting

Jika user permanently denied permission, tampilkan dialog:

```dart
// Sudah di-handle otomatis di PermissionHandler
// Tapi bisa juga dipanggil manual:
OpenSetting.openSettings(
  label: 'Kamera',
  message: 'Izin kamera diperlukan untuk fitur ini. Buka pengaturan?',
  afterCreateUpdate: () {
    // callback setelah dialog ditampilkan (opsional)
  },
);
// Di iOS: CupertinoAlertDialog
// Di Android: Material AlertDialog
```

---

## Pattern di Screen (Request saat tombol ditekan)

```dart
class ScanScreen extends GetView<ScanController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomButton(
          title: 'Scan QR',
          onPressed: _onScanPressed,
        ),
      ),
    );
  }

  Future<void> _onScanPressed() async {
    await PermissionHandler.requestCameraPermission();
    // Setelah return — sudah handle granted/denied/permanentlyDenied
    // Lanjutkan hanya jika granted
    final status = await Permission.camera.status;
    if (status.isGranted) {
      controller.startScan();
    }
  }
}
```

---

## Checklist

```
[ ] Manifest: tambah permission di AndroidManifest.xml dan Info.plist
[ ] Request permission sebelum menggunakan fitur yang butuh permission
[ ] Gunakan PermissionHandler (bukan permission_handler package langsung)
[ ] Tidak perlu handle permanently denied — sudah otomatis via OpenSetting
[ ] Request permission saat pertama kali butuh (di onInit atau saat tombol ditekan)
```
