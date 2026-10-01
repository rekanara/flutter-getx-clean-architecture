import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../utils/helper/logger.dart';
import '../notifications/notifications.dart';

/// Background message handler — MUST be a top-level function (not a method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LoggerHelper.d('FCM Background: ${message.messageId}');
  _processMessage(message);
}

/// Service to manage Firebase Cloud Messaging (FCM).
///
/// Features:
/// - Request permission (iOS)
/// - Listen foreground, background, and terminated messages
/// - Parse notification title/body + JSON payload
/// - Route to `ShowNotificationHelper` based on `type` field in payload
/// - Expose FCM token (observable)
class FirebaseMessagingService extends GetxController {
  late final FirebaseMessaging _messaging;

  /// Current FCM token (observable)
  final RxString fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _messaging = FirebaseMessaging.instance;
  }

  /// Complete FCM initialization: permission, token, and message listeners.
  Future<void> init() async {
    try {
      // 1. Request permission (iOS only, Android is automatically granted)
      await _requestPermission();

      // 2. Get FCM Token
      await _getToken();

      // 3. Get APNs Token
      await getApnsToken();

      // 4. Listen token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        LoggerHelper.i('FCM: 🔑 Token refreshed');
        // TODO: Send new token to backend if needed
      });

      // 5. Setup message handlers
      _setupMessageHandlers();

      LoggerHelper.i('FCM: ✅ Initialized');
    } catch (e, stack) {
      LoggerHelper.e('FCM: ❌ Init failed', e, stack);
    }
  }

  // ═══════════════════════════════════════════════════════════
  //  PERMISSION
  // ═══════════════════════════════════════════════════════════

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
    );

    LoggerHelper.i('FCM: Permission status → ${settings.authorizationStatus}');
  }

  // ═══════════════════════════════════════════════════════════
  //  TOKEN
  // ═══════════════════════════════════════════════════════════

  Future<void> _getToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      fcmToken.value = token;
      LoggerHelper.i('FCM: 🔑 Token → $token');
    }
  }

  Future<void> getApnsToken() async {
    final token = await _messaging.getAPNSToken();
    if (token != null) {
      fcmToken.value = token;
      LoggerHelper.i('FCM: 🔑 APNs Token → $token');
    }
  }

  /// Get the latest token (force refresh from server).
  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    final token = await _messaging.getToken();
    if (token != null) {
      fcmToken.value = token;
    }
    return token;
  }

  // ═══════════════════════════════════════════════════════════
  //  TOPIC SUBSCRIBE (FCM Topics — different from MQTT)
  // ═══════════════════════════════════════════════════════════

  /// Subscribe to FCM topic (for broadcast push notifications).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    LoggerHelper.i('FCM: Subscribed to topic "$topic"');
  }

  /// Unsubscribe from FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    LoggerHelper.i('FCM: Unsubscribed from topic "$topic"');
  }

  // ═══════════════════════════════════════════════════════════
  //  MESSAGE HANDLERS
  // ═══════════════════════════════════════════════════════════

  void _setupMessageHandlers() {
    // ── Foreground Messages ──
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LoggerHelper.d('FCM Foreground: ${message.messageId}');
      _processMessage(message);
    });

    // ── User tapped notification (app from background) ──
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      LoggerHelper.d('FCM Opened App: ${message.messageId}');
      _handleNotificationTap(message);
    });

    // ── App launched from terminated state (cold start) ──
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      LoggerHelper.d('FCM Initial: ${initialMessage.messageId}');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle when user taps notification — can navigate to a specific page.
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    LoggerHelper.d('FCM Tap: type=$type, data=$data');

    // TODO: Add navigation based on type
    // Example:
    // if (type == 'order') Get.toNamed(Routes.orderDetail, arguments: data);
  }
}

// ═══════════════════════════════════════════════════════════
//  PROCESS MESSAGE (shared between foreground & background)
// ═══════════════════════════════════════════════════════════

/// Parse and show notification from RemoteMessage.
///
/// Expected structure:
/// - `message.notification.title` → Notification title
/// - `message.notification.body` → Short body
/// - `message.data` → JSON payload containing:
///   - `type` → Determines `NotificationType` (order, chat, payment, etc.)
///   - other fields as needed
void _processMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  // Parse title & body
  final title = notification?.title ?? data['title'] ?? 'Notification';
  final body = notification?.body ?? data['body'] ?? '';

  // Parse type from data payload
  final typeStr = data['type'] as String? ?? 'general';
  final type = _parseNotificationType(typeStr);

  // Parse summary (optional)
  final summary = data['summary'] as String?;

  // Parse icon (optional)
  final iconUrl = data['icon_url'] as String?;

  // Payload for navigation when user taps
  final payload = <String, String>{};
  for (final entry in data.entries) {
    payload[entry.key] = entry.value.toString();
  }

  LoggerHelper.d('FCM: Showing notification → type=$typeStr, title=$title');

  // Show using existing ShowNotificationHelper
  ShowNotificationHelper.showNotification(
    type: type,
    title: title,
    body: body,
    summary: summary,
    iconUrl: iconUrl,
    payload: payload,
  );
}

/// Map string `type` from JSON to `NotificationType` enum.
NotificationType _parseNotificationType(String type) {
  switch (type.toLowerCase()) {
    case 'order':
      return NotificationType.order;
    case 'alert':
      return NotificationType.alert;
    case 'system':
      return NotificationType.system;
    case 'chat':
      return NotificationType.chat;
    case 'payment':
      return NotificationType.payment;
    case 'ticket':
      return NotificationType.ticket;
    case 'ads':
      return NotificationType.ads;
    case 'marketing':
      return NotificationType.marketing;
    case 'general':
      return NotificationType.general;
    default:
      return NotificationType.other;
  }
}
