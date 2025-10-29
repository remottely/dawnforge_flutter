import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/gameplay_character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class DungeonMiniBossEnemyConfig {
  static const kAttackDamage = 50.0;
  static const kLife = 150.0;
  static const kSpeed = GameplayCharacterConfig.kCharacterSpeedSlow;
  static const kCloseVisionRadius = GameplayCharacterConfig.kVisionRadiusMedium;
  static const kLongVisionRadius =
      GameplayCharacterConfig.kVisionRadiusExtraLarge;
  static const kMeleeAttackInterval = 300;
  static const kAttackEffectSize =
      GameplayTileConfig.kTileDimensionStandard * 0.62;
  static const kMeleeDamageReduction = 3.0;

  static final fTextureSize = Vector2(16, 24);
  static final fComponentSize = Vector2(
    GameplayTileConfig.kTileDimensionStandard * 0.68,
    GameplayTileConfig.kTileDimensionStandard * 0.93,
  );

  static final fDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_idle_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.dungeonMiniBossEnemyIdleRight4(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_left_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/enemies/dungeon_mini_boss/dungeon_mini_boss_enemy_run_right_4.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 4,
        textureSize: fTextureSize,
      ),
    ),
  );

  static RectangleHitbox createHitbox() =>
      RectangleHitbox(position: Vector2(2.5, 8), size: Vector2(6, 7));
}
