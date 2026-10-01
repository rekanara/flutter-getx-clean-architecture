import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../platform/storage/get_storage_impl.dart';

class LocalizationService extends GetxService {
  final GetStorageImpl _storage;

  LocalizationService(this._storage);

  static const fallbackLocale = Locale('en', 'US');

  final langs = ['English', 'Indonesian'];
  final locales = [const Locale('en', 'US'), const Locale('id', 'ID')];

  Locale get activeLocale {
    final langCode = _storage.read<String>(StorageValue.languageCode);
    if (langCode == null) return Get.deviceLocale ?? fallbackLocale;

    return _getLocaleFromLanguageCode(langCode);
  }

  void changeLocale(String langCode) {
    final locale = _getLocaleFromLanguageCode(langCode);
    Get.updateLocale(locale);
    _storage.write(StorageValue.languageCode, langCode);
  }

  Locale _getLocaleFromLanguageCode(String langCode) {
    for (int i = 0; i < langs.length; i++) {
      if (langCode == locales[i].languageCode) return locales[i];
    }
    return fallbackLocale;
  }
}
