import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class GoblinEnemyConfig {
  static const kAttackDamage = 25.0;
  static const kLife = 120.0;
  static const kSpeed = GameplayConstants.kCharacterSpeedSlow;
  static const kAttackInterval = 800;
  static const kAttackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static final fHitbox = RectangleHitbox(
    position: Vector2(3, 4),
    size: Vector2.all(7),
  );

  static final textureSize = GameplayConstants.kTileSizeStandard;
  static final componentSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );

  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        idleRight: UISpriteAnimations.goblinEnemyIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
      );
}
