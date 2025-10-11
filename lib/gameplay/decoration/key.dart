import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/game_constants.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

class DoorKey extends GameDecoration with Sensor {
  DoorKey(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('items/key_silver.png'),
        position: position,
        size: Vector2(
          GameConstants.kCurrentTileSize,
          GameConstants.kCurrentTileSize,
        ),
      );

  @override
  void onContact(GameComponent collision) {
    if (collision is Knight) {
      collision.hasKey = true;
      removeFromParent();
    }
  }
}
