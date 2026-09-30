import 'package:firebase_core/firebase_core.dart';

import '../../utils/helper/logger.dart';
import 'firebase_options.dart';

/// Service untuk menginisialisasi Firebase.
///
/// Panggil `FirebaseService.init()` di `main.dart` sebelum
/// menggunakan Firebase Messaging atau Remote Config.
class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  /// Inisialisasi Firebase App.
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
