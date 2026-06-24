# Skill: Firebase (Core, FCM, Remote Config)

Panduan menggunakan Firebase Core, Firebase Cloud Messaging (FCM), dan Remote Config.

---

## Inisialisasi (sudah ada di main.dart)

```dart
// lib/main.dart — sudah diinisialisasi, tidak perlu setup ulang
await FirebaseService.initialize();
await FirebaseMessagingService().init();
await RemoteConfigService().init();
```

---

## FirebaseService

`lib/config/firebase/firebase_service.dart`

Singleton init guard — aman dipanggil berkali-kali:

```dart
await FirebaseService.initialize();
// Idempotent: jika sudah init, langsung return
```

---

## Firebase Cloud Messaging (FCM)

`lib/config/firebase/firebase_messaging_service.dart`

### Mengakses Service

```dart
final fcmService = Get.find<FirebaseMessagingService>();
```

### FCM Token

```dart
// Token otomatis didapat saat init
// Untuk mendapatkan token saat ini:
final token = await fcmService.fcmToken; // String?

// Token auto-refresh — sudah ada listener di service
```

### Topic Subscription

```dart
// Subscribe ke topic (semua device dengan topic ini akan terima notif)
await fcmService.subscribeToTopic('promotions');
await fcmService.subscribeToTopic('user_${userId}');

// Unsubscribe
await fcmService.unsubscribeFromTopic('promotions');
```

### Notifikasi Handler

Notifikasi sudah di-handle otomatis di service:
- **Foreground** (`onMessage`): tampilkan local notification
- **Background tap** (`onMessageOpenedApp`): navigate ke screen terkait
- **Cold start** (`getInitialMessage`): navigate saat app dibuka dari killed state

### Payload Format FCM

```json
{
  "notification": {
    "title": "Pesanan Baru",
    "body": "Order #12345 telah dibuat"
  },
  "data": {
    "type": "order",
    "id": "12345",
    "message": "Pesanan Baru",
    "image": "https://example.com/icon.png"
  }
}
```

Field `type` yang dikenali: `order`, `alert`, `system`, `chat`, `payment`, `ticket`, `ads`, `marketing`, `general`

---

## Remote Config

`lib/config/firebase/remote_config_service.dart`

### Mengakses Service

```dart
final remoteConfig = Get.find<RemoteConfigService>();
```

### Default Keys (sudah ada)

```dart
// Observable — auto-update saat config berubah (real-time listener)
remoteConfig.maintenanceMode.value    // bool
remoteConfig.maintenanceMessage.value // String
```

### Membaca Nilai

```dart
// Generic getters
remoteConfig.getString('welcome_message');   // String
remoteConfig.getBool('feature_flag_x');      // bool
remoteConfig.getInt('max_items');            // int
remoteConfig.getDouble('discount_rate');     // double
```

### Menambah Key Baru

Di Firebase Console:
1. Remote Config → Add parameter
2. Key: `new_feature_enabled`, Value: `false` (default)

Di `RemoteConfigService.init()`:
```dart
// Tambah default value
await _remoteConfig.setDefaults({
  'maintenance_mode': false,
  'maintenance_message': '',
  'new_feature_enabled': false, // ← TAMBAHKAN
});
```

Di controller yang membutuhkan:
```dart
final isNewFeatureEnabled = Get.find<RemoteConfigService>().getBool('new_feature_enabled');
```

### Observable Remote Config di Controller

```dart
class HomeController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    
    // Reactive terhadap maintenance mode
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

Firebase config membaca dari `Domain.firebaseXxx` yang sudah environment-aware:

```dart
// TIDAK perlu ubah — otomatis pakai env saat ini
static FirebaseOptions get currentPlatform => FirebaseOptions(
  apiKey: Domain.firebaseApiKey,
  projectId: Domain.firebaseProjectId,
  // ...
);
```

---

## Checklist

```
[ ] Firebase sudah init di main.dart (FirebaseService.initialize())
[ ] FCM sudah init di main.dart (FirebaseMessagingService().init())
[ ] Remote Config sudah init di main.dart (RemoteConfigService().init())
[ ] Untuk baca FCM token: Get.find<FirebaseMessagingService>()
[ ] Topic subscription: fcmService.subscribeToTopic(topic)
[ ] Remote Config value: Get.find<RemoteConfigService>().getBool(key)
[ ] Default value untuk key baru di RemoteConfigService.init()
[ ] Firebase config otomatis env-aware via Domain.firebaseXxx
```
