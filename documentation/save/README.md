# Save System - Architecture & Documentation

## 📋 Overview

Sistema de salvamento de jogo robusto, escalável e type-safe, projetado para um clone de Stardew Valley. Implementa **Clean Architecture** com camadas bem definidas e princípios **SOLID**, **DRY** e **KISS**.

### ✨ Features

- ✅ **Type-Safe**: Modelos fortemente tipados (não usa `Map<String, dynamic>` genericamente)
- ✅ **Cross-Platform**: Suporta Mac, Windows, Linux, Web, Android e iOS
- ✅ **Performance**: Compressão automática para saves grandes (>100KB)
- ✅ **Testável**: Arquitetura desacoplada facilita testes unitários
- ✅ **Escalável**: Fácil adicionar novos campos e features
- ✅ **Migration Support**: Sistema automático de migração entre versões
- ✅ **Validation**: Validação de dados em múltiplas camadas
- ✅ **Auto-Save**: Sistema de auto-save com debouncing

---

## 🏗️ Architecture

```
lib/gameplay/core/modules/save/
├── domain/                          # Domain Layer (Clean Architecture)
│   ├── models/                      # Strongly-typed domain models
│   │   ├── player_save_data.dart    # Player state (health, skills, money)
│   │   ├── world_save_data.dart     # World state (day, season, time)
│   │   ├── inventory_save_data.dart # Inventory & equipment
│   │   ├── farm_save_data.dart      # Farm state (crops, animals)
│   │   └── game_save_data.dart      # Root save model
│   ├── interfaces/                  # Contracts
│   │   └── i_saveable.dart          # ISaveable, IResettable, IValidatable
│   └── services/                    # Use Cases
│       └── save_service.dart        # Business logic for save/load
├── implementations/                 # Infrastructure Layer
│   ├── save_repository_native.dart  # SharedPreferences (mobile/desktop)
│   └── save_repository_web.dart     # localStorage (web)
├── save_repository.dart             # Repository interface
└── [legacy files...]                # Old system (backward compatible)

test/core/modules/save/
└── domain/
    └── models/                      # Unit tests
        ├── player_save_data_test.dart
        └── game_save_data_test.dart
```

### 🎯 Layers

#### 1. **Domain Layer** (Business Logic)

- **Models**: Imutáveis, validáveis, serializáveis
- **Interfaces**: Contratos para managers (`ISaveable`, `IResettable`)
- **Services**: Casos de uso (`SaveService`)

#### 2. **Infrastructure Layer** (Platform-Specific)

- **Repositories**: Abstraem storage (SharedPreferences, localStorage)
- **Compression**: GZip automático para saves grandes

---

## 📦 Domain Models

### PlayerSaveData

```dart
final player = PlayerSaveData.initial(
  playerType: 'knight',
  playerName: 'Hero',
);

// Type-safe access
print('Level: ${player.level}');
print('Money: \$${player.money}');
print('Health: ${player.health}/${player.maxHealth}');

// Immutable updates
final leveledUp = player.copyWith(
  level: player.level + 1,
  experience: 0,
);
```

**Fields:**

- Position: `positionX`, `positionY`, `currentMapId`, `direction`
- Stats: `health`, `maxHealth`, `stamina`, `maxStamina`, `energy`, `maxEnergy`
- Progression: `level`, `experience`, `money`
- Skills: `farmingLevel`, `miningLevel`, `foragingLevel`, `fishingLevel`, `combatLevel`

### WorldSaveData

```dart
final world = WorldSaveData.initial();

print('Day ${world.currentDay} of ${world.seasonDisplayName}');
print('Time: ${world.getFormattedTime()}'); // "06:00"
print('Weather: ${world.weather}');
```

**Fields:**

- Time: `currentDay`, `currentSeason`, `currentYear`, `timeOfDaySeconds`
- Weather: `weather` (sunny, rainy, snowy, stormy, cloudy)
- Events: `activeEvents`, `completedEvents`
- Maps: `unlockedMaps`, `currentMapId`

### InventorySaveData

```dart
final inventory = InventorySaveData.initial(maxSlots: 36);

print('Slots used: ${inventory.usedSlots}/${inventory.maxInventorySlots}');
print('Equipped items: ${inventory.equippedItems.length}');
```

**Fields:**

- `inventorySlots`: List<InventorySlotData>
- `equipment`: Map<String, EquippedItemData?> (weapon, armor, accessories)
- `containers`: Map<String, List<InventorySlotData>> (chests, etc.)
- `quickBarSlots`: List<InventorySlotData> (hotbar)

