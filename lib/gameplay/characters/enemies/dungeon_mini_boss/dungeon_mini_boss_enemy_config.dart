import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class DungeonMiniBossEnemyConfig {
  DungeonMiniBossEnemyConfig._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusSmall;
  static const double kLongVisionRadius = CharacterConstants.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageLarge;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeLarge;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static const int kFireballAttackDamageReduction = 3;

  static final Vector2 textureSize = Vector2(
    GameplayTileConstants.kTileDimensionStandard,
    GameplayTileConstants.kTileDimensionLarge,
  );
  static final Vector2 componentSize = Vector2(
    GameplayTileConstants.kTileDimensionStandard,
    GameplayTileConstants.kTileDimensionLarge,
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

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    textureSize: textureSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 4.0,
  );
}
