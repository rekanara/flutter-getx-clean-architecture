# App Lifecycle Service

Location: `lib/config/lifecycle/app_lifecycle_service.dart`

## Overview

Global observer to manage app behavior when transitioning between **foreground** and **background**. Registered as a permanent singleton in `main.dart`.

```dart
Get.put(AppLifecycleService(), permanent: true);
```

---

## Lifecycle States

| State | When | Automatic Action |
|---|---|---|
| `resumed` | App returns to foreground | MQTT reconnect + trigger resume callbacks |
| `paused` | App goes to background | MQTT disconnect + trigger pause callbacks |
| `inactive` | App visible but not receiving input (dialog, split screen) | Log only |
| `detached` | App is terminated | MQTT disconnect |

### Flow

```
User minimizes app
    │
    ▼  paused
MQTT.disconnect()  ← save battery
Firebase keeps running  ← SDK handles it
 
User reopens app
    │
    ▼  resumed
MQTT.connect()  ← reconnect
onResumeCallbacks()  ← refresh data
```

---

## Callback Registration

Controllers can register functions to be called automatically when the app resumes or pauses.

### Registering a Callback

```dart
class HomeController extends BaseController {
  late final AppLifecycleService _lifecycle;

  @override
  void onInit() {
    super.onInit();
    _lifecycle = Get.find<AppLifecycleService>();
    _lifecycle.addOnResumeCallback(_refreshData);
  }

  @override
  void onClose() {
    _lifecycle.removeOnResumeCallback(_refreshData);
    super.onClose();
  }

  void _refreshData() {
    fetchBanners(); // called automatically when app resumes
  }
}
```

### API

| Method | Description |
|---|---|
| `addOnResumeCallback(VoidCallback)` | Register function called when app resumes |
| `removeOnResumeCallback(VoidCallback)` | Remove resume callback |
| `addOnPauseCallback(VoidCallback)` | Register function called when app pauses |
| `removeOnPauseCallback(VoidCallback)` | Remove pause callback |

### Observable State

```dart
final lifecycle = Get.find<AppLifecycleService>();

Obx(() {
  // React to lifecycle changes
  if (lifecycle.currentState.value == AppLifecycleState.paused) {
    return Text('App is in background');
  }
  return Text('App is active');
});
```

---

## Notes

- **Firebase** does not need to be handled here — the Firebase SDK keeps running in the background natively.
- **MQTT** is disconnected to save battery, as an active MQTT client consumes resources continuously.
- Always **remove callbacks in `onClose()`** to prevent memory leaks.
