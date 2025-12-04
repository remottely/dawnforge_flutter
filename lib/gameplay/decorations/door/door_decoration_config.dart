import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/conversation/conversation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/sprite_animation_config.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';

final class DoorDecorationConfig {
  DoorDecorationConfig._();

  static final Vector2 _textureSize = TileConstants.tileSizeExtraLarge;
  // static final Vector2 _componentSize = _textureSize;

  static Future<Sprite> loadClosedSprite() =>
      Sprite.load('gameplay/decorations/door_decoration_locked_1.png');

  static Future<SpriteAnimation> loadOpeningAnimation() => SpriteAnimation.load(
    'gameplay/decorations/door_decoration_opening_14.png',
    SpriteAnimationConfig.createStandardData(
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

  static List<Say> createConversationSequence() {
    return [ConversationConfig.createKnightLeft(_kRequiredKeyMessage)];
  }
}
