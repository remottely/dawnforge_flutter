import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class ImpEnemyDef {
  ImpEnemyDef._();

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusExtraLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageSmall;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalSmall;

  static const double kLife = CharacterConstants.kLifeSmall;
  static const double kSpeed = CharacterConstants.kSpeedMedium;

  static final Vector2 textureSize = TileDef.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static SimpleDirectionAnimation createAnimationWalkDirectional() {
    return SimpleDirectionAnimation(
      idleLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 4,
          textureSize: textureSize,
        ),
      ),
      idleRight: UISpriteAnimationsDef.loadAnimationImpEnemyIdleRight(),
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
