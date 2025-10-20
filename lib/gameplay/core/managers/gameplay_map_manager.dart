import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp_enemy.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid_npc.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard_npc.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/door_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/door_key_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/life_potion_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/spike_trap_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/torch_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_sensor.dart';
import 'package:darkness_dungeon/gameplay/terrain/farmable/farm_tile.dart';

/// [GameplayMapManager] responsible for managing game maps and navigation systems
/// Following Flutter naming conventions for map management systems
///
/// This class handles:
/// - Map loading and parsing from Tiled map files
/// - Entity factory creation based on map data
/// - Map collection management and caching
/// - Game object positioning and configuration
/// - Navigation between different game areas
class GameplayMapManager {
  // Flutter-style constants for entity types
  static const String kBarrelDecorationType = 'barrel_decoration';
  static const String kDoorDecorationType = 'door_decoration';
  static const String kDoorKeyDecorationType = 'door_key_decoration';
  static const String kLifePotionDecorationType = 'life_potion_decoration';
  static const String kTorchDecorationType = 'torch_decoration';
  static const String kTorchDecorationEmptyType = 'torch_decoration_empty';
  static const String kSpikeTrapDecorationType = 'spike_trap_decoration';
  static const String kWizardEntityType = 'wizard';
  static const String kKidEntityType = 'kid';
  static const String kBossEntityType = 'dungeon_boss';
  static const String kMiniBossEntityType = 'dungeon_mini_boss';
  static const String kGoblinEntityType = 'goblin';
  static const String kImpEntityType = 'imp';
  static const String kFarmTileEntityType = 'farm_tile';

  // Private constructor to prevent instantiation
  GameplayMapManager._();

  /// Gets the complete map configuration for the game
  /// Following Flutter pattern of static factory methods
  static Map<String, MapItemBuilder> get maps {
    final mapBuilders = <String, MapItemBuilder>{};

    // Build maps from centralized configuration
    for (final config in GameplayMapData.allMaps) {
      mapBuilders[config.id.name] = (context, args) => _createMapItem(config);
    }

    return mapBuilders;
  }

  /// Creates a MapItem from configuration
  /// Following Flutter pattern of factory methods
  static MapItem _createMapItem(GameplayMapData config) {
    return MapItem(
      id: config.id.name,
      properties: config.properties,
      map: _buildMap(mapAsset: config.asset, sensorIds: config.sensorIds),
    );
  }
}

/// Builds a tiled world map with specified configuration
/// Following Flutter pattern of private factory methods
WorldMapByTiled _buildMap({
  required String mapAsset,
  required List<String> sensorIds,
}) {
  return WorldMapByTiled(
    WorldMapReader.fromAsset(mapAsset),
    forceTileSize: GameplayConstants.kTileVector2Default,
    objectsBuilder: _createObjectBuilder(sensorIds: sensorIds),
  );
}

/// Creates object builders for map entities and decorations
/// Following Flutter pattern of component factory methods
Map<String, ObjectBuilder> _createObjectBuilder({
  required List<String> sensorIds,
}) {
  final builders = <String, ObjectBuilder>{};

  // Add sensor builders for map navigation
  _addSensorBuilders(builders, sensorIds);

  // Add game entity builders
  _addEntityBuilders(builders);

  return builders;
}

/// Adds sensor builders for map transition detection
/// Following Flutter pattern of builder pattern implementation
void _addSensorBuilders(
  Map<String, ObjectBuilder> builders,
  List<String> sensorIds,
) {
  for (final sensorId in sensorIds) {
    builders[sensorId] = (properties) => _createMapSensor(sensorId, properties);
  }
}

/// Creates a map sensor from Tiled object properties
/// Following Flutter pattern of factory constructor methods
///
/// This factory method handles:
/// - Parsing player position from string coordinates
/// - Converting direction strings to Direction enums
/// - Mapping Tiled properties to GameplayMapSensor objects
/// - Validating required properties for map transitions
MapSensor _createMapSensor(String sensorId, TiledObjectProperties properties) {
  final positionParts = properties
      .others[GameplayMapConstants.kPlayerPositionPropertyKey]
      .toString()
      .split(',');
  final playerPosition = Vector2(
    double.parse(positionParts[0]),
    double.parse(positionParts[1]),
  );

  return MapSensor(
    id: sensorId,
    position: properties.position,
    size: properties.size,
    targetMap: properties.others[GameplayMapConstants.kNextMapPropertyKey]
        .toString(),
    playerPosition: playerPosition,
    playerDirection: Direction.fromName(
      properties.others[GameplayMapConstants.kPlayerDirectionPropertyKey]
          .toString(),
    ),
  );
}

void _addEntityBuilders(Map<String, ObjectBuilder> builders) {
  final entityBuilders = <String, ObjectBuilder>{
    // Interactive decorations
    GameplayMapManager.kBarrelDecorationType: (p) =>
        BarrelDecoration(position: p.position),

    GameplayMapManager.kDoorDecorationType: (p) =>
        DoorDecoration(position: p.position, size: p.size),
    GameplayMapManager.kDoorKeyDecorationType: (p) =>
        DoorKeyDecoration(p.position),
    GameplayMapManager.kLifePotionDecorationType: (p) =>
        LifePotionDecoration(p.position, LifePotionDecoration.kHealAmount),

    // Environmental decorations
    GameplayMapManager.kTorchDecorationType: (p) =>
        TorchDecoration(position: p.position),
    GameplayMapManager.kTorchDecorationEmptyType: (p) =>
        TorchDecoration.empty(position: p.position),
    GameplayMapManager.kSpikeTrapDecorationType: (p) =>
        SpikeTrapDecoration(position: p.position),

    // Non-player characters
    GameplayMapManager.kWizardEntityType: (p) => WizardNpc(p.position),
    GameplayMapManager.kKidEntityType: (p) => KidNpc(p.position),

    // Enemies
    GameplayMapManager.kBossEntityType: (p) => DungeonBossEnemy(p.position),
    GameplayMapManager.kMiniBossEntityType: (p) =>
        DungeonMiniBossEnemy(p.position),
    GameplayMapManager.kGoblinEntityType: (p) => GoblinEnemy(p.position),
    GameplayMapManager.kImpEntityType: (p) => ImpEnemy(p.position),

    // Farm
    GameplayMapManager.kFarmTileEntityType: (p) => FarmTile(p.position),
  };

  builders.addEntries(entityBuilders.entries);
}
