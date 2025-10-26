import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

class EnemySpriteAnimations {
  static SimpleDirectionAnimation get goblinEnemyDirectional =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kGoblinIdleFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
        idleRight: UISpriteAnimations.goblinEnemyIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kRunFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kRunFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
      );

  static SimpleDirectionAnimation get impEnemyDirectional =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kIdleFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
        idleRight: UISpriteAnimations.impEnemyIdleRight4(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kIdleFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
          GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
            amount: GameplayAnimationConstants.kIdleFrames,
            textureSize: GameplayAnimationConstants.enemyTextureSize,
          ),
        ),
      );

  static SimpleDirectionAnimation
  get dungeonMiniBossEnemyDirectional => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplayAnimationConstants.kIdleFrames,
        textureSize: GameplayAnimationConstants.miniBossTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplayAnimationConstants.kIdleFrames,
        textureSize: GameplayAnimationConstants.miniBossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplayAnimationConstants.kIdleFrames,
        textureSize: GameplayAnimationConstants.miniBossTextureSize,
      ),
    ),
  );

  static SimpleDirectionAnimation
  get dungeonBossEnemyDirectional => SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplayAnimationConstants.kIdleFrames,
        textureSize: GameplayAnimationConstants.bossTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
        amount: GameplayAnimationConstants.kIdleFrames,
        textureSize: GameplayAnimationConstants.bossTextureSize,
      ),
    ),
  );
}
