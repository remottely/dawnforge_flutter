import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/shared/i_dd_game_decoration.dart';

abstract class _MapTransitionSensorConfig {
  static const _kSensorContactTime = 0.5;
  static const _kTransitionDelayMs = 100;
}

class MapTransitionSensorView extends DDSensorPlayerDecoration {
  final String id;
  final String targetMap;
  final Vector2 playerPosition;
  final Direction playerDirection;

  MapTransitionSensorView({
    required super.position,
    required super.size,
    required this.id,
    required this.targetMap,
    required this.playerPosition,
    required this.playerDirection,
  });

  bool _hasContact = false;
  bool _hasNavigated = false;
  double _contactTime = 0;

  @override
  void onContact(KnightPlayerView component) {
    if (!_hasContact && !_hasNavigated) {
      _hasContact = true;
      _contactTime = 0;
    }
    super.onContact(component);
  }

  @override
  void onContactExit(KnightPlayerView component) {
    _hasContact = false;
    _contactTime = 0;
    super.onContactExit(component);
  }

  @override
  void update(double dt) {
    if (_hasContact && !_hasNavigated) {
      _contactTime += dt;
      if (_contactTime >= _MapTransitionSensorConfig._kSensorContactTime) {
        _initiateMapTransition();
      }
    }
    super.update(dt);
  }

  void resetNavigationState() {
    _hasNavigated = false;
    _hasContact = false;
    _contactTime = 0;
  }

  void _initiateMapTransition() {
    _hasNavigated = true;
    _hasContact = false;
    Future.delayed(
      Duration(milliseconds: _MapTransitionSensorConfig._kTransitionDelayMs),
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
