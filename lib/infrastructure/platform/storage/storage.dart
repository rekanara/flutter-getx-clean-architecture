// platform/storage/storage.dart
abstract class Storage {
  Future<void> write(String key, dynamic value);
  T? read<T>(String key);
}
