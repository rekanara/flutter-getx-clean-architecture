import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/helper/logger.dart';

/// Centralized Error Handler for the entire application.
///
/// Handles:
/// - **Flutter Framework Errors** (rendering, layout, gesture)
/// - **Uncaught Async Errors** (unhandled Future exceptions)
/// - **Isolate Errors** (errors in background isolates)
///
/// In `kDebugMode` → errors logged to console.
/// In release → ready to be connected to Crashlytics / Sentry.
///
/// **Usage:**
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

  /// Initialize all error handlers and run the app inside `runZonedGuarded`.
  ///
  /// [appRunner] is a function containing all initialization and `runApp()`.
  static void init(Future<void> Function() appRunner) {
    // 1. Flutter Framework Errors (rendering, layout, gesture, etc.)
    FlutterError.onError = _handleFlutterError;

    // 2. Uncaught Async Errors (unhandled Future exceptions)
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // 3. Run app inside runZonedGuarded as an additional safety net
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
    // In debug mode, show standard Flutter error page (red screen)
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
    // Return true = error already handled, do not crash app
    return true;
  }

  /// Handle errors escaping the Zone (last safety net)
  static void _handleZoneError(Object error, StackTrace stack) {
    _reportError(error, stack, reason: 'Uncaught Zone Error');
  }

  // ═══════════════════════════════════════════════════════════
  //  ERROR REPORTING
  // ═══════════════════════════════════════════════════════════

  /// Central method to report errors.
  ///
  /// In debug → log to console via LoggerHelper.
  /// In release → send to crash reporting service.
  ///
  /// **For Crashlytics integration**, replace the content of this method:
  /// ```dart
  /// FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  /// ```
  static void _reportError(
    Object error,
    StackTrace? stack, {
    String? reason,
    String? context,
  }) {
    // ── Log to console ──
    final label = reason ?? 'Unknown Error';
    LoggerHelper.e(
      '[$label]${context != null ? ' ($context)' : ''}',
      error,
      stack,
    );

    // ── Send to Crash Reporting (release mode) ──
    if (!kDebugMode) {
      // TODO: Replace with your preferred crash reporting service:
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

  /// Public method to report errors manually from anywhere in the app.
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
      // TODO: Send to analytics/crash reporting:
      //   FirebaseCrashlytics.instance.log(message);
    }
  }
}
