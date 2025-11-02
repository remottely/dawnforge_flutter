import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class DungeonMiniBossEnemyConfig {
  DungeonMiniBossEnemyConfig._();

  static const double kCloseVisionRadius = CharacterConfig.kVisionRadiusSmall;
  static const double kLongVisionRadius = CharacterConfig.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = CharacterConfig.kDamageLarge;
  static const int kPrimaryAttackInterval =
      CharacterConfig.kAttackIntervalSmall;

  static const double kLife = CharacterConfig.kLifeLarge;
  static const double kSpeed = CharacterConfig.kSpeedSlow;

  static const int kFireballAttackDamageReduction = 3;

  static final Vector2 textureSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard,
    GameplayTileConfig.kTileDimensionLarge,
  );
  static final Vector2 componentSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard,
    GameplayTileConfig.kTileDimensionLarge,
  );

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadDungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );

  static const double hitboxStartPositionX = 2.0;
  static const double hitboxStartPositionY = 4.0;
  static RectangleHitbox createHitbox() => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      textureSize.x - (2 * hitboxStartPositionX),
      textureSize.y - hitboxStartPositionY,
    ),
  );
}
