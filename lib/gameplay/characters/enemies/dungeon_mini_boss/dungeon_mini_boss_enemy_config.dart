import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonMiniBossEnemyConfig {
  static const double attackDamage = 50.0;

  static const double life = 150.0;

  static const double speed = GameplayConstants.kCharacterSpeedSlow;

  static const double closeVisionRadius = GameplayConstants.kVisionRadiusMedium;

  static const double longVisionRadius =
      GameplayConstants.kVisionRadiusExtraLarge;

  static const int meleeAttackInterval = 300;

  static final Vector2 hitboxSize = Vector2(6.0, 7.0);

  static final Vector2 hitboxPosition = Vector2(2.5, 8.0);

  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static final double meleeDamageReduction = 3.0;

  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));

  static final Vector2 textureSize = Vector2(16, 24);
  static final Vector2 componentSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.68,
    GameplayConstants.kTileDimensionStandard * 0.93,
  );

  static SimpleDirectionAnimation
  get buildDirectionalAnimation => SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );
}
