import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class MiniBossEnemyDef {
  MiniBossEnemyDef._();

  static const double kFixedLifeBarWidth =
      CharacterConstants.kFixedLifeBarWidthMedium;
  static final Vector2 fixedLifeBarOffset =
      CharacterConstants.fixedLifeBarOffsetNone;

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

  static Future<SpriteAnimation>
  loadAnimationIdleRight() => SpriteAnimation.load(
    'gameplay/characters/enemies/mini_boss/mini_boss_enemy_idle_right_4.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 4,
      textureSize: MiniBossEnemyDef.textureSize,
    ),
  );

  static SimpleDirectionAnimation createAnimationWalkDirectional() {
    return SimpleDirectionAnimation(
      idleLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/mini_boss/mini_boss_enemy_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      idleRight: loadAnimationIdleRight(),
      runLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/mini_boss/mini_boss_enemy_run_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      runRight: SpriteAnimation.load(
        'gameplay/characters/enemies/mini_boss/mini_boss_enemy_run_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
    );
  }

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 4.0,
  );
}
