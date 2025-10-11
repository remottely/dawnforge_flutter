import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_tile_constants.dart';

class Barrel extends GameDecoration {
  Barrel(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('items/barrel.png'),
        position: position,
        size: Vector2(
          GameplayTileConstants.kCurrentTileSize,
          GameplayTileConstants.kCurrentTileSize,
        ),
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          GameplayTileConstants.kCurrentTileSize * 0.6,
          GameplayTileConstants.kCurrentTileSize * 0.6,
        ),
        position: Vector2(GameplayTileConstants.kCurrentTileSize * 0.2, 0),
      ),
    );
    return super.onLoad();
  }
}
