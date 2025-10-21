import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_logger.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

/// [MapSensor] responsible for detecting player interaction with map transition areas
/// Following Flutter naming conventions for game sensor systems

abstract class _MapSensorData {
  static const String playerEnteredEvent = 'Player entered sensor';
  static const String playerExitedEvent = 'Player exited sensor';
  static const String navigationInitiatedEvent = 'Navigating to';
  static const String resetNavigationEvent =
      'Reset navigation state for sensor';
  static double get sensorContactTime =>
      GameplayMapConstants.kSensorContactTime;
  static int get transitionDelayMs => GameplayMapConstants.kTransitionDelayMs;
  static String get mapNavigationLogPrefix =>
      GameplayMapConstants.kMapNavigationLogPrefix;
  static String get sensorLogPrefix => GameplayMapConstants.kSensorLogPrefix;
}

class MapSensor extends DFSensorPlayerDecoration {
  final String id;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  bool hasContact = false;
  bool _hasNavigated = false;
  double _contactTime = 0;

  MapSensor({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    required this.targetMap,
    required this.playerPosition,
    required this.playerDirection,
  }) : super(position: position, size: size);

  @override
  void onContact(KnightPlayer component) {
    if (!hasContact && !_hasNavigated) {
      hasContact = true;
      _contactTime = 0;
      _logSensorEvent('${_MapSensorData.playerEnteredEvent} $id');
    }
    super.onContact(component);
  }

  @override
  void onContactExit(KnightPlayer component) {
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('${_MapSensorData.playerExitedEvent} $id');
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;
      if (_contactTime >= _MapSensorData.sensorContactTime) {
        _initiateMapTransition();
      }
    }
    super.update(dt);
  }

  void resetNavigationState() {
    _hasNavigated = false;
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('${_MapSensorData.resetNavigationEvent} $id');
  }

  void _initiateMapTransition() {
    _hasNavigated = true;
    hasContact = false;
    AppLogger.info(
      '${_MapSensorData.mapNavigationLogPrefix}: ${_MapSensorData.navigationInitiatedEvent} $targetMap, position: $playerPosition, direction: $playerDirection',
    );
    Future.delayed(
      Duration(milliseconds: _MapSensorData.transitionDelayMs),
      () => _performNavigation(),
    );
  }

  void _performNavigation() {
    MapNavigator.of(context).toNamed(
      targetMap,
      arguments: MapArguments(
        playerPosition: playerPosition,
        playerDirection: playerDirection,
      ),
    );
  }

  void _logSensorEvent(String message) {
    AppLogger.debug('${_MapSensorData.sensorLogPrefix}: $message');
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
