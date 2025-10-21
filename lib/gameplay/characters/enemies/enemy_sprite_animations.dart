import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';

class EnemySpriteAnimations {
  /// ATTACK EFFECTS
  static Future<SpriteAnimation> enemyBasicAttackRight3() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kAttackFrames,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  /// GOBLIN
  static Future<SpriteAnimation> goblinEnemyIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kGoblinIdleFrames,
          textureSize: GameplaySpriteConstants.enemyTextureSize,
        ),
      );

  static SimpleDirectionAnimation goblinEnemyAnimation() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: goblinEnemyIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kRunFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kRunFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
      );

  /// IMP
  static Future<SpriteAnimation> impEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.enemyTextureSize,
    ),
  );

  static SimpleDirectionAnimation impEnemyAnimation() =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: impEnemyIdleRight4(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
      );

  /// DUNGEON MINI BOSS
  static Future<SpriteAnimation>
  dungeonMiniBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_right_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.miniBossTextureSize,
    ),
  );

  static SimpleDirectionAnimation
  dungeonMiniBossEnemyAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
    idleRight: dungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
  );

  /// DUNGEON BOSS
  static Future<SpriteAnimation>
  dungeonBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_right_4.png',
    GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplaySpriteConstants.kIdleFrames,
      textureSize: GameplaySpriteConstants.bossTextureSize,
    ),
  );

  static SimpleDirectionAnimation
  dungeonBossEnemyAnimation() => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    idleRight: dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.bossTextureSize,
      ),
    ),
  );
}
