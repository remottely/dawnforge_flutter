import 'dart:developer' as developer;

import 'package:darkness_dungeon/gameplay/core/modules/save/player_progress_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/game_state_collector.dart';
import 'package:darkness_dungeon/gameplay/core/modules/save/save_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/time/time_manager.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/map_state_model.dart';
import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

/// Example demonstrating complete save/load integration.
///
/// This file shows how to use the GameStateCollector with SaveManager
/// to persist and restore the complete game state.
///
/// Run this example with: `dart run lib/gameplay/core/modules/save/save_integration_example.dart`
void main() async {
  developer.log('=== Save/Load Integration Example ===\n');

  // ========== PART 1: Setup Game State ==========
  developer.log('PART 1: Setting up game state...\n');

  // Setup world state
  final worldManager = WorldStateManager.instance;
  worldManager.reset();
  worldManager.setCurrentMap('tutorial_map');
  worldManager.setMapState(
    'tutorial_map',
    MapState(
      decorationsModified: ['tree_1', 'rock_2'],
      farmTiles: ['farm_tile_1'],
      enemiesDefeated: ['slime_boss'],
      customData: {'treasureChestOpened': true},
    ),
  );

  // Advance some days
  for (int i = 0; i < 10; i++) {
    worldManager.advanceDay();
  }

  developer.log('World State:');
  developer.log('  - Day: ${worldManager.currentDay}');
  developer.log('  - Season: ${worldManager.currentSeason.displayName}');
  developer.log('  - Current Map: ${worldManager.currentMapId}');
  developer.log('  - Active Maps: ${worldManager.activeMapCount}\n');

  // Setup time state
  final timeManager = TimeManager.instance;
  timeManager.reset();
  timeManager.setTime(TimeConfig.eveningStartTime); // 18:00
  timeManager.setTimeScale(2.0);

  developer.log('Time State:');
  developer.log(
    '  - Time: ${timeManager.currentHour.toString().padLeft(2, '0')}:'
    '${timeManager.currentMinute.toString().padLeft(2, '0')}',
  );
  developer.log('  - Time of Day: ${timeManager.currentTimeOfDay.displayName}');
  developer.log('  - Time Scale: ${timeManager.timeScale}x\n');

  // Setup player progress
  final progressManager = PlayerProgressManager.instance;
  progressManager.reset();
  progressManager.setFlag('quest_tutorial_completed');
  progressManager.setFlag('npc_met_elder');
  progressManager.setFlag('area_forest_unlocked');
  progressManager.incrementAchievement('enemies_defeated', 25);
  progressManager.incrementAchievement('items_crafted', 5);
  progressManager.totalPlayTimeSeconds = 7200; // 2 hours
  progressManager.enemiesDefeated = 25;
  progressManager.itemsCrafted = 5;
  progressManager.distanceTraveled = 15000;

  developer.log('Progress State:');
  developer.log('  - Flags: ${progressManager.getAllFlags().length}');
  developer.log(
    '  - Achievements: ${progressManager.getAllAchievements().length}',
  );
  developer.log(
    '  - Play Time: ${progressManager.totalPlayTimeSeconds ~/ 3600}h '
    '${(progressManager.totalPlayTimeSeconds % 3600) ~/ 60}m',
  );
  developer.log('  - Enemies Defeated: ${progressManager.enemiesDefeated}\n');

  // ========== PART 2: Save Game ==========
  developer.log('PART 2: Saving game...\n');

  // Collect current game state
  final saveData = GameStateCollector.collectCurrentGameState();
  developer.log('Game state collected:');
  developer.log('  $saveData\n');

  // Validate state before saving
  if (GameStateCollector.validateCurrentState()) {
    developer.log('✓ State validation passed\n');
  } else {
    developer.log('✗ State validation failed!\n');
    return;
  }

  // Save to persistent storage
  final saveSuccess = await SaveManager.instance.save(saveData);
  if (saveSuccess) {
    developer.log('✓ Game saved successfully!\n');
  } else {
    developer.log('✗ Failed to save game!\n');
    return;
  }

  // Display summary
  developer.log('Current State Summary:');
  developer.log(GameStateCollector.getCurrentStateSummary());
  developer.log('');

  // ========== PART 3: Reset Managers (Simulate Game Restart) ==========
  developer.log(
    'PART 3: Resetting all managers (simulating game restart)...\n',
  );

  GameStateCollector.resetAllManagers();

  developer.log('After Reset:');
  developer.log('  - Day: ${worldManager.currentDay}');
  developer.log('  - Current Map: ${worldManager.currentMapId ?? 'None'}');
  developer.log(
    '  - Time: ${timeManager.currentHour.toString().padLeft(2, '0')}:'
    '${timeManager.currentMinute.toString().padLeft(2, '0')}',
  );
  developer.log('  - Flags: ${progressManager.getAllFlags().length}');
  developer.log('  - Play Time: ${progressManager.totalPlayTimeSeconds}s\n');

  // ========== PART 4: Load Game ==========
  developer.log('PART 4: Loading game...\n');

  // Check if save exists
  final hasSave = await SaveManager.instance.hasSave();
  developer.log('Has save file: $hasSave\n');

  if (!hasSave) {
    developer.log('No save file found!\n');
    return;
  }

  // Load from persistent storage
  final loadedData = await SaveManager.instance.load();

  if (loadedData == null) {
    developer.log('✗ Failed to load game!\n');
    return;
  }

  developer.log('✓ Save file loaded successfully');
  developer.log('  $loadedData\n');

  // Restore game state
  final restoreSuccess = GameStateCollector.restoreGameState(loadedData);

  if (restoreSuccess) {
    developer.log('✓ Game state restored successfully!\n');
  } else {
    developer.log('✗ Failed to restore game state!\n');
    return;
  }

  // Verify restored state
  developer.log('After Restore:');
  developer.log('  - Day: ${worldManager.currentDay}');
  developer.log('  - Season: ${worldManager.currentSeason.displayName}');
  developer.log('  - Current Map: ${worldManager.currentMapId}');
  developer.log(
    '  - Time: ${timeManager.currentHour.toString().padLeft(2, '0')}:'
    '${timeManager.currentMinute.toString().padLeft(2, '0')}',
  );
  developer.log('  - Time of Day: ${timeManager.currentTimeOfDay.displayName}');
  developer.log('  - Flags: ${progressManager.getAllFlags()}');
  developer.log('  - Enemies Defeated: ${progressManager.enemiesDefeated}');
  developer.log(
    '  - Play Time: ${progressManager.totalPlayTimeSeconds ~/ 3600}h '
    '${(progressManager.totalPlayTimeSeconds % 3600) ~/ 60}m\n',
  );

  // ========== PART 5: Auto-Save Example ==========
  developer.log('PART 5: Auto-save example...\n');

  // Make some progress
  worldManager.advanceDay();
  progressManager.setFlag('quest_forest_completed');
  progressManager.incrementAchievement('enemies_defeated', 5);

  developer.log('Made some progress:');
  developer.log('  - Day advanced to: ${worldManager.currentDay}');
  developer.log('  - New flag set: quest_forest_completed');
  developer.log(
    '  - Enemies defeated: ${progressManager.getAchievementProgress("enemies_defeated")}\n',
  );

  // Collect updated state
  final updatedSaveData = GameStateCollector.collectCurrentGameState();

  // Update cached save data and trigger auto-save
  await SaveManager.instance.save(updatedSaveData);
  SaveManager.instance.autoSave(); // This will be debounced

  developer.log('✓ Auto-save triggered (debounced)\n');

  // ========== PART 6: Save Metadata ==========
  developer.log('PART 6: Save metadata...\n');

  final metadata = await SaveManager.instance.getSaveMetadata();
  if (metadata != null) {
    developer.log('Save Metadata:');
    developer.log('  - Last Save Time: ${metadata['lastSaveTime']}');
    developer.log('  - Save Count: ${metadata['saveCount']}');
    developer.log('  - Version: ${metadata['version']}\n');
  }

  // ========== CLEANUP ==========
  developer.log('=== Example Complete ===\n');
  developer.log('To delete the save file, uncomment the following line:');
  developer.log('// await SaveManager.instance.deleteSave();\n');

  // Cleanup
  SaveManager.instance.dispose();
}
