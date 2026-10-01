---
name: App Lifecycle Service
description: Handling app resume and pause states
---
# Skill: App Lifecycle Service

Guide to using `AppLifecycleService` to run callbacks when the app is resumed or paused.

---

## AppLifecycleService Overview

`lib/config/lifecycle/app_lifecycle_service.dart`

- GetxController + `WidgetsBindingObserver` (permanent)
- On **resumed**: reconnect MQTT → fire `onResumeCallbacks`
- On **paused**: disconnect MQTT → fire `onPauseCallbacks`
- On **detached**: disconnect MQTT
- Controller register/remove callbacks via methods

---

## Accessing the Service

```dart
final lifecycleService = Get.find<AppLifecycleService>();
```

---

## Register Resume Callback

Use to refresh data when the user returns to the app:

```dart
class HomeController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    fetchBanners(); // initial fetch

    // Register resume callback
    Get.find<AppLifecycleService>().addOnResumeCallback(_onAppResumed);
  }

  @override
  void onClose() {
    // IMPORTANT: remove callback when controller is disposed
    Get.find<AppLifecycleService>().removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  void _onAppResumed() {
    // Automatically called when app is resumed from the background
    fetchBanners();
    LoggerHelper.d('App resumed — refreshing banners');
  }
}
```

---

## Register Pause Callback

```dart
class VideoController extends BaseController {
  @override
  void onInit() {
    super.onInit();
    Get.find<AppLifecycleService>().addOnPauseCallback(_onAppPaused);
    Get.find<AppLifecycleService>().addOnResumeCallback(_onAppResumed);
  }

  @override
  void onClose() {
    Get.find<AppLifecycleService>().removeOnPauseCallback(_onAppPaused);
    Get.find<AppLifecycleService>().removeOnResumeCallback(_onAppResumed);
    super.onClose();
  }

  void _onAppPaused() {
    videoPlayer.pause(); // pause video when app goes to background
  }

  void _onAppResumed() {
    videoPlayer.play(); // resume video when app returns
  }
}
```

---

## Lifecycle States

```dart
// AppLifecycleState from Flutter SDK
// handled by AppLifecycleService:

AppLifecycleState.resumed   → MQTT reconnect + onResumeCallbacks
AppLifecycleState.paused    → MQTT disconnect + onPauseCallbacks
AppLifecycleState.detached  → MQTT disconnect
AppLifecycleState.inactive  → (not handled specifically)
```

---

## Auto-Reconnect MQTT

When the app resumes from the background:
1. `AppLifecycleService` detects the `resumed` state
2. Checks MQTT connection status
3. If disconnected → `mqtt.connect()` automatically
4. After connect → `mqtt.restoreSubscriptions()` (restore saved topics)
5. Fire `onResumeCallbacks`

No need to implement reconnect manually in controllers.

---

## Controller Pattern

```dart
class DashboardController extends BaseController {
  late final AppLifecycleService _lifecycle;

  DashboardController() {
    _lifecycle = Get.find<AppLifecycleService>();
  }

  @override
  void onInit() {
    super.onInit();
    _lifecycle.addOnResumeCallback(_refresh);
    _lifecycle.addOnPauseCallback(_cleanup);
    _fetchAll();
  }

  @override
  void onClose() {
    _lifecycle.removeOnResumeCallback(_refresh);
    _lifecycle.removeOnPauseCallback(_cleanup);
    super.onClose();
  }

  void _refresh() {
    LoggerHelper.d('DashboardController: app resumed');
    _fetchAll();
  }

  void _cleanup() {
    LoggerHelper.d('DashboardController: app paused');
  }

  Future<void> _fetchAll() async {
    await Future.wait([
      fetchStats(),
      fetchNotifications(),
    ]);
  }
}
```

---

## Checklist

```
[ ] Register callback in onInit()
[ ] REMOVE callback in onClose() — prevent memory leaks
[ ] No need to handle MQTT connect/disconnect — it is automatic
[ ] Use named method references (not lambdas) so removeCallback works
[ ] onResumeCallback for: refreshing data, starting audio/video, etc
[ ] onPauseCallback for: pausing media, stopping timers, etc
```
