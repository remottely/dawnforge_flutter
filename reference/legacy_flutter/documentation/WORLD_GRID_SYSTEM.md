# World Grid System Architecture

## Overview

This document describes the refactored World Grid System that replaces the old farm-specific tile system with a generic, extensible architecture capable of representing any object in the game world.

## Architecture

### Core Concepts

**GridTile** - Generic tile in the world grid that can hold any type of object
**TileObject** - Abstract base for any object that can be placed on a grid tile
**TileObjectType** - Enum categorizing different types of objects

### Directory Structure

```
lib/gameplay/world/entities/
├── grid_tile.dart              # Generic grid tile
├── tile_object.dart            # Abstract tile object interface
├── tile_object_type.dart       # Object type categories
├── world_entities.dart         # Barrel export file
└── objects/
    └── farm/
        ├── farm_object.dart     # Farm-specific tile object
        ├── crop_entity.dart     # Crop data entity
        ├── crop_stage.dart      # Growth stages enum
        └── soil_state.dart      # Soil states enum
```

### Key Classes

#### GridTile
```dart
final class GridTile {
  final int x, y;                     // Position
  final TileObject? object;            // Object on this tile
  final Map<String, dynamic>? metadata; // Extra data
  
  bool get isEmpty;
  bool get blocksMovement;
  bool get isInteractable;
  
  GridTile placeObject(TileObject object);
  GridTile removeObject();
  GridTile setMetadata(String key, dynamic value);
}
```

#### TileObject (abstract)
```dart
abstract class TileObject {
  String get objectId;
  String get name;
  TileObjectType get type;
  bool get blocksMovement;
  bool get isInteractable;
  bool get shouldUseYSorting;
  Map<String, dynamic> get visualData;
  
  Map<String, dynamic> toJson();
  TileObject copyWith();
}
```

#### FarmObject (implements TileObject)
```dart
final class FarmObject implements TileObject {
  final String objectId;
  final SoilState soilState;
  final CropEntity? crop;
  final int? lastWateredDay;
  
  @override
  TileObjectType get type => TileObjectType.farm;
  
  FarmObject till();
  FarmObject water(int currentDay);
  FarmObject plant(CropEntity crop);
  FarmObject harvest();
  FarmObject advanceDay(int dayEnded);
}
```

## Migration from Old System

### Before (Farm-specific)
```dart
// Old way - farm-specific tile (REMOVED)
FarmTile tile = FarmTile(
  x: 0, 
  y: 0,
  soilState: SoilState.tilled,
  crop: someCrop,
);
```

### After (Generic system)
```dart
// New way - generic tile with farm object
GridTile tile = GridTile(
  x: 0,
  y: 0,
  object: FarmObject(
    objectId: 'farm_0_0',
    soilState: SoilState.tilled,
    crop: someCrop,
  ),
);

// Accessing farm-specific data
final farmObject = tile.object as FarmObject;
print(farmObject.soilState); // SoilState.tilled
print(farmObject.crop);       // someCrop
```

### Direct Usage Pattern

The system now uses `GridTile + FarmObject` directly throughout the codebase:

```dart
// In FarmManager
final tile = getTile(x, y);
final farmObject = tile?.object as FarmObject?;
if (farmObject?.canPlant == true) {
  // Plant logic
}

// Creating a new farm tile
final newTile = GridTile(
  x: x,
  y: y,
  object: FarmObject(objectId: 'farm_${x}_$y'),
);
```

## Extensibility

### Adding New Object Types

1. **Define the type** in `TileObjectType`:
```dart
enum TileObjectType {
  // ...existing types
  furniture,  // Add new type
}
```

2. **Create the object class**:
```dart
final class FurnitureObject implements TileObject {
  final String objectId;
  final String furnitureType; // 'bed', 'table', etc.
  
  @override
  TileObjectType get type => TileObjectType.furniture;
  
  @override
  bool get blocksMovement => true; // Furniture blocks movement
  
  // Implement other TileObject methods...
}
```

3. **Use it with GridTile**:
```dart
GridTile tile = GridTile(
  x: 5,
  y: 5,
  object: FurnitureObject(
    objectId: 'bed_001',
    furnitureType: 'bed',
  ),
);
```

## Benefits

✅ **Extensibility** - Easy to add new object types (furniture, fences, decorations)
✅ **Separation of Concerns** - Grid logic separate from object-specific logic
✅ **Type Safety** - Strongly typed with proper abstractions
✅ **Backward Compatible** - Existing farm code continues to work
✅ **Metadata Support** - Generic metadata system for custom data
✅ **Future-Proof** - Designed to handle any game object type

## Future Object Types

Planned object types that can now be easily implemented:

- **Furniture** - Beds, tables, chairs, storage chests
- **Fences** - Wooden fence, stone wall, iron gate
- **Decorations** - Flowers, stones, statues
- **Buildings** - Houses, barns, workshops
- **Terrain** - Trees, rocks, water features
- **Interactive** - Doors, switches, signs

## Import Usage

```dart
// Import everything from world entities
import 'package:dawnforge/features/world/entities/world_entities.dart';

// Now you have access to:
// - GridTile
// - TileObject
// - TileObjectType
// - FarmObject
// - CropEntity
// - CropStage
// - SoilState
```

## Migration Checklist for Developers

- [x] Create world/entities/ structure
- [x] Implement GridTile, TileObject, TileObjectType
- [x] Create FarmObject implementing TileObject
- [x] Move farm entities to objects/farm/
- [x] **REMOVED FarmTile** - Now using GridTile + FarmObject directly
- [x] Update all imports throughout project
- [x] Update FarmManager to work with GridTile
- [x] Update all UseCases to use FarmObject
- [x] Update FarmViewModel to use FarmObject
- [x] Update FarmTileView to use GridTile + FarmObject
- [x] Validate with flutter analyze (0 errors!)
- [ ] Update tests to use new imports
- [ ] Add examples for new object types
- [ ] Create builder patterns for common objects

## Notes

- ✅ **FarmTile has been completely removed** - The project now uses `GridTile + FarmObject` directly
- The old `lib/gameplay/farm/entities/farm_tile.dart` has been deleted
- All farm entities are now in `lib/gameplay/world/entities/objects/farm/`
- `GridTile` is the universal tile type, `FarmObject` implements `TileObject` for farm-specific functionality
- Metadata system allows storing additional data per tile without modifying core classes
- Pattern: `final farmObject = gridTile.object as FarmObject?;` to access farm-specific data
