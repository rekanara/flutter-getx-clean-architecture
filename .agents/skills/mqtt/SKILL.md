---
name: MQTT Service
description: Guide for MQTT real-time messaging
---
# Skill: MQTT Service

Guide to using MQTT for real-time messaging: connect, subscribe, publish, and listeners.

---

## MqttService Overview

`lib/config/mqtt/mqtt_service.dart`

- Permanent GetxController (singleton)
- Auto-connects on app start (in main.dart)
- Built-in auto-reconnect
- Topic subscriptions persisted to SecureStorage
- Wildcard support: `+` (single-level) and `#` (multi-level)

---

## Accessing the Service

```dart
final mqtt = Get.find<MqttService>();
```

---

## Connection Status

```dart
// Observable
mqtt.connectionStatus.value // MqttConnectionStatus enum

// Enum values:
// MqttConnectionStatus.connecting
// MqttConnectionStatus.connected
// MqttConnectionStatus.disconnected
// MqttConnectionStatus.error

// In UI
Obx(() => Icon(
  mqtt.connectionStatus.value == MqttConnectionStatus.connected
    ? Icons.wifi
    : Icons.wifi_off,
))
```

---

## Connect & Disconnect

```dart
// Connect (usually done automatically from main.dart)
await mqtt.connect();

// Disconnect (manual, e.g., on logout)
mqtt.disconnect();
```

---

## Subscribe to Topics

```dart
// Subscribe to a single topic
mqtt.subscribe('user/123/notifications');

// Subscribe to multiple topics at once
mqtt.subscribeMany([
  'user/123/notifications',
  'order/456/status',
  'company/general',
]);

// Topics are automatically saved to SecureStorage and restored upon reconnect

// Unsubscribe
mqtt.unsubscribe('user/123/notifications');
```

---

## Publish Messages

```dart
// topic and message are POSITIONAL parameters, not named
mqtt.publish(
  'order/123/status',
  '{"status": "delivered"}',
  qos: MqttQos.atLeastOnce, // or atMostOnce, exactlyOnce
  retain: false,
);
```

---

## Listening to Messages (Topic Listener)

### Per-Topic Listener

```dart
class OrderController extends BaseController {
  final MqttService _mqtt = Get.find<MqttService>();

  @override
  void onInit() {
    super.onInit();

    // Subscribe to the topic
    _mqtt.subscribe('order/${orderId}/status');

    // Add a listener
    _mqtt.addTopicListener('order/${orderId}/status', _onOrderStatusChanged);
  }

  void _onOrderStatusChanged(String topic, String message) {
    final data = jsonDecode(message);
    LoggerHelper.d('Order status: ${data['status']}');

    // Refresh UI
    fetchOrderDetail();
  }

  @override
  void onClose() {
    // IMPORTANT: remove the listener when the controller is disposed
    _mqtt.removeTopicListener('order/${orderId}/status', _onOrderStatusChanged);
    _mqtt.unsubscribe('order/${orderId}/status');
    super.onClose();
  }
}
```

### Global Listener (All messages)

```dart
// Receive all messages from all subscribed topics
_mqtt.addGlobalListener((topic, message) {
  LoggerHelper.d('MQTT message on $topic: $message');
});
```

---

## Wildcard Topics

```dart
// + = single-level wildcard
_mqtt.subscribe('order/+/status'); // matches: order/123/status, order/abc/status
                                   // does not match: order/123/detail/status

// # = multi-level wildcard (must be at the end)
_mqtt.subscribe('user/#');         // matches: user/123, user/123/notif, user/123/order/detail
```

---

## Integration Example in Controller

```dart
class ChatController extends BaseController {
  final MqttService _mqtt = Get.find<MqttService>();
  final messages = <ChatMessage>[].obs;

  final String _roomTopic = 'chat/room_${roomId}';
  final String _presenceTopic = 'chat/room_${roomId}/presence';

  @override
  void onInit() {
    super.onInit();
    _mqtt.subscribe(_roomTopic);
    _mqtt.subscribe(_presenceTopic);
    _mqtt.addTopicListener(_roomTopic, _onMessage);
    _mqtt.addTopicListener(_presenceTopic, _onPresence);
  }

  void _onMessage(String topic, String payload) {
    final msg = ChatMessage.fromJson(jsonDecode(payload));
    messages.add(msg);
  }

  void _onPresence(String topic, String payload) {
    final data = jsonDecode(payload);
    // update presence state
  }

  void sendMessage(String text) {
    _mqtt.publish(
      topic: _roomTopic,
      message: jsonEncode({'text': text, 'sender': userId}),
    );
  }

  @override
  void onClose() {
    _mqtt.removeTopicListener(_roomTopic, _onMessage);
    _mqtt.removeTopicListener(_presenceTopic, _onPresence);
    // No need to unsubscribe — topics persist for the next session
    super.onClose();
  }
}
```

---

## Topic Persistence

Subscribed topics are automatically:
1. Saved to `SecureStorage` (`SecureStorageKey.mqttTopic`) as JSON
2. Restored upon reconnect (after app resumes from background)
3. `AppLifecycleService` handles disconnect (paused) and reconnect (resumed)

---

## Checklist

```
[ ] Get.find<MqttService>() to access the service
[ ] subscribe() before calling addTopicListener()
[ ] onClose(): removeTopicListener() to prevent memory leaks
[ ] Wildcards: + for single-level, # for multi-level
[ ] publish() to send messages
[ ] Connection status via mqtt.connectionStatus.value
[ ] App lifecycle (connect/disconnect) is handled automatically by AppLifecycleService
```
