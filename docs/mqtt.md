# MQTT Service

Dokumentasi lengkap untuk `MqttService` — service MQTT yang terintegrasi dengan `EnvironmentConfig` dan `SecureStorage`.

## Overview

`MqttService` (`lib/config/mqtt/mqtt_service.dart`) menyediakan abstraksi penuh untuk komunikasi real-time melalui protokol MQTT. Service ini dibangun di atas package `mqtt_client` dan terintegrasi langsung dengan:

- **`EnvironmentConfig`** — Konfigurasi broker otomatis berdasarkan environment aktif (dev/staging/prod)
- **`SecureStorage`** — Menyimpan dan me-restore daftar topic subscription secara encrypted
- **`GetxController`** — State management reaktif (observable)

## Arsitektur

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
    └── publish() ─────────► Kirim pesan ke topic
```

## Setup

### 1. Register di DI (main.dart atau binding)

```dart
// Di main.dart (global singleton)
Get.put(MqttService(), permanent: true);

// Atau di binding tertentu
Get.lazyPut(() => MqttService());
```

### 2. Connect

```dart
final mqtt = Get.find<MqttService>();
await mqtt.connect(); // auto-reconnect enabled by default

// Tanpa auto-reconnect:
await mqtt.connect(autoReconnect: false);
```

### 3. Disconnect

```dart
mqtt.disconnect();
```

## Subscribe & Unsubscribe

### Subscribe ke satu topic

```dart
mqtt.subscribe('chat/room/123');
mqtt.subscribe('notification/user/456');
```

### Subscribe ke banyak topic sekaligus

```dart
mqtt.subscribeMany([
  'chat/room/123',
  'chat/room/456',
  'notification/alerts',
]);
```

### Unsubscribe dari satu topic

```dart
mqtt.unsubscribe('chat/room/123');
```

### Unsubscribe dari semua topic

```dart
mqtt.unsubscribeAll();
```

### Wildcard Topics

MQTT mendukung 2 jenis wildcard:

| Wildcard | Deskripsi | Contoh |
|---|---|---|
| `+` | Single-level — cocok dengan 1 segment | `chat/+/messages` cocok dengan `chat/room1/messages` |
| `#` | Multi-level — cocok dengan semua sub-segment | `chat/#` cocok dengan `chat/room1/messages/new` |

```dart
mqtt.subscribe('notification/+/alerts');  // single-level wildcard
mqtt.subscribe('chat/#');                 // multi-level wildcard
```

## Listeners

### Per-Topic Listener

Callback spesifik yang hanya dipanggil untuk pesan dari topic tertentu:

```dart
mqtt.addTopicListener('chat/room/123', (topic, payload) {
  final data = jsonDecode(payload);
  print('Pesan baru di room 123: ${data['message']}');
});

// Hapus listener tertentu
mqtt.removeTopicListener('chat/room/123', myCallback);

// Hapus semua listener dari sebuah topic
mqtt.clearTopicListeners('chat/room/123');
```

### Global Listener

Callback yang dipanggil untuk **semua** pesan masuk:

```dart
mqtt.addGlobalListener((topic, payload) {
  LoggerHelper.d('MQTT ← [$topic] $payload');
});
```

## Publish

Kirim pesan ke topic tertentu:

```dart
// Default QoS: atLeastOnce
mqtt.publish('chat/room/123', '{"message": "Hello!"}');

// Dengan opsi
mqtt.publish(
  'chat/room/123',
  jsonEncode({'message': 'Hello!', 'sender': 'user_001'}),
  qos: MqttQos.exactlyOnce,
  retain: true, // Broker simpan pesan terakhir
);
```

## Persistence (SecureStorage)

Daftar topic yang sedang aktif **otomatis** tersimpan di `SecureStorage` setiap kali `subscribe()` atau `unsubscribe()` dipanggil.

Saat `connect()` berhasil, topics otomatis di-restore dan di-subscribe ulang.

### Manual Control

```dart
// Restore manual (biasanya tidak perlu — otomatis saat connect)
await mqtt.restoreSubscriptions();

// Hapus semua topic tersimpan
await mqtt.clearPersistedTopics();
```

## Observing State

`MqttService` expose reactive state yang bisa digunakan di UI:

```dart
// Di controller
final mqtt = Get.find<MqttService>();

// Cek status koneksi
Obx(() => Text('Status: ${mqtt.connectionStatus.value}'));

// Cek daftar topic aktif
Obx(() => Column(
  children: mqtt.subscribedTopics.map((t) => Text(t)).toList(),
));

// Boolean check
if (mqtt.isConnected) { ... }
```

### Connection Status

| Status | Deskripsi |
|---|---|
| `connected` | Terhubung ke broker |
| `connecting` | Sedang proses koneksi / reconnect |
| `disconnected` | Tidak terhubung |
| `error` | Koneksi gagal |

## Contoh Lengkap di Controller

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
    // Pastikan connected
    if (!mqtt.isConnected) {
      await mqtt.connect();
    }

    // Subscribe ke room
    mqtt.subscribe(_topic);

    // Listen pesan masuk di room ini saja
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

## Konfigurasi Environment

Konfigurasi broker diambil otomatis dari `EnvironmentConfig` (file `.env`):

| Key di `.env` | Field | Contoh |
|---|---|---|
| `MQTT_BROKER_URL_DEV` | `mqttBrokerUrl` | `broker.hivemq.com` |
| `MQTT_BROKER_PORT_DEV` | `mqttBrokerPort` | `1883` |
| `MQTT_CLIENT_ID_DEV` | `mqttClientId` | `nexus_app_dev_001` |
| `MQTT_USERNAME_DEV` | `mqttUsername` | `user` |
| `MQTT_PASSWORD_DEV` | `mqttPassword` | `pass` |

> Ganti suffix `_DEV` dengan `_STAGING` atau `_PROD` untuk environment lain.

## Auto-Reconnect

Auto-reconnect sudah built-in dari `mqtt_client`:

```
Koneksi terputus
    │
    ▼
onDisconnected() callback
    │
    ▼
Auto-reconnect attempt (otomatis)
    │
    ▼
onAutoReconnected() callback
    │
    ▼
Topics otomatis di-resubscribe (resubscribeOnAutoReconnect: true)
```

Semua proses ini sudah di-handle secara internal oleh `MqttService`. Kamu cukup memanggil `connect()` sekali di awal.
