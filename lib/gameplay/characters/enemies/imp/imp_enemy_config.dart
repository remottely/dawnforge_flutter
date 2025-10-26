import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class ImpEnemyConfig {
  static const double attackDamage = 10.0;

  static const double life = 80.0;

  static const double speed = GameplayConstants.kCharacterSpeedMedium;

  static const int attackInterval = 300;

  static const double hitboxSize = 6.0;

  static final Vector2 hitboxPosition = Vector2(3.0, 5.0);

  static final double attackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static void buildHitBox(GameComponent target) => target.add(
    RectangleHitbox(
      size: Vector2(hitboxSize, hitboxSize),
      position: hitboxPosition,
    ),
  );

  static final Vector2 textureSize = GameplayConstants.kTileSizeStandard;
  static final Vector2 componentSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );

  static SimpleDirectionAnimation get buildDirectionalAnimation =>
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
        idleRight: UISpriteAnimations.impEnemyIdleRight4(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
          GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
      );
}
