import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class ImpEnemyConfig {
  ImpEnemyConfig._();

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageSmall;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeSmall;
  static const double kSpeed = CharacterConstants.kSpeedMedium;

  static final Vector2 textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animationWalkDirectional =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
          SpriteAnimationConfig.createStandardData(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
        idleRight: UISpriteAnimationsConfig.loadAnimationImpEnemyIdleRight(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
          SpriteAnimationConfig.createStandardData(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
          SpriteAnimationConfig.createStandardData(
            amount: 4,
            textureSize: textureSize,
          ),
        ),
      );

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 6.0,
  );
}
