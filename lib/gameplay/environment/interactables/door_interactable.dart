import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/config/gameplay_tile_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/gameplay_conversation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/gameplay_ui_state_manager.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_game_decoration.dart';

final class _DoorInteractableConfig {
  _DoorInteractableConfig._();

  static const String _kClosedDoorAsset =
      'gameplay/environment/interactables/door_interactable_locked_1.png';
  static const String _kRequiredKeyMessage = 'door_without_key';
  static const double _kHitboxHeightRatio = 0.25;
  static const double _kHitboxPositionRatio = 0.75;

  static Future<Sprite> _loadClosedSprite() => Sprite.load(_kClosedDoorAsset);

  static Future<SpriteAnimation> _loadOpeningAnimation() =>
      SpriteAnimation.load(
        'gameplay/environment/interactables/door_interactable_opening_14.png',
        GameplaySpriteAnimationConfig.createStandardData(
          amount: 14,
          textureSize: GameplayTileConfig.tileSizeExtraLarge,
        ),
      );

  static _buildHitbox(GameComponent target) => RectangleHitbox(
    position: Vector2(0, target.height * _kHitboxPositionRatio),
    size: Vector2(target.width, target.height * _kHitboxHeightRatio),
  );

  static List<Say> createConversationSequence() {
    return [
      GameplayConversationConfig.createKnightLeftDialog(_kRequiredKeyMessage),
    ];
  }
}

class DoorInteractableView extends DDGameDecoration {
  bool _isOpen = false;

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
      if (player.model.hasKey == true) {
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage(player);
      }
    }
  }

  void _triggerDoorOpening(KnightPlayerView player) {
    _isOpen = true;
    player.model.removeKey();
    _playDoorOpeningAnimation();
  }

  void _playDoorOpeningAnimation() {
    playSpriteAnimationOnce(
      _DoorInteractableConfig._loadOpeningAnimation(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  void _showKeyRequiredMessage(Player player) {
    if (!GameplayUIStateManager.instance.isShowingConversation) {
      GameplayUIStateManager.instance.isShowingConversation = true;
      _showConversation(player);
    }
  }

  void _showConversation(Player player) {
    GameplayUIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence:
          _DoorInteractableConfig.createConversationSequence(),
      onClose: () {
        GameplayUIStateManager.instance.isShowingConversation = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
