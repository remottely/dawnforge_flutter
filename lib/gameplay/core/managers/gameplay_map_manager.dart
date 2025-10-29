import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/data/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
import 'package:flutter/widgets.dart';

class GameplayMapManager {
  static MapTransitionSensorView _createMapSensor(
    String sensorId,
    TiledObjectProperties properties,
  ) {
    final positionParts = properties
        .others[GameplayMapConfig.kPlayerPositionPropertyKey]
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
      targetMap: properties.others[GameplayMapConfig.kNextMapPropertyKey]
          .toString(),
      playerPosition: playerPosition,
      playerDirection: Direction.fromName(
        properties.others[GameplayMapConfig.kPlayerDirectionPropertyKey]
            .toString(),
      ),
    );
  }

  static void _addSensorBuilders(
    Map<String, ObjectBuilder> builders,
    List<String> sensorIds,
  ) {
    for (final sensorId in sensorIds) {
      builders[sensorId] = (properties) =>
          _createMapSensor(sensorId, properties);
    }
  }

  static void _addEntityBuilders(Map<String, ObjectBuilder> builders) {
    builders.addEntries(GameplayMapConfig.entityBuilders.entries);
  }

  static Map<String, ObjectBuilder> _createObjectBuilder({
    required List<String> sensorIds,
  }) {
    final builders = <String, ObjectBuilder>{};

    _addSensorBuilders(builders, sensorIds);

    _addEntityBuilders(builders);

    return builders;
  }

  static WorldMapByTiled _buildMap({
    required String mapAsset,
    required List<String> sensorIds,
  }) {
    return WorldMapByTiled(
      WorldMapReader.fromAsset(mapAsset),
      forceTileSize: GameplayTileConfig.fTileSizeStandard,
      objectsBuilder: _createObjectBuilder(sensorIds: sensorIds),
    );
  }

  static MapItem _createMapItem(GameplayMapData data) {
    return MapItem(
      id: data.id.name,
      properties: data.properties,
      map: _buildMap(mapAsset: data.asset, sensorIds: data.sensorIds),
    );
  }

  static final fAllMaps = (() {
    final mapBuilders = <String, MapItemBuilder>{};

    for (final config in GameplayMapConfig.kAllMaps) {
      mapBuilders[config.id.name] = (context, args) => _createMapItem(config);
    }

    return mapBuilders;
  })();

  static MapItem? byId(BuildContext context, MapId id) {
    final builder = fAllMaps[id.name];

    if (builder != null) return builder(context, null);

    return null;
  }
}
