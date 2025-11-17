import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/characters/player/custom/custom_player_model.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/player/player_progress_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_state_collector.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_data_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_model.dart';

/// Adapter that bridges PlayerModel and SaveManager systems.
///
/// Provides high-level save/load operations for the complete game state,
/// including player data and all global managers (World, Time, Progress).
///
/// This adapter decouples the player system from the save system, making
/// both more maintainable and testable.
///
/// Usage:
/// ```dart
/// // Save game
/// final success = await PlayerSaveAdapter.saveGame(playerModel);
/// if (success) print('Game saved!');
///
/// // Load game
/// final player = await PlayerSaveAdapter.loadGame();
/// if (player != null) {
///   // Restore game with loaded player
/// }
/// ```
final class PlayerSaveAdapter {
  PlayerSaveAdapter._(); // Prevent instantiation

  // ============================================================================
  // High-Level Save/Load Operations
  // ============================================================================

  /// Saves the complete game state (player + all managers).
  ///
  /// Collects data from:
  /// - Player model (stamina, energy, inventory)
  /// - WorldStateManager (day, season, maps)
  /// - TimeManager (current time, time scale)
  /// - PlayerProgressManager (flags, achievements, stats)
  ///
  /// Returns `true` if save was successful, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final knight = CustomModelModel();
  /// final success = await PlayerSaveAdapter.saveGame(knight);
  /// ```
  static Future<bool> saveGame(DDBasePlayerModel player) async {
    try {
      developer.log('[PlayerSaveAdapter] Initiating game save...');

      // 1. Collect player data
      final playerJson = player.toJson();

      // 2. Collect manager data
      final worldData = {
        'world': WorldStateManager.instance.toJson(),
        'time': TimeManager.instance.toJson(),
        'progress': PlayerProgressManager.instance.toJson(),
      };

      // 3. Combine into SaveData
      final saveData = SaveData(
        version: SaveData.kCurrentVersion,
        timestamp: DateTime.now(),
        playerData: playerJson,
        worldData: worldData,
        inventoryData: {}, // TODO: Implement in FASE 2.1
      );

      // 4. Persist to storage
      final success = await SaveManager.instance.save(saveData);

      if (success) {
        developer.log('[PlayerSaveAdapter] Game saved successfully');
      } else {
        developer.log(
          '[PlayerSaveAdapter] Save failed',
          level: 900, // WARNING
        );
      }

      return success;
    } catch (e, stackTrace) {
      developer.log(
        '[PlayerSaveAdapter] Error during save',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return false;
    }
  }

  /// Loads the complete game state.
  ///
  /// Restores:
  /// - Player model from saved data
  /// - WorldStateManager state
  /// - TimeManager state
  /// - PlayerProgressManager state
  ///
  /// Returns the restored player model, or `null` if:
  /// - No save file exists
  /// - Save data is corrupted
  /// - Player type is unknown
  ///
  /// Example:
  /// ```dart
  /// final player = await PlayerSaveAdapter.loadGame();
  /// if (player != null) {
  ///   // Continue game with loaded player
  /// }
  /// ```
  static Future<DDBasePlayerModel?> loadGame() async {
    try {
      developer.log('[PlayerSaveAdapter] Initiating game load...');

      // 1. Load save data
      final saveData = await SaveManager.instance.load();

      if (saveData == null) {
        developer.log(
          '[PlayerSaveAdapter] No save data found',
          level: 500, // FINE
        );
        return null;
      }

      // 2. Restore managers first
      if (!GameStateCollector.restoreGameState(saveData)) {
        developer.log(
          '[PlayerSaveAdapter] Failed to restore manager state',
          level: 900, // WARNING
        );
        return null;
      }

      // 3. Restore player
      final player = saveDataToPlayer(saveData);

      if (player == null) {
        developer.log(
          '[PlayerSaveAdapter] Failed to restore player',
          level: 900, // WARNING
        );
        return null;
      }

      developer.log(
        '[PlayerSaveAdapter] Game loaded successfully: '
        '${player.toJson()['playerType']}',
      );

      return player;
    } catch (e, stackTrace) {
      developer.log(
        '[PlayerSaveAdapter] Error during load',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return null;
    }
  }

  /// Checks if a saved game exists.
  ///
  /// Returns `true` if a save file exists, `false` otherwise.
  ///
  /// Useful for showing "Continue" button in main menu.
  static Future<bool> hasSavedGame() async {
    return await SaveManager.instance.hasSave();
  }

  /// Deletes the current saved game.
  ///
  /// Returns `true` if deletion was successful, `false` otherwise.
  ///
  /// Warning: This action cannot be undone!
  static Future<bool> deleteSavedGame() async {
    developer.log('[PlayerSaveAdapter] Deleting saved game...');
    return await SaveManager.instance.deleteSave();
  }

  // ============================================================================
  // Conversion Utilities (for testing and advanced usage)
  // ============================================================================

  /// Converts PlayerModel to SaveData (without persisting).
  ///
  /// Useful for testing serialization or creating save data objects
  /// without immediately writing to disk.
  ///
  /// [player] The player model to convert.
  ///
  /// Returns a complete SaveData object ready for persistence.
  static SaveData playerToSaveData(DDBasePlayerModel player) {
    final playerJson = player.toJson();

    final worldData = {
      'world': WorldStateManager.instance.toJson(),
      'time': TimeManager.instance.toJson(),
      'progress': PlayerProgressManager.instance.toJson(),
    };

    return SaveData(
      version: SaveData.kCurrentVersion,
      timestamp: DateTime.now(),
      playerData: playerJson,
      worldData: worldData,
      inventoryData: {},
    );
  }

  /// Converts SaveData to PlayerModel (without restoring managers).
  ///
  /// Useful for testing deserialization or inspecting save data
  /// without affecting global manager state.
  ///
  /// [saveData] The save data to convert.
  ///
  /// Returns the player model, or `null` if:
  /// - Player data is empty or invalid
  /// - Player type is unknown or unsupported
  static DDBasePlayerModel? saveDataToPlayer(SaveData saveData) {
    try {
      final playerData = saveData.playerData;

      if (playerData.isEmpty) {
        developer.log(
          '[PlayerSaveAdapter] Player data is empty',
          level: 900, // WARNING
        );
        return null;
      }

      // Determine player type and deserialize accordingly
      final playerType = playerData['playerType'] as String?;

      switch (playerType) {
        case 'knight':
          return CustomPlayerModel.fromJson(playerData);
        case 'sunny':
          return SunnyPlayerModel.fromJson(playerData);
        default:
          developer.log(
            '[PlayerSaveAdapter] Unknown player type: $playerType',
            level: 900, // WARNING
          );
          return null;
      }
    } catch (e, stackTrace) {
      developer.log(
        '[PlayerSaveAdapter] Error converting SaveData to Player',
        error: e,
        stackTrace: stackTrace,
        level: 1000, // ERROR
      );
      return null;
    }
  }

  // ============================================================================
  // Validation and Diagnostics
  // ============================================================================

  /// Validates that the current game state can be saved.
  ///
  /// Performs sanity checks on player and manager state.
  ///
  /// Returns `true` if state is valid and can be saved, `false` otherwise.
  static bool validateCurrentState(DDBasePlayerModel player) {
    try {
      // Validate player can be serialized
      final playerJson = player.toJson();
      if (playerJson.isEmpty) {
        developer.log(
          '[PlayerSaveAdapter] Player serialization produced empty data',
          level: 900,
        );
        return false;
      }

      // Validate managers
      if (!GameStateCollector.validateCurrentState()) {
        developer.log(
          '[PlayerSaveAdapter] Manager state validation failed',
          level: 900,
        );
        return false;
      }

      developer.log('[PlayerSaveAdapter] State validation passed');
      return true;
    } catch (e, stackTrace) {
      developer.log(
        '[PlayerSaveAdapter] Error during state validation',
        error: e,
        stackTrace: stackTrace,
        level: 1000,
      );
      return false;
    }
  }

  /// Gets a human-readable summary of the saved game.
  ///
  /// Useful for displaying save file information in the UI.
  ///
  /// Returns formatted string with save details, or null if no save exists.
  static Future<String?> getSaveSummary() async {
    try {
      final saveData = await SaveManager.instance.load();
      if (saveData == null) return null;

      final playerData = saveData.playerData;
      final playerType = playerData['playerType'] as String? ?? 'Unknown';
      final timestamp = saveData.timestamp;

      final worldState = GameStateCollector.getCurrentStateSummary();

      return '''
Save Summary:
- Player Type: ${playerType.toUpperCase()}
- Saved: ${timestamp.toLocal()}
- Age: ${DateTime.now().difference(timestamp).inHours}h ago

$worldState
      '''
          .trim();
    } catch (e) {
      developer.log(
        '[PlayerSaveAdapter] Error getting save summary',
        error: e,
        level: 900,
      );
      return null;
    }
  }
}
