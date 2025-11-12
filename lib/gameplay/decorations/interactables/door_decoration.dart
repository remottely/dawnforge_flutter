import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/sunny/sunny_player_view.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/conversation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/ui_state_manager.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/framework/decorations/dd_decoration.dart';

final class _DoorDecorationConfig {
  _DoorDecorationConfig._();

  static const String _kRequiredKeyMessage =
      'door_without_key'; // TODO(Kevin): enhance this nomenclature

  // static final Vector2 _textureSize = GameplayTileConstants.tileSizeExtraLarge;
  // static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> _loadClosedSprite() =>
      Sprite.load('gameplay/decorations/door_decoration_locked_1.png');

  static Future<SpriteAnimation> _loadOpeningAnimation() =>
      SpriteAnimation.load(
        'gameplay/decorations/door_decoration_opening_14.png',
        SpriteAnimationConfig.createStandardData(
          amount: 14,
          textureSize: TileConstants.tileSizeExtraLarge,
        ),
      );

  static _createHitbox(GameComponent target) => HitboxUtils.createBottomHitbox(
    componentSize: target.size,
    hitboxStartPositionX: 0.0,
    hitboxStartPositionY: target.height * 0.75,
  );

  static List<Say> createConversationSequence() {
    return [ConversationConfig.createKnightLeft(_kRequiredKeyMessage)];
  }
}

class DoorDecorationView extends DDDecoration {
  bool _isOpen = false;

  DoorDecorationView({required super.position, required super.size})
    : super.withSprite(sprite: _DoorDecorationConfig._loadClosedSprite());

  @override
  Future<void> onLoad() {
    add(_DoorDecorationConfig._createHitbox(this));
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
      if ((player as SunnyPlayerView).model.hasKey == true) {
        // TODO(Kevin): make this more generic, like DDBasePlayerView
        _triggerDoorOpening(player);
      } else {
        _showKeyRequiredMessage(player);
      }
    }
  }

  void _triggerDoorOpening(SimplePlayer player) {
    _isOpen = true;
    (player as SunnyPlayerView).model
        .removeKey(); // TODO(Kevin): make this more generic, like DDBasePlayerView
    _playDoorOpeningAnimation();
  }

  void _playDoorOpeningAnimation() {
    playSpriteAnimationOnce(
      _DoorDecorationConfig._loadOpeningAnimation(),
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
      conversationSequence: _DoorDecorationConfig.createConversationSequence(),
      onClose: () {
        UIStateManager.instance.isShowingConversation = false;
      },
    );
  }

  void _cleanup() {
    removeFromParent();
  }
}
