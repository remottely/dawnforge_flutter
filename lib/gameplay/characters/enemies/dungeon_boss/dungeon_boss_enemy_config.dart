import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonBossEnemyConfig {
  static const kAttackDamage = 40.0;
  static const kLife = 200.0;
  static const kSpeed = GameplayConstants.kCharacterSpeedSlow;
  static const kAttackEffectSize = 10.0;
  static const kVisionRadiusLarge = GameplayConstants.kVisionRadiusLarge;
  static const kVisionRadiusUltraLarge =
      GameplayConstants.kVisionRadiusUltraLarge;

  static final fHitbox = RectangleHitbox(
    position: Vector2(5, 11),
    size: Vector2(14, 16),
  );

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_1'),
      GameplayDialogConstants.bossLeftDialog('talk_boss_1'),
      GameplayDialogConstants.knightLeftDialog('talk_player_3'),
      GameplayDialogConstants.bossRightDialog('talk_boss_2'),
    ];
  }

  static final fTextureSize = Vector2(32, 36);
  static final fComponentSize = fTextureSize;

  static SimpleDirectionAnimation
  get buildDirectionalAnimation => SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );
}
