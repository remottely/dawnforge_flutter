import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';

class UISpriteAnimations {
  static Future<SpriteAnimation> knightPlayerIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/player/knight/knight_player_idle_right_6.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kIdleFrames,
          textureSize: GameplayAnimationConstants.playerTextureSize,
        ),
      );

  static Future<SpriteAnimation> goblinEnemyIdleRight6() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
          amount: GameplayAnimationConstants.kGoblinIdleFrames,
          textureSize: GameplayAnimationConstants.enemyTextureSize,
        ),
      );

  static Future<SpriteAnimation> impEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: GameplayAnimationConstants.enemyTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonMiniBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_right_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: GameplayAnimationConstants.miniBossTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonBossEnemyIdleRight4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_right_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: GameplayAnimationConstants.bossTextureSize,
    ),
  );

  static Future<SpriteAnimation>
  dungeonBossEnemyIdleLeft4() => SpriteAnimation.load(
    'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_idle_left_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: GameplayAnimationConstants.bossTextureSize,
    ),
  );

  static final Vector2 _npcKidTextureSize = Vector2(16, 22);
  static final Vector2 _npcWizardTextureSize = Vector2(16, 22);

  static Future<SpriteAnimation> kidIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/kid_idle_npc_left_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: _npcKidTextureSize,
    ),
  );

  static Future<SpriteAnimation> wizardIdleLeft() => SpriteAnimation.load(
    'gameplay/characters/npcs/wizard_idle_npc_left_4.png',
    GameplayAnimationConstants.defaultStepTimeSpriteAnimationData(
      amount: GameplayAnimationConstants.kIdleFrames,
      textureSize: _npcWizardTextureSize,
    ),
  );
}
