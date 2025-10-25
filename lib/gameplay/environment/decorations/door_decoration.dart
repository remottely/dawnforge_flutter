import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/constants/gameplay_dialog_constants.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration.dart';
import 'package:darkness_dungeon/gameplay/environment/decorations/decoration_sprite_animations.dart';

abstract class _DoorDecorationConfig {
  static const String _kClosedDoorAsset =
      'gameplay/environment/decorations/door_decoration_locked_1.png';
  static const String _kRequiredKeyMessage = 'door_without_key';
  static const double _kHitboxHeightRatio = 0.25;
  static const double _kHitboxPositionRatio = 0.75;

  static Future<Sprite> _loadClosedSprite() => Sprite.load(_kClosedDoorAsset);

  static Future<SpriteAnimation> _loadOpeningAnimation() =>
      DecorationSpriteAnimations.doorDecorationOpening14();

  static FutureOr<void> _buildHitBox(GameComponent target) {
    target.add(
      RectangleHitbox(
        size: Vector2(target.width, target.height * _kHitboxHeightRatio),
        position: Vector2(0, target.height * _kHitboxPositionRatio),
      ),
    );
  }

  static List<Say> createDialogueSequence() {
    return [GameplayDialogConstants.playerLeftDialog(_kRequiredKeyMessage)];
  }
}

class DoorDecorationView extends DFGameDecoration {
  bool _isOpen = false;
  bool _isShowingDialog = false;

  DoorDecorationView({required super.position, required super.size})
    : super.withSprite(sprite: _DoorDecorationConfig._loadClosedSprite());

  @override
  Future<void> onLoad() {
    _DoorDecorationConfig._buildHitBox(this);
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
      _DoorDecorationConfig._loadOpeningAnimation(),
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
    GameplayUIManager.displayConversationDialog(
      gameRef.context,
      _DoorDecorationConfig.createDialogueSequence(),
      onClose: () {
        _isShowingDialog = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
