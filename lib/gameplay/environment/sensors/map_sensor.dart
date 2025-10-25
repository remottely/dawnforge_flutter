import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/app_logger.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

abstract class _MapSensorConfig {
  static const String playerEnteredEvent = 'Player entered sensor';
  static const String playerExitedEvent = 'Player exited sensor';
  static const String navigationInitiatedEvent = 'Navigating to';
  static const String resetNavigationEvent =
      'Reset navigation state for sensor';
  static final double sensorContactTime =
      GameplayMapConstants.kSensorContactTime;
  static final int transitionDelayMs = GameplayMapConstants.kTransitionDelayMs;
  static final String mapNavigationLogPrefix =
      GameplayMapConstants.kMapNavigationLogPrefix;
  static final String sensorLogPrefix = GameplayMapConstants.kSensorLogPrefix;
}

class MapSensorView extends DFSensorPlayerDecoration {
  final String id;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  bool hasContact = false;
  bool _hasNavigated = false;
  double _contactTime = 0;

  MapSensorView({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    required this.targetMap,
    required this.playerPosition,
    required this.playerDirection,
  }) : super(position: position, size: size);

  @override
  void onContact(KnightPlayerView component) {
    if (!hasContact && !_hasNavigated) {
      hasContact = true;
      _contactTime = 0;
      _logSensorEvent('${_MapSensorConfig.playerEnteredEvent} $id');
    }
    super.onContact(component);
  }

  @override
  void onContactExit(KnightPlayerView component) {
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('${_MapSensorConfig.playerExitedEvent} $id');
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;
      if (_contactTime >= _MapSensorConfig.sensorContactTime) {
        _initiateMapTransition();
      }
    }
    super.update(dt);
  }

  void resetNavigationState() {
    _hasNavigated = false;
    hasContact = false;
    _contactTime = 0;
    _logSensorEvent('${_MapSensorConfig.resetNavigationEvent} $id');
  }

  void _initiateMapTransition() {
    _hasNavigated = true;
    hasContact = false;
    AppLogger.info(
      '${_MapSensorConfig.mapNavigationLogPrefix}: ${_MapSensorConfig.navigationInitiatedEvent} $targetMap, position: $playerPosition, direction: $playerDirection',
    );
    Future.delayed(
      Duration(milliseconds: _MapSensorConfig.transitionDelayMs),
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
    AppLogger.debug('${_MapSensorConfig.sensorLogPrefix}: $message');
  }
}

class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  const MapArguments({
    required this.playerPosition,
    required this.playerDirection,
  });
}
