import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';

class CharacterEffectsSpriteAnimationsConfig {
  static Future<SpriteAnimation> characterExplosionSmokeRight5() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_smoke_right_5.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 5,
          textureSize: GameplayTileConfig.fTileSizeStandard,
        ),
      );

  static Future<SpriteAnimation> characterExplosionRight7() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_right_7.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 7,
          textureSize: GameplayTileConfig.fTileSizeExtraLarge,
        ),
      );
}
