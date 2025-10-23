import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';

/// DONE
class DFGameDecoration extends GameDecoration {
  DFGameDecoration({required super.position, required super.size}) : super();

  DFGameDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super.withSprite();

  DFGameDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}

abstract class DFPushableDecoration extends DFGameDecoration
    with Movement, BlockMovementCollision, HandleForces, Pushable {
  DFPushableDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super.withSprite() {
    addForce(ResistanceForce2D(id: 'attr', value: Vector2.all(10)));
  }
}

abstract class DFSensorPlayerDecoration extends DFGameDecoration
    with Sensor<KnightPlayerView> {
  DFSensorPlayerDecoration({required super.position, required super.size})
    : super();

  DFSensorPlayerDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
  }) : super.withSprite();

  DFSensorPlayerDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}

/// TODO: DFDamageableDecoration
