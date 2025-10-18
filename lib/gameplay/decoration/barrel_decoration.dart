import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/decoration/decoration.dart';

class BarrelDecoration extends DFPushableDecoration {
  BarrelDecoration(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('decorations/barrel_decoration.png'),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize,
          GameplayConstants.kCurrentTileSize,
        ),
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          GameplayConstants.kCurrentTileSize * 0.7,
          GameplayConstants.kCurrentTileSize * 0.3,
        ),
        position: Vector2(
          GameplayConstants.kCurrentTileSize * 0.1,
          GameplayConstants.kCurrentTileSize * 0.4,
        ),
      ),
    );
    return super.onLoad();
  }
}
