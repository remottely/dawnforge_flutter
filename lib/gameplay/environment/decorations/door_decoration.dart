import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/characters/player/player_sprite_animations.dart';
import 'package:darkness_dungeon/gameplay/core/localization/gameplay_strings_location.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';
import 'package:flutter/widgets.dart';

// -----------------------------------------------------------------------------
//  DATA CLASS (Seguindo o padrão de barrel_decoration.dart)
// -----------------------------------------------------------------------------

abstract class _DoorDecorationData {
  /// DATA
  static const String _kClosedDoorAsset =
      'gameplay/environment/decorations/door_decoration_locked_1.png';
  static const String _kRequiredKeyMessage = 'door_without_key';
  static const double _kHitboxHeightRatio = 0.25;
  static const double _kHitboxPositionRatio = 0.75;

  /// LOAD
  static Future<Sprite> _loadClosedSprite() => Sprite.load(_kClosedDoorAsset);

  static Future<SpriteAnimation> _loadOpeningAnimation() =>
      DecorationSpriteAnimations.doorDecorationOpening14();

  static Widget _loadDialogPersonWidget() =>
      PlayerSpriteAnimations.knightPlayerIdleRight6().asWidget();

  static FutureOr<void> _buildHitBox(GameComponent target) {
    target.add(
      RectangleHitbox(
        size: Vector2(target.width, target.height * _kHitboxHeightRatio),
        position: Vector2(0, target.height * _kHitboxPositionRatio),
      ),
    );
  }

  /// CONFIG
  static void _showKeyRequiredDialog({
    required BuildContext context,
    required VoidCallback onClose,
  }) {
    GameplayUIManager.displayConversationDialog(context, [
      Say(
        text: [TextSpan(text: getString(_kRequiredKeyMessage))],
        person: _loadDialogPersonWidget(),
        personSayDirection: PersonSayDirection.LEFT,
      ),
    ], onClose: onClose);
  }
}

// -----------------------------------------------------------------------------
//  CLASSE PRINCIPAL (Refatorada para usar _DoorDecorationData)
// -----------------------------------------------------------------------------

class DoorDecoration extends DFGameDecoration {
  bool _isOpen = false;
  bool _isShowingDialog = false;

  DoorDecoration({required super.position, required super.size})
    : super.withSprite(sprite: _DoorDecorationData._loadClosedSprite());

  @override
  Future<void> onLoad() {
    _DoorDecorationData._buildHitBox(this);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is KnightPlayerView) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _handlePlayerCollision(KnightPlayerView player) {
    if (!_isOpen) {
      if (player.controller.model.hasKey == true) {
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage();
      }
    }
  }

  void _triggerDoorOpening(KnightPlayerView player) {
    _isOpen = true;
    player.controller.model.hasKey = false;
    _playOpeningAnimation();
  }

  void _playOpeningAnimation() {
    playSpriteAnimationOnce(
      _DoorDecorationData._loadOpeningAnimation(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  void _showKeyRequiredMessage() {
    if (!_isShowingDialog) {
      _isShowingDialog = true;
      _showKeyRequiredDialog();
    }
  }

  void _showKeyRequiredDialog() {
    _DoorDecorationData._showKeyRequiredDialog(
      context: gameRef.context,
      onClose: () {
        _isShowingDialog = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
