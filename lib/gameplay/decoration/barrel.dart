import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';

class Barrel extends GameDecoration {
  Barrel(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('items/barrel.png'),
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
          GameplayConstants.kCurrentTileSize * 0.6,
          GameplayConstants.kCurrentTileSize * 0.6,
        ),
        position: Vector2(GameplayConstants.kCurrentTileSize * 0.2, 0),
      ),
    );
    return super.onLoad();
  }
}
