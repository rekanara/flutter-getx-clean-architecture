import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/navigation/routes.dart';

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
    'notification(${notificationResponse.id}) action tapped: '
    '${notificationResponse.actionId} with'
    ' payload: ${notificationResponse.payload}',
  );
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
      'notification action tapped with input: ${notificationResponse.input}',
    );
  }
}

class NotificationsHelper {
  // prevent making instance
  NotificationsHelper._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// initialize local notifications service, create channels
  static Future<void> init() async {
    await _initNotification();
  }

  static Future<void> _initNotification() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final List<DarwinNotificationCategory> darwinNotificationCategories =
        <DarwinNotificationCategory>[
          DarwinNotificationCategory(
            darwinNotificationCategoryText,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.text(
                'text_1',
                'Action 1',
                buttonTitle: 'Send',
                placeholder: 'Placeholder',
              ),
            ],
          ),
          DarwinNotificationCategory(
            darwinNotificationCategoryPlain,
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Action 1'),
              DarwinNotificationAction.plain(
                'id_2',
                'Action 2 (destructive)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.destructive,
                },
              ),
              DarwinNotificationAction.plain(
                navigationActionId,
                'Action 3 (foreground)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.foreground,
                },
              ),
              DarwinNotificationAction.plain(
                'id_4',
                'Action 4 (auth required)',
                options: <DarwinNotificationActionOption>{
                  DarwinNotificationActionOption.authenticationRequired,
                },
              ),
            ],
            options: <DarwinNotificationCategoryOption>{
              DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
            },
          ),
        ];

    // iOS initialization settings
    IOSInitializationSettings iosSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: darwinNotificationCategories,
    );

    InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: NotificationController.onActionReceived,
      onDidReceiveBackgroundNotificationResponse:
          NotificationController.onBackgroundActionReceived,
    );

    // Create Android notification channels
    await _createChannels();

    // Request permissions for Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> _createChannels() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    final channels = [
      _buildChannel(
        key: NotificationChannels.generalChannelKey,
        name: NotificationChannels.generalChannelName,
        description: NotificationChannels.generalChannelDescription,
      ),
      _buildChannel(
        key: NotificationChannels.chatChannelKey,
        name: NotificationChannels.chatChannelName,
        description: NotificationChannels.chatChannelDescription,
      ),
      _buildChannel(
        key: NotificationChannels.orderChannelKey,
        name: NotificationChannels.orderChannelName,
        description: NotificationChannels.orderChannelDescription,
      ),
      _buildChannel(
        key: NotificationChannels.ticketChannelKey,
        name: NotificationChannels.ticketChannelName,
        description: NotificationChannels.ticketChannelDescription,
      ),
      _buildChannel(
        key: NotificationChannels.adsChannelKey,
        name: NotificationChannels.adsChannelName,
        description: NotificationChannels.adsChannelDescription,
      ),
      _buildChannel(
        key: NotificationChannels.marketingChannelKey,
        name: NotificationChannels.marketingChannelName,
        description: NotificationChannels.marketingChannelDescription,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  static AndroidNotificationChannel _buildChannel({
    required String key,
    required String name,
    required String description,
  }) {
    return AndroidNotificationChannel(
      key,
      name,
      description: description,
      importance: Importance.max,
      playSound: true,
      showBadge: true,
      ledColor: Colors.white,
    );
  }

  /// Show notification
  static Future<void> showNotification({
    required String title,
    required String body,
    required int id,
    String? channelKey,
    String? groupKey,
    String? customSound,
    bool isBigText = false,
    bool isBigPicture = false,
    String? summary,
    Map<String, String>? payload,
    String? largeIcon,
    String? bigPicture,
  }) async {
    final channel = channelKey ?? NotificationChannels.generalChannelKey;

    StyleInformation? styleInformation;
    if (isBigPicture && bigPicture != null) {
      styleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicture),
        largeIcon: largeIcon != null ? FilePathAndroidBitmap(largeIcon) : null,
        contentTitle: title,
        summaryText: summary ?? body,
      );
    } else if (isBigText) {
      styleInformation = BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: summary,
      );
    }

    final androidDetails = AndroidNotificationDetails(
      channel,
      _channelName(channel),
      channelDescription: _channelDescription(channel),
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      showWhen: true,
      autoCancel: true,
      groupKey: groupKey,
      subText: summary,
      styleInformation: styleInformation,
      sound: customSound != null
          ? RawResourceAndroidNotificationSound(customSound)
          : null,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadString = payload != null ? jsonEncode(payload) : null;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payloadString,
    );
  }

  static String _channelName(String key) {
    switch (key) {
      case 'chat_channel':
        return NotificationChannels.chatChannelName;
      case 'order_channel':
        return NotificationChannels.orderChannelName;
      case 'ticket_channel':
        return NotificationChannels.ticketChannelName;
      case 'ads_channel':
        return NotificationChannels.adsChannelName;
      case 'marketing_channel':
        return NotificationChannels.marketingChannelName;
      default:
        return NotificationChannels.generalChannelName;
    }
  }

  static String _channelDescription(String key) {
    switch (key) {
      case 'chat_channel':
        return NotificationChannels.chatChannelDescription;
      case 'order_channel':
        return NotificationChannels.orderChannelDescription;
      case 'ticket_channel':
        return NotificationChannels.ticketChannelDescription;
      case 'ads_channel':
        return NotificationChannels.adsChannelDescription;
      case 'marketing_channel':
        return NotificationChannels.marketingChannelDescription;
      default:
        return NotificationChannels.generalChannelDescription;
    }
  }
}

