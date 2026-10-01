import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../../infrastructure/network/environments.dart';
import '../../infrastructure/platform/secure_storage/flutter_secure_storage_impl.dart';
import '../../infrastructure/platform/secure_storage/secure_storage.dart';
import '../../utils/helper/logger.dart';

/// More readable MQTT connection status.
enum MqttConnectionStatus { connected, connecting, disconnected, error }

/// Callback when receiving a message from a topic.
typedef MqttMessageCallback = void Function(String topic, String payload);

/// Complete service to manage MQTT connections, subscriptions, and messages.
///
/// Features:
/// - Connect / disconnect with auto-reconnect
/// - Subscribe / unsubscribe per-topic separately
/// - Persist and restore topic list to/from SecureStorage
/// - Per-topic callbacks (separate listeners for each topic)
/// - Global message listener
/// - Publish messages to specific topics
class MqttService extends GetxController {
  MqttServerClient? _client;
  final SecureStorage _secureStorage;

  /// Connection status (observable)
  final Rx<MqttConnectionStatus> connectionStatus =
      MqttConnectionStatus.disconnected.obs;

  /// List of actively subscribed topics (observable)
  final RxSet<String> subscribedTopics = <String>{}.obs;

  /// Separate callbacks per topic
  final Map<String, List<MqttMessageCallback>> _topicListeners = {};

  /// Global listener — called for ALL incoming messages
  final List<MqttMessageCallback> _globalListeners = [];

  /// Stream subscription internal
  StreamSubscription? _messageSubscription;

  /// Auto-reconnect flag
  bool _autoReconnect = true;

  /// Reconnect delay
  final Duration _reconnectDelay = const Duration(seconds: 5);

