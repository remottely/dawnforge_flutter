import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class ImpEnemyConfig {
  ImpEnemyConfig._();

  static const double kAttackDamage = 10.0;
  static const double kLife = 80.0;
  static const double kSpeed = CharacterConfig.kCharacterSpeedMedium;
  static const int kAttackInterval = 300;
  static const double kAttackEffectSize =
      GameplayTileConfig.kTileDimensionStandard * 0.62;

  static final Vector2 fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final Vector2 fComponentSize = Vector2.all(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
  );

  static final SimpleDirectionAnimation fLoadDirectionalSpriteAnimation =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          GameplaySpriteAnimationConfig.createStandardData(
            amount: 4,
            textureSize: fTextureSize,
          ),
        ),
        idleRight: UISpriteAnimationsConfig.loadImpEnemyIdleRight4(),
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
