import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/game_constants.dart';

class Barrel extends GameDecoration {
  Barrel(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('items/barrel.png'),
        position: position,
        size: Vector2(
          GameConstants.kCurrentTileSize,
          GameConstants.kCurrentTileSize,
        ),
      );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          GameConstants.kCurrentTileSize * 0.6,
          GameConstants.kCurrentTileSize * 0.6,
        ),
        position: Vector2(GameConstants.kCurrentTileSize * 0.2, 0),
      ),
    );
    return super.onLoad();
  }
}
