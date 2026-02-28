import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../utils/helper/logger.dart';
import '../notifications/notifications.dart';

/// Background message handler — HARUS top-level function (bukan method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  LoggerHelper.d('FCM Background: ${message.messageId}');
  _processMessage(message);
}

/// Service untuk mengelola Firebase Cloud Messaging (FCM).
///
/// Fitur:
/// - Request permission (iOS)
/// - Listen foreground, background, dan terminated messages
/// - Parse notification title/body + JSON payload
/// - Route ke `ShowNotificationHelper` berdasarkan field `type` di payload
/// - Expose FCM token (observable)
class FirebaseMessagingService extends GetxController {
  late final FirebaseMessaging _messaging;

  /// FCM token saat ini (observable)
  final RxString fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _messaging = FirebaseMessaging.instance;
  }

  /// Inisialisasi lengkap FCM: permission, token, dan message listeners.
  Future<void> init() async {
    try {
      // 1. Request permission (khusus iOS, Android otomatis granted)
      await _requestPermission();

      // 2. Dapatkan FCM Token
      await _getToken();

      // 3. Dapatkan APNs Token
      await getApnsToken();

      // 4. Listen token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        LoggerHelper.i('FCM: 🔑 Token refreshed');
        // TODO: Kirim token baru ke backend jika diperlukan
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

  /// Mendapatkan token terbaru (force refresh dari server).
  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    final token = await _messaging.getToken();
    if (token != null) {
      fcmToken.value = token;
    }
    return token;
  }

  // ═══════════════════════════════════════════════════════════
  //  TOPIC SUBSCRIBE (FCM Topics — berbeda dari MQTT)
  // ═══════════════════════════════════════════════════════════

  /// Subscribe ke FCM topic (untuk broadcast push notification).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    LoggerHelper.i('FCM: Subscribed to topic "$topic"');
  }

  /// Unsubscribe dari FCM topic.
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

    // ── User tapped notification (app dari background) ──
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

  /// Handle ketika user tap notifikasi — bisa navigasi ke halaman tertentu.
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String?;

    LoggerHelper.d('FCM Tap: type=$type, data=$data');

    // TODO: Tambahkan navigasi berdasarkan type
    // Contoh:
    // if (type == 'order') Get.toNamed(Routes.orderDetail, arguments: data);
  }
}

// ═══════════════════════════════════════════════════════════
//  PROCESS MESSAGE (shared between foreground & background)
// ═══════════════════════════════════════════════════════════

/// Parse dan tampilkan notifikasi dari RemoteMessage.
///
/// Struktur yang di-expect:
/// - `message.notification.title` → Judul notifikasi
/// - `message.notification.body` → Body singkat
/// - `message.data` → JSON payload berisi:
///   - `type` → Menentukan `NotificationType` (order, chat, payment, dll)
///   - field lain sesuai kebutuhan
void _processMessage(RemoteMessage message) {
  final notification = message.notification;
  final data = message.data;

  // Parse title & body
  final title = notification?.title ?? data['title'] ?? 'Notification';
  final body = notification?.body ?? data['body'] ?? '';

  // Parse type dari data payload
  final typeStr = data['type'] as String? ?? 'general';
  final type = _parseNotificationType(typeStr);

  // Parse summary (opsional)
  final summary = data['summary'] as String?;

  // Parse icon (opsional)
  final iconUrl = data['icon_url'] as String?;

  // Payload untuk navigasi saat user tap
  final payload = <String, String>{};
  for (final entry in data.entries) {
    payload[entry.key] = entry.value.toString();
  }

  LoggerHelper.d('FCM: Showing notification → type=$typeStr, title=$title');

  // Tampilkan menggunakan ShowNotificationHelper yang sudah ada
  ShowNotificationHelper.showNotification(
    type: type,
    title: title,
    body: body,
    summary: summary,
    iconUrl: iconUrl,
    payload: payload,
  );
}

/// Map string `type` dari JSON ke `NotificationType` enum.
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
