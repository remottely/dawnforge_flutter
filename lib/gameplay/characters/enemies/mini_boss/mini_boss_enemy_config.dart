import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class MiniBossEnemyConfig {
  MiniBossEnemyConfig._();

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusLarge;
  static const double kFireballAttackVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageLarge;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeLarge;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static const int kFireballAttackDamageReduction = 3;

  static final Vector2 textureSize = Vector2(
    TileConstants.kTileDimensionStandard,
    TileConstants.kTileDimensionLarge,
  );
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation
  walkAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/mini_boss/mini_boss_enemy_idle_left_4.png',
      SpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/mini_boss/mini_boss_enemy_run_left_4.png',
      SpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/mini_boss/mini_boss_enemy_run_right_4.png',
      SpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 4.0,
  );
}
