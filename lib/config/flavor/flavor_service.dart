import 'package:meta/meta.dart';

import '../../infrastructure/network/environments.dart';

/// Compile-time flavor of the application.
///
/// The value is injected by the native build system:
/// - Android: `flutter run --flavor dev` / Gradle `productFlavors`
///   (Flutter passes `--dart-define=app.flavor=<flavor>` automatically
///   for flavors registered in build.gradle.kts).
/// - iOS: matching Xcode scheme (see docs/flavors.md for iOS plan).
///
/// When no flavor is provided (e.g. plain `dart test`), the app falls
/// back to [AppFlavor.dev] so tooling keeps working.
enum AppFlavor {
  dev('dev'),
  staging('staging'),
  prod('prod');

  final String label;

  const AppFlavor(this.label);

  static AppFlavor fromLabel(String? label) => AppFlavor.values.firstWhere(
    (f) => f.label == label,
    orElse: () => AppFlavor.dev,
  );

  bool get isProduction => this == AppFlavor.prod;
}

/// Reads the compile-time flavor and exposes the allowed [Environment] set.
///
/// Policy:
/// - prod flavor    -> locked to Environment.prod, no switching.
/// - staging flavor -> locked to Environment.staging, no switching.
/// - dev flavor     -> defaults to dev, MAY switch to staging (not prod).
class FlavorService {
  FlavorService._();

  /// Compile-time flavor, defaults to dev when unset (tests / tooling).
  static AppFlavor get flavor => _testFlavor ?? _compileTimeFlavor;

  static final AppFlavor _compileTimeFlavor = AppFlavor.fromLabel(
    const String.fromEnvironment('app.flavor'),
  );

  /// Whether the runtime environment switcher may be shown at all.
  static bool get canSwitchEnv => flavor == AppFlavor.dev;

  /// Environments allowed for this flavor, in UI order.
  static List<Environment> get allowedEnvironments {
    switch (flavor) {
      case AppFlavor.dev:
        return const [Environment.dev, Environment.staging];
      case AppFlavor.staging:
        return const [Environment.staging];
      case AppFlavor.prod:
        return const [Environment.prod];
    }
  }

  /// The environment this flavor is locked to (null when switching allowed).
  static Environment? get lockedEnvironment =>
      canSwitchEnv ? null : allowedEnvironments.first;

  /// Test-only seam: override the compile-time flavor in unit tests.
  @visibleForTesting
  static void testOverride(AppFlavor? override) => _testFlavor = override;

  static AppFlavor? _testFlavor;
}
