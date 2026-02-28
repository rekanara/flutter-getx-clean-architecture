import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/error/global_error_handler.dart';
import 'config/firebase/firebase_service.dart';
import 'config/firebase/firebase_messaging_service.dart';
import 'config/firebase/remote_config_service.dart';
import 'config/lifecycle/app_lifecycle_service.dart';
import 'config/mqtt/mqtt_service.dart';
import 'config/notifications/notifications.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'utils/helper/logger.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

void main() {
  /// GlobalErrorHandler membungkus seluruh app dalam runZonedGuarded
  /// dan menangani FlutterError, PlatformDispatcher error, dan Zone error.
  GlobalErrorHandler.init(() async {
    await _initializeApp();

    /// Register FCM background handler (HARUS sebelum runApp)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    var initialRoute = await Routes.initialRoute;

    runApp(Main(initialRoute));
  });
}

Future<void> _initializeApp() async {
  try {
    /// Chucker Flutter Configuration
    ChuckerFlutter.configure(
      showOnRelease: kDebugMode,
      showNotification: kDebugMode,
      notificationAlignment: Alignment.topCenter,
      offsetBegin: const Offset(0, -0.1),
      offsetEnd: Offset.zero,
    );

    /// Load Environment Variables
    await dotenv.load(fileName: ".env");

    /// Initialize Get Storage
    await GetStorage.init();

    /// Initialize Firebase Core
    await FirebaseService.init();

    /// Initialize Notifications (local)
    await NotificationsHelper.init();

    /// Initialize Firebase Messaging (FCM)
    final fcmService = Get.put(FirebaseMessagingService(), permanent: true);
    await fcmService.init();

    /// Initialize Firebase Remote Config
    final rcService = Get.put(RemoteConfigService(), permanent: true);
    await rcService.init();

    /// Initialize MQTT Service (global singleton)
    Get.put(MqttService(), permanent: true);

    /// Initialize App Lifecycle Observer (MQTT reconnect, refresh hooks)
    Get.put(AppLifecycleService(), permanent: true);
  } catch (e, stack) {
    LoggerHelper.e('Initialization Error', e, stack);
    rethrow;
  } finally {
    debugPrint('=== App Initialization Completed ===');
  }
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: initialRoute,
      getPages: Nav.routes,
      navigatorObservers: [ChuckerFlutter.navigatorObserver],
    );
  }
}
