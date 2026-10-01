# Notifications

Location: `lib/config/notifications/notifications.dart`

## Overview

Local notification system using `flutter_local_notifications`. Consists of several classes:

| Class | Function |
|---|---|
| `NotificationsHelper` | Init, create channels, show notification |
| `NotificationController` | Handle tap (foreground/background), parse payload |
| `NotificationChannels` | Definition of channel IDs and configs |
| `ShowNotificationHelper` | Facade for showing notifications based on `NotificationType` |
| `NotificationImageHelper` | Download images for big picture notifications |

---

## Initialization

```dart
await NotificationsHelper.init();
```

Called in `main.dart` before Firebase Messaging. Creates all notification channels (Android) and platform configuration.

---

## Notification Channels

Android requires notification channels. Available channels are defined in `NotificationChannels`:

Each channel has a `key`, `name`, and `description` that is automatically generated from the key.

---

## Showing Notifications

### Via `ShowNotificationHelper` (Recommended)

Facade that automatically selects the channel, icon, and style based on `NotificationType`:

```dart
ShowNotificationHelper.showNotification(
  type: NotificationType.order,
  title: 'New Order',
  body: 'Order #123 has been created',
  summary: 'Additional details',
  iconUrl: 'https://img.com/icon.png',
  payload: {'order_id': '123'},
);
```

### Via `NotificationsHelper` (Low-Level)

Full control over all parameters:

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
  order,      // Order
  alert,      // Alert/Warning
  system,     // System
  chat,       // Chat message
  payment,    // Payment
  ticket,     // Support ticket
  ads,        // Ads
  marketing,  // Marketing
  other,      // Other
  general,    // General (default)
}
```

Each type is mapped to the corresponding channel in `ShowNotificationHelper`.

---

## Handle Notification Tap

```dart
class NotificationController {
  // Foreground + background tap
  static void onActionReceived(NotificationResponse response) { ... }

  // Background tap (isolate)
  static void onBackgroundActionReceived(NotificationResponse response) { ... }

  // Parse JSON payload and navigate
  static void _handlePayload(String? rawPayload) { ... }
}
```

Expected payload:

```json
{
  "type": "order",
  "order_id": "123",
  "route": "/order-detail"
}
```

---

## Big Picture Notification

`NotificationImageHelper` downloads an image from a URL to a temporary directory:

```dart
final localPath = await NotificationImageHelper.downloadToTemp(imageUrl);
```

- Uses `DioClient.download()` 
- Auto-cleanup for image files older than 7 days
- Saved in `{tempDir}/notification_images/`
