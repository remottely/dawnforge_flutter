import 'package:dawnforge/core/utils/game_logger.dart';

import 'package:dawnforge/game/systems/world/map_state_model.dart';
import 'package:dawnforge/game/systems/world/season.dart';

final class WorldStateManager {
  WorldStateManager._();

  static final WorldStateManager instance = WorldStateManager._();

  int _currentDay = 1;

  Season _currentSeason = Season.spring;

  String? _currentMapId;

  final Map<String, MapState> _activeMapStates = {};

  int get currentDay => _currentDay;

  Season get currentSeason => _currentSeason;

  String? get currentMapId => _currentMapId;

  int get activeMapCount => _activeMapStates.length;

  void setCurrentMap(String mapId) {
    GameLogger.info('[WorldStateManager] Setting current map: $mapId');
    _currentMapId = mapId;
  }

  void advanceDay() {
    _currentDay++;
    final previousSeason = _currentSeason;
    _currentSeason = getSeasonForDay(_currentDay);

    GameLogger.info('[WorldStateManager] Advanced to day $_currentDay');

    if (previousSeason != _currentSeason) {
      GameLogger.info(
        '[WorldStateManager] Season changed: $previousSeason -> $_currentSeason',
      );
    }
  }

  Season getSeasonForDay(int day) {
    final seasonIndex = ((day - 1) ~/ 28) % 4;
    return Season.values[seasonIndex];
  }

  MapState? getMapState(String mapId) {
    return _activeMapStates[mapId];
  }

  void setMapState(String mapId, MapState state) {
    GameLogger.info('[WorldStateManager] Setting map state for: $mapId');
    _activeMapStates[mapId] = state;
  }

  void unloadInactiveMaps() {
    if (_currentMapId == null) {
      GameLogger.info(
        '[WorldStateManager] No current map, clearing all cached maps',
      );
      _activeMapStates.clear();
      return;
    }

    final initialCount = _activeMapStates.length;
    _activeMapStates.removeWhere((mapId, _) => mapId != _currentMapId);
    final removedCount = initialCount - _activeMapStates.length;

    if (removedCount > 0) {
      GameLogger.info(
        '[WorldStateManager] Unloaded $removedCount inactive map(s)',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'currentDay': _currentDay,
      'currentSeason': _currentSeason.toJson(),
      'currentMapId': _currentMapId,
      'mapStates': _activeMapStates.map(
        (mapId, state) => MapEntry(mapId, state.toJson()),
      ),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    GameLogger.info('[WorldStateManager] Loading world state from JSON');

    _currentDay = json['currentDay'] as int? ?? 1;
    _currentSeason = Season.fromJson(
      json['currentSeason'] as String? ?? 'spring',
    );
    _currentMapId = json['currentMapId'] as String?;

    _activeMapStates.clear();
    final mapStatesJson = json['mapStates'] as Map<String, dynamic>?;
    if (mapStatesJson != null) {
      for (var entry in mapStatesJson.entries) {
        _activeMapStates[entry.key] = MapState.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    GameLogger.info(
      '[WorldStateManager] Loaded: Day $_currentDay, Season: $_currentSeason, Maps: ${_activeMapStates.length}',
    );
  }

  void reset() {
    GameLogger.info('[WorldStateManager] Resetting world state');
    _currentDay = 1;
    _currentSeason = Season.spring;
    _currentMapId = null;
    _activeMapStates.clear();
  }

  @override
  String toString() =>
      'WorldState(Day: $_currentDay, Season: $_currentSeason, Map: $_currentMapId)';
}
