// platform/storage/get_storage_impl.dart
import 'package:get_storage/get_storage.dart';
import 'storage.dart';

class GetStorageImpl implements Storage {
  final box = GetStorage();

  @override
  Future<void> write(String key, value) async {
    await box.write(key, value);
  }

  @override
  T? read<T>(String key) {
    return box.read<T>(key);
  }
}

class StorageValue {
  // APP
  static const String appVersion = 'app_version';
  static const String appBuildNumber = 'app_build_number';

  // THEME
  static const String themeIsLight = 'theme_is_light';

  // AUTH
  static const String accessToken = 'access_token';
}
