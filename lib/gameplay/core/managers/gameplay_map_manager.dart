import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/models/map_model.dart';
import 'package:darkness_dungeon/gameplay/core/utils/gameplay_map_sensor.dart';
import 'package:darkness_dungeon/gameplay/decoration/door.dart';
import 'package:darkness_dungeon/gameplay/decoration/key.dart';
import 'package:darkness_dungeon/gameplay/decoration/life_potion.dart';
import 'package:darkness_dungeon/gameplay/decoration/spikes.dart';
import 'package:darkness_dungeon/gameplay/decoration/torch.dart';
import 'package:darkness_dungeon/gameplay/enemies/dungeon_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/enemies/goblin_enemy.dart';
import 'package:darkness_dungeon/gameplay/enemies/imp_enemy.dart';
import 'package:darkness_dungeon/gameplay/enemies/mini_boss_enemy.dart';
import 'package:darkness_dungeon/gameplay/npc/kid_npc.dart';
import 'package:darkness_dungeon/gameplay/npc/wizard_npc.dart';

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
  static const String kDoorEntityType = 'door';
  static const String kKeyEntityType = 'key';
  static const String kPotionEntityType = 'potion';
  static const String kTorchEntityType = 'torch';
  static const String kTorchEmptyEntityType = 'torch_empty';
  static const String kSpikesEntityType = 'spikes';
  static const String kWizardEntityType = 'wizard';
  static const String kKidEntityType = 'kid';
  static const String kBossEntityType = 'boss';
  static const String kMiniBossEntityType = 'mini_boss';
  static const String kGoblinEntityType = 'goblin';
  static const String kImpEntityType = 'imp';

  // Private constructor to prevent instantiation
  GameplayMapManager._();

  /// Gets the complete map configuration for the game
  /// Following Flutter pattern of static factory methods
  static Map<String, MapItemBuilder> get maps {
    final mapBuilders = <String, MapItemBuilder>{};

    // Build maps from centralized configuration
    for (final config in MapModel.allMaps) {
      mapBuilders[config.id.name] = (context, args) => _createMapItem(config);
    }

    return mapBuilders;
  }

  /// Creates a MapItem from configuration
  /// Following Flutter pattern of factory methods
  static MapItem _createMapItem(MapModel config) {
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
    forceTileSize: Vector2.all(GameplayConstants.kCurrentTileSize),
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
GameplayMapSensor _createMapSensor(
  String sensorId,
  TiledObjectProperties properties,
) {
  final positionParts = properties
      .others[GameplayMapConstants.kPlayerPositionPropertyKey]
      .toString()
      .split(',');
  final playerPosition = Vector2(
    double.parse(positionParts[0]),
    double.parse(positionParts[1]),
  );

  return GameplayMapSensor(
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

/// Adds entity builders for interactive game objects
/// Following Flutter pattern of comprehensive object mapping
///
/// This method handles factory creation for:
/// - Interactive decorations (doors, keys, potions, spikes, torches)
/// - Enemy entities (goblins, imps, mini-boss, dungeon boss)
/// - NPC characters (wizard, kid)
/// - Position and size mapping from Tiled object properties
void _addEntityBuilders(Map<String, ObjectBuilder> builders) {
  final entityBuilders = <String, ObjectBuilder>{
    // Interactive decorations
    GameplayMapManager.kDoorEntityType: (p) => Door(p.position, p.size),
    GameplayMapManager.kKeyEntityType: (p) => DoorKey(p.position),
    GameplayMapManager.kPotionEntityType: (p) =>
        LifePotion(p.position, GameplayConstants.kLifePotionHealAmount),

    // Environmental decorations
    GameplayMapManager.kTorchEntityType: (p) => Torch(p.position),
    GameplayMapManager.kTorchEmptyEntityType: (p) =>
        Torch(p.position, isExtinguished: true),
    GameplayMapManager.kSpikesEntityType: (p) => Spikes(p.position),

    // Non-player characters
    GameplayMapManager.kWizardEntityType: (p) => WizardNpc(p.position),
    GameplayMapManager.kKidEntityType: (p) => KidNpc(p.position),

    // Enemies
    GameplayMapManager.kBossEntityType: (p) => DungeonBossEnemy(p.position),
    GameplayMapManager.kMiniBossEntityType: (p) => MiniBossEnemy(p.position),
    GameplayMapManager.kGoblinEntityType: (p) => GoblinEnemy(p.position),
    GameplayMapManager.kImpEntityType: (p) => ImpEnemy(p.position),
  };

  builders.addEntries(entityBuilders.entries);
}
