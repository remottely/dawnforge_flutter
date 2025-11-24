import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';

class CharacterFxSpriteAnimationsConfig {
  static Future<SpriteAnimation> createExplosionRight7() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_right_7.png',
        SpriteAnimationConfig.createStandardData(
          amount: 7,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      );

  static Future<SpriteAnimation> createExplosionSmokeRight5() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_smoke_right_5.png',
        SpriteAnimationConfig.createStandardData(
          amount: 5,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );
}
