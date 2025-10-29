import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/managers/gameplay_ui_manager.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_dialog_config.dart';
import 'package:darkness_dungeon/shared/dd_game_decoration.dart';

abstract class _DoorInteractableConfig {
  static const _kClosedDoorAsset =
      'gameplay/environment/interactables/door_interactable_locked_1.png';
  static const _kRequiredKeyMessage = 'door_without_key';
  static const _kHitboxHeightRatio = 0.25;
  static const _kHitboxPositionRatio = 0.75;

  static Future<Sprite> _loadClosedSprite() => Sprite.load(_kClosedDoorAsset);

  static Future<SpriteAnimation> _loadOpeningAnimation() =>
      SpriteAnimation.load(
        'gameplay/environment/interactables/door_interactable_opening_14.png',
        GameplayAnimationConfig.standardStepTimeSpriteAnimationConfig(
          amount: 14,
          textureSize: GameplayTileConfig.fTileSizeExtraLarge,
        ),
      );

  static _buildHitbox(GameComponent target) => RectangleHitbox(
    position: Vector2(0, target.height * _kHitboxPositionRatio),
    size: Vector2(target.width, target.height * _kHitboxHeightRatio),
  );

  static List<Say> createDialogueSequence() {
    return [GameplayDialogConfig.knightLeftDialog(_kRequiredKeyMessage)];
  }
}

class DoorInteractableView extends DDGameDecoration {
  bool _isOpen = false;
  bool _isShowingDialog = false;

  DoorInteractableView({required super.position, required super.size})
    : super.withSprite(sprite: _DoorInteractableConfig._loadClosedSprite());

  @override
  Future<void> onLoad() {
    add(_DoorInteractableConfig._buildHitbox(this));
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
      _DoorInteractableConfig._loadOpeningAnimation(),
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
      _DoorInteractableConfig.createDialogueSequence(),
      onClose: () {
        _isShowingDialog = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
