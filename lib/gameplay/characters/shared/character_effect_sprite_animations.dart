import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';

class CharacterEffectSpriteAnimations {
  static Future<SpriteAnimation> characterExplosionSmokeRight5() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_smoke_right_5.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kSmokeExplosionFrames,
          textureSize: GameplayAnimationConstants.effectTextureSize,
        ),
      );

  static Future<SpriteAnimation> characterExplosionRight7() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_explosion_right_7.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kExplosionFrames,
          textureSize: GameplayAnimationConstants.explosionTextureSize,
        ),
      );
}
