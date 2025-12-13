import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/character_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/lightning_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_strings_location.dart';

/// Configuration constants and factory methods for torch decorations.
///
/// This final class serves as a centralized configuration hub for all
/// torch-related settings, including visual properties, detection ranges,
/// and resource loading. It follows the static factory pattern to prevent
/// instantiation while providing utility methods.
final class TorchDecorationConfig {
  /// Private constructor to prevent instantiation.
  TorchDecorationConfig._();

  // ============================================================================
  // Detection & Interaction Constants
  // ============================================================================

  /// The radius within which the torch can detect player presence.
  ///
  /// Uses the super small vision radius for intimate interaction range.
  static const double kCloseVisionRadius =
      CharacterConstants.kVisionRadiusSuperSmall;

  /// Interval in milliseconds between player proximity checks.
  ///
  /// A 500ms interval provides responsive detection without excessive
  /// computation overhead.
  static const int kVisionCheckInterval = 500;

  /// Unique identifier for the vision check interval timer.
  ///
  /// Used by the game engine's interval checking system.
  static const String kVisionCheckIntervalId = 'SeePlayer';

  // ============================================================================
  // UI & Display Constants
  // ============================================================================

  /// The text displayed as an interaction prompt when the player is in range.
  ///
  /// Shown above the torch when it's unlit and the player can interact with it.
  static final String interactionPromptText = GameplayStringsLocation.instance
      .getString('torch_decoration_light_up');

  /// Amount of health restored per healing potion interaction.
  ///
  /// Note: This constant appears misplaced in torch configuration and should
  /// potentially be moved to a potion or healing-specific config class.
  static const double kHealAmountPerPotion = 30.0;

  // ============================================================================
  // Component Dimensions
  // ============================================================================

  /// The texture size used for sprite sheet frames.
  static final Vector2 _textureSize = TileConstants.tileSizeStandard;

  /// The rendered size of the torch component in the game world.
  ///
  /// Currently matches the texture size for 1:1 pixel rendering.
  static final Vector2 componentSize = _textureSize;

  // ============================================================================
  // Text Rendering Configuration
  // ============================================================================

  /// Creates a configured TextPaint instance for rendering interaction prompts.
  ///
  /// The text size is dynamically calculated based on component width to ensure
  /// proper scaling across different screen resolutions.
  ///
  /// [componentWidth] The width of the torch component for text sizing.
  ///
  /// Returns a configured TextPaint instance with white color and appropriate font size.
  static TextPaint createTextConfig(double componentWidth) => TextPaint(
    style: TextStyle(
      color: const Color(0xFFFFFFFF),
      fontSize: componentWidth / 2,
    ),
  );

  /// Calculates the position for rendering the interaction prompt text.
  ///
  /// Positions the text above and slightly to the left of the torch component
  /// for optimal visibility without obscuring the torch itself.
  ///
  /// [componentWidth] The width of the torch component.
  /// [componentHeight] The height of the torch component.
  ///
  /// Returns a Vector2 representing the text's render position offset.
  static Vector2 getTextPosition(
    double componentWidth,
    double componentHeight,
  ) => Vector2(componentWidth / -1.5, -componentHeight);

  // ============================================================================
  // Asset Loading
  // ============================================================================

  /// Loads and configures the torch's sprite animation from assets.
  ///
  /// The animation consists of 6 frames that create a flickering torch effect,
  /// loaded from the game's decoration sprite sheet.
  ///
  /// Returns a Future that resolves to the configured SpriteAnimation.
  static Future<SpriteAnimation> loadAnimation() => SpriteAnimation.load(
    'gameplay/decorations/torch_decoration_6.png',
    SpriteAnimationConfig.createStandardData(
      amount: 6,
      textureSize: _textureSize,
    ),
  );

  // ============================================================================
  // Lighting Configuration
  // ============================================================================

  /// Configuration for the torch's dynamic lighting effect.
  ///
  /// Defines the visual properties of the light emitted by lit torches,
  /// including radius, blur, and color characteristics.
  static final LightingConfig lighting = LightingConfig(
    radius: TileConstants.kTileDimensionStandard,
    blurBorder: TileConstants.kTileDimensionStandard,
    color: LightingConstants.torchLighting,
  );
}
