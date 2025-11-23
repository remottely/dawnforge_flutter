import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';

/// Interface for collecting game state from various managers.
///
/// Implementations of this interface are responsible for gathering data from
/// all game managers (PlayerStateManager, WorldStateManager, InventoryManager,
/// etc.) and assembling it into a [SaveData] object.
///
/// **Design Pattern:** Strategy Pattern
///
/// **Example:**
/// ```dart
/// class DefaultSaveDataCollector implements ISaveDataCollector {
///   @override
///   SaveData collectGameState() {
///     final playerData = PlayerStateManager.instance.toJson();
///     final worldData = WorldStateManager.instance.toJson();
///     // ... collect from other managers
///
///     return SaveData(
///       version: SaveData.kCurrentVersion,
///       timestamp: DateTime.now(),
///       playerData: playerData,
///       worldData: worldData,
///       inventoryData: inventoryData,
///     );
///   }
/// }
/// ```
abstract interface class ISaveDataCollector {
  /// Collects current game state from all managers.
  ///
  /// This method should:
  /// 1. Call `toJson()` on all relevant managers
  /// 2. Combine the data into appropriate sections
  /// 3. Create and return a [SaveData] object
  ///
  /// **Returns:** Complete game state packaged as [SaveData]
  ///
  /// **Thread-safe:** No (call from main thread only)
  /// **Throws:** May throw if managers are in invalid state
  SaveData collectGameState();

  /// Validates that all managers are in a saveable state.
  ///
  /// Performs sanity checks to ensure data is valid before collection.
  ///
  /// **Returns:** `true` if all managers have valid state, `false` otherwise
  ///
  /// **Thread-safe:** No (call from main thread only)
  /// **Throws:** Never (catches all errors internally)
  bool validateManagerStates();

  /// Gets a human-readable summary of current game state.
  ///
  /// Useful for debugging or displaying save info to players.
  ///
  /// **Returns:** Formatted string with key game state information
  ///
  /// **Thread-safe:** No (call from main thread only)
  /// **Throws:** Never (catches all errors internally)
  String getStateSummary();
}
