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

  static final fTextureSize = GameplayConstants.fTileSizeStandard;
  static final fComponentSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );

  static final fDirectionalAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.goblinEnemyIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox buildHitbox() =>
      RectangleHitbox(position: Vector2(3, 4), size: Vector2.all(7));
}
