# Permissions

Location: `lib/config/permissions/permissions.dart`

## Overview

Centralized handler for requesting permissions from the user using the `permission_handler` package.

---

## Initialization

```dart
final permissions = PermissionHandler();
await permissions.init();
```

`init()` requests the following permissions sequentially (all optional — the app will still run if denied):

1. **Notification** — for push notifications
2. **Location** — for location-based features
3. **Camera** — for photos/videos

---

## Available Permissions

| Method | Permission | Description |
|---|---|---|
| `requestNotificationPermission()` | `Permission.notification` | Notification permission |
| `requestLocationPermission()` | `Permission.locationWhenInUse` | Location permission (while in use) |
| `requestStoragePermission()` | `Permission.storage` | Storage permission (optional, not initialized) |
| `requestCameraPermission()` | `Permission.camera` | Camera permission |

---

## Permission Request Flow

```
Check status → Granted?
    │            ✅ → Done
    ▼  
  Denied? → Request → Granted?
    │                    ✅ → Done
    ▼
Permanently Denied? → Open App Settings (dialog)
```

---

## Manual Usage

```dart
final permissions = PermissionHandler();

// Request a single permission
bool granted = await permissions.requestCameraPermission();
if (granted) {
  // open camera
} else {
  // show message
}

// Request storage (not included in init)
bool storageGranted = await permissions.requestStoragePermission();
```

---

## Permanently Denied

If the user denies a permission permanently, `PermissionHandler` will automatically:

1. Show a dialog via `OpenSetting`
2. Redirect the user to **App Settings** to enable the permission manually

---

## Platform Configuration

### Android (`AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS (`Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need location access for nearby features.</string>
```
