import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_logger.dart';

/// [GameplayMapSensor] responsible for detecting player interaction with map transition areas
/// Following Flutter naming conventions for game sensor systems
class GameplayMapSensor extends GameDecoration with Sensor<Player> {
  // Sensor identification and configuration
  final String id;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  // Contact state management
  bool hasContact = false;
  bool _hasNavigated = false;
  double _contactTime = 0;

  /// Creates a map sensor for player navigation between maps
  /// Following Flutter pattern of descriptive constructors
  GameplayMapSensor(
    this.id,
    Vector2 position,
    Vector2 size,
    this.targetMap,
    this.playerPosition,
    this.playerDirection,
  ) : super(position: position, size: size);

  @override
  void onContact(Player component) {
    if (!hasContact && !_hasNavigated) {
      hasContact = true;
      _contactTime = 0;
      _logSensorEvent('Player entered sensor $id');
    }
    super.onContact(component);
  }

  @override
  void onContactExit(Player component) {
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('Player exited sensor $id');
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;

      if (_contactTime >= MapConstants.sensorContactTime) {
        _initiateMapTransition();
      }
    }
    super.update(dt);
  }

  /// Resets the sensor navigation state
  /// Following Flutter pattern of component state management
  void resetNavigationState() {
    _hasNavigated = false;
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('Reset navigation state for sensor $id');
  }

  /// Initiates map transition with smooth timing
  /// Following Flutter pattern of private utility methods
  void _initiateMapTransition() {
    _hasNavigated = true;
    hasContact = false;

    AppLogger.info(
      'MapSensor: Navigating to $targetMap, position: $playerPosition, direction: $playerDirection',
    );

    // Delayed transition for smooth gameplay experience
    Future.delayed(
      Duration(milliseconds: MapConstants.transitionDelayMs),
      () => _performNavigation(),
    );
  }

  /// Performs the actual map navigation
  /// Following Flutter pattern of separation of concerns
  void _performNavigation() {
    MapNavigator.of(context).toNamed(
      targetMap,
      arguments: MapArguments(playerPosition, playerDirection),
    );
  }

  /// Logs sensor events for debugging
  /// Following Flutter pattern of centralized logging
  void _logSensorEvent(String message) {
    AppLogger.debug('MapSensor: $message');
  }
}
