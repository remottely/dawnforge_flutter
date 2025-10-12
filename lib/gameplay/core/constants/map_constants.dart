import 'package:bonfire/bonfire.dart';

/// [MapConstants] responsible for centralizing map-related configuration
/// Following Flutter naming conventions for game map systems
class MapConstants {
  // Map asset paths following _k constant pattern
  static const String _kMap1Asset = 'tiled/map_1.json';
  static const String _kDungeon1Asset = 'tiled/dungeon_1.json';

  // Map transition timing constants
  static const double _kSensorContactTime = 0.5; // 500ms delay
  static const int _kTransitionDelayMs = 100; // Smooth transition delay

  // Sensor configuration constants
  static const List<String> _kMap1SensorIds = [
    'sensor_dungeon_1',
    'sensor_dungeon_2',
  ];
  static const List<String> _kDungeon1SensorIds = ['sensor_map_1'];

  // Getter methods for asset paths
  static String get map1Asset => _kMap1Asset;
  static String get dungeon1Asset => _kDungeon1Asset;

  // Getter methods for timing
  static double get sensorContactTime => _kSensorContactTime;
  static int get transitionDelayMs => _kTransitionDelayMs;

  // Getter methods for sensor configurations
  static List<String> get map1SensorIds => _kMap1SensorIds;
  static List<String> get dungeon1SensorIds => _kDungeon1SensorIds;
}

/// [MapBiomeId] enumeration of available map biomes
/// Following Flutter pattern of descriptive enum naming
enum MapBiomeId { none, map1, dungeon1 }

/// [MapArguments] data class for map navigation parameters
/// Following Flutter pattern of immutable data classes
class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  const MapArguments(this.playerPosition, this.playerDirection);
}
