import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

/// Configuration constants and factory methods for the Sunny player character.
///
/// This final class serves as a centralized configuration hub for all
/// Sunny-related settings including combat stats, resource management,
/// visual properties, and asset loading. It follows the static factory pattern
/// to prevent instantiation while providing utility methods.
///
/// Organized into logical sections:
/// - Detection & Vision
/// - Character Stats & Movement
/// - Resource Management
/// - Combat Configuration
/// - Visual & Animation Assets
/// - Equipment & Items
final class SunnyPlayerConfig {
  /// Private constructor to prevent instantiation.
  SunnyPlayerConfig._();

  // ============================================================================
  // Detection & Vision Configuration
  // ============================================================================

  /// The radius within which the player can detect enemies and decorations.
  ///
  /// Uses an extra-large vision radius allowing the player to spot threats
  /// and opportunities from a considerable distance.
  static const double kLongVisionRadius =
      CharacterConstants.kVisionRadiusSuperLarge;

  // ============================================================================
  // Character Stats & Movement
  // ============================================================================

  /// Maximum health points for the player character.
  ///
  /// Uses an extra-large life pool suitable for extended dungeon exploration.
  static const double kLife = CharacterConstants.kLifeExtraLarge;

  /// Base movement speed in pixels per second.
  ///
  /// Classified as "fast" movement for responsive player control.
  static double kSpeed = CharacterConstants.kSpeedFast;

  /// Speed multiplier applied when the player is running.
  ///
  /// A 1.4x multiplier provides noticeable speed increase without making
  /// the character difficult to control.
  static const double kRunSpeedMultiplier = 1.4;

  // ============================================================================
  // Resource Management - Stamina
  // ============================================================================

  /// Maximum stamina capacity for combat actions.
  ///
  /// Stamina is consumed by attacks and regenerates over time.
  static const double kMaxStamina = 100.0;

  /// Amount of stamina regenerated per regeneration tick.
  ///
  /// Balanced to allow frequent but not unlimited combat actions.
  static const int kStaminaIncrement = 1;

  /// Debounce duration between stamina regeneration ticks.
  ///
  /// A 150ms interval provides smooth regeneration without being too fast.
  static const Duration kStaminaRegenDebounce = Duration(milliseconds: 150);

  // ============================================================================
  // Resource Management - Energy
  // ============================================================================

  /// Maximum energy capacity for farming and tool actions.
  ///
  /// Energy is consumed by tool usage and typically restored at rest points.
  static const int kMaxEnergy = 100;

  /// Energy cost per farming tool action.
  ///
  /// Low cost allows for extended farming sessions before requiring rest.
  static const int kToolActionEnergyCost = 2;

  // ============================================================================
  // Combat Configuration - Primary Attack
  // ============================================================================

  /// Damage dealt by the primary melee attack.
  ///
  /// Balanced for close-range combat encounters.
  static const double kPrimaryAttackDamage = 25.0;

  /// Stamina cost to execute the primary melee attack.
  ///
  /// Moderate cost allows for multiple attacks before requiring regeneration.
  static const int kPrimaryAttackStaminaCost = 15;

  // ============================================================================
  // Combat Configuration - Fireball Attack
  // ============================================================================

  /// Damage dealt by the fireball ranged attack.
  ///
  /// Lower than melee damage to balance the safety of ranged combat.
  static const double kFireballAttackDamage = 10.0;

  /// Stamina cost to execute the fireball ranged attack.
  ///
  /// Lower cost than melee to encourage mixed combat strategies.
  static const int kFireballAttackStaminaCost = 10;

  static const int kShovelStaminaCost = 5;

  static const int kWateringCanStaminaCost = 5;

  static const int kSeedStaminaCost = 5;

  static const int kHarvestBasketStaminaCost = 5;

  // ============================================================================
  // Component Dimensions
  // ============================================================================

  /// The texture size used for Sunny's sprite sheet frames.
  static final Vector2 textureSize = TileConstants.tileSizeSunnyWorld;

  /// The rendered size of the player component in the game world.
  ///
  /// Currently matches texture size for 1:1 pixel rendering.
  static final Vector2 componentSize = textureSize;

