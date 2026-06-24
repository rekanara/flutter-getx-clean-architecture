# Skill: Local Notifications

Panduan menampilkan notifikasi lokal, channel, tipe notifikasi, dan handling tap.

---

## NotificationHelper Overview

`lib/config/notifications/notifications.dart`

- `NotificationsHelper` — init + tampilkan notifikasi
- `ShowNotificationHelper` — facade berdasarkan `NotificationType`
- `NotificationChannels` — definisi channel Android
- `NotificationController` — handle tap payload + navigasi
- `NotificationImageHelper` — download icon image ke temp

---

## NotificationType

```dart
enum NotificationType {
  order,
  alert,
  system,
  chat,
  payment,
  ticket,
  ads,
  marketing,
  other,
  general,
}
```

---

## Menampilkan Notifikasi

### Via ShowNotificationHelper (Rekomendasi)

```dart
// Pilih channel berdasarkan type
ShowNotificationHelper.showNotification(
  type: NotificationType.order,
  title: 'Pesanan Baru',
  body: 'Order #12345 sedang diproses',
  payload: jsonEncode({'type': 'order', 'id': '12345'}),
  imageUrl: 'https://example.com/icon.png', // opsional
);

// Chat notification
ShowNotificationHelper.showNotification(
  type: NotificationType.chat,
  title: 'Pesan dari Support',
  body: 'Halo, ada yang bisa kami bantu?',
  payload: jsonEncode({'type': 'chat', 'room_id': 'support_1'}),
);
```

### Via NotificationsHelper langsung (detail lengkap)

```dart
await NotificationsHelper.showNotification(
  id: 101,
  title: 'Promo Flash Sale!',
  body: 'Diskon 50% untuk semua produk',
  channel: NotificationChannels.ads,
  payload: jsonEncode({'type': 'ads', 'promo_id': 'fs_001'}),
  bigText: 'Dapatkan diskon 50% untuk semua produk pilihan dalam Flash Sale hari ini. Penawaran terbatas!',
  imageUrl: 'https://example.com/promo.jpg',
  groupKey: 'promo_group',
);
```

---

## Channel Definitions

```dart
// lib/config/notifications/notifications.dart
class NotificationChannels {
  static const chat      = 'chat_channel';
  static const order     = 'order_channel';
  static const ticket    = 'ticket_channel';
  static const ads       = 'ads_channel';
  static const marketing = 'marketing_channel';
  static const general   = 'general_channel';
}
```

Semua channel importance: `Importance.max` (heads-up notification).

---

## Handling Tap (NotificationController)

Sudah di-handle otomatis di `NotificationController`. Routing berdasarkan payload `type`:

```dart
// Default routing di NotificationController:
void _handlePayload(String payload) {
  final data = jsonDecode(payload);
  final type = data['type'] as String?;

  switch (type) {
    case 'order':
      Get.toNamed(Routes.orderDetail, arguments: {'id': data['id']});
      break;
    case 'chat':
      Get.toNamed(Routes.chat, arguments: {'room_id': data['room_id']});
      break;
    default:
      Get.toNamed(Routes.home);
  }
}
```

Untuk menambah routing baru, edit `NotificationController`.

---

## FCM → Local Notification

FCM message otomatis di-convert ke local notification di `FirebaseMessagingService`:

```dart
// Di firebaseMessagingBackgroundHandler (background) + onMessage (foreground)
void _processMessage(RemoteMessage message) {
  final type = message.data['type'];
  final notifType = _mapTypeToEnum(type); // 'order' → NotificationType.order

  ShowNotificationHelper.showNotification(
    type: notifType,
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    payload: jsonEncode(message.data),
    imageUrl: message.data['image'],
  );
}
```

---

## NotificationImageHelper

Download icon dari URL untuk notifikasi bergambar:

```dart
// Download otomatis dipanggil saat ada imageUrl
final imagePath = await NotificationImageHelper.downloadImage(imageUrl);
// Disimpan di temp dir, dibersihkan setelah 7 hari
```

---

## Request Permission

```dart
// Sebelum show notifikasi, pastikan permission sudah di-request
// (Sudah dilakukan di main.dart via PermissionHandler)
await PermissionHandler.requestNotificationPermission();
```

---

## Checklist

```
[ ] Gunakan ShowNotificationHelper.showNotification() dengan type yang tepat
[ ] Payload selalu jsonEncode Map dengan key 'type'
[ ] type di payload sesuai NotificationType (order, chat, ticket, dll)
[ ] Routing tap notifikasi di NotificationController
[ ] Permission sudah di-request di main.dart
[ ] FCM → local notification sudah otomatis via FirebaseMessagingService
```
