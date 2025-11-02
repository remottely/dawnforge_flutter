import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_config.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_fx_particles_animations_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_game_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

final class KnightPlayerConfig {
  KnightPlayerConfig._();

  static const double kVisionRadius = CharacterConfig.kVisionRadiusExtraLarge;

  static const double kLife = CharacterConfig.kLifeExtraLarge;
  static double kSpeed = CharacterConfig.kSpeedFast;

  static const double kMaxStamina = 100.0;
  static const int kMaxEnergy = 100;

  static const int kToolActionEnergyCost = 2;
  static const int kStaminaIncrement = 2;
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  static const double kPrimaryAttackDamage = 25.0;
  static const int kPrimaryAttackStaminaCost = 15;

  static const double kFireballAttackDamage = 10.0;
  static const int kFireballAttackStaminaCost = 10;

  static final RectangleHitbox hitbox = RectangleHitbox(
    position: Vector2(4, 9),
    size: Vector2(8, 6),
  );

  static final Vector2 textureSize = GameplayTileConfig.tileSizeStandard;
  static final Vector2 componentSize = textureSize;

  static final SimpleDirectionAnimation animation = SimpleDirectionAnimation(
    idleLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_idle_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    idleRight: UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_left_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'gameplay/characters/player/knight/knight_player_run_right_6.png',
      GameplaySpriteAnimationConfig.createStandardData(
        amount: 6,
        textureSize: textureSize,
      ),
    ),
  );

  static final LightingConfig lightingConfig = LightingConfig(
    radius: GameplayTileConfig.kTileDimensionStandard,
    blurBorder: GameplayTileConfig.kTileDimensionStandard,
    color: CharacterFxParticlesAnimationsConfig.lightingConfigColor,
  );

  static final Vector2 cryptComponentSize = GameplayTileConfig.tileSizeStandard;
  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');
  static DDGameDecoration createCryptComponent(Vector2 position) =>
      DDGameDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}
