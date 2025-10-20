import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class PlayerSpriteAnimations {
  static Future<SpriteAnimation> knightIdleRight6() => SpriteAnimation.load(
    'gameplay/characters/player/knight_idle_right_6.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.playerTextureSize,
    ),
  );

  // static Future<SpriteAnimation> attackEffectBottom3() => SpriteAnimation.load(
  //   'gameplay/characters/player/attack_effect_bottom_3.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kAttackFrames,
  //
  //     textureSize: GameplaySpriteConstants.effectTextureSize,
  //   ),
  // );

  // static Future<SpriteAnimation> attackEffectLeft3() => SpriteAnimation.load(
  //   'gameplay/characters/player/attack_effect_left_3.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kAttackFrames,
  //
  //     textureSize: GameplaySpriteConstants.effectTextureSize,
  //   ),
  // );

  static Future<SpriteAnimation> attackEffectRight3() => SpriteAnimation.load(
    'gameplay/characters/player/attack_effect_right_3.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kAttackFrames,
      textureSize: GameplaySpriteConstants.effectTextureSize,
    ),
  );

  // static Future<SpriteAnimation> attackEffectTop3() => SpriteAnimation.load(
  //   'gameplay/characters/player/attack_effect_top_3.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kAttackFrames,
  //
  //     textureSize: GameplaySpriteConstants.effectTextureSize,
  //   ),
  // );

  static SimpleDirectionAnimation knightAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight_idle_left_6.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kPlayerIdleFrames,

        textureSize: GameplaySpriteConstants.playerTextureSize,
      ),
    ),
    idleRight: knightIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight_run_left_6.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kRunFrames,

        textureSize: GameplaySpriteConstants.playerTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/player/knight_run_right_6.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kRunFrames,

        textureSize: GameplaySpriteConstants.playerTextureSize,
      ),
    ),
  );
}
