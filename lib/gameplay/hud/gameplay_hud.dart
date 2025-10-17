import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/constants/gameplay_ui_constants.dart';
import 'package:darkness_dungeon/gameplay/hud/player_vital_stats_hud.dart';
import 'package:darkness_dungeon/gameplay/player/player_character.dart';

/// [GameplayHUD] responsible for managing the main gameplay user interface
/// Following Flutter naming conventions for HUD interface systems
///
/// This class handles:
/// - Key item display when player obtains it
/// - Integration with player vital stats display
/// - Main HUD rendering and lifecycle management
class GameplayHUD extends GameInterface {
  // Private variables
  late Sprite _keySprite;

  /// Initializes the HUD components and loads required assets
  /// Following Flutter pattern of async initialization methods
  @override
  Future<void> onLoad() async {
    await _loadAssets();
    _initializeComponents();
    return super.onLoad();
  }

  /// Renders the HUD elements on the game canvas
  /// Following Flutter pattern of render lifecycle methods
  @override
  void render(Canvas canvas) {
    try {
      _drawKeyIcon(canvas);
    } catch (e) {
      // Silent catch to prevent render crashes
    }
    super.render(canvas);
  }

  // Private helper methods

  /// Loads all required sprite assets for the HUD
  /// Following Flutter pattern of private utility methods with underscore prefix
  Future<void> _loadAssets() async {
    _keySprite = await Sprite.load(GameplayUIConstants.kKeyAssetPath);
  }

  /// Initializes HUD components and adds them to the interface
  /// Following Flutter pattern of component initialization methods
  void _initializeComponents() {
    add(PlayerVitalStatsHUD());
  }

  /// Draws the key icon when player has obtained a key
  /// Following Flutter pattern of private rendering methods
  void _drawKeyIcon(Canvas canvas) {
    if (_hasPlayerWithKey()) {
      _keySprite.renderRect(
        canvas,
        Rect.fromLTWH(
          GameplayUIConstants.kKeyIconX,
          GameplayUIConstants.kKeyIconY,
          GameplayUIConstants.kKeyIconWidth,
          GameplayUIConstants.kKeyIconHeight,
        ),
      );
    }
  }

  /// Checks if the player exists and has a key
  /// Following Flutter pattern of state checking methods
  bool _hasPlayerWithKey() {
    return gameRef.player != null && (gameRef.player as PlayerCharacter).hasKey;
  }
}