  /// The collision hitbox for the player character.
  ///
  /// Positioned to match the character's feet/base for accurate collision
  /// detection with ground elements and other entities.
  static final RectangleHitbox hitbox = HitboxUtils.createCustomHitbox(
    componentSize: componentSize,
    left: 44.0,
    top: 28.0,
    right: 44.0,
    bottom: 25.0,
  );

  // ============================================================================
  // Animation Asset Loading
  // ============================================================================

  static Future<SpriteAnimation>
  _loadSunnyPlayerIdleLeft6() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_idle_left_strip9.png',
    SpriteAnimationConfig.createStandardData(
      amount: 9,
      textureSize: SunnyPlayerConfig.textureSize,
    ),
  );

  /// Loads the melee attack animation sprite sheet.
  ///
  /// 10-frame animation cycle for detailed sword attack motion with visual effects.
  ///
  /// Returns a Future that resolves to the configured SpriteAnimation.
  static Future<SpriteAnimation>
  loadRightAttackAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_strip10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftAttackAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_sword_left_strip10.png',
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightShovelAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_strip13.png', // spr_doing_till_strip8
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftShovelAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_dig_left_strip13.png', // spr_doing_till_left_strip8
    SpriteAnimationConfig.createStandardData(
      amount: 10,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightWateringCanAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_strip5.png',
    SpriteAnimationConfig.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftWateringCanAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_watering_left_strip5.png',
    SpriteAnimationConfig.createStandardData(
      amount: 5,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightSeedAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftSeedAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_seed_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadRightHarvestBasketAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  static Future<SpriteAnimation>
  loadLeftHarvestBasketAnimation() => SpriteAnimation.load(
    'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_doing_left_strip8.png',
    SpriteAnimationConfig.createStandardData(
      amount: 8,
      textureSize: textureSize,
    ),
  );

  // ============================================================================
  // Animation Set Creation
  // ============================================================================

  /// Creates the directional animation set for walking movement.
  ///
  /// Includes idle and movement animations for all directions.
  /// Currently uses the same animation for left and right (mirroring handled elsewhere).
  ///
  /// Returns a configured SimpleDirectionAnimation instance.
  static final SimpleDirectionAnimation
  walkAnimation = SimpleDirectionAnimation(
    idleLeft: _loadSunnyPlayerIdleLeft6(),
    idleRight: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_left_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_walking_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
  );

  /// Creates the directional animation set for running movement.
  ///
  /// Includes idle and running animations for all directions.
  /// Uses the same idle animation as walking for consistency.
  ///
  /// Returns a configured SimpleDirectionAnimation instance.
  static final SimpleDirectionAnimation runAnimation = SimpleDirectionAnimation(
    idleLeft: _loadSunnyPlayerIdleLeft6(),
    idleRight: UISpriteAnimationsConfig.loadSunnyPlayerIdleRight6(),
    runLeft: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_left_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
    runRight: SpriteAnimation.load(
      'SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX/spr_run_strip8.png',
      SpriteAnimationConfig.createStandardData(
        amount: 8,
        textureSize: textureSize,
      ),
    ),
  );

  // ============================================================================
  // Lighting Configuration
  // ============================================================================

  /// Configuration for the player's dynamic lighting effect.
  ///
  /// Creates ambient lighting around the player for dungeon exploration,
  /// revealing nearby environment and entities.
  static final LightingConfig lightingConfig = LightingConfig(
    radius: TileConstants.kTileDimensionLarge,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.playerLighting,
  );

  // ============================================================================
  // Death Effect Configuration
  // ============================================================================

  /// The size of the crypt sprite displayed on player death.
  static final Vector2 cryptComponentSize = TileConstants.tileSizeStandard;

  /// Loads the crypt sprite shown at the player's death location.
  ///
  /// Returns a Future that resolves to the loaded Sprite.
  static Future<Sprite> loadCryptSprite() =>
      Sprite.load('gameplay/characters/player/player_crypt_1.png');

  /// Creates a crypt decoration component at the specified position.
  ///
  /// Used to mark the player's death location in the game world.
  ///
  /// [position] The world position for the crypt sprite.
  ///
  /// Returns a configured DDDecoration instance.
  static DDDecoration createDeathMarker(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );
}
