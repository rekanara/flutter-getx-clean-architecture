import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../platform/storage/get_storage_impl.dart';

// ─── Environment Enum ────────────────────────────────────────

/// Enum untuk tipe environment yang tersedia.
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

/// Typed class untuk semua konfigurasi per-environment.
/// Menggantikan Map&lt;String, String&gt; agar compile-time safe.
class EnvironmentConfig {
  final Environment env;
  final String appName;
  final String jwt;

  // ── Services ──
  final String sso;
  final String billing;
  final String odp;
  final String homepass;
  final String transaction;
  final String nextune;
  final String nexadmin;
  final String nexads;
  final String nexpayment;
  final String nexreward;
  final String cdn;
  final String fe;
  final String app;

  // ── FZ ──
  final String fzAdmin;
  final String fzContent;
  final String fzCdn;
  final String fzTncPp;

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
    required this.sso,
    required this.billing,
    required this.odp,
    required this.homepass,
    required this.transaction,
    required this.nextune,
    required this.nexadmin,
    required this.nexads,
    required this.nexpayment,
    required this.nexreward,
    required this.cdn,
    required this.fe,
    required this.app,
    required this.fzAdmin,
    required this.fzContent,
    required this.fzCdn,
    required this.fzTncPp,
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

/// Controller untuk mengelola environment aktif secara reaktif.
class EnvironmentController extends GetxController {
  final Rx<Environment> currentEnv = Environment.dev.obs;

  @override
  void onInit() {
    super.onInit();
    _initEnvFromStorage();
  }

  void _initEnvFromStorage() {
    final storage = GetStorageImpl();
    final storedEnvStr = storage.read<String>(StorageValue.env);

    if (storedEnvStr == null || storedEnvStr.isEmpty) {
      // Jika kosong, write ke storage berdasarkan currentEnv saat ini.
      storage.write(StorageValue.env, currentEnv.value.label);
    } else {
      // Jika ada isi, update currentEnv berdasarkan nilai di storage.
      final savedEnv = Environment.values.firstWhere(
        (e) => e.label == storedEnvStr,
        orElse: () => Environment.dev, // Fallback jika string tidak cocok
      );
      currentEnv.value = savedEnv;
    }
  }

  /// Switch environment secara runtime dan simpan state barunya ke storage.
  void switchEnvironment(Environment env) {
    currentEnv.value = env;
    GetStorageImpl().write(StorageValue.env, env.label);
  }
}

// ─── Config Environments ────────────────────────────────────

/// Menyediakan konfigurasi environment berdasarkan environment aktif.
///
/// Semua value dibaca dari `.env` file dan di-cast ke [EnvironmentConfig].
class ConfigEnvironments {
  static final EnvironmentController _controller = Get.put(
    EnvironmentController(),
  );

  /// Environment yang sedang aktif.
  static Environment get current => _controller.currentEnv.value;

  /// Mendapatkan konfigurasi untuk environment aktif.
  static EnvironmentConfig get config {
    return _configs.firstWhere((c) => c.env == current);
  }

  static final List<EnvironmentConfig> _configs = [
    // ── DEV ──
    EnvironmentConfig(
      env: Environment.dev,
      appName: dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      jwt: dotenv.env['JWT_SECRET']!,
      sso: dotenv.env['NEX_SSO_DEV']!,
      billing: dotenv.env['NEX_BILL_MASTER_DEV']!,
      odp: dotenv.env['NEX_ODP_DEV']!,
      homepass: dotenv.env['NEX_HOMEPASS_DEV']!,
      transaction: dotenv.env['NEX_TRANSACTION_DEV']!,
      nextune: dotenv.env['NEX_NEXTUNE_DEV']!,
      nexadmin: dotenv.env['NEX_ADMIN_DEV']!,
      nexads: dotenv.env['NEX_ADS_DEV']!,
      nexpayment: dotenv.env['NEX_PAYMENT_DEV']!,
      nexreward: dotenv.env['NEX_REWARD_DEV']!,
      cdn: dotenv.env['CDN_DEV']!,
      fe: dotenv.env['NEX_FE_DEV']!,
      app: dotenv.env['NEX_APP_DEV']!,
      fzAdmin: dotenv.env['FZ_ADMIN_DEV']!,
      fzContent: dotenv.env['FZ_CONTENT_DEV']!,
      fzCdn: dotenv.env['FZ_CDN_DEV']!,
      fzTncPp: dotenv.env['FZ_TNCPP_DEV']!,
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
      sso: dotenv.env['NEX_SSO_STAGING']!,
      billing: dotenv.env['NEX_BILL_MASTER_STAGING']!,
      odp: dotenv.env['NEX_ODP_STAGING']!,
      homepass: dotenv.env['NEX_HOMEPASS_STAGING']!,
      transaction: dotenv.env['NEX_TRANSACTION_STAGING']!,
      nextune: dotenv.env['NEX_NEXTUNE_STAGING']!,
      nexadmin: dotenv.env['NEX_ADMIN_STAGING']!,
      nexads: dotenv.env['NEX_ADS_STAGING']!,
      nexpayment: dotenv.env['NEX_PAYMENT_STAGING']!,
      nexreward: dotenv.env['NEX_REWARD_STAGING']!,
      cdn: dotenv.env['CDN_STAGING']!,
      fe: dotenv.env['NEX_FE_STAGING']!,
      app: dotenv.env['NEX_APP_STAGING']!,
      fzAdmin: dotenv.env['FZ_ADMIN_PROD']!,
      fzContent: dotenv.env['FZ_CONTENT_PROD']!,
      fzCdn: dotenv.env['FZ_CDN_PROD']!,
      fzTncPp: dotenv.env['FZ_TNCPP_PROD']!,
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
      sso: dotenv.env['NEX_SSO_PROD']!,
      billing: dotenv.env['NEX_BILL_MASTER_PROD']!,
      odp: dotenv.env['NEX_ODP_PROD']!,
      homepass: dotenv.env['NEX_HOMEPASS_PROD']!,
      transaction: dotenv.env['NEX_TRANSACTION_PROD']!,
      nextune: dotenv.env['NEX_NEXTUNE_PROD']!,
      nexadmin: dotenv.env['NEX_ADMIN_PROD']!,
      nexads: dotenv.env['NEX_ADS_PROD']!,
      nexpayment: dotenv.env['NEX_PAYMENT_PROD']!,
      nexreward: dotenv.env['NEX_REWARD_PROD']!,
      cdn: dotenv.env['CDN_PROD']!,
      fe: dotenv.env['NEX_FE_PROD']!,
      app: dotenv.env['NEX_APP_PROD']!,
      fzAdmin: dotenv.env['FZ_ADMIN_PROD']!,
      fzContent: dotenv.env['FZ_CONTENT_PROD']!,
      fzCdn: dotenv.env['FZ_CDN_PROD']!,
      fzTncPp: dotenv.env['FZ_TNCPP_PROD']!,
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
