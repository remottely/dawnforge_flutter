import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class GoblinEnemyConfig {
  static const double attackDamage = 25.0;

  static const double life = 120.0;

  static const double speed = GameplayConstants.kCharacterSpeedSlow;

  static const int attackInterval = 800;

  static final Vector2 hitboxSize = Vector2.all(7.0);

  static final Vector2 hitboxPosition = Vector2(3.0, 4.0);

  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static void buildHitBox(GameComponent target) =>
      target.add(RectangleHitbox(size: hitboxSize, position: hitboxPosition));

  static final Vector2 textureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 componentSize = Vector2.all(
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
