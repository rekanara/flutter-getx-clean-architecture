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

  @override
  Future<void> delete(String key) async {
    await box.remove(key);
  }

  @override
  Future<void> clear() async {
    await box.erase();
  }
}

class StorageValue {
  // APP
  static const String appVersion = 'app_version';
  static const String appBuildNumber = 'app_build_number';

  // ENV
  static const String env = 'env';

  // THEME
  static const String themeIsLight = 'theme_is_light';

  // AUTH
  static const String accessToken = 'access_token';
}
