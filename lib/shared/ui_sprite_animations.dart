import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_animation_config.dart';

class UISpriteAnimations {
  static Future<SpriteAnimation> knightPlayerIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
          amount: 6,
          textureSize: KnightPlayerConfig.fTextureSize,
        ),
      );

  static Future<SpriteAnimation> goblinEnemyIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
          amount: 6,
          textureSize: GoblinEnemyConfig.fTextureSize,
        ),
      );

  static Future<SpriteAnimation> impEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: ImpEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonMiniBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_right_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: DungeonMiniBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_right_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: DungeonBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonBossEnemyIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_left_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: DungeonBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation> kidNpcIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_npc_idle_left_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: KidNpcConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation> wizardNpcIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/npcs/wizard_npc_idle_left_4.png',
    GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
      amount: 4,
      textureSize: WizardNpcConfig.fTextureSize,
    ),
  );
}
