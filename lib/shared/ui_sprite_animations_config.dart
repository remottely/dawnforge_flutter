import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/boss/boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/goblin/goblin_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/imp/imp_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/enemies/mini_boss/mini_boss_enemy_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/kid/kid_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/npcs/wizard/wizard_npc_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/cute/cute_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';

class UISpriteAnimationsConfig {
  static Future<SpriteAnimation> loadKnightPlayerIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: KnightPlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadCutePlayerIdleRight6() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_east_6.png',
        SpriteAnimationConfig.createCustomData(
          amount: 2,
          textureSize: CutePlayerConfig.textureSize,
          stepTime: 0.2,
        ),
      );

  static Future<SpriteAnimation>
  loadSunnyPlayerIdleRight6() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_strip9.png',
    SpriteAnimationConfig.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> loadGoblinEnemyIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        SpriteAnimationConfig.createStandardData(
          amount: 6,
          textureSize: GoblinEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadImpEnemyIdleRight4() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: ImpEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation>
  loadMiniBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/mini_boss/mini_boss_enemy_idle_right_4.png',
    SpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: MiniBossEnemyConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> loadBossEnemyIdleRight4() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_right_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: BossEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadBossEnemyIdleLeft4() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_left_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: BossEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadKidNpcIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_npc_idle_left_4.png',
    SpriteAnimationConfig.createStandardData(
      amount: 4,
      textureSize: KidNpcConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> loadWizardNpcIdleLeft4() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/wizard_npc_idle_left_4.png',
        SpriteAnimationConfig.createStandardData(
          amount: 4,
          textureSize: WizardNpcConfig.textureSize,
        ),
      );
}
