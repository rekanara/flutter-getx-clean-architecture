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
// payload bertipe Map<String, String>?, BUKAN String hasil jsonEncode
ShowNotificationHelper.showNotification(
  type: NotificationType.order,
  title: 'Pesanan Baru',
  body: 'Order #12345 sedang diproses',
  payload: {'type': 'order', 'id': '12345'},
  iconUrl: 'https://example.com/icon.png', // opsional — parameter bernama iconUrl, bukan imageUrl
);

// Chat notification
ShowNotificationHelper.showNotification(
  type: NotificationType.chat,
  title: 'Pesan dari Support',
  body: 'Halo, ada yang bisa kami bantu?',
  payload: {'type': 'chat', 'room_id': 'support_1'},
);
```

### Via NotificationsHelper langsung (detail lengkap)

```dart
// Parameter sebenarnya: channelKey (bukan channel), isBigText+summary (bukan bigText),
// payload Map<String,String>? (bukan jsonEncode string), largeIcon/bigPicture untuk gambar
await NotificationsHelper.showNotification(
  id: 101,
  channelKey: NotificationChannels.adsChannelKey,
  groupKey: NotificationChannels.adsGroupKey,
  title: 'Promo Flash Sale!',
  body: 'Diskon 50% untuk semua produk',
  summary: 'Dapatkan diskon 50% untuk semua produk pilihan dalam Flash Sale hari ini.',
  isBigText: true,
  payload: {'type': 'ads', 'promo_id': 'fs_001'},
);
```

---

## Channel Definitions

```dart
// lib/config/notifications/notifications.dart
// Getter bernama {name}ChannelKey / {name}GroupKey / {name}ChannelName / {name}ChannelDescription
// — BUKAN konstanta bare seperti NotificationChannels.chat
class NotificationChannels {
  static String get chatChannelKey => "chat_channel";
  static String get chatGroupKey => "chat_group_key";
  static String get orderChannelKey => "order_channel";
  static String get orderGroupKey => "order_group_key";
  static String get ticketChannelKey => "ticket_channel";
  static String get ticketGroupKey => "ticket_group_key";
  static String get adsChannelKey => "ads_channel";
  static String get adsGroupKey => "ads_group_key";
  static String get marketingChannelKey => "marketing_channel";
  static String get marketingGroupKey => "marketing_group_key";
  static String get generalChannelKey => "general_channel";
  static String get generalGroupKey => "general_group_key";
  // + *ChannelName / *ChannelDescription untuk tiap channel
}
```

Semua channel importance: `Importance.max` (heads-up notification).

---

## Handling Tap (NotificationController)

Sudah di-handle otomatis di `NotificationController` untuk **local notification** (bukan FCM). Routing yang benar-benar ada saat ini sangat minimal:

```dart
// lib/config/notifications/notifications.dart — implementasi nyata saat ini
class NotificationController {
  static void onActionReceived(NotificationResponse response) =>
      _handlePayload(response.payload);

  @pragma('vm:entry-point')
  static void onBackgroundActionReceived(NotificationResponse response) =>
      _handlePayload(response.payload);

  static void _handlePayload(String? rawPayload) {
    if (rawPayload == null) return;
    final payload = jsonDecode(rawPayload) as Map<String, dynamic>;
    final type = payload['type'] as String?;

    String route;
    Map<String, dynamic>? args;
    switch (type) {
      case 'order':
        route = Routes.home; // TODO: belum ada Routes.orderDetail
        args = {'ticket_id': payload['data']};
        break;
      default:
        route = Routes.login;
        args = {'refresh': true};
    }

    Get.key.currentState?.pushNamed(route, arguments: args);
  }
}
```

`Routes.orderDetail` dan `Routes.chat` **belum ada** di `routes.dart` (baru `home`/`login`/`user`) — tambahkan dulu sebelum bisa routing ke sana. Untuk tap dari **FCM** (bukan local notification), lihat `FirebaseMessagingService._handleNotificationTap` di `firebase_messaging_service.dart` — saat ini masih TODO/belum ada navigasi sama sekali.

Untuk menambah routing baru, edit `NotificationController._handlePayload`.

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
// Method bernama downloadToTemp, bukan downloadImage
final imagePath = await NotificationImageHelper.downloadToTemp(imageUrl);
// Disimpan di temp dir, dibersihkan setelah 7 hari
```

---

## Request Permission

```dart
// Sebelum show notifikasi, pastikan permission sudah di-request
// (Sudah dilakukan di main.dart via PermissionHandler)
await PermissionHandler().requestNotificationPermission();
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
