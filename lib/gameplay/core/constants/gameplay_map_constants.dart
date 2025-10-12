/// [MapId] enumeration of available map biomes
/// Following Flutter pattern of descriptive enum naming
enum MapId { map1, dungeon1 }

/// [GameplayMapConstants] responsible for centralizing map-related configuration
/// Following Flutter naming conventions for game map systems
class GameplayMapConstants {
  // Map transition timing constants
  static const double kSensorContactTime = 0.5; // 500ms delay
  static const int kTransitionDelayMs = 100; // Smooth transition delay

  // Map navigation constants
  static const String kMapNavigationLogPrefix = 'MapNavigation';
  static const String kSensorLogPrefix = 'MapSensor';

  // Map property keys for consistency
  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';
}
