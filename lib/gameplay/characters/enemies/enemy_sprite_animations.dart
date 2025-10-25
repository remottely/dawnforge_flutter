import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

class EnemySpriteAnimations {
  static Future<SpriteAnimation> enemyBasicAttackRight3() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/enemy_basic_attack_right_3.png',
        GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplaySpriteConstants.kAttackFrames,
          textureSize: GameplaySpriteConstants.effectTextureSize,
        ),
      );

  static SimpleDirectionAnimation get goblinEnemyDirectional =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kGoblinIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: UISpriteAnimations.goblinEnemyIdleRight6(),
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

  static SimpleDirectionAnimation get impEnemyDirectional =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplaySpriteConstants.kIdleFrames,
            textureSize: GameplaySpriteConstants.enemyTextureSize,
          ),
        ),
        idleRight: UISpriteAnimations.impEnemyIdleRight4(),
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

  static SimpleDirectionAnimation
  get dungeonMiniBossEnemyDirectional => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplaySpriteConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplaySpriteConstants.kIdleFrames,
        textureSize: GameplaySpriteConstants.miniBossTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
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

  static SimpleDirectionAnimation
  get dungeonBossEnemyDirectional => SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
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
