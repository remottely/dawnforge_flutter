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
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

class UISpriteAnimationsConfig {
  static Future<SpriteAnimation> loadAnimationKnightPlayerIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: KnightPlayerConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationCutePlayerIdleRightOld() =>
      SpriteAnimation.load(
        'new/Player/idle/player_idle_right_48x48_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: CutePlayerConfig.textureSize,
        ),
      );

  static Future<DDSpriteAnimation> loadAnimationCutePlayerIdleRight() {
    final data = SpriteAnimationConfigHelper.createStandardData(
      amount: 4,
      textureSize: Vector2(48, 48),
      // texturePosition: Vector2(16, 16),
      effectiveSize: Vector2(48, 48),
    );

    return DDSpriteAnimation.load(
      'new/Player/idle/player_idle_right_48x48_6.png',
      data,
    );
  }

  static Future<DDSpriteAnimation> loadAnimationKnightPlayerIdleRight2() {
    final data = SpriteAnimationConfigHelper.createStandardData(
      amount: 6,
      textureSize: KnightPlayerConfig.textureSize,
      effectiveSize: Vector2(16, 16),
    );

    return DDSpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_idle_right_6.png',
      data,
    );
  }

  static Future<DDSpriteAnimation> loadAnimationSunnyPlayerIdleRight2() {
    final data = SpriteAnimationConfigHelper.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerConfig.textureSize,
      effectiveSize: Vector2(16, 16),
    );

    return DDSpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_strip9.png',
      data,
    );
  }

  static Future<SpriteAnimation>
  loadAnimationSunnyPlayerIdleRight() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_strip9.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> loadAnimationGoblinEnemyIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: GoblinEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationImpEnemyIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: ImpEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation>
  loadAnimationMiniBossEnemyIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/mini_boss/mini_boss_enemy_idle_right_4.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 4,
      textureSize: MiniBossEnemyConfig.textureSize,
    ),
  );

  static Future<SpriteAnimation> loadAnimationBossEnemyIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: BossEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationBossEnemyIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/boss/boss_enemy_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: BossEnemyConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationKidNpcIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/kid_npc_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: KidNpcConfig.textureSize,
        ),
      );

  static Future<SpriteAnimation> loadAnimationWizardNpcIdleLeft() =>
      SpriteAnimation.load(
        'gameplay/characters/npcs/wizard_npc_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: WizardNpcConfig.textureSize,
        ),
      );
}
