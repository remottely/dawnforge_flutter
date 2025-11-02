import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class ImpEnemyConfig {
  ImpEnemyConfig._();

  static const double kCloseVisionRadius = CharacterConfig.kVisionRadiusLarge;
  static const double kPrimaryAttackDamage = CharacterConfig.kDamageSmall;
  static const int kPrimaryAttackInterval =
      CharacterConfig.kAttackIntervalSmall;

  static const double kLife = CharacterConfig.kLifeSmall;
  static const double kSpeed = CharacterConfig.kSpeedMedium;

  static final Vector2 textureSize = GameplayTileConfig.tileSizeStandard;
  static final Vector2 componentSize = GameplayTileConfig.tileSizeStandard;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_idle_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadImpEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/imp/imp_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: textureSize,
      ),
    ),
  );

  static const double hitboxStartPositionX = 4.0;
  static const double hitboxStartPositionY = 6.0;
  static RectangleHitbox createHitbox() => RectangleHitbox(
    position: Vector2(hitboxStartPositionX, hitboxStartPositionY),
    size: Vector2(
      textureSize.x - (2 * hitboxStartPositionX),
      textureSize.y - hitboxStartPositionY,
    ),
  );
}
