enum MapId { map1, dungeon1 }

class GameplayMapConstants {
  static const kSensorContactTime = 0.5;
  static const kTransitionDelayMs = 100;

  static const kMapNavigationLogPrefix = 'MapNavigation';
  static const kSensorLogPrefix = 'MapSensor';

  static const kNextMapPropertyKey = 'nextMap';
  static const kPlayerPositionPropertyKey = 'playerPosition';
  static const kPlayerDirectionPropertyKey = 'playerDirection';
}
