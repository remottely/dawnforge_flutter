import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class CharacterEffectSpriteAnimations {
  static Future<SpriteAnimation> explosionSmokeRight5() => SpriteAnimation.load(
    'gameplay/characters/shared/character_explosin_smoke_right_5.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kSmokeExplosionFrames,
      textureSize: GameplaySpriteConstants.effectTextureSize,
    ),
  );

  static Future<SpriteAnimation> explosionRight7() => SpriteAnimation.load(
    'gameplay/characters/shared/character_explosion_right_7.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kExplosionFrames,
      textureSize: GameplaySpriteConstants.explosionTextureSize,
    ),
  );

  static Future<SpriteAnimation> fireBallAttackRight3() => SpriteAnimation.load(
    'gameplay/characters/shared/character_fireball_attack_right_3.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kFireballFrames,
      textureSize: GameplaySpriteConstants.fireballTextureSize,
    ),
  );

  static Future<SpriteAnimation> fireBallExplosionRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/shared/character_fireball_explosion_right_6.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kFireballExplosionFrames,
          textureSize: GameplaySpriteConstants.explosionTextureSize,
        ),
      );

  // static Future<SpriteAnimation> fireBallAttackLeft() => SpriteAnimation.load(
  //   'gameplay/characters/shared/fireball_left.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kFireballFrames,
  //     textureSize: GameplaySpriteConstants.fireballTextureSize,
  //   ),
  // );

  // static Future<SpriteAnimation> fireBallAttackTop() => SpriteAnimation.load(
  //   'gameplay/characters/shared/fireball_top.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kFireballFrames,
  //     textureSize: GameplaySpriteConstants.fireballTextureSize,
  //   ),
  // );

  // static Future<SpriteAnimation> fireBallAttackBottom() => SpriteAnimation.load(
  //   'gameplay/characters/shared/fireball_bottom.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kFireballFrames,
  //     textureSize: GameplaySpriteConstants.fireballTextureSize,
  //   ),
  // );
}