### FarmSaveData

```dart
final farm = FarmSaveData.initial(layout: 'standard');

print('Crops: ${farm.totalCrops}');
print('Animals: ${farm.totalAnimals}');
print('Buildings: ${farm.totalBuildings}');
```

**Fields:**

- `crops`: List<CropTileData> (growth stages, watering, fertilizer)
- `animals`: List<FarmAnimalData> (happiness, health, production)
- `buildings`: List<FarmBuildingData> (barns, coops, upgrade levels)
- `tilledTiles`: List<TilePositionData>
- `wateredTiles`: List<TilePositionData>

### GameSaveData (Root)

```dart
final saveData = GameSaveData.newGame(
  playerType: 'knight',
  playerName: 'Hero',
  farmLayout: 'standard',
);

// Access nested models
print(saveData.player.level);
print(saveData.world.currentDay);
print(saveData.inventory.usedSlots);
print(saveData.farm.totalCrops);

// Human-readable summary
print(saveData.getSummary());
```

---

## 🔌 Usage

### 1. Implementing ISaveable in Managers

```dart
class PlayerStateManager implements ISaveableManager<PlayerSaveData> {
  // Your manager state
  double _health = 100.0;
  double _maxHealth = 100.0;
  int _level = 1;
  int _money = 500;
  // ... other fields

  @override
  PlayerSaveData toSaveData() {
    return PlayerSaveData(
      health: _health,
      maxHealth: _maxHealth,
      level: _level,
      money: _money,
      // ... map all fields
    );
  }

  @override
  void fromSaveData(PlayerSaveData data) {
    _health = data.health;
    _maxHealth = data.maxHealth;
    _level = data.level;
    _money = data.money;
    // ... restore all fields
  }

  @override
  void reset() {
    _health = 100.0;
    _maxHealth = 100.0;
    _level = 1;
    _money = 500;
    // ... reset to defaults
  }

  @override
  bool validate() {
    return _health >= 0 &&
           _health <= _maxHealth &&
           _level > 0;
  }
}
```

### 2. Saving Game

```dart
import 'package:darkness_dungeon/gameplay/core/modules/save/domain/services/save_service.dart';

final saveService = SaveService();

// Save
final result = await saveService.saveGame(
  playerManager: PlayerStateManager.instance,
  worldManager: WorldStateManager.instance,
  inventoryManager: InventoryManager.instance,
  farmManager: FarmManager.instance,
  progressData: {'achievements': [...], 'flags': [...]},
);

if (result.success) {
  print('✅ Game saved at ${result.timestamp}');
} else {
  print('❌ Save failed: ${result.errorMessage}');
}
```

### 3. Loading Game

```dart
// Load
final result = await saveService.loadGame();

if (result.success && result.data != null) {
  final saveData = result.data!;

  // Restore all managers
  PlayerStateManager.instance.fromSaveData(saveData.player);
  WorldStateManager.instance.fromSaveData(saveData.world);
  InventoryManager.instance.fromSaveData(saveData.inventory);
  FarmManager.instance.fromSaveData(saveData.farm);

  print('✅ Game loaded: ${saveData.getSummary()}');
} else {
  print('❌ Load failed: ${result.errorMessage}');
}
```

### 4. Auto-Save

```dart
// Call periodically (e.g., after important actions)
saveService.scheduleAutoSave(
  playerManager: PlayerStateManager.instance,
  worldManager: WorldStateManager.instance,
  inventoryManager: InventoryManager.instance,
  farmManager: FarmManager.instance,
);

// Auto-save is debounced (only saves if >30s since last save)
```

### 5. Other Operations

```dart
// Check if save exists
if (await saveService.hasSave()) {
  print('Continue game available');
}

// Delete save
await saveService.deleteSave();

// Get metadata without loading full save
final metadata = await saveService.getSaveMetadata();
print('Player level: ${metadata?['playerLevel']}');

// Cleanup on app close
saveService.dispose();
```

---

## 🧪 Testing

### Unit Tests

```dart
import 'package:test/test.dart';

void main() {
  group('PlayerSaveData', () {
    test('initial state is valid', () {
      final data = PlayerSaveData.initial(playerType: 'knight');
      expect(data.isValid(), isTrue);
    });

    test('serialization round-trip', () {
      final original = PlayerSaveData.initial(playerType: 'knight');
      final json = original.toJson();
      final restored = PlayerSaveData.fromJson(json);

      expect(restored, equals(original));
    });

    test('validation detects invalid states', () {
      final invalid = PlayerSaveData.initial(playerType: 'knight')
          .copyWith(health: -10);
      expect(invalid.isValid(), isFalse);
    });
  });
}
```

