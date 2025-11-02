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
    final List<String> _positionParts = properties
        .others[GameplayMapConfig.kPlayerPositionPropertyKey]
        .toString()
        .split(',');
    final Vector2 _playerPosition = Vector2(
      double.parse(_positionParts[0]),
      double.parse(_positionParts[1]),
    );

    return MapTransitionSensorView(
      id: sensorId,
      position: properties.position,
      size: properties.size,
      targetMap: properties.others[GameplayMapConfig.kNextMapPropertyKey]
          .toString(),
      playerPosition: _playerPosition,
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
      forceTileSize: GameplayTileConfig.tileSizeStandard,
      objectsBuilder: _createObjectBuilder(sensorIds: sensorIds),
    );
  }

  static MapItem _createMapItem(GameplayMapData data) {
    return MapItem(
      id: data.id,
      properties: data.properties,
      map: _buildMapByTiled(mapAsset: data.asset, sensorIds: data.sensorIds),
    );
  }

  static final Map<String, MapItem Function(BuildContext, Object?)> allMaps =
      (() {
        final mapBuilders = <String, MapItemBuilder>{};

        for (final config in GameplayMapConfig.kAllMaps) {
          mapBuilders[config.id] = (context, args) => _createMapItem(config);
        }

        return mapBuilders;
      })();

  static MapItem? getMapById(BuildContext context, String id) {
    final builder = allMaps[id];

    if (builder != null) return builder(context, null);

    return null;
  }
}
