import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
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
  static final Vector2 componentSize = Vector2.all(
    GameplayTileConfig.kTileDimensionStandard * 0.8,
  );

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

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(3, 4), size: Vector2.all(7));
}