class NotificationController {
  /// Handle notification tap (foreground + background)
  static void onActionReceived(NotificationResponse response) {
    _handlePayload(response.payload);
  }

  /// Handle notification tap from background/terminated
  @pragma('vm:entry-point')
  static void onBackgroundActionReceived(NotificationResponse response) {
    _handlePayload(response.payload);
  }

  static void _handlePayload(String? rawPayload) {
    if (rawPayload == null) return;

    Map<String, dynamic> payload = {};
    try {
      payload = jsonDecode(rawPayload);
    } catch (_) {
      return;
    }

    final type = payload['type'] as String?;
    Map<String, dynamic> data = {};

    if (payload['data'] != null) {
      try {
        data = jsonDecode(payload['data'] as String);
      } catch (_) {}
    }

    String route;
    Map<String, dynamic>? args;

    switch (type) {
      case 'order':
        route = Routes.home;
        args = {'ticket_id': data['ticket_id']};
        break;
      default:
        route = Routes.login;
        args = {'refresh': true};
        break;
    }

    Get.key.currentState?.pushNamed(route, arguments: args);
  }
}

class NotificationChannels {
  // chat channel
  static String get chatChannelKey => "chat_channel";
  static String get chatChannelName => "Chat channel";
  static String get chatGroupKey => "chat_group_key";
  static String get chatChannelDescription => "Chat notifications channel";

  // order channel
  static String get orderChannelKey => "order_channel";
  static String get orderChannelName => "Order channel";
  static String get orderGroupKey => "order_group_key";
  static String get orderChannelDescription => "Order notifications channel";

  // ticket channel
  static String get ticketChannelKey => "ticket_channel";
  static String get ticketChannelName => "Ticket channel";
  static String get ticketGroupKey => "ticket_group_key";
  static String get ticketChannelDescription => "Ticket notifications channel";

  // ads channel
  static String get adsChannelKey => "ads_channel";
  static String get adsChannelName => "Ads channel";
  static String get adsGroupKey => "ads_group_key";
  static String get adsChannelDescription => "Ads notifications channel";

  // marketing channel
  static String get marketingChannelKey => "marketing_channel";
  static String get marketingChannelName => "Marketing channel";
  static String get marketingGroupKey => "marketing_group_key";
  static String get marketingChannelDescription =>
      "Marketing notifications channel";

  // general channel
  static String get generalChannelKey => "general_channel";
  static String get generalGroupKey => "general_group_key";
  static String get generalChannelName => "General notifications channel";
  static String get generalChannelDescription =>
      "Notification channel for general notifications";
}

