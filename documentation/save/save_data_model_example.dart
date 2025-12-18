import '../../lib/gameplay/core/modules/save/save_data_model.dart';

/// Examples demonstrating SaveData usage.
void main() {
  print('=== Example 1: Create and Serialize ===');
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
    worldData: {
      'currentDay': 10,
      'season': 'spring',
      'timeOfDay': 'morning',
      'weather': 'sunny',
    },
    inventoryData: {
      'slots': [
        {'item': 'sword', 'quantity': 1},
        {'item': 'potion', 'quantity': 5},
        {'item': 'key', 'quantity': 1},
      ],
      'gold': 150,
    },
  );

  print('Created: $saveData');
  print('Valid: ${saveData.isValid()}');

  // Serialize to JSON
  final json = saveData.toJson();
  print('\nJSON: $json');

  // Example 2: Deserialize from JSON
  print('\n=== Example 2: Deserialize ===');
  final loaded = SaveData.fromJson(json);
  print('Loaded: $loaded');
  print('Equal: ${saveData == loaded}');

  // Example 3: copyWith (immutable update)
  print('\n=== Example 3: Immutable Update ===');
  final updated = saveData.copyWith(
    playerData: {
      ...saveData.playerData,
      'health': 100, // Healed!
    },
  );
  print('Original health: ${saveData.playerData['health']}');
  print('Updated health: ${updated.playerData['health']}');

  // Example 4: Version migration
  print('\n=== Example 4: Old Save Migration ===');
  final oldSaveJson = {
    // No version field (old save)
    'timestamp': DateTime.now().toIso8601String(),
    'playerData': {'name': 'OldHero'},
    // worldData and inventoryData missing
  };

  final migratedSave = SaveData.fromJson(oldSaveJson);
  print('Migrated version: ${migratedSave.version}');
  print('Has worldData: ${migratedSave.worldData.isNotEmpty}');

  // Example 5: Validation
  print('\n=== Example 5: Validation ===');
  final invalidSave = SaveData(
    version: SaveData.kCurrentVersion,
    timestamp: DateTime.now(),
    playerData: {}, // Empty! Invalid
    worldData: {},
    inventoryData: {},
  );
  print('Invalid save valid? ${invalidSave.isValid()}'); // false

  final futureSave = SaveData(
    version: SaveData.kCurrentVersion,
    timestamp: DateTime.now().add(const Duration(days: 1)), // Future!
    playerData: {'name': 'Future'},
    worldData: {},
    inventoryData: {},
  );
  print('Future timestamp valid? ${futureSave.isValid()}'); // false

  print('\n✅ All examples completed!');
}
