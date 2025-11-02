import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_game_decoration.dart';

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
