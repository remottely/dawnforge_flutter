import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class GoblinEnemyConfig {
  GoblinEnemyConfig._();

  static const double kCloseVisionRadius = CharacterConfig.kVisionRadiusMedium;
  static const double kPrimaryAttackDamage = CharacterConfig.kDamageMedium;
  static const int kPrimaryAttackInterval =
      CharacterConfig.kAttackIntervalMedium;

  static const double kLife = CharacterConfig.kLifeMedium;
  static const double kSpeed = CharacterConfig.kSpeedSlow;

  static final Vector2 textureSize = GameplayTileConfig.tileSizeStandard;
  static final Vector2 componentSize = GameplayTileConfig.tileSizeStandard;

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

  static const double hitboxStartPositionX = 4.0;
  static const double hitboxStartPositionY = 4.0;
  static RectangleHitbox createHitbox() => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      textureSize.x - (2 * hitboxStartPositionX),
      textureSize.y - hitboxStartPositionY,
    ),
  );
}
