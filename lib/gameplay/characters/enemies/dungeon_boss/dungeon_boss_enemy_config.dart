import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_animation_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/gameplay_character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonBossEnemyConfig {
  static const kAttackDamage = 40.0;
  static const kLife = 200.0;
  static const kSpeed = GameplayCharacterConfig.kCharacterSpeedSlow;
  static const kAttackEffectSize = 10.0;
  static const kVisionRadiusLarge = GameplayCharacterConfig.kVisionRadiusLarge;
  static const kVisionRadiusUltraLarge =
      GameplayCharacterConfig.kVisionRadiusUltraLarge;

  static final fTextureSize = Vector2(32, 36);
  static final fComponentSize = fTextureSize;

  static final fdirectionalAnimation = SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox buildHitbox() =>
      RectangleHitbox(position: Vector2(5, 11), size: Vector2(14, 16));

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConfig.kidRightDialog('talk_kid_1'),
      GameplayDialogConfig.bossLeftDialog('talk_boss_1'),
      GameplayDialogConfig.knightLeftDialog('talk_player_3'),
      GameplayDialogConfig.bossRightDialog('talk_boss_2'),
    ];
  }
}
