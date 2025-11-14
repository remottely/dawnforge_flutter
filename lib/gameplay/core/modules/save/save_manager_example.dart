import 'package:flutter/material.dart';

import 'save_data_model.dart';
import 'save_manager.dart';

/// Example demonstrating SaveManager usage in a complete save/load cycle.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('=== Example 1: Save Game ===');

  // Create game state
  final saveData = SaveData(
    version: SaveData.kCurrentVersion,
    timestamp: DateTime.now(),
    playerData: {
      'name': 'Hero',
      'health': 80,
      'maxHealth': 100,
      'position': {'x': 150.0, 'y': 200.0},
      'level': 5,
    },
    worldData: {'currentDay': 10, 'season': 'spring', 'timeOfDay': 'morning'},
    inventoryData: {
      'slots': [
        {'item': 'sword', 'quantity': 1},
        {'item': 'potion', 'quantity': 5},
      ],
    },
  );

  // Save
  final saved = await SaveManager.instance.save(saveData);
  print('Save successful: $saved');

  // Example 2: Check if save exists
  print('\n=== Example 2: Check Save Exists ===');
  final hasSave = await SaveManager.instance.hasSave();
  print('Has save: $hasSave');

  // Example 3: Load game
  print('\n=== Example 3: Load Game ===');
  final loaded = await SaveManager.instance.load();
  if (loaded != null) {
    print('Loaded: $loaded');
    print('Player name: ${loaded.playerData['name']}');
    print('Current day: ${loaded.worldData['currentDay']}');
  }

  // Example 4: Update and save again
  print('\n=== Example 4: Update Save ===');
  if (loaded != null) {
    final updated = loaded.copyWith(
      timestamp: DateTime.now(),
      playerData: {
        ...loaded.playerData,
        'health': 100, // Healed!
        'level': 6, // Leveled up!
      },
      worldData: {
        ...loaded.worldData,
        'currentDay': 11, // Next day
      },
    );

    await SaveManager.instance.save(updated);
    print('Updated save with new data');
  }

  // Example 5: Get metadata
  print('\n=== Example 5: Save Metadata ===');
  final metadata = await SaveManager.instance.getSaveMetadata();
  if (metadata != null) {
    print('Last save: ${metadata['lastSaveTime']}');
    print('Save count: ${metadata['saveCount']}');
  }

  // Example 6: Auto-save (non-blocking)
  print('\n=== Example 6: Auto-Save ===');
  SaveManager.instance.autoSave();
  print('Auto-save triggered (will execute after debounce)');

  // Wait a bit to let auto-save complete
  await Future.delayed(const Duration(seconds: 1));

  // Example 7: Delete save
  print('\n=== Example 7: Delete Save ===');
  // Uncomment to test deletion
  // final deleted = await SaveManager.instance.deleteSave();
  // print('Save deleted: $deleted');

  // Example 8: Attempt to load after delete
  // final afterDelete = await SaveManager.instance.load();
  // print('Load after delete: $afterDelete'); // Should be null

  // Cleanup
  SaveManager.instance.dispose();

  print('\n✅ All examples completed!');
}
