import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_sprite_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';

// -----------------------------------------------------------------------------
//  DATA CLASS (Seguindo o padrão de barrel_decoration.dart)
// -----------------------------------------------------------------------------

abstract class _DoorKeyDecorationData {
  /// DATA
  static const String _spritePath =
      GameplaySpriteConstants.kDoorKeyDecorationAssetPath;
  static final Vector2 _spriteSize = GameplayConstants.kTileSizeStandard;

  /// LOAD
  static Future<Sprite> _loadSprite() => Sprite.load(_spritePath);
}

// -----------------------------------------------------------------------------
//  CLASSE PRINCIPAL (Refatorada para usar _DoorKeyDecorationData)
// -----------------------------------------------------------------------------

/// Interactive decoration Key for the Darkness Dungeon game
/// Following Flutter naming conventions for item interaction systems
///
/// This class handles:
/// - Key collection by the player
/// - Single-use pickup mechanism
/// - Inventory state update for doorDecoration access
///
/// Usage patterns:
/// ```dart
/// final key = DoorKeyDecoration(position: Vector2(x, y));
/// key.onLoad();
/// ```
class DoorKeyDecoration extends DFSensorPlayerDecoration {
  bool _hasBeenCollected = false;

  DoorKeyDecoration({required super.position})
    : super.withSprite(
        sprite: _DoorKeyDecorationData._loadSprite(),
        size: _DoorKeyDecorationData._spriteSize,
      );

  @override
  void onContact(KnightPlayerView player) {
    if (!_hasBeenCollected) {
      _hasBeenCollected = true;
      _triggerEffect(player);
      _cleanup();
    }
  }

  /// Triggers the key collection effect
  void _triggerEffect(KnightPlayerView player) {
    player.controller.model.hasKey = true;
  }

  /// Cleans up the key after collection
  void _cleanup() {
    removeFromParent();
  }
}
