import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../config/flavor/flavor_service.dart';
import '../platform/storage/get_storage_impl.dart';
import '../platform/storage/storage.dart';

// ─── Environment Enum ────────────────────────────────────────

/// Enum for available environment types.
enum Environment {
  dev('dev', Colors.purple),
  staging('staging', Colors.orange),
  prod('prod', Colors.transparent);

  final String label;
  final Color badgeColor;

  const Environment(this.label, this.badgeColor);

  bool get isProduction => this == Environment.prod;
}

// ─── Environment Config (typed) ──────────────────────────────

/// Typed class for all per-environment configurations.
/// Replaces `Map<String, String>` to be compile-time safe.
class EnvironmentConfig {
  final Environment env;
  final String appName;
  final String jwt;

  // ── Services ──
  final String be;
  final String cdn;
  final String fe;

  // ── MQTT ──
  final String mqttBrokerUrl;
  final int mqttBrokerPort;
  final String mqttClientId;
  final String mqttUsername;
  final String mqttPassword;

  // ── Firebase ──
  final String firebaseProjectId;
  final String firebaseStorageBucket;
  final String firebaseBundleId;
  final String firebaseMessagingSenderId;
  final String firebaseAndroidApiKey;
  final String firebaseAndroidAppId;
  final String firebaseIosApiKey;
  final String firebaseIosAppId;

  const EnvironmentConfig({
    required this.env,
    required this.appName,
    required this.jwt,
    required this.be,
    required this.cdn,
    required this.fe,
    required this.mqttBrokerUrl,
    required this.mqttBrokerPort,
    required this.mqttClientId,
    required this.mqttUsername,
    required this.mqttPassword,
    required this.firebaseProjectId,
    required this.firebaseStorageBucket,
    required this.firebaseBundleId,
    required this.firebaseMessagingSenderId,
    required this.firebaseAndroidApiKey,
    required this.firebaseAndroidAppId,
    required this.firebaseIosApiKey,
    required this.firebaseIosAppId,
  });
}

// ─── Environment Controller ─────────────────────────────────

/// Controller to manage the active environment reactively.
class EnvironmentController extends GetxController {
  EnvironmentController({Storage? storage})
    : _storage = storage ?? GetStorageImpl();

  final Storage _storage;
  final Rx<Environment> currentEnv = Environment.dev.obs;

  @override
  void onInit() {
    super.onInit();
    _initEnvFromStorage();
  }

  void _initEnvFromStorage() {
    // Flavor lock: a native flavor (staging/prod) always wins over storage.
    final locked = FlavorService.lockedEnvironment;
    if (locked != null) {
      currentEnv.value = locked;
      _storage.write(StorageValue.env, locked.label);
      return;
    }

    final storedEnvStr = _storage.read<String>(StorageValue.env);

    if (storedEnvStr == null || storedEnvStr.isEmpty) {
      // If empty, write to storage based on current currentEnv.
      _storage.write(StorageValue.env, currentEnv.value.label);
    } else {
      // If not empty, update currentEnv based on the value in storage.
      final savedEnv = Environment.values.firstWhere(
        (e) => e.label == storedEnvStr,
        orElse: () => Environment.dev, // Fallback if string does not match
      );
      // Never allow a stored env outside the flavor's allowed set.
      currentEnv.value = FlavorService.allowedEnvironments.contains(savedEnv)
          ? savedEnv
          : Environment.dev;
    }
  }

  /// Switch environment at runtime and save its new state to storage.
  ///
  /// Silently ignored when the current flavor does not allow the target
  /// environment (e.g. dev flavor attempting to switch to prod).
  void switchEnvironment(Environment env) {
    if (!FlavorService.allowedEnvironments.contains(env)) return;
    currentEnv.value = env;
    _storage.write(StorageValue.env, env.label);
  }
}

// ─── Config Environments ────────────────────────────────────

/// Provides environment configurations based on the active environment.
///
/// All values are read from the `.env` file and cast to [EnvironmentConfig].
class ConfigEnvironments {
  static final EnvironmentController _controller = Get.put(
    EnvironmentController(),
  );

  /// The currently active environment.
  static Environment get current => _controller.currentEnv.value;

  /// Gets the configuration for the active environment.
  static EnvironmentConfig get config {
    return _configs.firstWhere((c) => c.env == current);
  }

