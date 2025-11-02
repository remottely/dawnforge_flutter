import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_game_decoration.dart';

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
