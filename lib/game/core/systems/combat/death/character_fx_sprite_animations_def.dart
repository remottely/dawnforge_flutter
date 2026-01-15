import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/systems/game/tile_constants.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

class CharacterFxSpriteAnimationsDef {
  static Future<SpriteAnimation> loadAnimationExplosionRight() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_right_7.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 7,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      );

  static Future<SpriteAnimation> loadAnimationExplosionSmokeRight() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_smoke_right_5.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 5,
          textureSize: TileConstants.tileSizeStandard,
        ),
      );
}
