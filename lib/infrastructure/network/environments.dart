import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

class Environments {
  static const String PRODUCTION = 'prod';
  static const String STAGING = 'staging';
  static const String DEV = 'dev';
  // static const String LOCAL = 'local';
}

class DomainController extends GetxController {
  final env = Environments.DEV.obs;

  @override
  void onInit() {
    super.onInit();
  }
}

class ConfigEnvironments extends GetxController {
  DomainController domainController = Get.put(DomainController());
  // static const String _currentEnvironments = Environments.DEV;
  final List<Map<String, String>> _availableEnvironments = [
    {
      'env': Environments.DEV,
      'appName': dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      'jwt': dotenv.env['JWT_SECRET']!,
      'sso': dotenv.env['NEX_SSO_DEV']!,
      'billing': dotenv.env['NEX_BILL_MASTER_DEV']!,
      'odp': dotenv.env['NEX_ODP_DEV']!,
      'homepass': dotenv.env['NEX_HOMEPASS_DEV']!,
      'transaction': dotenv.env['NEX_TRANSACTION_DEV']!,
      'nextune': dotenv.env['NEX_NEXTUNE_DEV']!,
      'nexadmin': dotenv.env['NEX_ADMIN_DEV']!,
      'nexads': dotenv.env['NEX_ADS_DEV']!,
      'nexpayment': dotenv.env['NEX_PAYMENT_DEV']!,
      'nexreward': dotenv.env['NEX_REWARD_DEV']!,
      'cdn': dotenv.env['CDN_DEV']!,
      'fe': dotenv.env['NEX_FE_DEV']!,
      'app': dotenv.env['NEX_APP_DEV']!,
      'fzAdmin': dotenv.env['FZ_ADMIN_DEV']!,
      'fzContent': dotenv.env['FZ_CONTENT_DEV']!,
      'fzCdn': dotenv.env['FZ_CDN_DEV']!,
      'fzTncPp': dotenv.env['FZ_TNCPP_DEV']!,
      'mtqqBrokerUrl': dotenv.env['MQTT_BROKER_URL_DEV']!,
      'mtqqBrokerPort': dotenv.env['MQTT_BROKER_PORT_DEV']!,
      'mtqqClientId': dotenv.env['MQTT_CLIENT_ID_DEV']!,
      'mtqqUsername': dotenv.env['MQTT_USERNAME_DEV']!,
      'mtqqPassword': dotenv.env['MQTT_PASSWORD_DEV']!,
      'firebaseProjectId': dotenv.env['FIREBASE_PROJECT_ID_DEV']!,
      'firebaseStorageBucket': dotenv.env['FIREBASE_STORAGE_BUCKET_DEV']!,
      'firebaseBundleId': dotenv.env['FIREBASE_BUNDLE_ID_DEV']!,
      'firebaseMessagingSenderId':
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID_DEV']!,
      'firebaseAndroidApiKey': dotenv.env['ANDROID_FIREBASE_API_KEY_DEV']!,
      'firebaseAndroidAppId': dotenv.env['ANDROID_FIREBASE_APPID_DEV']!,
      'firebaseIosApiKey': dotenv.env['IOS_FIREBASE_API_KEY_DEV']!,
      'firebaseIosAppId': dotenv.env['IOS_FIREBASE_APPID_DEV']!,
    },
    {
      'env': Environments.STAGING,
      'appName': dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      'jwt': dotenv.env['JWT_SECRET']!,
      'sso': dotenv.env['NEX_SSO_STAGING']!,
      'billing': dotenv.env['NEX_BILL_MASTER_STAGING']!,
      'odp': dotenv.env['NEX_ODP_STAGING']!,
      'homepass': dotenv.env['NEX_HOMEPASS_STAGING']!,
      'transaction': dotenv.env['NEX_TRANSACTION_STAGING']!,
      'nextune': dotenv.env['NEX_NEXTUNE_STAGING']!,
      'nexadmin': dotenv.env['NEX_ADMIN_STAGING']!,
      'nexads': dotenv.env['NEX_ADS_STAGING']!,
      'nexpayment': dotenv.env['NEX_PAYMENT_STAGING']!,
      'nexreward': dotenv.env['NEX_REWARD_STAGING']!,
      'cdn': dotenv.env['CDN_STAGING']!,
      'fe': dotenv.env['NEX_FE_STAGING']!,
      'app': dotenv.env['NEX_APP_STAGING']!,
      'fzAdmin': dotenv.env['FZ_ADMIN_PROD']!,
      'fzContent': dotenv.env['FZ_CONTENT_PROD']!,
      'fzCdn': dotenv.env['FZ_CDN_PROD']!,
      'fzTncPp': dotenv.env['FZ_TNCPP_PROD']!,
      'mtqqBrokerUrl': dotenv.env['MQTT_BROKER_URL_STAGING']!,
      'mtqqBrokerPort': dotenv.env['MQTT_BROKER_PORT_STAGING']!,
      'mtqqClientId': dotenv.env['MQTT_CLIENT_ID_STAGING']!,
      'mtqqUsername': dotenv.env['MQTT_USERNAME_STAGING']!,
      'mtqqPassword': dotenv.env['MQTT_PASSWORD_STAGING']!,
      'firebaseProjectId': dotenv.env['FIREBASE_PROJECT_ID_STAGING']!,
      'firebaseStorageBucket': dotenv.env['FIREBASE_STORAGE_BUCKET_STAGING']!,
      'firebaseBundleId': dotenv.env['FIREBASE_BUNDLE_ID_STAGING']!,
      'firebaseMessagingSenderId':
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID_STAGING']!,
      'firebaseAndroidApiKey': dotenv.env['ANDROID_FIREBASE_API_KEY_STAGING']!,
      'firebaseAndroidAppId': dotenv.env['ANDROID_FIREBASE_APPID_STAGING']!,
      'firebaseIosApiKey': dotenv.env['IOS_FIREBASE_API_KEY_STAGING']!,
      'firebaseIosAppId': dotenv.env['IOS_FIREBASE_APPID_STAGING']!,
    },
    {
      'env': Environments.PRODUCTION,
      'appName': dotenv.env['NEX_APP_NAME'] ?? 'Nexus',
      'jwt': dotenv.env['JWT_SECRET']!,
      'sso': dotenv.env['NEX_SSO_PROD']!,
      'billing': dotenv.env['NEX_BILL_MASTER_PROD']!,
      'odp': dotenv.env['NEX_ODP_PROD']!,
      'homepass': dotenv.env['NEX_HOMEPASS_PROD']!,
      'transaction': dotenv.env['NEX_TRANSACTION_PROD']!,
      'nextune': dotenv.env['NEX_NEXTUNE_PROD']!,
      'nexadmin': dotenv.env['NEX_ADMIN_PROD']!,
      'nexads': dotenv.env['NEX_ADS_PROD']!,
      'nexpayment': dotenv.env['NEX_PAYMENT_PROD']!,
      'nexreward': dotenv.env['NEX_REWARD_PROD']!,
      'cdn': dotenv.env['CDN_PROD']!,
      'fe': dotenv.env['NEX_FE_PROD']!,
      'app': dotenv.env['NEX_APP_PROD']!,
      'fzAdmin': dotenv.env['FZ_ADMIN_PROD']!,
      'fzContent': dotenv.env['FZ_CONTENT_PROD']!,
      'fzCdn': dotenv.env['FZ_CDN_PROD']!,
      'fzTncPp': dotenv.env['FZ_TNCPP_PROD']!,
      'mtqqBrokerUrl': dotenv.env['MQTT_BROKER_URL_PROD']!,
      'mtqqBrokerPort': dotenv.env['MQTT_BROKER_PORT_PROD']!,
      'mtqqClientId': dotenv.env['MQTT_CLIENT_ID_PROD']!,
      'mtqqUsername': dotenv.env['MQTT_USERNAME_PROD']!,
      'mtqqPassword': dotenv.env['MQTT_PASSWORD_PROD']!,
      'firebaseProjectId': dotenv.env['FIREBASE_PROJECT_ID']!,
      'firebaseStorageBucket': dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      'firebaseMessagingSenderId': dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      'firebaseBundleId': dotenv.env['FIREBASE_BUNDLE_ID']!,
      'firebaseAndroidApiKey': dotenv.env['ANDROID_FIREBASE_API_KEY']!,
      'firebaseAndroidAppId': dotenv.env['ANDROID_FIREBASE_APPID']!,
      'firebaseIosApiKey': dotenv.env['IOS_FIREBASE_API_KEY']!,
      'firebaseIosAppId': dotenv.env['IOS_FIREBASE_APPID']!,
    },
  ];

  Map<String, String> getEnvironments() {
    return _availableEnvironments.firstWhere(
      (d) => d['env'] == domainController.env.value,
    );
  }
}
