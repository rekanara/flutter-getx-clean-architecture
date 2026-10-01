---
name: Firebase
description: Setup and usage for Firebase Core, FCM, and Remote Config
---
# Skill: Firebase (Core, FCM, Remote Config)

Guide to using Firebase Core, Firebase Cloud Messaging (FCM), and Remote Config.

---

## Initialization (already in main.dart)

```dart
// lib/main.dart — already initialized, no setup needed
await FirebaseService.init();
final fcmService = Get.put(FirebaseMessagingService(), permanent: true);
await fcmService.init();
final rcService = Get.put(RemoteConfigService(), permanent: true);
await rcService.init();
```

---

## FirebaseService

`lib/config/firebase/firebase_service.dart`

Singleton init guard — safe to call multiple times:

```dart
await FirebaseService.init();
// Idempotent: if already initialized, returns immediately
```

---

## Firebase Cloud Messaging (FCM)

`lib/config/firebase/firebase_messaging_service.dart`

### Accessing the Service

```dart
final fcmService = Get.find<FirebaseMessagingService>();
```

### FCM Token

```dart
// fcmToken is an RxString (observable), NOT a Future — do not await
final token = fcmService.fcmToken.value; // String

// Reactive in UI:
Obx(() => Text(fcmService.fcmToken.value));

// Auto-refresh token — listener is already in the service
```

### Topic Subscription

```dart
// Subscribe to topic (all devices with this topic receive the notification)
await fcmService.subscribeToTopic('promotions');
await fcmService.subscribeToTopic('user_${userId}');

// Unsubscribe
await fcmService.unsubscribeFromTopic('promotions');
```

### Notification Handlers

Notifications are automatically handled in the service:
- **Foreground** (`onMessage`): shows a local notification
- **Background tap** (`onMessageOpenedApp`): navigates to the related screen
- **Cold start** (`getInitialMessage`): navigates when app is opened from a killed state

### FCM Payload Format

```json
{
  "notification": {
    "title": "New Order",
    "body": "Order #12345 has been created"
  },
  "data": {
    "type": "order",
    "id": "12345",
    "message": "New Order",
    "image": "https://example.com/icon.png"
  }
}
```

Recognized `type` fields: `order`, `alert`, `system`, `chat`, `payment`, `ticket`, `ads`, `marketing`, `general`

---

## Remote Config

`lib/config/firebase/remote_config_service.dart`

### Accessing the Service

```dart
final remoteConfig = Get.find<RemoteConfigService>();
```

### Default Keys (already exist)

```dart
// Observable — auto-update when config changes (real-time listener)
remoteConfig.maintenanceMode.value    // bool
remoteConfig.maintenanceMessage.value // String
```

### Reading Values

```dart
// Generic getters
remoteConfig.getString('welcome_message');   // String
remoteConfig.getBool('feature_flag_x');      // bool
remoteConfig.getInt('max_items');            // int
remoteConfig.getDouble('discount_rate');     // double
```

### Adding a New Key

In the Firebase Console:
1. Remote Config → Add parameter
2. Key: `new_feature_enabled`, Value: `false` (default)

In `RemoteConfigService.init()`:
```dart
// Add default value
await _remoteConfig.setDefaults({
  'maintenance_mode': false,
  'maintenance_message': '',
  'new_feature_enabled': false, // ← ADD THIS
});
```

In the required controller:
```dart
final isNewFeatureEnabled = Get.find<RemoteConfigService>().getBool('new_feature_enabled');
```

### Observable Remote Config in a Controller

```dart
class HomeController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    
    // Reactive to maintenance mode
    final config = Get.find<RemoteConfigService>();
    ever(config.maintenanceMode, (isMaintenance) {
      if (isMaintenance) {
        Get.dialog(MaintenanceDialog(message: config.maintenanceMessage.value));
      }
    });
  }
}
```

---

## FirebaseOptions (Environment-Aware)

`lib/config/firebase/firebase_options.dart`

Firebase config reads from `Domain.firebaseXxx` which is environment-aware:

```dart
// NO NEED to change — automatically uses current env
static FirebaseOptions get currentPlatform => FirebaseOptions(
  apiKey: Domain.firebaseApiKey,
  projectId: Domain.firebaseProjectId,
  // ...
);
```

---

## Checklist

```
[ ] Firebase initialized in main.dart (FirebaseService.init())
[ ] FCM initialized in main.dart (FirebaseMessagingService().init())
[ ] Remote Config initialized in main.dart (RemoteConfigService().init())
[ ] To read FCM token: Get.find<FirebaseMessagingService>()
[ ] Topic subscription: fcmService.subscribeToTopic(topic)
[ ] Remote Config value: Get.find<RemoteConfigService>().getBool(key)
[ ] Default values for new keys in RemoteConfigService.init()
[ ] Firebase config is automatically env-aware via Domain.firebaseXxx
```
