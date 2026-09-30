# Device Config

Lokasi: `lib/config/device/device_config.dart`

## Overview

Singleton untuk membaca informasi perangkat (device) menggunakan `device_info_plus`. Berguna untuk analytics, debugging, dan API calls yang membutuhkan device metadata.

---

## Inisialisasi

```dart
await DeviceConfig.instance.init();
```

Otomatis mendeteksi platform (Android/iOS/Web) dan membaca detail device.

---

## Properties yang Tersedia

| Property | Type | Contoh Output |
|---|---|---|
| `deviceId` | `String?` | `"ABCD1234-5678"` |
| `deviceOS` | `String` | `"Android"` / `"iOS"` / `"Web"` |
| `deviceOs` | `String` | `"14.5"` (versi OS) |
| `deviceMake` | `String?` | `"Samsung"` / `"Apple"` |
| `deviceModel` | `String?` | `"SM-G998B"` / `"iPhone14,2"` |
| `deviceTypeCode` | `String` | `"1"` (Android), `"2"` (iOS), `"3"` (Web) |
| `deviceMacAddress` | `String?` | Hardware identifier |
| `platformMessage` | `String` | `"Android"` / `"iOS"` |

---

## Cara Pakai

```dart
final device = DeviceConfig.instance;

// Kirim ke API sebagai header/body
final headers = {
  'X-Device-Id': device.deviceId ?? '',
  'X-Device-OS': device.deviceOS,
  'X-Device-Model': '${device.deviceMake} ${device.deviceModel}',
};

// Untuk analytics
analytics.setUserProperty(
  name: 'device_type',
  value: device.deviceTypeCode,
);
```

---

## Device Type Detection (UI)

Untuk responsive layout, gunakan `DeviceConfig.getDeviceType(context)`:

```dart
final type = DeviceConfig.getDeviceType(context);

switch (type) {
  case DeviceType.mobile:   // width < 600
  case DeviceType.tablet:   // 600 <= width < 1200
  case DeviceType.desktop:  // width >= 1200
}
```

> **Catatan:** Untuk responsive UI, disarankan menggunakan `Responsive` widget dan `context.responsive()` extension di `lib/utils/responsive.dart`, karena lebih fleksibel dan deklaratif.

---

## Output Log

Saat `init()` dipanggil, device info di-log:

```
Device Info:
Device: Samsung SM-G998B
OS: 14
ID: ABCD1234
```
