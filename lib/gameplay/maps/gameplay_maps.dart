import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/decoration/door.dart';
import 'package:darkness_dungeon/gameplay/decoration/key.dart';
import 'package:darkness_dungeon/gameplay/decoration/life_potion.dart';
import 'package:darkness_dungeon/gameplay/decoration/spikes.dart';
import 'package:darkness_dungeon/gameplay/decoration/torch.dart';
import 'package:darkness_dungeon/gameplay/enemies/boss.dart';
import 'package:darkness_dungeon/gameplay/enemies/goblin.dart';
import 'package:darkness_dungeon/gameplay/enemies/imp.dart';
import 'package:darkness_dungeon/gameplay/enemies/mini_boss.dart';
import 'package:darkness_dungeon/gameplay/maps/multiscenario_assets.dart';
import 'package:darkness_dungeon/gameplay/maps/map_id_enum.dart';
import 'package:darkness_dungeon/gameplay/maps/map_sensor.dart';
import 'package:darkness_dungeon/gameplay/npc/kid.dart';
import 'package:darkness_dungeon/gameplay/npc/wizard_npc.dart';

final String map1Path = MapBiomeId.map1.name;
final String dungeon1Path = MapBiomeId.dungeon1.name;

abstract class GameplayMaps {
  static get maps => {
    map1Path: (context, args) => MapItem(
      id: map1Path,
      map: _buildMap(
        mapAsset: MultiScenarioAssets.map1,
        sensorIds: ['sensor_dungeon_1', 'sensor_dungeon_2'],
      ),
    ),
    dungeon1Path: (context, args) => MapItem(
      id: dungeon1Path,
      map: _buildMap(
        mapAsset: MultiScenarioAssets.dungeon1,
        sensorIds: ['sensor_map_1'],
      ),
    ),
  };

  static WorldMapByTiled _buildMap({
    required String mapAsset,
    required List<String> sensorIds,
  }) {
    return WorldMapByTiled(
      WorldMapReader.fromAsset(mapAsset),
      // WorldMapReader.fromAsset('SunnysideWorld/tiles/Level-001.json'),
      // WorldMapReader.fromAsset('tiled/map1.tmx'),
      forceTileSize: Vector2.all(GameplayConstants.kCurrentTileSize),
      objectsBuilder: _objectBuilder(sensorIds: sensorIds),
    );
  }

  static Map<String, ObjectBuilder> _objectBuilder({
    required List<String> sensorIds,
  }) {
    final builders = <String, ObjectBuilder>{};

    for (final sensorId in sensorIds) {
      builders[sensorId] = (p) {
        final parts = p.others['playerPosition'].toString().split(',');
        Vector2 playerPosition = Vector2(
          double.parse(parts[0]),
          double.parse(parts[1]),
        );
        return MapSensor(
          sensorId,
          p.position,
          p.size,
          p.others['nextMap'].toString(),
          playerPosition,
          Direction.fromName(p.others['playerDirection'].toString()),
        );
      };
    }

    final darknessDungeon = {
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
      'wizard': (p) => WizardNPC(p.position),
      'kid': (p) => Kid(p.position),

      // Enemies
      'boss': (p) => DungeonBoss(p.position),
      'mini_boss': (p) => MiniBoss(p.position),
      'goblin': (p) => Goblin(p.position),
      'imp': (p) => Imp(p.position),
    };

    builders.addEntries(darknessDungeon.entries);

    return builders;
  }
}

class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  MapArguments(this.playerPosition, this.playerDirection);
}
