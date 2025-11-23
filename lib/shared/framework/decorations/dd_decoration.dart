import 'package:bonfire/bonfire.dart';

class DDDecoration extends GameDecoration {
  DDDecoration({required super.position, required super.size});

  DDDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super.withSprite();

  DDDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