  static final List<EnvironmentConfig> _configs = [
    // ── DEV ──
    EnvironmentConfig(
      env: Environment.dev,
      appName: dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      jwt: dotenv.env['JWT_SECRET']!,
      be: dotenv.env['NEX_BE_DEV']!,
      cdn: dotenv.env['CDN_DEV']!,
      fe: dotenv.env['NEX_FE_DEV']!,
      mqttBrokerUrl: dotenv.env['MQTT_BROKER_URL_DEV']!,
      mqttBrokerPort: int.parse(dotenv.env['MQTT_BROKER_PORT_DEV']!),
      mqttClientId: dotenv.env['MQTT_CLIENT_ID_DEV']!,
      mqttUsername: dotenv.env['MQTT_USERNAME_DEV']!,
      mqttPassword: dotenv.env['MQTT_PASSWORD_DEV']!,
      firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID_DEV']!,
      firebaseStorageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_DEV']!,
      firebaseBundleId: dotenv.env['FIREBASE_BUNDLE_ID_DEV']!,
      firebaseMessagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID_DEV']!,
      firebaseAndroidApiKey: dotenv.env['ANDROID_FIREBASE_API_KEY_DEV']!,
      firebaseAndroidAppId: dotenv.env['ANDROID_FIREBASE_APPID_DEV']!,
      firebaseIosApiKey: dotenv.env['IOS_FIREBASE_API_KEY_DEV']!,
      firebaseIosAppId: dotenv.env['IOS_FIREBASE_APPID_DEV']!,
    ),

    // ── STAGING ──
    EnvironmentConfig(
      env: Environment.staging,
      appName: dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      jwt: dotenv.env['JWT_SECRET']!,
      be: dotenv.env['NEX_BE_STAGING']!,
      cdn: dotenv.env['CDN_STAGING']!,
      fe: dotenv.env['NEX_FE_STAGING']!,
      mqttBrokerUrl: dotenv.env['MQTT_BROKER_URL_STAGING']!,
      mqttBrokerPort: int.parse(dotenv.env['MQTT_BROKER_PORT_STAGING']!),
      mqttClientId: dotenv.env['MQTT_CLIENT_ID_STAGING']!,
      mqttUsername: dotenv.env['MQTT_USERNAME_STAGING']!,
      mqttPassword: dotenv.env['MQTT_PASSWORD_STAGING']!,
      firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID_STAGING']!,
      firebaseStorageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET_STAGING']!,
      firebaseBundleId: dotenv.env['FIREBASE_BUNDLE_ID_STAGING']!,
      firebaseMessagingSenderId:
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID_STAGING']!,
      firebaseAndroidApiKey: dotenv.env['ANDROID_FIREBASE_API_KEY_STAGING']!,
      firebaseAndroidAppId: dotenv.env['ANDROID_FIREBASE_APPID_STAGING']!,
      firebaseIosApiKey: dotenv.env['IOS_FIREBASE_API_KEY_STAGING']!,
      firebaseIosAppId: dotenv.env['IOS_FIREBASE_APPID_STAGING']!,
    ),

    // ── PRODUCTION ──
    EnvironmentConfig(
      env: Environment.prod,
      appName: dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      jwt: dotenv.env['JWT_SECRET']!,
      be: dotenv.env['NEX_BE_PROD']!,
      cdn: dotenv.env['CDN_PROD']!,
      fe: dotenv.env['NEX_FE_PROD']!,
      mqttBrokerUrl: dotenv.env['MQTT_BROKER_URL_PROD']!,
      mqttBrokerPort: int.parse(dotenv.env['MQTT_BROKER_PORT_PROD']!),
      mqttClientId: dotenv.env['MQTT_CLIENT_ID_PROD']!,
      mqttUsername: dotenv.env['MQTT_USERNAME_PROD']!,
      mqttPassword: dotenv.env['MQTT_PASSWORD_PROD']!,
      firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      firebaseStorageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      firebaseBundleId: dotenv.env['FIREBASE_BUNDLE_ID']!,
      firebaseMessagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      firebaseAndroidApiKey: dotenv.env['ANDROID_FIREBASE_API_KEY']!,
      firebaseAndroidAppId: dotenv.env['ANDROID_FIREBASE_APPID']!,
      firebaseIosApiKey: dotenv.env['IOS_FIREBASE_API_KEY']!,
      firebaseIosAppId: dotenv.env['IOS_FIREBASE_APPID']!,
    ),
  ];
}
