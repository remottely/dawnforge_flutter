import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class EnemySpriteSheet {
  // static Future<SpriteAnimation> enemyAttackEffectBottom() =>
  //     SpriteAnimation.load(
  //       'gameplay/characters/enemies/atack_effect_bottom.png',
  //       SpriteAnimationData.sequenced(
  //         amount: GameplaySpriteConstants.kAttackFrames,
  //         stepTime: GameplaySpriteConstants.kDefaultStepTime,
  //         textureSize: GameplaySpriteConstants.effectTextureSize,
  //       ),
  //     );
  //
  // static Future<SpriteAnimation> enemyAttackEffectLeft() =>
  //     SpriteAnimation.load(
  //       'gameplay/characters/enemies/atack_effect_left.png',
  //       SpriteAnimationData.sequenced(
  //         amount: GameplaySpriteConstants.kAttackFrames,
  //         stepTime: GameplaySpriteConstants.kDefaultStepTime,
  //         textureSize: GameplaySpriteConstants.effectTextureSize,
  //       ),
  //     );

  static Future<SpriteAnimation> enemyAttackEffectRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/atack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: GameplaySpriteConstants.kAttackFrames,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  // static Future<SpriteAnimation> enemyAttackEffectTop() => SpriteAnimation.load(
  //   'gameplay/characters/enemies/atack_effect_top.png',
  //   SpriteAnimationData.sequenced(
  //     amount: GameplaySpriteConstants.kAttackFrames,
  //     stepTime: GameplaySpriteConstants.kDefaultStepTime,
  //     textureSize: GameplaySpriteConstants.effectTextureSize,
  //   ),
  // );

  static Future<SpriteAnimation> bossIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/boss/boss_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.bossTextureSize,
    ),
  );

  static SimpleDirectionAnimation bossAnimations() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/boss/boss_idle_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    idleRight: bossIdleRight(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/boss/boss_run_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/boss/boss_run_right.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> goblinIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/goblin/goblin_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kGoblinIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation goblinAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_idle.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_run_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kRunFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_run_right.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kRunFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
      );

  static Future<SpriteAnimation> impIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/imp/imp_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation impAnimations() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_idle_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    idleRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_idle.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_run_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_run_right.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> miniBossIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/mini_boss/mini_boss_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.miniBossTextureSize,
    ),
  );

  static SimpleDirectionAnimation miniBossAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/mini_boss/mini_boss_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        idleRight: SpriteAnimation.load(
          'gameplay/characters/enemies/mini_boss/mini_boss_idle.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/mini_boss/mini_boss_run_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/mini_boss/mini_boss_run_right.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
      );
}
