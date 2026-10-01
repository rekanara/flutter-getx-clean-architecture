# Device Config

Location: `lib/config/device/device_config.dart`

## Overview

Singleton for reading device information using `device_info_plus`. Useful for analytics, debugging, and API calls that require device metadata.

---

## Initialization

```dart
await DeviceConfig.instance.init();
```

Automatically detects the platform (Android/iOS/Web) and reads device details.

---

## Available Properties

| Property | Type | Example Output |
|---|---|---|
| `deviceId` | `String?` | `"ABCD1234-5678"` |
| `deviceOS` | `String` | `"Android"` / `"iOS"` / `"Web"` |
| `deviceOs` | `String` | `"14.5"` (OS version) |
| `deviceMake` | `String?` | `"Samsung"` / `"Apple"` |
| `deviceModel` | `String?` | `"SM-G998B"` / `"iPhone14,2"` |
| `deviceTypeCode` | `String` | `"1"` (Android), `"2"` (iOS), `"3"` (Web) |
| `deviceMacAddress` | `String?` | Hardware identifier |
| `platformMessage` | `String` | `"Android"` / `"iOS"` |

---

## Usage

```dart
final device = DeviceConfig.instance;

// Send to API as header/body
final headers = {
  'X-Device-Id': device.deviceId ?? '',
  'X-Device-OS': device.deviceOS,
  'X-Device-Model': '${device.deviceMake} ${device.deviceModel}',
};

// For analytics
analytics.setUserProperty(
  name: 'device_type',
  value: device.deviceTypeCode,
);
```

---

## Device Type Detection (UI)

For responsive layout, use `DeviceConfig.getDeviceType(context)`:

```dart
final type = DeviceConfig.getDeviceType(context);

switch (type) {
  case DeviceType.mobile:   // width < 600
  case DeviceType.tablet:   // 600 <= width < 1200
  case DeviceType.desktop:  // width >= 1200
}
```

> **Note:** For responsive UI, it is recommended to use the `Responsive` widget and the `context.responsive()` extension in `lib/utils/responsive.dart`, as they are more flexible and declarative.

---

## Output Log

When `init()` is called, the device info is logged:

```
Device Info:
Device: Samsung SM-G998B
OS: 14
ID: ABCD1234
```
