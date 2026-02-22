import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'config/notifications/notifications.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'package:chucker_flutter/chucker_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();

  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
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

    /// Initialize Notifications
    await NotificationsHelper.init();
  } catch (e) {
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