### Mock Repository for Testing

```dart
class MockSaveRepository implements SaveRepository {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<bool> save(String key, Map<String, dynamic> data) async {
    _storage[key] = data;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> load(String key) async {
    return _storage[key];
  }

  // ... implement other methods
}

// Use in tests
final service = SaveService(repository: MockSaveRepository());
```

---

## 🔄 Migration System

### Adding New Fields

**Version 2 → 3: Adding player crafting level**

```dart
// 1. Add field to PlayerSaveData
final class PlayerSaveData {
  final int craftingLevel; // NEW FIELD

  const PlayerSaveData({
    // ... existing fields
    required this.craftingLevel, // NEW
  });

  factory PlayerSaveData.fromJson(Map<String, dynamic> json) {
    return PlayerSaveData(
      // ... existing fields
      craftingLevel: json['craftingLevel'] as int? ?? 1, // DEFAULT
    );
  }
}

// 2. Update GameSaveData version
final class GameSaveData {
  static const int kCurrentVersion = 3; // INCREMENT

  static Map<String, dynamic> _migrateFromVersion(
    int oldVersion,
    Map<String, dynamic> json,
  ) {
    var data = Map<String, dynamic>.from(json);

    // ... existing migrations

    // NEW: Migration from version 2 to 3
    if (oldVersion < 3) {
      final playerData = data['player'] as Map<String, dynamic>? ?? {};
      playerData['craftingLevel'] ??= 1; // Add default value
      data['player'] = playerData;
    }

    data['version'] = kCurrentVersion;
    return data;
  }
}
```

---

## 📊 Performance

### Compression

- **Automatic**: Saves >100KB are compressed with GZip
- **Native**: SharedPreferences with compression
- **Web**: localStorage (5MB limit, compression reduces size)
- **Typical sizes**:
  - Early game: ~10KB (no compression)
  - Mid game: ~150KB → ~50KB compressed (67% reduction)
  - Late game: ~500KB → ~150KB compressed (70% reduction)

### Optimization Tips

1. **Debounce auto-saves**: Built-in 30s debounce
2. **Lazy loading**: Load only metadata when needed
3. **Validation**: Fast validation before expensive serialization
4. **Compression threshold**: Adjust in repository (default 100KB)

---

## 🚀 Roadmap

### Current Version (v2)

- ✅ Strongly-typed domain models
- ✅ Clean Architecture separation
- ✅ Cross-platform support
- ✅ Compression for large saves
- ✅ Migration system
- ✅ Unit tests structure

### Future Enhancements

- [ ] Multiple save slots
- [ ] Cloud sync support
- [ ] Save file encryption
- [ ] Incremental saves (delta compression)
- [ ] Save file analytics/corruption detection
- [ ] Backup/restore system

---

## 📚 References

### Design Patterns Used

- **Repository Pattern**: SaveRepository abstração
- **Use Case Pattern**: SaveService
- **Factory Pattern**: `*.initial()`, `*.fromJson()`
- **Builder Pattern**: `copyWith()` para updates imutáveis

### Clean Architecture Layers

1. **Domain**: Models + Interfaces + Services (business logic)
2. **Infrastructure**: Repositories (platform-specific)
3. **Presentation**: Controllers (orchestration)

---

## 🆘 Troubleshooting

### "Save data is corrupted"

- Check `isValid()` on all models
- Look for negative values or out-of-range data
- Check logs for deserialization errors
- Corrupted saves are automatically backed up

### "No save file found"

- Verify `hasSave()` before `loadGame()`
- Check correct save key is used
- Ensure write permissions on platform

### Performance Issues

- Enable compression in repository
- Reduce auto-save frequency
- Profile with large save files
- Consider incremental saves

### Web localStorage Full

- Clear old saves with `listKeys()` + `delete()`
- Increase compression threshold
- Implement save slot limit

---

## 👥 Contributing

### Adding New Domain Model

1. Create model in `domain/models/`
2. Implement `fromJson()`, `toJson()`, `isValid()`
3. Add to `GameSaveData`
4. Create unit tests
5. Update migration logic
6. Document in this README

### Code Style

- Use `final` for immutability
- Document all public APIs
- Add examples in doc comments
- Follow SOLID principles
- Write tests for new features

---

## 📝 License

Part of Darkness Dungeon project.
