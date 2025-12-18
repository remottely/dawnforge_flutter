import 'implementations/save_repository_native.dart'
    if (dart.library.html) 'implementations/save_repository_web.dart'
    as platform;

abstract class SaveRepository {
  factory SaveRepository() {
    return platform.createRepository();
  }

  Future<bool> save(String key, Map<String, dynamic> data);

  Future<Map<String, dynamic>?> load(String key);

  Future<bool> delete(String key);

  Future<bool> clear();

  Future<bool> exists(String key);

  Future<List<String>> listKeys();
}
