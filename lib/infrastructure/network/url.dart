import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/state_manager.dart';

import 'environments.dart';

class UrlDomain extends GetxController {
  final appCastUrlAndroid = dotenv.env['URL_APPCAST_ANDROID']!.obs;
  final appCastUrlIos = dotenv.env['URL_APPCAST_IOS']!.obs;

  final appName = ConfigEnvironments().getEnvironments()['appName']!.obs;
  final jwt = ConfigEnvironments().getEnvironments()['jwt']!.obs;
  final sso = ConfigEnvironments().getEnvironments()['sso']!.obs;
  final billing = ConfigEnvironments().getEnvironments()['billing']!.obs;
  final odp = ConfigEnvironments().getEnvironments()['odp']!.obs;
  final homepass = ConfigEnvironments().getEnvironments()['homepass']!.obs;
  final transaction = ConfigEnvironments()
      .getEnvironments()['transaction']!
      .obs;
  final nextune = ConfigEnvironments().getEnvironments()['nextune']!.obs;
  final nexadmin = ConfigEnvironments().getEnvironments()['nexadmin']!.obs;
  final nexads = ConfigEnvironments().getEnvironments()['nexads']!.obs;
  final nexpayment = ConfigEnvironments().getEnvironments()['nexpayment']!.obs;
  final nexreward = ConfigEnvironments().getEnvironments()['nexreward']!.obs;
  final cdn = ConfigEnvironments().getEnvironments()['cdn']!.obs;
  final fe = ConfigEnvironments().getEnvironments()['fe']!.obs;
  final app = ConfigEnvironments().getEnvironments()['app']!.obs;
  final fzAdmin = ConfigEnvironments().getEnvironments()['fzAdmin']!.obs;
  final fzContent = ConfigEnvironments().getEnvironments()['fzContent']!.obs;
  final fzCdn = ConfigEnvironments().getEnvironments()['fzCdn']!.obs;
  final fzTncPp = ConfigEnvironments().getEnvironments()['fzTncPp']!.obs;

  /// ---------------------------------------- MQTT ---------------------------------------- ///
  final mtqqBrokerUrl = ConfigEnvironments()
      .getEnvironments()['mtqqBrokerUrl']!
      .obs;
  final mtqqBrokerPort = int.parse(
    ConfigEnvironments().getEnvironments()['mtqqBrokerPort']!,
  ).obs;
  final mtqqClientId = ConfigEnvironments()
      .getEnvironments()['mtqqClientId']!
      .obs;
  final mtqqUsername = ConfigEnvironments()
      .getEnvironments()['mtqqUsername']!
      .obs;
  final mtqqPassword = ConfigEnvironments()
      .getEnvironments()['mtqqPassword']!
      .obs;

  final firebaseProjectId = ConfigEnvironments()
      .getEnvironments()['firebaseProjectId']!
      .obs;
  final firebaseStorageBucket = ConfigEnvironments()
      .getEnvironments()['firebaseStorageBucket']!
      .obs;

  final firebaseMessagingSenderId = ConfigEnvironments()
      .getEnvironments()['firebaseMessagingSenderId']!
      .obs;
  final firebaseBundleId = ConfigEnvironments()
      .getEnvironments()['firebaseBundleId']!
      .obs;

  final firebaseAndroidApiKey = ConfigEnvironments()
      .getEnvironments()['firebaseAndroidApiKey']!
      .obs;
  final firebaseAndroidAppId = ConfigEnvironments()
      .getEnvironments()['firebaseAndroidAppId']!
      .obs;
  final firebaseIosApiKey = ConfigEnvironments()
      .getEnvironments()['firebaseIosApiKey']!
      .obs;
  final firebaseIosAppId = ConfigEnvironments()
      .getEnvironments()['firebaseIosAppId']!
      .obs;
}

class PathDomain extends GetxController {
  final banner = '/assets/banner/'.obs;
  final v1 = '/v1'.obs;
  final v2 = '/v2'.obs;
  final api = '/api'.obs;
  final nexbill = '/nexbill'.obs;
  final nexads = '/nexads'.obs;
  final public = '/public'.obs;
}

class Domain extends GetxController {
  final backendSSO =
      (UrlDomain().sso + PathDomain().api.value + PathDomain().v1.value).obs;
  final backendBilling =
      (UrlDomain().billing + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final backendOdp =
      (UrlDomain().odp + PathDomain().api.value + PathDomain().v1.value).obs;
  final backendHomepass =
      (UrlDomain().homepass + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final backendTransaction =
      (UrlDomain().transaction + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final nextune =
      (UrlDomain().nextune + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final nexadmin =
      (UrlDomain().nexadmin + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final nexads =
      (UrlDomain().nexads + PathDomain().api.value + PathDomain().v1.value).obs;
  final nexpayment =
      (UrlDomain().nexpayment + PathDomain().api.value + PathDomain().v1.value)
          .obs;
  final nexreward =
      (UrlDomain().nexreward + PathDomain().api.value + PathDomain().v1.value)
          .obs;

  /// ---------------------------------------- CDN ---------------------------------------- ///

  final cdnNexBillPackages =
      ('${UrlDomain().cdn + PathDomain().nexbill.value}/packages').obs;
  final cdnNexAds = (UrlDomain().cdn + PathDomain().nexads.value).obs;

  /// ---------------------------------------- FZ ---------------------------------------- ///
  final backendFzAdmin =
      (UrlDomain().fzAdmin + PathDomain().api.value + PathDomain().v2.value)
          .obs;
  final backendFzContent =
      (UrlDomain().fzContent +
              PathDomain().v1.value +
              PathDomain().public.value +
              PathDomain().api.value)
          .obs;
  final backendFzCdn = (UrlDomain().fzCdn).obs;
}

class URL extends GetxController {
  /// ---------------------------------------- SSO ---------------------------------------- ///
  final login = "${Domain().backendSSO}/auth/login".obs;

  /// ---------------------------------------- Nexadmin ---------------------------------------- ///
  final banners = "${Domain().nexadmin}/banners".obs;
  //customer-detail
  final customerDetail = "${Domain().backendBilling}/customer-details/me".obs;
}
