import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
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

class GameplayMapManager {
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

  GameplayMapManager._();

  static final Map<String, MapItemBuilder> maps = (() {
    final mapBuilders = <String, MapItemBuilder>{};

    for (final config in GameplayMapData.allMaps) {
      mapBuilders[config.id.name] = (context, args) => _createMapItem(config);
    }

    return mapBuilders;
  })();

  static MapItem _createMapItem(GameplayMapData config) {
    return MapItem(
      id: config.id.name,
      properties: config.properties,
      map: _buildMap(mapAsset: config.asset, sensorIds: config.sensorIds),
    );
  }
}

WorldMapByTiled _buildMap({
  required String mapAsset,
  required List<String> sensorIds,
}) {
  return WorldMapByTiled(
    WorldMapReader.fromAsset(mapAsset),
    forceTileSize: GameplayConstants.kTileSizeStandard,
    objectsBuilder: _createObjectBuilder(sensorIds: sensorIds),
  );
}

Map<String, ObjectBuilder> _createObjectBuilder({
  required List<String> sensorIds,
}) {
  final builders = <String, ObjectBuilder>{};

  _addSensorBuilders(builders, sensorIds);

  _addEntityBuilders(builders);

  return builders;
}

void _addSensorBuilders(
  Map<String, ObjectBuilder> builders,
  List<String> sensorIds,
) {
  for (final sensorId in sensorIds) {
    builders[sensorId] = (properties) => _createMapSensor(sensorId, properties);
  }
}

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
    GameplayMapManager.kBarrelDecorationType: (p) =>
        BarrelDecoration(position: p.position),

    GameplayMapManager.kDoorDecorationType: (p) =>
        DoorDecoration(position: p.position, size: p.size),
    GameplayMapManager.kDoorKeyDecorationType: (p) =>
        DoorKeyDecoration(position: p.position),
    GameplayMapManager.kLifePotionDecorationType: (p) => LifePotionDecoration(
      position: p.position,
      healAmount: LifePotionData.healAmount,
    ),

    GameplayMapManager.kTorchDecorationType: (p) =>
        TorchDecoration(position: p.position),
    GameplayMapManager.kTorchDecorationEmptyType: (p) =>
        TorchDecoration.empty(position: p.position),
    GameplayMapManager.kSpikeTrapDecorationType: (p) =>
        SpikeTrapDecoration(position: p.position),

    GameplayMapManager.kWizardEntityType: (p) => WizardNpcView(p.position),
    GameplayMapManager.kKidEntityType: (p) => KidNpcView(p.position),

    GameplayMapManager.kBossEntityType: (p) => DungeonBossEnemyView(p.position),
    GameplayMapManager.kMiniBossEntityType: (p) =>
        DungeonMiniBossEnemyView(p.position),

    GameplayMapManager.kGoblinEntityType: (p) => GoblinEnemyView(p.position),

    GameplayMapManager.kImpEntityType: (p) => ImpEnemyView(p.position),

    GameplayMapManager.kFarmTileEntityType: (p) => FarmTile(p.position),
  };

  builders.addEntries(entityBuilders.entries);
}
