import 'package:bonfire/bonfire.dart';

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
