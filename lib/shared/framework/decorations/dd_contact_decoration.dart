import 'package:bonfire/bonfire.dart';

abstract class DDContactDecoration extends GameDecoration
    with Sensor<SimplePlayer> {
  DDContactDecoration({required super.position, required super.size});

  DDContactDecoration.withSprite({
    required super.sprite,
    required super.position,
    required super.size,
  }) : super.withSprite();

  DDContactDecoration.withAnimation({
    required super.animation,
    required super.position,
    required super.size,
  }) : super.withAnimation();
}
