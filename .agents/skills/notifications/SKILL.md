---
name: Local Notifications
description: Local notifications, channels, notification types, tap handling
---
# Skill: Local Notifications

Guide to displaying local notifications, channels, notification types, and tap handling.

---

## NotificationHelper Overview

`lib/config/notifications/notifications.dart`

- `NotificationsHelper` — init + display notifications
- `ShowNotificationHelper` — facade based on `NotificationType`
- `NotificationChannels` — Android channel definitions
- `NotificationController` — handles tap payload + navigation
- `NotificationImageHelper` — downloads icon image to temp storage

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

## Displaying Notifications

### Via ShowNotificationHelper (Recommended)

```dart
// payload is of type Map<String, String>?, NOT a jsonEncode string
ShowNotificationHelper.showNotification(
  type: NotificationType.order,
  title: 'New Order',
  body: 'Order #12345 is being processed',
  payload: {'type': 'order', 'id': '12345'},
  iconUrl: 'https://example.com/icon.png', // optional — parameter named iconUrl, not imageUrl
);

// Chat notification
ShowNotificationHelper.showNotification(
  type: NotificationType.chat,
  title: 'Message from Support',
  body: 'Hello, how can we help you?',
  payload: {'type': 'chat', 'room_id': 'support_1'},
);
```

### Via NotificationsHelper directly (full detail)

```dart
// Actual parameters: channelKey (not channel), isBigText+summary (not bigText),
// payload Map<String,String>? (not jsonEncode string), largeIcon/bigPicture for images
await NotificationsHelper.showNotification(
  id: 101,
  channelKey: NotificationChannels.adsChannelKey,
  groupKey: NotificationChannels.adsGroupKey,
  title: 'Flash Sale Promo!',
  body: '50% off all products',
  summary: 'Get a 50% discount on all selected products in today\'s Flash Sale.',
  isBigText: true,
  payload: {'type': 'ads', 'promo_id': 'fs_001'},
);
```

---

## Channel Definitions

```dart
// lib/config/notifications/notifications.dart
// Getters named {name}ChannelKey / {name}GroupKey / {name}ChannelName / {name}ChannelDescription
// — NOT bare constants like NotificationChannels.chat
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
  // + *ChannelName / *ChannelDescription for each channel
}
```

All channels have importance: `Importance.max` (heads-up notifications).

---

## Handling Taps (NotificationController)

Automatically handled in `NotificationController` for **local notifications** (not FCM). Routing that actually exists currently is very minimal:

```dart
// lib/config/notifications/notifications.dart — current real implementation
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
        route = Routes.home; // TODO: Routes.orderDetail doesn't exist yet
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

`Routes.orderDetail` and `Routes.chat` **do not exist yet** in `routes.dart` (only `home`/`login`/`user`) — add them first before routing there. For taps from **FCM** (not local notifications), see `FirebaseMessagingService._handleNotificationTap` in `firebase_messaging_service.dart` — it is currently a TODO/has no navigation logic at all.

To add new routing, edit `NotificationController._handlePayload`.

---

## FCM → Local Notification

FCM messages are automatically converted to local notifications in `FirebaseMessagingService`:

```dart
// In firebaseMessagingBackgroundHandler (background) + onMessage (foreground)
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

Downloads an icon from a URL for image notifications:

```dart
// Method named downloadToTemp, not downloadImage
final imagePath = await NotificationImageHelper.downloadToTemp(imageUrl);
// Saved to temp dir, cleaned up after 7 days
```

---

## Requesting Permissions

```dart
// Before showing notifications, make sure permissions have been requested
// (Already done in main.dart via PermissionHandler)
await PermissionHandler().requestNotificationPermission();
```

---

## Checklist

```
[ ] Use ShowNotificationHelper.showNotification() with the correct type
[ ] Payload is always a jsonEncode Map with a 'type' key
[ ] type in the payload matches a NotificationType (order, chat, ticket, etc.)
[ ] Route notification taps in NotificationController
[ ] Permissions requested in main.dart
[ ] FCM → local notification is handled automatically via FirebaseMessagingService
```
