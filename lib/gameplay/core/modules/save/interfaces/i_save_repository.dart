/// Interface for persistent storage of game save data.
///
/// This abstraction allows different implementations for different platforms
/// (web, mobile, desktop) without changing the business logic.
///
/// **Implementations:**
/// - `SaveRepositoryNative`: Uses SharedPreferences for desktop/mobile
/// - `SaveRepositoryWeb`: Uses localStorage for web
///
/// **Design Pattern:** Repository Pattern
///
/// **Example:**
/// ```dart
/// class SaveManager {
///   final ISaveRepository _repository;
///
///   SaveManager(this._repository);
///
///   Future<bool> saveGame(SaveData data) async {
///     return await _repository.save('main_save', data.toJson());
///   }
/// }
/// ```
abstract interface class ISaveRepository {
  /// Saves data to persistent storage.
  ///
  /// **Parameters:**
  /// - [key]: Unique identifier for the save data
  /// - [data]: Map containing serialized game state
  ///
  /// **Returns:** `true` if save succeeded, `false` otherwise
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<bool> save(String key, Map<String, dynamic> data);

  /// Loads data from persistent storage.
  ///
  /// **Parameters:**
  /// - [key]: Unique identifier for the save data
  ///
  /// **Returns:** Deserialized map if found, `null` if not found or error
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<Map<String, dynamic>?> load(String key);

  /// Deletes specific save data.
  ///
  /// **Parameters:**
  /// - [key]: Unique identifier for the save data to delete
  ///
  /// **Returns:** `true` if deletion succeeded, `false` otherwise
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<bool> delete(String key);

  /// Clears all game-related data.
  ///
  /// Only removes keys with the game prefix.
  /// Other application data is preserved.
  ///
  /// **Returns:** `true` if clear succeeded, `false` otherwise
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<bool> clear();

  /// Checks if a specific key exists in storage.
  ///
  /// **Parameters:**
  /// - [key]: Unique identifier to check
  ///
  /// **Returns:** `true` if key exists, `false` otherwise
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<bool> exists(String key);

  /// Lists all game-related save keys.
  ///
  /// **Returns:** List of save keys (empty list if none found)
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  Future<List<String>> listKeys();
}