  MqttService({SecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? FlutterSecureStorageImpl();

  // ═══════════════════════════════════════════════════════════
  //  CONNECTION
  // ═══════════════════════════════════════════════════════════

  /// Initialize and connect to MQTT broker based on active environment.
  Future<bool> connect({bool autoReconnect = true}) async {
    if (connectionStatus.value == MqttConnectionStatus.connecting) {
      LoggerHelper.w('MQTT: Already connecting...');
      return false;
    }

    _autoReconnect = autoReconnect;
    connectionStatus.value = MqttConnectionStatus.connecting;

    final config = ConfigEnvironments.config;

    _client = MqttServerClient(config.mqttBrokerUrl, config.mqttClientId)
      ..port = config.mqttBrokerPort
      ..keepAlivePeriod = 60
      ..autoReconnect = autoReconnect
      ..resubscribeOnAutoReconnect = true
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onAutoReconnect = _onAutoReconnect
      ..onAutoReconnected = _onAutoReconnected
      ..onSubscribed = _onSubscribed
      ..onUnsubscribed = _onUnsubscribed
      ..logging(on: false);

    // Last Will & Testament (optional)
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(config.mqttClientId)
        .authenticateAs(config.mqttUsername, config.mqttPassword)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    _client!.connectionMessage = connMessage;

    try {
      LoggerHelper.i(
        'MQTT: Connecting to ${config.mqttBrokerUrl}:${config.mqttBrokerPort}...',
      );
      await _client!.connect(config.mqttUsername, config.mqttPassword);
    } catch (e) {
      LoggerHelper.e('MQTT: Connection failed — $e');
      connectionStatus.value = MqttConnectionStatus.error;
      _client?.disconnect();
      return false;
    }

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      LoggerHelper.i('MQTT: Connected successfully');
      connectionStatus.value = MqttConnectionStatus.connected;

      // Listen to incoming messages
      _listenMessages();

      // Restore topics from SecureStorage
      await restoreSubscriptions();

      return true;
    } else {
      LoggerHelper.e(
        'MQTT: Connection failed — ${_client?.connectionStatus?.state}',
      );
      connectionStatus.value = MqttConnectionStatus.error;
      _client?.disconnect();
      return false;
    }
  }

  /// Disconnect from MQTT broker.
  void disconnect() {
    _autoReconnect = false;
    _messageSubscription?.cancel();
    _messageSubscription = null;

    if (_client != null) {
      LoggerHelper.i('MQTT: Disconnecting...');
      _client!.disconnect();
    }

    connectionStatus.value = MqttConnectionStatus.disconnected;
    subscribedTopics.clear();
  }

  /// Check if connected
  bool get isConnected =>
      connectionStatus.value == MqttConnectionStatus.connected;

  // ═══════════════════════════════════════════════════════════
  //  SUBSCRIBE / UNSUBSCRIBE
  // ═══════════════════════════════════════════════════════════

  /// Subscribe to a specific topic.
  /// [qos] default: At Least Once.
  void subscribe(String topic, {MqttQos qos = MqttQos.atLeastOnce}) {
    if (!isConnected) {
      LoggerHelper.w('MQTT: Cannot subscribe — not connected');
      return;
    }

    if (subscribedTopics.contains(topic)) {
      LoggerHelper.w('MQTT: Already subscribed to "$topic"');
      return;
    }

    _client!.subscribe(topic, qos);
    subscribedTopics.add(topic);
    _persistTopics();

    LoggerHelper.i('MQTT: Subscribed to "$topic"');
  }

  /// Subscribe to multiple topics at once.
  void subscribeMany(List<String> topics, {MqttQos qos = MqttQos.atLeastOnce}) {
    for (final topic in topics) {
      subscribe(topic, qos: qos);
    }
  }

  /// Unsubscribe from a specific topic.
  void unsubscribe(String topic) {
    if (!isConnected) {
      LoggerHelper.w('MQTT: Cannot unsubscribe — not connected');
      return;
    }

    if (!subscribedTopics.contains(topic)) {
      LoggerHelper.w('MQTT: Not subscribed to "$topic"');
      return;
    }

    _client!.unsubscribe(topic);
    subscribedTopics.remove(topic);
    _topicListeners.remove(topic);
    _persistTopics();

    LoggerHelper.i('MQTT: Unsubscribed from "$topic"');
  }

  /// Unsubscribe from all topics.
  void unsubscribeAll() {
    final topics = List<String>.from(subscribedTopics);
    for (final topic in topics) {
      unsubscribe(topic);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  LISTENERS (per-topic & global)
  // ═══════════════════════════════════════════════════════════

  /// Add a specific listener for a topic.
  ///
  /// ```dart
  /// mqttService.addTopicListener('chat/room1', (topic, payload) {
  ///   print('New message: $payload');
  /// });
  /// ```
  void addTopicListener(String topic, MqttMessageCallback callback) {
    _topicListeners.putIfAbsent(topic, () => []);
    _topicListeners[topic]!.add(callback);
  }

  /// Remove a specific listener from a topic.
  void removeTopicListener(String topic, MqttMessageCallback callback) {
    _topicListeners[topic]?.remove(callback);
    if (_topicListeners[topic]?.isEmpty ?? false) {
      _topicListeners.remove(topic);
    }
  }

  /// Remove all listeners from a topic.
  void clearTopicListeners(String topic) {
    _topicListeners.remove(topic);
  }

  /// Add a global listener — called for all incoming messages.
  void addGlobalListener(MqttMessageCallback callback) {
    _globalListeners.add(callback);
  }

  /// Remove global listener.
  void removeGlobalListener(MqttMessageCallback callback) {
    _globalListeners.remove(callback);
  }

  // ═══════════════════════════════════════════════════════════
  //  PUBLISH
  // ═══════════════════════════════════════════════════════════

  /// Publish a message to a specific topic.
  ///
  /// ```dart
  /// mqttService.publish('chat/room1', '{"message": "Hello!"}');
  /// ```
  void publish(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atLeastOnce,
    bool retain = false,
  }) {
    if (!isConnected) {
      LoggerHelper.w('MQTT: Cannot publish — not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    _client!.publishMessage(topic, qos, builder.payload!, retain: retain);

    LoggerHelper.d('MQTT: Published to "$topic" → $message');
  }

  // ═══════════════════════════════════════════════════════════
  //  PERSISTENCE (SecureStorage)
  // ═══════════════════════════════════════════════════════════

  /// Save list of active topics to SecureStorage (JSON encoded).
  Future<void> _persistTopics() async {
    final topicList = subscribedTopics.toList();
    await _secureStorage.write(
      SecureStorageKey.mqttTopic,
      jsonEncode(topicList),
    );
  }

  /// Restore and re-subscribe to all topics saved in SecureStorage.
  Future<void> restoreSubscriptions() async {
    final raw = await _secureStorage.read(SecureStorageKey.mqttTopic);
    if (raw == null || raw.isEmpty) return;

    try {
      final List<dynamic> topics = jsonDecode(raw);
      for (final topic in topics) {
        if (topic is String && topic.isNotEmpty) {
          subscribe(topic);
        }
      }
      LoggerHelper.i('MQTT: Restored ${topics.length} subscriptions');
    } catch (e) {
      LoggerHelper.w('MQTT: Failed to restore subscriptions — $e');
    }
  }

  /// Clear all topics from SecureStorage.
  Future<void> clearPersistedTopics() async {
    await _secureStorage.delete(SecureStorageKey.mqttTopic);
  }

  // ═══════════════════════════════════════════════════════════
  //  INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Listen to the incoming message stream and dispatch to listeners.
  void _listenMessages() {
    _messageSubscription?.cancel();

    _messageSubscription = _client!.updates!.listen((
      List<MqttReceivedMessage<MqttMessage>> messages,
    ) {
      for (final msg in messages) {
        final topic = msg.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(
          (msg.payload as MqttPublishMessage).payload.message,
        );

        LoggerHelper.d('MQTT ← [$topic] $payload');

        // Dispatch to global listeners
        for (final listener in _globalListeners) {
          listener(topic, payload);
        }

        // Dispatch to topic-specific listeners
        // Check for exact match and wildcard match
        for (final entry in _topicListeners.entries) {
          if (_topicMatches(entry.key, topic)) {
            for (final listener in entry.value) {
              listener(topic, payload);
            }
          }
        }
      }
    });
  }

  /// Wildcard topic matching support (#+)
  bool _topicMatches(String pattern, String topic) {
    if (pattern == topic) return true;

    final patternParts = pattern.split('/');
    final topicParts = topic.split('/');

    for (int i = 0; i < patternParts.length; i++) {
      if (patternParts[i] == '#') return true; // multi-level wildcard
      if (i >= topicParts.length) return false;
      if (patternParts[i] != '+' && patternParts[i] != topicParts[i]) {
        return false; // '+' = single-level wildcard
      }
    }

    return patternParts.length == topicParts.length;
  }

  // ─── Connection Callbacks ──────────────────────────────────

  void _onConnected() {
    LoggerHelper.i('MQTT: ✅ Connected');
    connectionStatus.value = MqttConnectionStatus.connected;
  }

  void _onDisconnected() {
    LoggerHelper.w('MQTT: ❌ Disconnected');
    connectionStatus.value = MqttConnectionStatus.disconnected;
    subscribedTopics.clear();

    if (_autoReconnect) {
      LoggerHelper.i(
        'MQTT: Will auto-reconnect in ${_reconnectDelay.inSeconds}s...',
      );
    }
  }

  void _onAutoReconnect() {
    LoggerHelper.i('MQTT: 🔄 Auto-reconnecting...');
    connectionStatus.value = MqttConnectionStatus.connecting;
  }

  void _onAutoReconnected() {
    LoggerHelper.i('MQTT: ✅ Auto-reconnected');
    connectionStatus.value = MqttConnectionStatus.connected;
  }

  void _onSubscribed(String topic) {
    LoggerHelper.d('MQTT: ✅ Subscribed confirmation → "$topic"');
  }

  void _onUnsubscribed(String? topic) {
    LoggerHelper.d('MQTT: 🗑️ Unsubscribed confirmation → "$topic"');
  }

  // ─── Lifecycle ──────────────────────────────────────────────

  @override
  void onClose() {
    disconnect();
    _topicListeners.clear();
    _globalListeners.clear();
    super.onClose();
  }
}
