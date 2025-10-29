import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/gameplay_character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class ImpEnemyConfig {
  static const kAttackDamage = 10.0;
  static const kLife = 80.0;
  static const kSpeed = GameplayCharacterConfig.kCharacterSpeedMedium;
  static const kAttackInterval = 300;
  static const kAttackEffectSize =
      GameplayTileConfig.kTileDimensionStandard * 0.62;

  static final fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final fComponentSize = Vector2.all(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
  );

  static final fDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.impEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(3, 5), size: Vector2.all(6));
}
