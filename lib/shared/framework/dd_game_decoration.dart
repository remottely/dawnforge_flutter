import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';

class DDGameDecoration extends GameDecoration {
  DDGameDecoration({required super.position, required super.size}) : super();

  DDGameDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super.withSprite();

  DDGameDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}

abstract class DDPushableDecoration extends DDGameDecoration
    with Movement, BlockMovementCollision, HandleForces, Pushable {
  static const String _kResistanceForceId = 'attr';
  static final Vector2 _resistanceForceValue = Vector2.all(100);

  DDPushableDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super.withSprite() {
    addForce(
      ResistanceForce2D(id: _kResistanceForceId, value: _resistanceForceValue),
    );
  }
}

abstract class DDSensorPlayerDecoration extends DDGameDecoration
    with Sensor<KnightPlayerView> {
  DDSensorPlayerDecoration({required super.position, required super.size})
    : super();

  DDSensorPlayerDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
  }) : super.withSprite();

  DDSensorPlayerDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
