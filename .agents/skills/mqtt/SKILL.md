# Skill: MQTT Service

Panduan penggunaan MQTT untuk real-time messaging: connect, subscribe, publish, dan listener.

---

## MqttService Overview

`lib/config/mqtt/mqtt_service.dart`

- GetxController permanent (singleton)
- Auto-connect saat app start (di main.dart)
- Auto-reconnect built-in
- Topic subscriptions persisted ke SecureStorage
- Wildcard support: `+` (single-level) dan `#` (multi-level)

---

## Mengakses Service

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
// MqttConnectionStatus.faulted

// Di UI
Obx(() => Icon(
  mqtt.connectionStatus.value == MqttConnectionStatus.connected
    ? Icons.wifi
    : Icons.wifi_off,
))
```

---

## Connect & Disconnect

```dart
// Connect (biasanya sudah auto dari main.dart)
await mqtt.connect();

// Disconnect (manual, misal saat logout)
mqtt.disconnect();
```

---

## Subscribe ke Topic

```dart
// Subscribe satu topic
mqtt.subscribe('user/123/notifications');

// Subscribe banyak topic sekaligus
mqtt.subscribeMany([
  'user/123/notifications',
  'order/456/status',
  'company/general',
]);

// Topic tersimpan otomatis ke SecureStorage dan di-restore saat reconnect

// Unsubscribe
mqtt.unsubscribe('user/123/notifications');
```

---

## Publish Pesan

```dart
mqtt.publish(
  topic: 'order/123/status',
  message: '{"status": "delivered"}',
  qos: MqttQos.atLeastOnce, // atau atMostOnce, exactlyOnce
  retain: false,
);
```

---

## Mendengarkan Pesan (Topic Listener)

### Listener per Topic

```dart
class OrderController extends BaseController {
  final MqttService _mqtt = Get.find<MqttService>();

  @override
  void onInit() {
    super.onInit();

    // Subscribe ke topic
    _mqtt.subscribe('order/${orderId}/status');

    // Tambah listener
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
    // PENTING: hapus listener saat controller di-dispose
    _mqtt.removeTopicListener('order/${orderId}/status', _onOrderStatusChanged);
    _mqtt.unsubscribe('order/${orderId}/status');
    super.onClose();
  }
}
```

### Listener Global (semua pesan)

```dart
// Mendapat semua pesan dari semua topic yang di-subscribe
_mqtt.addGlobalListener((topic, message) {
  LoggerHelper.d('MQTT message on $topic: $message');
});
```

---

## Wildcard Topics

```dart
// + = satu level wildcard
_mqtt.subscribe('order/+/status'); // cocok: order/123/status, order/abc/status
                                   // tidak cocok: order/123/detail/status

// # = multi-level wildcard (harus di akhir)
_mqtt.subscribe('user/#');         // cocok: user/123, user/123/notif, user/123/order/detail
```

---

## Contoh Integrasi di Controller

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
    // Tidak perlu unsubscribe — topic persists untuk session berikutnya
    super.onClose();
  }
}
```

---

## Topic Persistence

Topic yang di-subscribe secara otomatis:
1. Disimpan ke `SecureStorage` (`SecureStorageKey.mqttTopic`) sebagai JSON
2. Di-restore saat reconnect (setelah app resume dari background)
3. `AppLifecycleService` menangani disconnect (paused) dan reconnect (resumed)

---

## Checklist

```
[ ] Get.find<MqttService>() untuk akses service
[ ] subscribe() sebelum addTopicListener()
[ ] onClose(): removeTopicListener() untuk cegah memory leak
[ ] Wildcard: + untuk single-level, # untuk multi-level
[ ] publish() untuk kirim pesan
[ ] Connection status via mqtt.connectionStatus.value
[ ] App lifecycle (connect/disconnect) sudah handled otomatis oleh AppLifecycleService
```
