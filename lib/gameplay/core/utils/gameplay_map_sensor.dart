import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/app_logger.dart';

/// [GameplayMapSensor] responsible for detecting player interaction with map transition areas
/// Following Flutter naming conventions for game sensor systems
class GameplayMapSensor extends GameDecoration with Sensor<Player> {
  // Flutter-style constants for sensor events
  static const String kPlayerEnteredEvent = 'Player entered sensor';
  static const String kPlayerExitedEvent = 'Player exited sensor';
  static const String kNavigationInitiatedEvent = 'Navigating to';
  static const String kResetNavigationEvent =
      'Reset navigation state for sensor';

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
  GameplayMapSensor({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    required this.targetMap,
    required this.playerPosition,
    required this.playerDirection,
  }) : super(position: position, size: size);

  @override
  void onContact(Player component) {
    if (!hasContact && !_hasNavigated) {
      hasContact = true;
      _contactTime = 0;
      _logSensorEvent('$kPlayerEnteredEvent $id');
    }
    super.onContact(component);
  }

  @override
  void onContactExit(Player component) {
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('$kPlayerExitedEvent $id');
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;

      if (_contactTime >= GameplayMapConstants.kSensorContactTime) {
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
    _logSensorEvent('$kResetNavigationEvent $id');
  }

  /// Initiates map transition with smooth timing
  /// Following Flutter pattern of private utility methods
  void _initiateMapTransition() {
    _hasNavigated = true;
    hasContact = false;

    AppLogger.info(
      '${GameplayMapConstants.kMapNavigationLogPrefix}: $kNavigationInitiatedEvent $targetMap, position: $playerPosition, direction: $playerDirection',
    );

    // Delayed transition for smooth gameplay experience
    Future.delayed(
      Duration(milliseconds: GameplayMapConstants.kTransitionDelayMs),
      () => _performNavigation(),
    );
  }

  /// Performs the actual map navigation
  /// Following Flutter pattern of separation of concerns
  void _performNavigation() {
    MapNavigator.of(context).toNamed(
      targetMap,
      arguments: MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      ),
    );
  }

  /// Logs sensor events for debugging
  /// Following Flutter pattern of centralized logging
  void _logSensorEvent(String message) {
    AppLogger.debug('${GameplayMapConstants.kSensorLogPrefix}: $message');
  }
}

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
