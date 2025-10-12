/// [MapId] enumeration of available map biomes
/// Following Flutter pattern of descriptive enum naming
enum MapId { map1, dungeon1 }

/// [GameplayMapConstants] responsible for centralizing map-related configuration
/// Following Flutter naming conventions for game map systems
class GameplayMapConstants {
  // Map transition timing constants
  static const double kSensorContactTime = 0; // 500ms delay
  static const int kTransitionDelayMs = 0; // Smooth transition delay
}
