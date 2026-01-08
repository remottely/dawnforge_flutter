import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/utils/dd_animation_directional.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_constants.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

final class ImpEnemyDef {
  ImpEnemyDef._();

  static const double fixedLifeBarWidth = CharacterConstants.fixedLifeBarWidthSmall;
  static final Vector2 fixedLifeBarOffset = CharacterConstants.fixedLifeBarOffsetSmall;

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageSmall;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeSmall;
  static const double kSpeed = CharacterConstants.kSpeedMedium;

  static final Vector2 textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static const int _attackFrameCount = 6;
  static const double _attackFrameRightY = 0;
  static const double _attackFrameLeftY = TileConstants.kCharacterDimensionDemo;
  static const double _attackFrameUpY =
      TileConstants.kCharacterDimensionDemo * 2;
  static const double _attackFrameDownY =
      TileConstants.kCharacterDimensionDemo * 3;

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
