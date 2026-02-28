import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/helper/logger.dart';

/// Centralized Error Handler untuk seluruh aplikasi.
///
/// Menangani:
/// - **Flutter Framework Errors** (rendering, layout, gesture)
/// - **Uncaught Async Errors** (unhandled Future exceptions)
/// - **Isolate Errors** (error di background isolates)
///
/// Di `kDebugMode` → error dilog ke console.
/// Di release → siap disambungkan ke Crashlytics / Sentry.
///
/// **Penggunaan:**
/// ```dart
/// void main() async {
///   GlobalErrorHandler.init(() async {
///     // ... initialization code ...
///     runApp(MyApp());
///   });
/// }
/// ```
class GlobalErrorHandler {
  GlobalErrorHandler._();

  /// Inisialisasi semua error handlers dan jalankan app di dalam `runZonedGuarded`.
  ///
  /// [appRunner] adalah fungsi yang berisi semua initialization dan `runApp()`.
  static void init(Future<void> Function() appRunner) {
    // 1. Flutter Framework Errors (rendering, layout, gesture, dll.)
    FlutterError.onError = _handleFlutterError;

    // 2. Uncaught Async Errors (unhandled Future exceptions)
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // 3. Jalankan app di dalam runZonedGuarded sebagai safety net tambahan
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await appRunner();
    }, _handleZoneError);
  }

  // ═══════════════════════════════════════════════════════════
  //  ERROR HANDLERS
  // ═══════════════════════════════════════════════════════════

  /// Handle Flutter framework errors (widgets, rendering, gestures)
  static void _handleFlutterError(FlutterErrorDetails details) {
    // Di debug mode, tampilkan error page standar Flutter (red screen)
    if (kDebugMode) {
      FlutterError.presentError(details);
    }

    _reportError(
      details.exception,
      details.stack,
      reason: 'Flutter Framework Error',
      context: details.context?.toString(),
    );
  }

  /// Handle uncaught async/platform errors
  static bool _handlePlatformError(Object error, StackTrace stack) {
    _reportError(error, stack, reason: 'Uncaught Platform Error');
    // Return true = error sudah ditangani, jangan crash app
    return true;
  }

  /// Handle errors yang lolos dari Zone (safety net terakhir)
  static void _handleZoneError(Object error, StackTrace stack) {
    _reportError(error, stack, reason: 'Uncaught Zone Error');
  }

  // ═══════════════════════════════════════════════════════════
  //  ERROR REPORTING
  // ═══════════════════════════════════════════════════════════

  /// Central method untuk melaporkan error.
  ///
  /// Di debug → log ke console via LoggerHelper.
  /// Di release → kirim ke crash reporting service.
  ///
  /// **Untuk integrasi Crashlytics**, ganti isi method ini:
  /// ```dart
  /// FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  /// ```
  static void _reportError(
    Object error,
    StackTrace? stack, {
    String? reason,
    String? context,
  }) {
    // ── Log ke console ──
    final label = reason ?? 'Unknown Error';
    LoggerHelper.e(
      '[$label]${context != null ? ' ($context)' : ''}',
      error,
      stack,
    );

    // ── Kirim ke Crash Reporting (release mode) ──
    if (!kDebugMode) {
      // TODO: Ganti dengan crash reporting service pilihan:
      //
      // Firebase Crashlytics:
      //   FirebaseCrashlytics.instance.recordError(
      //     error, stack ?? StackTrace.current,
      //     reason: reason, fatal: false,
      //   );
      //
      // Sentry:
      //   Sentry.captureException(error, stackTrace: stack);
    }
  }

  /// Method publik untuk melaporkan error secara manual dari bagian app manapun.
  ///
  /// ```dart
  /// try {
  ///   // risky operation
  /// } catch (e, stack) {
  ///   GlobalErrorHandler.reportError(e, stack, reason: 'Payment Processing');
  /// }
  /// ```
  static void reportError(Object error, StackTrace? stack, {String? reason}) {
    _reportError(error, stack, reason: reason ?? 'Manual Report');
  }

  /// Log non-fatal event / breadcrumb.
  ///
  /// ```dart
  /// GlobalErrorHandler.logEvent('User tapped checkout', {'cart_items': 5});
  /// ```
  static void logEvent(String message, [Map<String, dynamic>? data]) {
    LoggerHelper.d('[Event] $message${data != null ? ' | $data' : ''}');

    if (!kDebugMode) {
      // TODO: Kirim ke analytics/crash reporting:
      //   FirebaseCrashlytics.instance.log(message);
    }
  }
}
