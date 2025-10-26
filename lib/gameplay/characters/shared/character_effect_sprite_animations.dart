import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';

class CharacterEffectSpriteAnimations {
  static Future<SpriteAnimation> characterExplosionSmokeRight5() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_smoke_right_5.png',
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 5,
          textureSize: GameplayConstants.fTileSizeStandard,
        ),
      );

  static Future<SpriteAnimation> characterExplosionRight7() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_right_7.png',
        GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
          amount: 7,
          textureSize: GameplayConstants.fTileSizeExtraLarge,
        ),
      );
}
