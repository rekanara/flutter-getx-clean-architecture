# Notifications

Lokasi: `lib/config/notifications/notifications.dart`

## Overview

Sistem notifikasi lokal menggunakan `flutter_local_notifications`. Terdiri dari beberapa class:

| Class | Fungsi |
|---|---|
| `NotificationsHelper` | Init, create channels, show notification |
| `NotificationController` | Handle tap (foreground/background), parse payload |
| `NotificationChannels` | Definisi channel IDs dan configs |
| `ShowNotificationHelper` | Facade untuk menampilkan notifikasi berdasarkan `NotificationType` |
| `NotificationImageHelper` | Download gambar untuk big picture notification |

---

## Inisialisasi

```dart
await NotificationsHelper.init();
```

Dipanggil di `main.dart` sebelum Firebase Messaging. Membuat semua notification channels (Android) dan konfigurasi platform.

---

## Notification Channels

Android memerlukan notification channels. Channels yang tersedia didefinisikan di `NotificationChannels`:

Setiap channel memiliki `key`, `name`, dan `description` yang otomatis di-generate dari key.

---

## Menampilkan Notifikasi

### Via `ShowNotificationHelper` (Recommended)

Facade yang otomatis memilih channel, icon, dan style berdasarkan `NotificationType`:

```dart
ShowNotificationHelper.showNotification(
  type: NotificationType.order,
  title: 'Pesanan Baru',
  body: 'Pesanan #123 telah dibuat',
  summary: 'Detail tambahan',
  iconUrl: 'https://img.com/icon.png',
  payload: {'order_id': '123'},
);
```

### Via `NotificationsHelper` (Low-Level)

Kontrol penuh terhadap semua parameter:

```dart
NotificationsHelper.showNotification(
  id: 1,
  title: 'Title',
  body: 'Body text',
  channelKey: 'order',
  groupKey: 'order_group',
  isBigText: true,
  isBigPicture: true,
  bigPicture: 'https://img.com/big.jpg',
  largeIcon: 'https://img.com/icon.png',
  payload: {'key': 'value'},
);
```

---

## Notification Types

```dart
enum NotificationType {
  order,      // Pesanan
  alert,      // Alert/Warning
  system,     // Sistem
  chat,       // Pesan chat
  payment,    // Pembayaran
  ticket,     // Tiket support
  ads,        // Iklan
  marketing,  // Marketing
  other,      // Lainnya
  general,    // Umum (default)
}
```

Setiap type di-map ke channel yang sesuai di `ShowNotificationHelper`.

---

## Handle Tap Notifikasi

```dart
class NotificationController {
  // Foreground + background tap
  static void onActionReceived(NotificationResponse response) { ... }

  // Background tap (isolate)
  static void onBackgroundActionReceived(NotificationResponse response) { ... }

  // Parse payload JSON dan navigasi
  static void _handlePayload(String? rawPayload) { ... }
}
```

Payload yang di-expect:

```json
{
  "type": "order",
  "order_id": "123",
  "route": "/order-detail"
}
```

---

## Big Picture Notification

`NotificationImageHelper` mendownload gambar dari URL ke temp directory:

```dart
final localPath = await NotificationImageHelper.downloadToTemp(imageUrl);
```

- Menggunakan `DioClient.download()` 
- Auto-cleanup file gambar yang lebih dari 7 hari
- Disimpan di `{tempDir}/notification_images/`
