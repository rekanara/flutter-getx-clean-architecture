import 'package:firebase_core/firebase_core.dart';

import '../../utils/helper/logger.dart';
import 'firebase_options.dart';

/// Service to initialize Firebase.
///
/// Call `FirebaseService.init()` in `main.dart` before
/// using Firebase Messaging or Remote Config.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Initialize Firebase App.
  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      LoggerHelper.i('Firebase: ✅ Initialized');
    } catch (e, stack) {
      LoggerHelper.e('Firebase: ❌ Initialization failed', e, stack);
      rethrow;
    }
  }
}
