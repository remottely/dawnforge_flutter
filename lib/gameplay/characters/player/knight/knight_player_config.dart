import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/shared/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/ui_sprite_animations_config.dart';

/// Configuration constants and factory methods for the Knight player character.
///
/// This final class serves as a centralized configuration hub for all
/// Knight-related settings including combat stats, resource management,
/// visual properties, and asset loading. It follows the static factory pattern
/// to prevent instantiation while providing utility methods.
///
/// The Knight character uses a dual-hand equipment system for combat, with
/// this configuration providing the base stats and visual assets. Equipment-specific
/// configurations are managed separately through the hand management system.
///
/// Organized into logical sections:
/// - Detection & Vision
/// - Character Stats & Movement
/// - Resource Management (Stamina & Energy)
/// - Combat Configuration
/// - Component Dimensions & Collision
/// - Animation Assets
/// - Lighting Configuration
/// - Death Effect Configuration
/// - Equipment & Weapon Asset Paths
final class KnightPlayerConfig {
  /// Private constructor to prevent instantiation.
  KnightPlayerConfig._();

  // ============================================================================
  // Detection & Vision Configuration
  // ============================================================================

  /// The radius within which the player can detect enemies and interactables.
  ///
  /// Uses an extra-large vision radius allowing the player to spot threats
  /// and opportunities from a considerable distance, matching other player characters.
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
  /// Note: Knight character does not have a run mechanic, unlike Sunny player.
  static double kSpeed = CharacterConstants.kSpeedFast;

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

  /// Damage dealt by the primary attack.
  ///
  /// For Knight, this is routed through the dual-hand equipment system,
  /// which determines the actual attack behavior based on equipped items.
  static const double kPrimaryAttackDamage = 25.0;

  /// Stamina cost to execute the primary attack.
  ///
  /// Moderate cost allows for multiple attacks before requiring regeneration.
  static const int kPrimaryAttackStaminaCost = 15;

  // ============================================================================
  // Combat Configuration - Fireball Attack
  // ============================================================================

  /// Damage dealt by the fireball/ranged attack.
  ///
  /// For Knight, this is routed through the dual-hand equipment system,
  /// which determines the actual attack behavior based on equipped items.
  static const double kFireballAttackDamage = 10.0;

  /// Stamina cost to execute the fireball/ranged attack.
  ///
  /// Lower cost than melee to encourage mixed combat strategies.
  static const int kFireballAttackStaminaCost = 10;

  static const int kDiggerStaminaCost = 5;

  // ============================================================================
  // Component Dimensions & Collision
  // ============================================================================

  /// The texture size used for Knight's sprite sheet frames.
  static final Vector2 textureSize = TileConstants.tileSizeStandard;

  /// The rendered size of the player component in the game world.
  ///
  /// Currently matches texture size for 1:1 pixel rendering.
  static final Vector2 componentSize = textureSize;

  /// The collision hitbox for the player character.
  ///
  /// Positioned at the bottom to match the character's feet/base for accurate
  /// collision detection with ground elements. This differs from center-based
  /// hitboxes used by other characters.
  static final RectangleHitbox hitbox = HitboxUtils.createBottomHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 4.0,
    hitboxStartPositionY: 8.0,
  );

  // ============================================================================
  // Animation Assets
  // ============================================================================

  /// The complete directional animation set for the Knight character.
  ///
  /// Includes idle and running animations for both left and right directions.
  /// The Knight has distinct left/right animations unlike some characters
  /// that mirror a single animation.
  static final SimpleDirectionAnimation walkAnimation =
      SimpleDirectionAnimation(
        idleLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_idle_left_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        idleRight: UISpriteAnimationsConfig.loadKnightPlayerIdleRight6(),
        runLeft: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_walking_left_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
            textureSize: textureSize,
          ),
        ),
        runRight: SpriteAnimation.load(
          'gameplay/characters/player/knight/knight_player_walking_right_6.png',
          SpriteAnimationConfig.createStandardData(
            amount: 6,
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
    radius: TileConstants.kTileDimensionStandard,
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
  /// Shares the same death sprite as other player characters for consistency.
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
  static DDDecoration createCryptComponent(Vector2 position) =>
      DDDecoration.withSprite(
        sprite: loadCryptSprite(),
        position: Vector2(position.x, position.y),
        size: cryptComponentSize,
      );

  // ============================================================================
  // Equipment & Weapon Asset Paths
  // ============================================================================
  // Note: These paths are managed here for convenience but the actual equipment
  // system is handled through the CustomPlayerHandManager and related components.
  // Consider organizing into a separate EquipmentAssetConfig class if the list grows.

  // /// Default pickaxe tool sprite path.
  // static const String defaultPickaxeSpritePath =
  //     'gameplay/characters/weapons/SolarPoweredHammer.png';

  /// Magic staff weapon sprite path.
  static const String staffSpritePath = 'JellySquish Weapons Pack/staff.png';

  // /// Arched sword weapon sprite path.
  // static const String archedSwordSpritePath =
  //     'JellySquish Weapons Pack/arched_sword.png';

  // /// Standard sword weapon sprite path.
  // static const String swordSpritePath = 'JellySquish Weapons Pack/sword.png';

  //   static const String steelShield1SpritePath =
  // 'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/7_Shield/SteelShield1.png';

  /// Wooden shield sprite path (currently active default).
  ///
  /// Alternative steel shield path commented out for future use.
  static const String woodShield4SpritePath =
      'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/7_Shield/WoodShield4.png';

  /// Alternative sword sprite path from SPUM legacy assets.
  static const String sword3SpritePath =
      'SPUM/Resources/Addons/Legacy/0_Unit/0_Sprite/6_Weapons/0_Sword/Sword_3.png';

  /// Axe weapon sprite path.
  static const String axeNormal1SpritePath =
      'SPUM/Resources/Addons/Ver121/0_Unit/0_Sprite/6_Weapons/2_Axe/AxeNormal1.png';

  /// Mace weapon sprite path.

  // static const String newWeapon07SpritePath =
  //     'SPUM/Resources/Addons/Ver300/0_Unit/0_Sprite/8_Weapons/8_Mace/New_Weapon_07.png';
}
