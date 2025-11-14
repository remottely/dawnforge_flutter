import 'package:flutter/material.dart';

import 'save_repository.dart';

/// Example demonstrating SaveRepository usage.
///
/// This example shows how to:
/// - Save data
/// - Load data
/// - Delete data
/// - Clear all game data
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = SaveRepository();

  // Example 1: Save and load player data
  print('=== Example 1: Save and Load ===');
  await repo.save('player_data', {
    'name': 'Hero',
    'level': 5,
    'health': 100,
    'position': {'x': 150.0, 'y': 200.0},
    'inventory': ['sword', 'potion', 'shield'],
  });

  final playerData = await repo.load('player_data');
  print('Loaded: $playerData');
  // Output: {name: Hero, level: 5, health: 100, ...}

  // Example 2: Load non-existent key
  print('\n=== Example 2: Load Non-Existent Key ===');
  final missingData = await repo.load('non_existent_key');
  print('Missing data: $missingData'); // Output: null

  // Example 3: Save multiple keys
  print('\n=== Example 3: Multiple Saves ===');
  await repo.save('world_state', {
    'currentDay': 10,
    'season': 'spring',
    'timeOfDay': 'morning',
  });

  await repo.save('inventory', {
    'slots': [
      {'item': 'sword', 'quantity': 1},
      {'item': 'potion', 'quantity': 5},
    ],
  });

  // Example 4: Delete specific key
  print('\n=== Example 4: Delete Key ===');
  await repo.delete('inventory');
  final deletedData = await repo.load('inventory');
  print('After delete: $deletedData'); // Output: null

  // Example 5: Clear all game data
  print('\n=== Example 5: Clear All ===');
  await repo.clear();
  final afterClear = await repo.load('player_data');
  print('After clear: $afterClear'); // Output: null

  print('\n✅ All examples completed!');
}
