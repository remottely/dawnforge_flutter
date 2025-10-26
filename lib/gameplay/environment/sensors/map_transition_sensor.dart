import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_map_constants.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _MapSensorConfig {
  static const _kPlayerEnteredEvent = 'Player entered sensor';
  static const _kPlayerExitedEvent = 'Player exited sensor';
  static const _kNavigationInitiatedEvent = 'Navigating to';
  static const _kResetNavigationEvent = 'Reset navigation state for sensor';
  static const _kSensorContactTime = GameplayMapConstants.kSensorContactTime;
  static const _kTransitionDelayMs = GameplayMapConstants.kTransitionDelayMs;
  static const _kMapNavigationLogPrefix =
      GameplayMapConstants.kMapNavigationLogPrefix;
  static const _kSensorLogPrefix = GameplayMapConstants.kSensorLogPrefix;
}

class MapTransitionSensorView extends DDSensorPlayerDecoration {
  final String id;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  bool hasContact = false;
  bool _hasNavigated = false;
  double _contactTime = 0;

  MapTransitionSensorView({
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
    }
    super.onContact(component);
  }

  @override
  void onContactExit(KnightPlayerView component) {
    hasContact = false;
    _contactTime = 0;
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (hasContact && !_hasNavigated) {
      _contactTime += dt;
      if (_contactTime >= _MapSensorConfig._kSensorContactTime) {
        _initiateMapTransition();
      }
    }
    super.update(dt);
  }

  void resetNavigationState() {
    _hasNavigated = false;
    hasContact = false;
    _contactTime = 0;
  }

  void _initiateMapTransition() {
    _hasNavigated = true;
    hasContact = false;
    Future.delayed(
      Duration(milliseconds: _MapSensorConfig._kTransitionDelayMs),
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
}

class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  const MapArguments({
    required this.playerPosition,
    required this.playerDirection,
  });
}
