import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/map/map_data.dart';
import 'package:darkness_dungeon/gameplay/decorations/interactables/map_transition_sensor.dart';
import 'package:flutter/widgets.dart';

class MapManager {
  static MapTransitionSensorView _createMapSensor(
    String sensorId,
    TiledObjectProperties properties,
  ) {
    final List<String> _positionParts = properties
        .others[MapConfig.kPlayerPositionPropertyKey]
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
      targetMap: properties.others[MapConfig.kNextMapPropertyKey].toString(),
      playerPosition: _playerPosition,
      playerDirection: Direction.fromName(
        properties.others[MapConfig.kPlayerDirectionPropertyKey].toString(),
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
    builders.addEntries(MapConfig.createEntityBuilder().entries);
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
      forceTileSize: TileConstants.tileSizeStandard,
      objectsBuilder: _createObjectBuilder(sensorIds: sensorIds),
    );
  }

  static MapItem _createMapItem(MapData data) {
    return MapItem(
      id: data.id,
      properties: data.properties,
      map: _buildMapByTiled(mapAsset: data.asset, sensorIds: data.sensorIds),
    );
  }

  static final Map<String, MapItem Function(BuildContext, Object?)> allMaps =
      (() {
        final mapBuilders = <String, MapItemBuilder>{};

        for (final config in MapConfig.kAllMaps) {
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
