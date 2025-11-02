import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class DungeonMiniBossEnemyConfig {
  DungeonMiniBossEnemyConfig._();

  static const double kCloseVisionRadius = CharacterConfig.kVisionRadiusSmall;
  static const double kLongVisionRadius = CharacterConfig.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = 50.0;
  static const int kPrimaryAttackInterval = 300;

  static const double kLife = CharacterConfig.kLifeLarge;
  static const double kSpeed = CharacterConfig.kSpeedSlow;

  static const int kFireballAttackDamageReduction = 3;

  static final Vector2 fTextureSize = Vector2(16, 24);
  static final Vector2 fComponentSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard * 0.68,
    GameplayTileConfig.kTileDimensionStandard * 0.93,
  );

  static final SimpleDirectionAnimation
  fLoadDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadDungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(2.5, 8), size: Vector2(6, 7));
}
