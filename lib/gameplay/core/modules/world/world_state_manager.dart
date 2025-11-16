import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/time/time_of_day.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/map_state_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/season.dart';

/// Singleton manager for world state
///
/// Manages the global state of the game world including:
/// - Current day and season
/// - Time of day
/// - Active map states
final class WorldStateManager {
  WorldStateManager._();

  /// Singleton instance
  static final instance = WorldStateManager._();

  // ========== STATE ==========

  /// Current day in the game (starts at 1)
  int _currentDay = 1;

  /// Current season
  Season _currentSeason = Season.spring;

  /// Current time of day
  TimeOfDay _timeOfDay = TimeOfDay.morning;

  /// ID of the currently active map
  String? _currentMapId;

  /// Cache of active map states
  final Map<String, MapState> _activeMapStates = {};

  // ========== GETTERS ==========

  /// Get current day
  int get currentDay => _currentDay;

  /// Get current season
  Season get currentSeason => _currentSeason;

  /// Get current time of day
  TimeOfDay get timeOfDay => _timeOfDay;

  /// Get current map ID
  String? get currentMapId => _currentMapId;

  /// Get number of active maps in cache
  int get activeMapCount => _activeMapStates.length;

  // ========== SETTERS ==========

  /// Set current map ID
  void setCurrentMap(String mapId) {
    developer.log('[WorldStateManager] Setting current map: $mapId');
    _currentMapId = mapId;
  }

  /// Set time of day
  void setTimeOfDay(TimeOfDay time) {
    if (_timeOfDay != time) {
      developer.log(
        '[WorldStateManager] Time of day changed: $_timeOfDay -> $time',
      );
      _timeOfDay = time;
    }
  }

  // ========== DAY/SEASON MANAGEMENT ==========

  /// Advance to the next day
  ///
  /// Updates current day and recalculates season if necessary
  void advanceDay() {
    _currentDay++;
    final previousSeason = _currentSeason;
    _currentSeason = getSeasonForDay(_currentDay);

    developer.log('[WorldStateManager] Advanced to day $_currentDay');

    if (previousSeason != _currentSeason) {
      developer.log(
        '[WorldStateManager] Season changed: $previousSeason -> $_currentSeason',
      );
    }
  }

  /// Calculate season for a given day
  ///
  /// Each season lasts 28 days:
  /// - Spring: Days 1-28
  /// - Summer: Days 29-56
  /// - Fall: Days 57-84
  /// - Winter: Days 85-112
  /// - Then cycles back to Spring
  Season getSeasonForDay(int day) {
    final seasonIndex = ((day - 1) ~/ 28) % 4;
    return Season.values[seasonIndex];
  }

  // ========== MAP STATE MANAGEMENT ==========

  /// Get state for a specific map
  MapState? getMapState(String mapId) {
    return _activeMapStates[mapId];
  }

  /// Set state for a specific map
  void setMapState(String mapId, MapState state) {
    developer.log('[WorldStateManager] Setting map state for: $mapId');
    _activeMapStates[mapId] = state;
  }

  /// Unload maps that are not the current active map
  ///
  /// This helps manage memory by removing inactive map states
  void unloadInactiveMaps() {
    if (_currentMapId == null) {
      developer.log(
        '[WorldStateManager] No current map, clearing all cached maps',
      );
      _activeMapStates.clear();
      return;
    }

    final initialCount = _activeMapStates.length;
    _activeMapStates.removeWhere((mapId, _) => mapId != _currentMapId);
    final removedCount = initialCount - _activeMapStates.length;

    if (removedCount > 0) {
      developer.log(
        '[WorldStateManager] Unloaded $removedCount inactive map(s)',
      );
    }
  }

  // ========== SERIALIZATION ==========

  /// Serialize world state to JSON
  Map<String, dynamic> toJson() {
    return {
      'currentDay': _currentDay,
      'currentSeason': _currentSeason.toJson(),
      'timeOfDay': _timeOfDay.toJson(),
      'currentMapId': _currentMapId,
      'mapStates': _activeMapStates.map(
        (mapId, state) => MapEntry(mapId, state.toJson()),
      ),
    };
  }

  /// Deserialize world state from JSON
  void fromJson(Map<String, dynamic> json) {
    developer.log('[WorldStateManager] Loading world state from JSON');

    _currentDay = json['currentDay'] as int? ?? 1;
    _currentSeason = Season.fromJson(
      json['currentSeason'] as String? ?? 'spring',
    );
    _timeOfDay = TimeOfDay.fromJson(json['timeOfDay'] as String? ?? 'morning');
    _currentMapId = json['currentMapId'] as String?;

    // Load map states
    _activeMapStates.clear();
    final mapStatesJson = json['mapStates'] as Map<String, dynamic>?;
    if (mapStatesJson != null) {
      for (var entry in mapStatesJson.entries) {
        _activeMapStates[entry.key] = MapState.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    developer.log(
      '[WorldStateManager] Loaded: Day $_currentDay, Season: $_currentSeason, '
      'Maps: ${_activeMapStates.length}',
    );
  }

  /// Reset world state to initial values
  void reset() {
    developer.log('[WorldStateManager] Resetting world state');
    _currentDay = 1;
    _currentSeason = Season.spring;
    _timeOfDay = TimeOfDay.morning;
    _currentMapId = null;
    _activeMapStates.clear();
  }

  @override
  String toString() =>
      'WorldState(Day: $_currentDay, Season: $_currentSeason, '
      'Time: $_timeOfDay, Map: $_currentMapId)';
}
