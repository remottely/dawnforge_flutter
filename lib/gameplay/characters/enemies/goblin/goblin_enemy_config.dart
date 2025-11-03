import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class GoblinEnemyConfig {
  GoblinEnemyConfig._();

  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusMedium;
  static const double kPrimaryAttackDamage = CharacterConstants.kDamageMedium;
  static const int kPrimaryAttackInterval =
      CharacterConstants.kAttackIntervalMedium;

  static const double kLife = CharacterConstants.kLifeMedium;
  static const double kSpeed = CharacterConstants.kSpeedSlow;

  static final Vector2 textureSize = GameplayTileConstants.tileSizeStandard;
  static final Vector2 componentSize = GameplayTileConstants.tileSizeStandard;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_idle_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadGoblinEnemyIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_run_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/goblin/goblin_enemy_run_right_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() => HitboxUtils.createBottomHitbox(
    textureSize: textureSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 6.0,
  );
}
