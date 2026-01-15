abstract interface class ISaveRepository {
  Future<bool> save(String key, Map<String, dynamic> data);

  Future<Map<String, dynamic>?> load(String key);

  Future<bool> delete(String key);

  Future<bool> clear();

  Future<bool> exists(String key);

  Future<List<String>> listKeys();
}
