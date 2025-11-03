import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

abstract class DDContactDecoration extends DDDecoration
    with Sensor<KnightPlayerView> {
  DDContactDecoration({required super.position, required super.size}) : super();

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
