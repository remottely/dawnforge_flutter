import 'package:bonfire/bonfire.dart';

abstract class DDPushableDecoration extends GameDecoration
    with Movement, BlockMovementCollision, HandleForces, Pushable {
  static const String _kResistanceForceId = 'attr';
  static final Vector2 _resistanceForceValue = Vector2.all(100);

  DDPushableDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    LightingConfig? lighting,
    super.renderAboveComponents,
  }) : super.withSprite(lightingConfig: lighting) {
    addForce(
      ResistanceForce2D(id: _kResistanceForceId, value: _resistanceForceValue),
    );
  }
}
