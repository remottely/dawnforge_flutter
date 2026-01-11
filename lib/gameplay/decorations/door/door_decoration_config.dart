import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/gameplay/core/modules/game/tile_constants.dart';
import 'package:dawnforge/gameplay/core/modules/ui/conversation_def.dart';
import 'package:dawnforge/gameplay/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class DoorDecorationDef {
  DoorDecorationDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeExtraLarge;
  // static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> loadSpriteClosed() =>
      Sprite.load('gameplay/decorations/door_decoration_locked_1.png');

  static Future<SpriteAnimation> loadAnimationOpening() => SpriteAnimation.load(
    'gameplay/decorations/door_decoration_opening_14.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 14,
      textureSize: _textureSize,
    ),
  );

  static RectangleHitbox createHitbox(GameComponent target) =>
      HitboxUtils.createBottomHitbox(
        componentSize: target.size,
        hitboxStartPositionX: 0.0,
        hitboxStartPositionY: target.height * 0.75,
      );

  static const String _kRequiredKeyMessage =
      'door_without_key'; // TODO(Kevin): enhance this nomenclature

  static const String _kWithKeyMessage = 'door_with_key';

  static List<Say> createConversationSequence() {
    return [ConversationDef.createPlayerLeft(_kRequiredKeyMessage)];
  }

  static List<Say> createConversationSequenceWithKey() {
    return [ConversationDef.createPlayerLeft(_kWithKeyMessage)];
  }
}
