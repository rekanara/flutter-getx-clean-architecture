# MQTT Service

Complete documentation for `MqttService` — an MQTT service integrated with `EnvironmentConfig` and `SecureStorage`.

## Overview

`MqttService` (`lib/config/mqtt/mqtt_service.dart`) provides full abstraction for real-time communication via the MQTT protocol. This service is built on top of the `mqtt_client` package and integrates directly with:

- **`EnvironmentConfig`** — Automatic broker configuration based on the active environment (dev/staging/prod)
- **`SecureStorage`** — Saves and restores the list of topic subscriptions securely
- **`GetxController`** — Reactive state management (observable)

## Architecture

```
MqttService (GetxController)
    │
    ├── connect() ─────────► EnvironmentConfig
    │                          ├── mqttBrokerUrl
    │                          ├── mqttBrokerPort
    │                          ├── mqttClientId
    │                          ├── mqttUsername
    │                          └── mqttPassword
    │
    ├── subscribe() ───────► SecureStorage (persist topics)
    ├── unsubscribe() ─────► SecureStorage (update topics)
    │
    ├── _topicListeners ───► Per-topic callbacks
    ├── _globalListeners ──► Global callbacks
    │
    └── publish() ─────────► Send message to topic
```

## Setup

### 1. Register in DI (`main.dart` or binding)

```dart
// In main.dart (global singleton)
Get.put(MqttService(), permanent: true);

// Or in a specific binding
Get.lazyPut(() => MqttService());
```

### 2. Connect

```dart
final mqtt = Get.find<MqttService>();
await mqtt.connect(); // auto-reconnect enabled by default

// Without auto-reconnect:
await mqtt.connect(autoReconnect: false);
```

### 3. Disconnect

```dart
mqtt.disconnect();
```

## Subscribe & Unsubscribe

### Subscribe to a single topic

```dart
mqtt.subscribe('chat/room/123');
mqtt.subscribe('notification/user/456');
```

### Subscribe to multiple topics at once

```dart
mqtt.subscribeMany([
  'chat/room/123',
  'chat/room/456',
  'notification/alerts',
]);
```

### Unsubscribe from a single topic

```dart
mqtt.unsubscribe('chat/room/123');
```

### Unsubscribe from all topics

```dart
mqtt.unsubscribeAll();
```

### Wildcard Topics

MQTT supports 2 types of wildcards:

| Wildcard | Description | Example |
|---|---|---|
| `+` | Single-level — matches 1 segment | `chat/+/messages` matches `chat/room1/messages` |
| `#` | Multi-level — matches all sub-segments | `chat/#` matches `chat/room1/messages/new` |

```dart
mqtt.subscribe('notification/+/alerts');  // single-level wildcard
mqtt.subscribe('chat/#');                 // multi-level wildcard
```

## Listeners

### Per-Topic Listener

Specific callback that is only triggered for messages from a specific topic:

```dart
mqtt.addTopicListener('chat/room/123', (topic, payload) {
  final data = jsonDecode(payload);
  print('New message in room 123: ${data['message']}');
});

// Remove a specific listener
mqtt.removeTopicListener('chat/room/123', myCallback);

// Clear all listeners from a topic
mqtt.clearTopicListeners('chat/room/123');
```

### Global Listener

Callback triggered for **all** incoming messages:

```dart
mqtt.addGlobalListener((topic, payload) {
  LoggerHelper.d('MQTT ← [$topic] $payload');
});
```

## Publish

Send a message to a specific topic:

```dart
// Default QoS: atLeastOnce
mqtt.publish('chat/room/123', '{"message": "Hello!"}');

// With options
mqtt.publish(
  'chat/room/123',
  jsonEncode({'message': 'Hello!', 'sender': 'user_001'}),
  qos: MqttQos.exactlyOnce,
  retain: true, // Broker saves the last message
);
```

## Persistence (SecureStorage)

The list of currently active topics is **automatically** saved to `SecureStorage` every time `subscribe()` or `unsubscribe()` is called.

When `connect()` succeeds, topics are automatically restored and re-subscribed.

### Manual Control

```dart
// Manual restore (usually not needed — automatic on connect)
await mqtt.restoreSubscriptions();

// Clear all saved topics
await mqtt.clearPersistedTopics();
```

## Observing State

`MqttService` exposes reactive state that can be used in the UI:

```dart
// In the controller
final mqtt = Get.find<MqttService>();

// Check connection status
Obx(() => Text('Status: ${mqtt.connectionStatus.value}'));

// Check active topics list
Obx(() => Column(
  children: mqtt.subscribedTopics.map((t) => Text(t)).toList(),
));

// Boolean check
if (mqtt.isConnected) { ... }
```

### Connection Status

| Status | Description |
|---|---|
| `connected` | Connected to broker |
| `connecting` | Connecting / reconnecting |
| `disconnected` | Not connected |
| `error` | Connection failed |

## Complete Controller Example

```dart
class ChatController extends GetxController {
  final MqttService mqtt = Get.find<MqttService>();
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final String roomId;

  ChatController({required this.roomId});

  String get _topic => 'chat/room/$roomId';

  @override
  void onInit() {
    super.onInit();
    _setupMqtt();
  }

  Future<void> _setupMqtt() async {
    // Ensure connected
    if (!mqtt.isConnected) {
      await mqtt.connect();
    }

    // Subscribe to room
    mqtt.subscribe(_topic);

    // Listen to messages in this room only
    mqtt.addTopicListener(_topic, _onMessageReceived);
  }

  void _onMessageReceived(String topic, String payload) {
    final data = jsonDecode(payload) as Map<String, dynamic>;
    messages.add(data);
  }

  void sendMessage(String text) {
    mqtt.publish(_topic, jsonEncode({
      'sender': 'current_user',
      'message': text,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  @override
  void onClose() {
    mqtt.removeTopicListener(_topic, _onMessageReceived);
    mqtt.unsubscribe(_topic);
    super.onClose();
  }
}
```

## Environment Configuration

Broker configuration is automatically retrieved from `EnvironmentConfig` (`.env` file):

| Key in `.env` | Field | Example |
|---|---|---|
| `MQTT_BROKER_URL_DEV` | `mqttBrokerUrl` | `broker.hivemq.com` |
| `MQTT_BROKER_PORT_DEV` | `mqttBrokerPort` | `1883` |
| `MQTT_CLIENT_ID_DEV` | `mqttClientId` | `nexus_app_dev_001` |
| `MQTT_USERNAME_DEV` | `mqttUsername` | `user` |
| `MQTT_PASSWORD_DEV` | `mqttPassword` | `pass` |

> Replace the `_DEV` suffix with `_STAGING` or `_PROD` for other environments.

## Auto-Reconnect

Auto-reconnect is built-in from `mqtt_client`:

```
Connection lost
    │
    ▼
onDisconnected() callback
    │
    ▼
Auto-reconnect attempt (automatic)
    │
    ▼
onAutoReconnected() callback
    │
    ▼
Topics automatically re-subscribed (resubscribeOnAutoReconnect: true)
```

All these processes are handled internally by `MqttService`. You only need to call `connect()` once at the start.
