import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/player/knight.dart';

class LifePotion extends GameDecoration with Sensor<Knight> {
  final Vector2 initialPosition;
  final double healAmount;

  bool _hasBeenConsumed = false;

  LifePotion(this.initialPosition, this.healAmount)
    : super.withSprite(
        sprite: Sprite.load('items/potion_red.png'),
        position: initialPosition,
        size: Vector2(
          GameplayTileConstants.kCurrentTileSize,
          GameplayTileConstants.kCurrentTileSize,
        ),
      );

  @override
  void onContact(Knight player) {
    if (!_hasBeenConsumed) {
      _hasBeenConsumed = true;
      _healPlayerGradually(player);
      removeFromParent();
    }
  }

  void _healPlayerGradually(Player player) {
    double healingProgress = 0;
    gameRef.add(
      ValueGeneratorComponent(
        const Duration(seconds: 1),
        onChange: (value) {
          if (healingProgress < healAmount) {
            double currentHealAmount = healAmount * value - healingProgress;
            healingProgress += currentHealAmount;
            player.addLife(currentHealAmount);
          }
        },
      ),
    );
  }
}
