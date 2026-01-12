// // lib/shared/framework/save/migration_helper.dart
// import 'package:dawnforge/core/utils/logger/game_logger.dart';
// import 'package:dawnforge/shared/framework/character/character_data.dart';

// class SaveMigrationHelper {
//   /// Migra save antigo (MVC) para novo formato (Behavior)
//   static Map<String, dynamic> migrateOldSave(Map<String, dynamic> oldSave) {
//     GameLogger.info('[Migration] Starting save migration...');
    
//     // Se já está no formato novo, retorna direto
//     if (oldSave.containsKey('maxStamina')) {
//       GameLogger.info('[Migration] Save already in new format');
//       return oldSave;
//     }
    
//     // Migra do formato antigo
//     final migratedSave = <String, dynamic>{
//       'stamina': oldSave['stamina'] ?? 100.0,
//       'maxStamina': oldSave['maxStamina'] ?? 100.0,
//       'energy': oldSave['energy'] ?? 100,
//       'maxEnergy': oldSave['maxEnergy'] ?? 100,
//       'life': oldSave['life'],
//       'maxLife': oldSave['maxLife'] ?? 100.0,
//       'coins': oldSave['coins'] ?? 0,
//       'position': oldSave['position'] ?? {'x': 0, 'y': 0},
//       'velocity': {'x': 0, 'y': 0},
//       'direction': 'down',
//       'isObservingEnemy': false,
//       'lastActionTimestamp': 0,
//       'equippedItemId': null,
//     };
    
//     GameLogger.info('[Migration] ✓ Save migrated successfully');
//     return migratedSave;
//   }
  
//   /// Valida se o save é válido
//   static bool validateSave(Map<String, dynamic> save) {
//     final requiredKeys = [
//       'stamina',
//       'maxStamina',
//       'energy',
//       'maxEnergy',
//       'coins',
//       'position',
//     ];
    
//     for (final key in requiredKeys) {
//       if (!save.containsKey(key)) {
//         GameLogger.warning('[Migration] ✗ Missing required key: $key');
//         return false;
//       }
//     }
    
//     return true;
//   }
// }