class ShowNotificationHelper {
  static Future<void> showNotification({
    required NotificationType type,
    String? title,
    required String body,
    String? summary,
    String? iconUrl,
    Map<String, String>? payload,
  }) async {
    final id = DateTime.now().second;

    final localPath = iconUrl != null
        ? await NotificationImageHelper.downloadToTemp(iconUrl)
        : null;

    switch (type) {
      case NotificationType.order:
        NotificationsHelper.showNotification(
          id: id,
          channelKey: NotificationChannels.orderChannelKey,
          groupKey: NotificationChannels.orderGroupKey,
          title: title ?? 'New Order',
          summary: summary,
          body: body,
          payload: payload,
          isBigText: true,
        );
        break;

      case NotificationType.alert:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'Information',
          summary: summary,
          body: body,
          payload: payload,
          channelKey: NotificationChannels.generalChannelKey,
        );
        break;

      case NotificationType.system:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'System',
          summary: summary,
          body: body,
          payload: payload,
          channelKey: NotificationChannels.generalChannelKey,
        );
        break;

      case NotificationType.chat:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'New Message',
          summary: summary,
          body: body,
          payload: payload,
          channelKey: NotificationChannels.chatChannelKey,
          groupKey: NotificationChannels.chatGroupKey,
          isBigText: true,
        );
        break;

      case NotificationType.other:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'Notification',
          summary: summary,
          body: body,
          payload: payload,
          channelKey: NotificationChannels.generalChannelKey,
        );
        break;

      case NotificationType.payment:
        NotificationsHelper.showNotification(
          id: id,
          channelKey: NotificationChannels.generalChannelKey,
          title: title ?? 'Payment',
          summary: summary,
          body: body,
          payload: payload,
        );
        break;

      case NotificationType.ticket:
        NotificationsHelper.showNotification(
          id: id,
          channelKey: NotificationChannels.ticketChannelKey,
          groupKey: NotificationChannels.ticketGroupKey,
          title: title ?? 'New Ticket',
          summary: summary,
          body: body,
          payload: payload,
          isBigText: true,
        );
        break;

      case NotificationType.ads:
        NotificationsHelper.showNotification(
          id: id,
          channelKey: NotificationChannels.adsChannelKey,
          groupKey: NotificationChannels.adsGroupKey,
          title: title ?? 'New Advertisement',
          summary: summary,
          body: body,
          payload: payload,
        );
        break;

      case NotificationType.marketing:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'Marketing',
          summary: summary,
          body: body,
          largeIcon: localPath,
          isBigPicture: localPath != null,
          bigPicture: localPath,
          payload: payload,
          channelKey: NotificationChannels.marketingChannelKey,
          groupKey: NotificationChannels.marketingGroupKey,
        );
        break;

      case NotificationType.general:
        NotificationsHelper.showNotification(
          id: id,
          title: title ?? 'Notification',
          summary: summary,
          body: body,
          payload: payload,
          channelKey: NotificationChannels.generalChannelKey,
        );
        break;
    }
  }
}

class NotificationImageHelper {
  NotificationImageHelper._();

  static const int _maxAgeDays = 7;
  static const String _prefix = 'notif_img_';

  /// Download image from URL to temp directory.
  /// Returns local file path, or null if failed.
  static Future<String?> downloadToTemp(String imageUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();

      // Cleanup old images before downloading
      await _cleanOldImages(tempDir);

      final fileName = '$_prefix${imageUrl.hashCode}.jpg';
      final file = File('${tempDir.path}/$fileName');

      // Return cached file if already exists
      if (await file.exists()) return file.path;

      // Gunakan DioClient.download (secara default noAuthClient, kecuali ditaruh parameter secureStorage)
      final response = await DioClient.download(
        url: imageUrl,
        savePath: file.path,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Hapus file jika gagal
        if (await file.exists()) {
          await file.delete();
        }
        return null;
      }

      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Delete temp images older than 7 days.
  static Future<void> _cleanOldImages(Directory tempDir) async {
    try {
      final now = DateTime.now();

      final files = tempDir.listSync().whereType<File>().where(
        (f) => f.path.contains(_prefix),
      );

      for (final file in files) {
        final stat = await file.stat();
        final age = now.difference(stat.modified);

        if (age.inDays >= _maxAgeDays) {
          await file.delete();
        }
      }
    } catch (_) {
      // Silently fail — cleanup is not critical
    }
  }
}

enum NotificationType {
  order,
  alert,
  system,
  chat,
  payment,
  ticket,
  ads,
  marketing,
  other,
  general,
}
