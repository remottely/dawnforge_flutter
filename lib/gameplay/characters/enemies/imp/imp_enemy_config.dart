import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_animation_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class ImpEnemyConfig {
  static const kAttackDamage = 10.0;
  static const kLife = 80.0;
  static const kSpeed = GameplayConstants.kCharacterSpeedMedium;
  static const kAttackInterval = 300;
  static const kAttackEffectSize =
      GameplayConstants.kTileDimensionStandard * 0.62;

  static final fHitbox = RectangleHitbox(
    position: Vector2(3, 5),
    size: Vector2.all(6),
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
