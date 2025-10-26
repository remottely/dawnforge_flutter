import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonBossEnemyConfig {
  static const double attackDamage = 40.0;

  static const double life = 200.0;

  static const double speed = GameplayConstants.kCharacterSpeedSlow;

  static final Vector2 hitboxSize = Vector2(14, 16);

  static final Vector2 hitboxPosition = Vector2(5, 11);

  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static double get visionRadiusUltraLarge =>
      GameplayConstants.kVisionRadiusUltraLarge;

  static double get visionRadiusLarge => GameplayConstants.kVisionRadiusLarge;

  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));

  static List<Say> createDialogueSequence() {
    return [
      GameplayDialogConstants.kidRightDialog('talk_kid_1'),
      GameplayDialogConstants.bossLeftDialog('talk_boss_1'),
      GameplayDialogConstants.knightLeftDialog('talk_player_3'),
      GameplayDialogConstants.bossRightDialog('talk_boss_2'),
    ];
  }

  static final Vector2 textureSize = Vector2(32, 36);
  static final Vector2 componentSize = textureSize;

  static SimpleDirectionAnimation
  get buildDirectionalAnimation => SimpleDirectionAnimation(
    idleLeft: UISpriteAnimations.dungeonBossEnemyIdleLeft4(),
    idleRight: UISpriteAnimations.dungeonBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_boss/dungeon_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );
}
