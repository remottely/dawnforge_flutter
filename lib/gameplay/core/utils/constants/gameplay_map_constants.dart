enum MapId { map1, dungeon1 }

class GameplayMapConstants {
  static const double kSensorContactTime = 0.5;
  static const int kTransitionDelayMs = 100;

  static const String kMapNavigationLogPrefix = 'MapNavigation';
  static const String kSensorLogPrefix = 'MapSensor';

  static const String kNextMapPropertyKey = 'nextMap';
  static const String kPlayerPositionPropertyKey = 'playerPosition';
  static const String kPlayerDirectionPropertyKey = 'playerDirection';
}
