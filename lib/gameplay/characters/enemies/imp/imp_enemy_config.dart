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

  static final fTextureSize = GameplayConstants.fTileSizeStandard;
  static final fComponentSize = Vector2.all(
    GameplayConstants.kTileDimensionStandard * 0.8,
  );

  static final fDirectionalAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.impEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
      GameplayAnimationConstants.standardStepTimeSpriteAnimationConfig(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox buildHitbox() =>
      RectangleHitbox(position: Vector2(3, 5), size: Vector2.all(6));
}
