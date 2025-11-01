import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/gameplay_map_data.dart';
import 'package:darkness_dungeon/gameplay/environment/sensors/map_transition_sensor.dart';
import 'package:flutter/widgets.dart';

class GameplayMapManager {
  static MapTransitionSensorView _createMapSensor(
    String sensorId,
    TiledObjectProperties properties,
  ) {
    final List<String> _fPositionParts = properties
        .others[GameplayMapConfig.kPlayerPositionPropertyKey]
        .toString()
        .split(',');
    final Vector2 _fPlayerPosition = Vector2(
      double.parse(_fPositionParts[0]),
      double.parse(_fPositionParts[1]),
    );

    return MapTransitionSensorView(
      id: sensorId,
      position: properties.position,
      size: properties.size,
      targetMap: properties.others[GameplayMapConfig.kNextMapPropertyKey]
          .toString(),
      playerPosition: _fPlayerPosition,
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
    builders.addEntries(GameplayMapConfig.createEntityBuilder().entries);
  }

  static Map<String, ObjectBuilder> _createObjectBuilder({
    required List<String> sensorIds,
  }) {
    final builders = <String, ObjectBuilder>{};

    _addSensorBuilders(builders, sensorIds);
    _addEntityBuilders(builders);

    return builders;
  }

  static WorldMapByTiled _buildMapByTiled({
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
      map: _buildMapByTiled(mapAsset: data.asset, sensorIds: data.sensorIds),
    );
  }

  static final Map<String, MapItem Function(BuildContext, Object?)> fAllMaps =
      (() {
        final mapBuilders = <String, MapItemBuilder>{};

        for (final config in GameplayMapConfig.kAllMaps) {
          mapBuilders[config.id.name] = (context, args) =>
              _createMapItem(config);
        }

        return mapBuilders;
      })();

  static MapItem? getMapById(BuildContext context, MapId id) {
    final builder = fAllMaps[id.name];

    if (builder != null) return builder(context, null);

    return null;
  }
}
