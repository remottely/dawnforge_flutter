import 'package:bonfire/bonfire.dart';

/// [MapConstants] responsible for centralizing map-related configuration
/// Following Flutter naming conventions for game map systems
class MapConstants {
  // Map asset paths following _k constant pattern
  static const String kMap1Asset = 'tiled/map_1.json';
  static const String kDungeon1Asset = 'tiled/dungeon_1.json';

  // Map transition timing constants
  static const double kSensorContactTime = 0.5; // 500ms delay
  static const int kTransitionDelayMs = 100; // Smooth transition delay

  // Sensor configuration constants
  static const List<String> kMap1SensorIds = [
    'sensor_dungeon_1',
    'sensor_dungeon_2',
  ];
  static const List<String> kDungeon1SensorIds = ['sensor_map_1'];
}

/// [MapBiomeId] enumeration of available map biomes
/// Following Flutter pattern of descriptive enum naming
enum MapBiomeId { none, map1, dungeon1 }

/// [MapArguments] data class for map navigation parameters
/// Following Flutter pattern of immutable data classes
class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  const MapArguments({
    required this.playerPosition,
    required this.playerDirection,
  });
}
