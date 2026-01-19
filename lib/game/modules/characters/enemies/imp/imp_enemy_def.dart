import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/modules/characters/character_constants.dart';
import 'package:dawnforge/game/systems/game/tile_constants.dart';
import 'package:dawnforge/game/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class ImpEnemyDef {
  ImpEnemyDef._();

  static const double kFixedLifeBarWidth =
      CharacterConstants.kFixedLifeBarWidthSmall;
  static final Vector2 fixedLifeBarOffset =
      CharacterConstants.fixedLifeBarOffsetSmall;

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageSmall;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeSmall;
  static const double kSpeed = CharacterConstants.kSpeedMedium;

  static final Vector2 textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static Future<SpriteAnimation> loadAnimationIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: ImpEnemyDef.textureSize,
        ),
      );

  static SimpleDirectionAnimation createAnimationWalkDirectional() {
    return SimpleDirectionAnimation(
      idleLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      idleRight: loadAnimationIdleRight(),
      runLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      runRight: SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
    );
  }

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 6.0,
  );
}
