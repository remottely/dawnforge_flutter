import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/decorations/door/door_decoration_config.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';
import 'package:darkness_dungeon/shared/framework/players/dd_base_player/dd_base_player_view.dart';

class DoorDecorationView extends DDDecoration {
  bool _isOpen = false;

  DoorDecorationView({required super.position, required super.size})
    : super.withSprite(sprite: DoorDecorationConfig.loadClosedSprite());

  @override
  Future<void> onLoad() {
    add(DoorDecorationConfig.createHitbox(this));
    return super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is SimplePlayer) {
      _handlePlayerCollision(other);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _handlePlayerCollision(SimplePlayer player) {
    if (!_isOpen) {
      if ((player as DDBasePlayerView).controller.model.hasKey == true) {
        // TODO(Kevin): make this more generic, like DDBasePlayerView
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage(player);
      }
    }
  }

  void _triggerDoorOpening(SimplePlayer player) {
    _isOpen = true;
    (player as DDBasePlayerView).controller.model
        .removeKey(); // TODO(Kevin): make this more generic, like DDBasePlayerView
    _playDoorOpeningAnimation();
  }

  void _playDoorOpeningAnimation() {
    playSpriteAnimationOnce(
      DoorDecorationConfig.loadOpeningAnimation(),
      onFinish: _cleanup,
      onStart: () {
        sprite = null;
      },
    );
  }

  void _showKeyRequiredMessage(Player player) {
    if (!UIStateManager.instance.isShowingConversation) {
      UIStateManager.instance.isShowingConversation = true;
      _showConversation(player);
    }
  }

  void _showConversation(Player player) {
    UIStateManager.instance.showConversation(
      gameRef.context,
      player: player,
      conversationSequence: DoorDecorationConfig.createConversationSequence(),
      onCloseConversation: () {
        UIStateManager.instance.isShowingConversation = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
