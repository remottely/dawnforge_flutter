import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class GoblinEnemyConfig {
  static const double kAttackDamage = 25.0;
  static const double kLife = 120.0;
  static const double kSpeed = CharacterConfig.kCharacterSpeedSlow;
  static const int kAttackInterval = 800;
  static const double kAttackEffectSize =
      GameplayTileConfig.kTileDimensionStandard * 0.62;

  static final Vector2 fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final Vector2 fComponentSize = Vector2.all(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
  );

  static final SimpleDirectionAnimation fDirectionalSpriteAnimation =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
          GameplaySpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: fTextureSize,
          ),
        ),
        idleRight: UISpriteAnimations.goblinEnemyIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
          GameplaySpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: fTextureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
          GameplaySpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: fTextureSize,
          ),
        ),
      );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(3, 4), size: Vector2.all(7));
}
