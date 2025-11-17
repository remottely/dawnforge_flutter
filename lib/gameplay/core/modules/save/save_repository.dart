import 'save_repository_native.dart'
    if (dart.library.html) 'save_repository_web.dart'
    as platform;

/// Abstract repository for game save data persistence.
///
/// Provides a platform-agnostic interface for save/load operations.
/// Automatically selects the correct implementation based on the platform:
/// - Web: Uses `localStorage`
/// - Native (Desktop/Mobile): Uses `SharedPreferences`
///
/// Example usage:
/// ```dart
/// final repo = SaveRepository();
/// await repo.save('player_data', {'name': 'Hero', 'level': 5});
/// final data = await repo.load('player_data');
/// ```
abstract class SaveRepository {
  /// Creates a platform-specific implementation of [SaveRepository].
  ///
  /// Returns [SaveRepositoryWeb] when running on web platform,
  /// otherwise returns [SaveRepositoryNative] for desktop/mobile.
  factory SaveRepository() {
    return platform.createRepository();
  }

  /// Saves data to persistent storage.
  ///
  /// [key] - Unique identifier for the data
  /// [data] - Map to be serialized and saved
  ///
  /// Returns `true` if save was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final success = await repo.save('player', {'hp': 100});
  /// ```
  Future<bool> save(String key, Map<String, dynamic> data);

  /// Loads data from persistent storage.
  ///
  /// [key] - Unique identifier for the data
  ///
  /// Returns the deserialized Map, or `null` if the key doesn't exist
  /// or an error occurred.
  ///
  /// Example:
  /// ```dart
  /// final data = await repo.load('player');
  /// if (data != null) {
  ///   print('HP: ${data['hp']}');
  /// }
  /// ```
  Future<Map<String, dynamic>?> load(String key);

  /// Deletes a specific key from persistent storage.
  ///
  /// [key] - Unique identifier for the data to delete
  ///
  /// Returns `true` if deletion was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await repo.delete('old_save');
  /// ```
  Future<bool> delete(String key);

  /// Clears all game-related data from persistent storage.
  ///
  /// Only removes keys with the game prefix ('darkness_dungeon_').
  /// Other application data is preserved.
  ///
  /// Returns `true` if clear was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// await repo.clear(); // Removes all game saves
  /// ```
  Future<bool> clear();
}
