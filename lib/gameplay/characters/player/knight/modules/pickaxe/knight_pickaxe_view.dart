import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/pickaxe/knight_pickaxe_config.dart';

final class KnightPickaxeView extends GameDecoration {
  KnightPickaxeView({required Sprite sprite, required Vector2 position})
    : super.withSprite(
        sprite: sprite,
        position: position,
        size: KnightPickaxeConfig.componentSize,
      ) {
    anchor = Anchor.bottomCenter;
  }

  @override
  int get priority => LayerPriority.getComponentPriority(1000);

  Future<void> updateSprite(String spritePath) async {
    sprite = await Sprite.load(spritePath);
  }
}
