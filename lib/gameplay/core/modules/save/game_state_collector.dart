import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/player/player_progress_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

/// Utility class for collecting and restoring game state from all managers.
///
/// This class acts as a bridge between the individual managers
/// (WorldStateManager, TimeManager, PlayerProgressManager) and the SaveManager,
/// collecting all their state into a single SaveData object and restoring it.
///
/// Usage:
/// ```dart
/// // Collect current game state
/// final saveData = GameStateCollector.collectCurrentGameState();
/// await SaveManager.instance.save(saveData);
///
/// // Restore game state
/// final loaded = await SaveManager.instance.load();
/// if (loaded != null) {
///   GameStateCollector.restoreGameState(loaded);
/// }
/// ```
final class GameStateCollector {
  GameStateCollector._();

  /// Collects current game state from all managers.
  ///
  /// Gathers state from:
  /// - WorldStateManager (world, maps, day, season)
  /// - TimeManager (current time, time scale, paused state)
  /// - PlayerProgressManager (flags, achievements, stats)
  ///
  /// Returns a complete [SaveData] object ready to be saved.
  static SaveData collectCurrentGameState() {
    developer.log('[GameStateCollector] Collecting current game state');

    // Collect from all managers
    final worldState = WorldStateManager.instance.toJson();
    final timeState = TimeManager.instance.toJson();
    final progressState = PlayerProgressManager.instance.toJson();

    // Combine into worldData map
    final worldData = {
      'world': worldState,
      'time': timeState,
      'progress': progressState,
    };

    // For now, playerData and inventoryData are empty
    // They will be populated when PlayerModel and Inventory systems are implemented
    final saveData = SaveData(
      version: SaveData.kCurrentVersion,
      timestamp: DateTime.now(),
      playerData: {}, // TODO: Implement in FASE 1.3
      worldData: worldData,
      inventoryData: {}, // TODO: Implement in FASE 2.1
    );

    developer.log(
      '[GameStateCollector] Game state collected: '
      'Day ${WorldStateManager.instance.currentDay}, '
      'Time ${TimeManager.instance.currentHour}:${TimeManager.instance.currentMinute}, '
      '${PlayerProgressManager.instance.getAllFlags().length} flags',
    );

    return saveData;
  }

  /// Restores game state to all managers from SaveData.
  ///
  /// Validates data before restoring and logs any errors.
  /// If data is invalid or corrupted, managers will not be updated.
  ///
  /// [saveData] - The save data to restore from
  ///
  /// Returns `true` if restoration was successful, `false` otherwise.
  static bool restoreGameState(SaveData saveData) {
    try {
      developer.log('[GameStateCollector] Restoring game state');

      // Validate save data
      if (!saveData.isValid()) {
        developer.log(
          '[GameStateCollector] Cannot restore from invalid save data',
          level: 900, // WARNING
        );
        return false;
      }

      final worldData = saveData.worldData;

      // Restore world state
      final worldState = worldData['world'] as Map<String, dynamic>?;
      if (worldState != null) {
        WorldStateManager.instance.fromJson(worldState);
        developer.log('[GameStateCollector] World state restored');
      } else {
        developer.log(
          '[GameStateCollector] No world state data found',
          level: 500, // FINE
        );
      }

      // Restore time state
      final timeState = worldData['time'] as Map<String, dynamic>?;
      if (timeState != null) {
        TimeManager.instance.fromJson(timeState);
        developer.log('[GameStateCollector] Time state restored');
      } else {
        developer.log(
          '[GameStateCollector] No time state data found',
          level: 500, // FINE
        );
      }

      // Restore progress state
      final progressState = worldData['progress'] as Map<String, dynamic>?;
      if (progressState != null) {
        PlayerProgressManager.instance.fromJson(progressState);
        developer.log('[GameStateCollector] Progress state restored');
      } else {
        developer.log(
          '[GameStateCollector] No progress state data found',
          level: 500, // FINE
        );
      }

      developer.log(
        '[GameStateCollector] Game state restored successfully: '
        'Day ${WorldStateManager.instance.currentDay}, '
        'Time ${TimeManager.instance.currentHour}:${TimeManager.instance.currentMinute}, '
        '${PlayerProgressManager.instance.getAllFlags().length} flags',
      );

      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameStateCollector] Error restoring game state',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }

  /// Resets all managers to their initial state.
  ///
  /// This is useful for starting a new game or clearing corrupted data.
  ///
  /// Warning: This will permanently clear all progress!
  static void resetAllManagers() {
    developer.log('[GameStateCollector] Resetting all managers');

    WorldStateManager.instance.reset();
    TimeManager.instance.reset();
    PlayerProgressManager.instance.reset();

    developer.log('[GameStateCollector] All managers reset complete');
  }

  /// Validates that all managers have valid state.
  ///
  /// Performs sanity checks on the current state of all managers.
  ///
  /// Returns `true` if all managers are in a valid state, `false` otherwise.
  static bool validateCurrentState() {
    try {
      // Check WorldStateManager
      final worldDay = WorldStateManager.instance.currentDay;
      if (worldDay < 1) {
        developer.log(
          '[GameStateCollector] Invalid world state: day < 1',
          level: 900,
        );
        return false;
      }

      // Check TimeManager
      final currentTime = TimeManager.instance.currentTime;
      if (currentTime < 0 || currentTime >= 86400) {
        developer.log(
          '[GameStateCollector] Invalid time state: time out of range',
          level: 900,
        );
        return false;
      }

      // PlayerProgressManager doesn't have strict validation requirements
      // (empty state is valid for new games)

      developer.log('[GameStateCollector] Current state is valid');
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[GameStateCollector] Error validating state',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  /// Gets a human-readable summary of the current game state.
  ///
  /// Useful for debugging or displaying save file information to players.
  ///
  /// Returns a formatted string with key information from all managers.
  static String getCurrentStateSummary() {
    final world = WorldStateManager.instance;
    final time = TimeManager.instance;
    final progress = PlayerProgressManager.instance;

    return '''
Game State Summary:
- Day: ${world.currentDay} (${world.currentSeason.displayName})
- Time: ${time.currentHour.toString().padLeft(2, '0')}:${time.currentMinute.toString().padLeft(2, '0')} (${time.currentTimeOfDay.displayName})
- Current Map: ${world.currentMapId ?? 'None'}
- Active Maps: ${world.activeMapCount}
- Flags: ${progress.getAllFlags().length}
- Achievements: ${progress.getAllAchievements().length}
- Play Time: ${progress.totalPlayTimeSeconds ~/ 3600}h ${(progress.totalPlayTimeSeconds % 3600) ~/ 60}m
- Enemies Defeated: ${progress.enemiesDefeated}
- Items Crafted: ${progress.itemsCrafted}
- Distance Traveled: ${progress.distanceTraveled}
    '''
        .trim();
  }
}
