import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/helpers/tile_helper.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

/// DONE
class BarrelDecoration extends DFPushableDecoration {
  static Future<Sprite> _barrelDecoration1() =>
      Sprite.load('decorations/barrel_decoration_1.png');

  BarrelDecoration({required super.position})
    : super.withSprite(
        sprite: _barrelDecoration1(),
        size: GameplayConstants.kCurrentVectorSize,
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          TileHelper.valueByTileSize(12),
          TileHelper.valueByTileSize(4),
        ),
        position: Vector2(
          TileHelper.valueByTileSize(2),
          TileHelper.valueByTileSize(6),
        ),
      ),
    );

    return super.onLoad();
  }
}
