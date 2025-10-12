import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/constants/map_constants.dart';
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
class GameplayMapManager {
  // Private constructor to prevent instantiation
  GameplayMapManager._();

  /// Gets the complete map configuration for the game
  /// Following Flutter pattern of static factory methods
  static Map<String, MapItemBuilder> get maps => {
    MapBiomeId.map1.name: (context, args) => MapItem(
      id: MapBiomeId.map1.name,
      map: _buildMap(
        mapAsset: MapConstants.map1Asset,
        sensorIds: MapConstants.map1SensorIds,
      ),
    ),
    MapBiomeId.dungeon1.name: (context, args) => MapItem(
      id: MapBiomeId.dungeon1.name,
      map: _buildMap(
        mapAsset: MapConstants.dungeon1Asset,
        sensorIds: MapConstants.dungeon1SensorIds,
      ),
    ),
  };

  /// Builds a tiled world map with specified configuration
  /// Following Flutter pattern of private factory methods
  static WorldMapByTiled _buildMap({
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
  static Map<String, ObjectBuilder> _createObjectBuilder({
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
  static void _addSensorBuilders(
    Map<String, ObjectBuilder> builders,
    List<String> sensorIds,
  ) {
    for (final sensorId in sensorIds) {
      builders[sensorId] = (properties) =>
          _createMapSensor(sensorId, properties);
    }
  }

  /// Creates a map sensor from Tiled object properties
  /// Following Flutter pattern of factory constructor methods
  static GameplayMapSensor _createMapSensor(
    String sensorId,
    TiledObjectProperties properties,
  ) {
    final positionParts = properties.others['playerPosition'].toString().split(
      ',',
    );
    final playerPosition = Vector2(
      double.parse(positionParts[0]),
      double.parse(positionParts[1]),
    );

    // Read background music from Tiled properties (optional field)
    final backgroundMusic = properties.others['backgroundMusic']?.toString();

    return GameplayMapSensor(
      sensorId,
      properties.position,
      properties.size,
      properties.others['nextMap'].toString(),
      playerPosition,
      Direction.fromName(properties.others['playerDirection'].toString()),
      backgroundMusic: backgroundMusic,
    );
  }

  /// Adds entity builders for interactive game objects
  /// Following Flutter pattern of comprehensive object mapping
  static void _addEntityBuilders(Map<String, ObjectBuilder> builders) {
    final entityBuilders = <String, ObjectBuilder>{
      // Interactive decorations
      'door': (p) => Door(p.position, p.size),
      'key': (p) => DoorKey(p.position),
      'potion': (p) =>
          LifePotion(p.position, GameplayConstants.kLifePotionHealAmount),

      // Environmental decorations
      'torch': (p) => Torch(p.position),
      'torch_empty': (p) => Torch(p.position, isExtinguished: true),
      'spikes': (p) => Spikes(p.position),

      // Non-player characters
      'wizard': (p) => WizardNpc(p.position),
      'kid': (p) => KidNpc(p.position),

      // Enemies
      'boss': (p) => DungeonBossEnemy(p.position),
      'mini_boss': (p) => MiniBossEnemy(p.position),
      'goblin': (p) => GoblinEnemy(p.position),
      'imp': (p) => ImpEnemy(p.position),
    };

    builders.addEntries(entityBuilders.entries);
  }
}
