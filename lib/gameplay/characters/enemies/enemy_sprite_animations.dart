import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class EnemySpriteAnimations {
  static Future<SpriteAnimation> enemyAttackEffectRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/attack_effect_right_3.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kAttackFrames,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  static Future<SpriteAnimation>
  dungeonBossIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_idle_right_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.bossTextureSize,
    ),
  );

  static SimpleDirectionAnimation
  dungeonBossAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_idle_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    idleRight: dungeonBossIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_run_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_run_right_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> goblinIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/goblin/goblin_idle.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kGoblinIdleFrames,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation goblinAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_idle_left.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kGoblinIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    idleRight: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_idle.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kGoblinIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_run_left.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kRunFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_run_right.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kRunFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation> impIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/imp/imp_idle.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation impAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_idle_left.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    idleRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_idle.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_run_left.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_run_right.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.enemyTextureSize,
      ),
    ),
  );

  static Future<SpriteAnimation>
  dungeonMiniBossIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_idle_right_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.miniBossTextureSize,
    ),
  );

  static SimpleDirectionAnimation
  miniBossAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_idle_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
    idleRight: dungeonMiniBossIdleRight(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_run_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_run_right_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
  );

  // static Future<SpriteAnimation> enemyAttackEffectBottom() =>
  //     SpriteAnimation.load(
  //       'gameplay/characters/enemies/attack_effect_bottom_3.png',
  //       GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //         amount: GameplaySpriteConstants.kAttackFrames,
  //
  //         textureSize: GameplaySpriteConstants.effectTextureSize,
  //       ),
  //     );
  //
  // static Future<SpriteAnimation> enemyAttackEffectLeft() =>
  //     SpriteAnimation.load(
  //       'gameplay/characters/enemies/attack_effect_left_3.png',
  //       GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //         amount: GameplaySpriteConstants.kAttackFrames,
  //
  //         textureSize: GameplaySpriteConstants.effectTextureSize,
  //       ),
  //     );

  // static Future<SpriteAnimation> enemyAttackEffectTop() => SpriteAnimation.load(
  //   'gameplay/characters/enemies/attack_effect_top_3.png',
  //   GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
  //     amount: GameplaySpriteConstants.kAttackFrames,
  //
  //     textureSize: GameplaySpriteConstants.effectTextureSize,
  //   ),
  // );
}
