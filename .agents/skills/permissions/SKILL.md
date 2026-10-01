---
name: Permissions
description: Using PermissionHandler to request platform permissions
---
# Skill: Permissions

Guide to requesting platform permissions (notification, location, camera, storage) using `PermissionHandler`.

---

## PermissionHandler Overview

`lib/config/permissions/permissions.dart`

- `requestNotificationPermission()`
- `requestLocationPermission()`
- `requestCameraPermission()`
- `requestStoragePermission()`
- If permanently denied → show a dialog to open app settings via `OpenSetting`

---

## Using PermissionHandler

```dart
// INSTANCE method (not static) — instantiate first
final permissions = PermissionHandler();
await permissions.requestNotificationPermission();
await permissions.requestCameraPermission();
await permissions.requestLocationPermission();
await permissions.requestStoragePermission();
```

---

## When to Request Permissions

```dart
// In a controller or screen when first needed:
class CameraController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    await PermissionHandler().requestCameraPermission();
    // After this returns, the user has been prompted or it's already granted
    openCamera();
  }
}
```

---

## Permission Flow

```
requestXxxPermission()
    │
    ▼
status == granted?
    ├─ Yes → proceed
    └─ No → request()
           │
           ▼
       status == granted?
           ├─ Yes → proceed
           └─ No (denied) → stop
                  │
                  ▼
           status == permanentlyDenied?
               └─ Yes → OpenSetting().openSettings() dialog
                         (user must open settings manually)
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
<string>Required to determine your location</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Required to take photos</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Required to access your photo library</string>
```

---

## OpenSetting

If the user permanently denies the permission, show a dialog:

```dart
// Handled automatically in PermissionHandler
// But can also be called manually (openSettings is an instance method, not static):
OpenSetting().openSettings(
  label: 'Camera',
  message: 'Camera permission is required for this feature. Open settings?',
  afterCreateUpdate: () {
    // callback after the dialog is shown (optional)
  },
);
// On iOS: CupertinoAlertDialog
// On Android: Material AlertDialog
```

---

## Screen Pattern (Request on button press)

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
    await PermissionHandler().requestCameraPermission();
    // After returning — granted/denied/permanentlyDenied handled
    // Proceed only if granted
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
[ ] Manifest: add permissions to AndroidManifest.xml and Info.plist
[ ] Request permissions before using a feature that needs them
[ ] Use PermissionHandler (not the permission_handler package directly)
[ ] No need to handle permanently denied manually — automatic via OpenSetting
[ ] Request permission when first needed (in onInit or button press)
```
