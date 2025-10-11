import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

class DoorKey extends GameDecoration with Sensor {
  DoorKey(Vector2 position)
    : super.withSprite(
        sprite: Sprite.load('items/key_silver.png'),
        position: position,
        size: Vector2(
          GameplayConstants.kCurrentTileSize,
          GameplayConstants.kCurrentTileSize,
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
