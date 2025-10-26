import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_view.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/barrel_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/torch_decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/door_key_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/life_potion_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/interactables/spike_trap_interactable.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
import 'package:darkness_dungeon/gameplay/terrain/farmable/farm_tile.dart';

class GameplayMapManager {
  static const kBarrelDecorationType = 'barrel_decoration';
  static const kLifePotionDecorationType = 'life_potion_interactable';
  static const kTorchDecorationType = 'torch_decoration';
  static const kTorchDecorationEmptyType = 'torch_decoration_empty';
  static const kSpikeTrapInteractableType = 'spike_trap_interactable';

  static const kDoorInteractableType = 'door_interactable';
  static const kDoorKeyInteractableType = 'door_key_interactable';

  static const kWizardEntityType = 'wizard';
  static const kKidEntityType = 'kid';
  static const kBossEntityType = 'dungeon_boss';
  static const kMiniBossEntityType = 'dungeon_mini_boss';
  static const kGoblinEntityType = 'goblin';
  static const kImpEntityType = 'imp';
  static const kFarmTileEntityType = 'farm_tile';

  static final Map<String, MapItemBuilder> fMaps = (() {
    final mapBuilders = <String, MapItemBuilder>{};

    for (final config in GameplayMapConfig.kAllMaps) {
      mapBuilders[config.id.name] = (context, args) => _createMapItem(config);
    }

    return mapBuilders;
  })();

  static MapItem _createMapItem(GameplayMapConfig config) {
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

MapTransitionSensorView _createMapSensor(
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

  return MapTransitionSensorView(
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
        BarrelDecorationView(position: p.position),

    GameplayMapManager.kDoorInteractableType: (p) =>
        DoorInteractableView(position: p.position, size: p.size),
    GameplayMapManager.kDoorKeyInteractableType: (p) =>
        DoorKeyInteractableView(position: p.position),
    GameplayMapManager.kLifePotionDecorationType: (p) =>
        LifePotionDecorationView(
          position: p.position,
          healAmount: LifePotionConfig.kHealAmount,
        ),

    GameplayMapManager.kTorchDecorationType: (p) =>
        TorchDecorationView(position: p.position),
    GameplayMapManager.kTorchDecorationEmptyType: (p) =>
        TorchDecorationView.empty(position: p.position),
    GameplayMapManager.kSpikeTrapInteractableType: (p) =>
        SpikeTrapInteractableView(position: p.position),

    GameplayMapManager.kWizardEntityType: (p) => WizardNpcView(p.position),
    GameplayMapManager.kKidEntityType: (p) => KidNpcView(p.position),

    GameplayMapManager.kBossEntityType: (p) => DungeonBossEnemyView(p.position),
    GameplayMapManager.kMiniBossEntityType: (p) =>
        DungeonMiniBossEnemyView(p.position),

    GameplayMapManager.kGoblinEntityType: (p) => GoblinEnemyView(p.position),

    GameplayMapManager.kImpEntityType: (p) => ImpEnemyView(p.position),

    GameplayMapManager.kFarmTileEntityType: (p) => FarmTileView(p.position),
  };

  builders.addEntries(entityBuilders.entries);
}
