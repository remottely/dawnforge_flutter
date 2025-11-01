import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';

class UISpriteAnimationsConfig {
  static Future<SpriteAnimation> loadKnightPlayerIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: KnightPlayerConfig.fTextureSize,
        ),
      );

  static Future<SpriteAnimation> loadGoblinEnemyIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: GoblinEnemyConfig.fTextureSize,
        ),
      );

  static Future<SpriteAnimation> loadImpEnemyIdleRight4() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: ImpEnemyConfig.fTextureSize,
        ),
      );

  static Future<SpriteAnimation>
  loadDungeonMiniBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_right_4.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: DungeonMiniBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadDungeonBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_right_4.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: DungeonBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadDungeonBossEnemyIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_left_4.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: DungeonBossEnemyConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation> loadKidNpcIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_npc_idle_left_4.png',
    GameplaySpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: KidNpcConfig.fTextureSize,
    ),
  );

  static Future<SpriteAnimation> loadWizardNpcIdleLeft4() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/wizard_npc_idle_left_4.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: WizardNpcConfig.fTextureSize,
        ),
      );
}
