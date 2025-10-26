import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonMiniBossEnemyConfig {
  static const kAttackDamage = 50.0;
  static const kLife = 150.0;
  static const kSpeed = GameplayConstants.kCharacterSpeedSlow;
  static const kCloseVisionRadius = GameplayConstants.kVisionRadiusMedium;
  static const kLongVisionRadius = GameplayConstants.kVisionRadiusExtraLarge;
  static const kMeleeAttackInterval = 300;
  static const kAttackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;
  static const kMeleeDamageReduction = 3.0;

  static final fHitbox = RectangleHitbox(
    position: Vector2(2.5, 8),
    size: Vector2(6, 7),
  );

  static final fTextureSize = Vector2(16, 24);
  static final fComponentSize = Vector2(
    GameplayConstants.kTileDimensionStandard * 0.68,
    GameplayConstants.kTileDimensionStandard * 0.93,
  );

  static final fDirectionalAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );
}
