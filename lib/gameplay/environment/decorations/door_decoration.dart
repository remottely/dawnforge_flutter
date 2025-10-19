import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/characters/sprites/player_sprite_sheet.dart';
import 'package:darkness_dungeon/gameplay/environment/sprites/environment_sprite_animation.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_character.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:flutter/cupertino.dart';

/// Interactive decoration DoorDecoration for the Darkness Dungeon game
/// Following Flutter naming conventions for barrier interaction systems
///
/// This class handles:
/// - Key-based access control system
/// - Visual and audio feedback for interactions
/// - DoorDecoration opening animation and removal
///
/// Usage patterns:
/// ```dart
/// final doorDecoration = DoorDecoration(position, size);
/// doorDecoration.onLoad();
/// ```
class DoorDecoration extends DFGameDecoration {
  // 1. Constantes de configuração
  static const String kClosedDoorAsset =
      'decorations/door_decoration_locked_1.png';
  static const String kRequiredKeyMessage = 'door_without_key';
  static const double kHitboxHeightRatio = 0.25;
  static const double kHitboxPositionRatio = 0.75;

  // 2. Variáveis de instância privadas
  final Vector2 _initialPosition;
  final Vector2 _size;
  bool _isOpen = false;
  bool _isShowingDialog = false;

  // 3. Construtor
  DoorDecoration(this._initialPosition, this._size)
    : super.withSprite(
        sprite: Sprite.load(kClosedDoorAsset),
        position: _initialPosition,
        size: _size,
      );

  // 4. Métodos públicos principais
  @override
  Future<void> onLoad() {
    _setupHitbox();
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is KnightCharacter) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  // 5. Métodos privados auxiliares
  /// Sets up the hitbox for collision detection
  void _setupHitbox() {
    add(
      RectangleHitbox(
        size: Vector2(width, height * kHitboxHeightRatio),
        position: Vector2(0, height * kHitboxPositionRatio),
      ),
    );
  }

  /// Handles collision with the player
  void _handlePlayerCollision(KnightCharacter player) {
    if (!_isOpen) {
      if (player.hasKey == true) {
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage();
      }
    }
  }

  /// Triggers the doorDecoration opening sequence
  void _triggerDoorOpening(KnightCharacter player) {
    _isOpen = true;
    player.hasKey = false;
    _playOpeningAnimation();
  }

  /// Plays the doorDecoration opening animation
  void _playOpeningAnimation() {
    playSpriteAnimationOnce(
      EnvironmentSpriteAnimation.doorDecorationOpening14(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  /// Shows the key required message to the player
  void _showKeyRequiredMessage() {
    if (!_isShowingDialog) {
      _isShowingDialog = true;
      _showKeyRequiredDialog();
    }
  }

  /// Shows the key required dialog
  void _showKeyRequiredDialog() {
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString(kRequiredKeyMessage))],
          person: PlayerSpriteSheet.idleRight().asWidget(),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onClose: () {
        _isShowingDialog = false;
      },
    );
  }

  /// Cleans up the doorDecoration after opening
  void _cleanup() {
    removeFromParent();
  }
}
