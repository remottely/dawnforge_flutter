import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_sprite_constants.dart';

/// [EnemySpriteSheet] responsible for providing enemy character sprite animations
/// Following Flutter naming conventions for enemy sprite systems
class EnemySpriteSheet {
  /// Creates enemy attack effect animation facing down
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> enemyAttackEffectBottom() =>
      SpriteAnimation.load(
        'enemy/atack_effect_bottom.png',
        SpriteAnimationData.sequenced(
          amount: GameplaySpriteConstants.kAttackFrames,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  /// Creates enemy attack effect animation facing left
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> enemyAttackEffectLeft() =>
      SpriteAnimation.load(
        'enemy/atack_effect_left.png',
        SpriteAnimationData.sequenced(
          amount: GameplaySpriteConstants.kAttackFrames,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  /// Creates enemy attack effect animation facing right
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> enemyAttackEffectRight() =>
      SpriteAnimation.load(
        'enemy/atack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: GameplaySpriteConstants.kAttackFrames,
          stepTime: GameplaySpriteConstants.kDefaultStepTime,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  /// Creates enemy attack effect animation facing up
  /// Following Flutter pattern of directional effect methods
  static Future<SpriteAnimation> enemyAttackEffectTop() => SpriteAnimation.load(
    'enemy/atack_effect_top.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kAttackFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.effectTextureSize,
    ),
  );

  /// Creates boss idle right animation
  /// Following Flutter pattern of descriptive factory methods
  static Future<SpriteAnimation> bossIdleRight() => SpriteAnimation.load(
    'enemy/boss/boss_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.bossTextureSize,
    ),
  );

  static SimpleDirectionAnimation bossAnimations() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'enemy/boss/boss_idle_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    idleRight: bossIdleRight(),
    runLeft: SpriteAnimation.load(
      'enemy/boss/boss_run_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'enemy/boss/boss_run_right.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> goblinIdleRight() => SpriteAnimation.load(
    'enemy/goblin/goblin_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kGoblinIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation goblinAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'enemy/goblin/goblin_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: SpriteAnimation.load(
          'enemy/goblin/goblin_idle.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runLeft: SpriteAnimation.load(
          'enemy/goblin/goblin_run_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kRunFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'enemy/goblin/goblin_run_right.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kRunFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
      );

  static Future<SpriteAnimation> impIdleRight() => SpriteAnimation.load(
    'enemy/imp/imp_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation impAnimations() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'enemy/imp/imp_idle_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    idleRight: SpriteAnimation.load(
      'enemy/imp/imp_idle.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runLeft: SpriteAnimation.load(
      'enemy/imp/imp_run_left.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'enemy/imp/imp_run_right.png',
      SpriteAnimationData.sequenced(
        amount: GameplaySpriteConstants.kIdleFrames,
        stepTime: GameplaySpriteConstants.kDefaultStepTime,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> miniBossIdleRight() => SpriteAnimation.load(
    'enemy/mini_boss/mini_boss_idle.png',
    SpriteAnimationData.sequenced(
      amount: GameplaySpriteConstants.kIdleFrames,
      stepTime: GameplaySpriteConstants.kDefaultStepTime,
      textureSize: GameplaySpriteConstants.miniBossTextureSize,
    ),
  );

  static SimpleDirectionAnimation miniBossAnimations() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'enemy/mini_boss/mini_boss_idle_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        idleRight: SpriteAnimation.load(
          'enemy/mini_boss/mini_boss_idle.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        runLeft: SpriteAnimation.load(
          'enemy/mini_boss/mini_boss_run_left.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'enemy/mini_boss/mini_boss_run_right.png',
          SpriteAnimationData.sequenced(
            amount: GameplaySpriteConstants.kIdleFrames,
            stepTime: GameplaySpriteConstants.kDefaultStepTime,
            textureSize: GameplaySpriteConstants.miniBossTextureSize,
          ),
        ),
      );
}
