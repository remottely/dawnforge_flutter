import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_particles_animations.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/gameplay_character_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations.dart';

abstract class KnightPlayerConfig {
  static const double kStandardLife = 200.0;
  static const double kStandardSpeed =
      GameplayTileConfig.kTileDimensionStandard * 2.5;
  static const int kMaxEnergy = 100;
  static const int kToolUsageEnergyCost = 2;
  static const double kMaxStamina = 100.0;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);
  static const double kStandardAttackDamage = 25.0;
  static const double kSmallAttackDamage = 10.0;
  static const int kMeleeAttackStaminaCost = 15;
  static const int kFireballAttackStaminaCost = 10;
  static const double kVisionRadius =
      GameplayCharacterConfig.kVisionRadiusUltraLarge;

  static final fHitbox = RectangleHitbox(
    position: Vector2(4, 9),
    size: Vector2(8, 6),
  );

  static final fTextureSize = GameplayTileConfig.fTileSizeStandard;
  static final fComponentSize = fTextureSize;

  static final fDirectionalSpriteAnimation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_idle_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
    idleRight: UISpriteAnimations.knightPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_right_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: fTextureSize,
      ),
    ),
  );

  static final fLightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionStandard,
    blurBorder: GameplayTileConfig.kTileDimensionStandard,
    color: CharacterParticlesAnimations.fLightingConfigColor,
  );

  static final fCryptComponentSize = GameplayTileConfig.fTileSizeStandard;
  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');
}
