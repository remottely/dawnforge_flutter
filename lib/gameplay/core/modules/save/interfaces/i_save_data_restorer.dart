import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';

/// Interface for restoring game state from save data.
///
/// Implementations of this interface handle the restoration of game state
/// from a [SaveData] object back to the individual managers.
///
/// **Design Pattern:** Strategy Pattern
///
/// **Example:**
/// ```dart
/// class DefaultSaveDataRestorer implements ISaveDataRestorer {
///   @override
///   bool restoreGameState(SaveData saveData) {
///     if (!saveData.isValid()) return false;
///
///     PlayerStateManager.instance.fromJson(saveData.playerData);
///     WorldStateManager.instance.fromJson(saveData.worldData);
///     // ... restore to other managers
///
///     return true;
///   }
/// }
/// ```
abstract interface class ISaveDataRestorer {
  /// Restores game state from [SaveData] to all managers.
  ///
  /// This method should:
  /// 1. Validate the save data
  /// 2. Call `fromJson()` on all relevant managers
  /// 3. Handle any migration if needed
  ///
  /// **Parameters:**
  /// - [saveData]: The save data to restore from
  ///
  /// **Returns:** `true` if restoration succeeded, `false` otherwise
  ///
  /// **Thread-safe:** No (call from main thread only)
  /// **Throws:** Never (catches all errors internally)
  bool restoreGameState(SaveData saveData);

  /// Resets all managers to their initial/default state.
  ///
  /// Useful for starting a new game or clearing corrupted data.
  ///
  /// **Warning:** This permanently clears all game progress!
  ///
  /// **Thread-safe:** No (call from main thread only)
  /// **Throws:** Never (catches all errors internally)
  void resetAllManagers();

  /// Validates save data before restoration.
  ///
  /// Checks if the save data is compatible and not corrupted.
  ///
  /// **Parameters:**
  /// - [saveData]: The save data to validate
  ///
  /// **Returns:** `true` if data is valid and safe to restore, `false` otherwise
  ///
  /// **Thread-safe:** Yes
  /// **Throws:** Never (catches all errors internally)
  bool validateSaveData(SaveData saveData);
}
