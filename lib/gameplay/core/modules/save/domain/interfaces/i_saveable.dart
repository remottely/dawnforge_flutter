/// Interface for objects that can be saved and loaded.
///
/// Implement this interface in managers or components that need
/// to persist their state across game sessions.
///
/// **Example Implementation:**
/// ```dart
/// class PlayerStateManager implements ISaveable<PlayerSaveData> {
///   @override
///   PlayerSaveData toSaveData() {
///     return PlayerSaveData(
///       health: _health,
///       maxHealth: _maxHealth,
///       // ... other fields
///     );
///   }
///
///   @override
///   void fromSaveData(PlayerSaveData data) {
///     _health = data.health;
///     _maxHealth = data.maxHealth;
///     // ... restore other fields
///   }
/// }
/// ```
abstract interface class ISaveable<T> {
  /// Converts the current state to a save data model.
  ///
  /// This method should collect all persistent state and return
  /// a strongly-typed save data object.
  ///
  /// **Thread-safe:** Implementation should be thread-safe
  /// **Throws:** Should not throw, return default values on error
  T toSaveData();

  /// Restores state from a save data model.
  ///
  /// This method should update the current state with values
  /// from the provided save data object.
  ///
  /// **Parameters:**
  /// - [data]: The save data to restore from
  ///
  /// **Thread-safe:** Implementation should be thread-safe
  /// **Throws:** Should not throw, log errors instead
  void fromSaveData(T data);
}

/// Interface for managers that can reset to initial state.
///
/// Useful for starting a new game or clearing corrupted data.
abstract interface class IResettable {
  /// Resets this manager to its initial state.
  ///
  /// This should clear all data and restore default values.
  ///
  /// **Warning:** This operation cannot be undone!
  void reset();
}

/// Interface for managers that can validate their state.
///
/// Useful for detecting corrupted data before saving or after loading.
abstract interface class IValidatable {
  /// Validates that the current state is valid.
  ///
  /// Returns `true` if the state is valid and ready to be saved,
  /// `false` if the state is corrupted or invalid.
  ///
  /// **Example checks:**
  /// - Required fields are not null
  /// - Numeric values are within valid ranges
  /// - Collections are not corrupted
  bool validate();
}

/// Combines all save-related interfaces for complete manager support.
///
/// Use this interface for managers that need full save/load functionality
/// with validation and reset capabilities.
///
/// **Example:**
/// ```dart
/// class WorldStateManager implements ISaveableManager<WorldSaveData> {
///   @override
///   WorldSaveData toSaveData() => WorldSaveData(/* ... */);
///
///   @override
///   void fromSaveData(WorldSaveData data) { /* ... */ }
///
///   @override
///   void reset() { /* restore defaults */ }
///
///   @override
///   bool validate() { /* check state */ }
/// }
/// ```
abstract interface class ISaveableManager<T>
    implements ISaveable<T>, IResettable, IValidatable {}
