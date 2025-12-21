import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';
import 'package:darkness_dungeon/shared/utils/ui_sprite_animations_def.dart';

final class GoblinEnemyDef {
  GoblinEnemyDef._();

  static const double kPrimaryAttackVisionRadius =
      CharacterConstants.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageMedium;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalMedium;

  static const double kLife = CharacterConstants.kLifeMedium;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static final Vector2 textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static Future<SpriteAnimation> loadAnimationIdleRight() =>
      SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_right_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: GoblinEnemyDef.textureSize,
        ),
      );

  static SimpleDirectionAnimation createAnimationWalkDirectional() {
    return SimpleDirectionAnimation(
      idleLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: textureSize,
        ),
      ),
      idleRight: loadAnimationIdleRight(),
      runLeft: SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
          textureSize: textureSize,
        ),
      ),
      runRight: SpriteAnimation.load(
        'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
        SpriteAnimationConfigHelper.createStandardData(
          amount: 6,
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
