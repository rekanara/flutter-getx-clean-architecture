import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeApp();

  var initialRoute = await Routes.initialRoute;
  runApp(Main(initialRoute));
}

Future<void> _initializeApp() async {
  try {
    await dotenv.load(fileName: ".env");
    await GetStorage.init();
  } catch (e) {
    rethrow;
  } finally {
    debugPrint('=== App Initialization Completed ===');
  }
}

class Main extends StatelessWidget {
  final String initialRoute;
  Main(this.initialRoute);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(initialRoute: initialRoute, getPages: Nav.routes);
  }
}
