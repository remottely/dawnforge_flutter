import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/game/core/modules/game/tile_constants.dart';
import 'package:dawnforge/game/core/modules/ui/conversation_def.dart';
import 'package:dawnforge/game/core/utils/hitbox_utils.dart';
import 'package:dawnforge/shared/utils/sprite_animation_config_helper.dart';

final class BedDecorationDef {
  BedDecorationDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeExtraLarge;
  static final Vector2 componentSize = _textureSize;

  static Future<Sprite> loadSpriteIdle() =>
      Sprite.load('gameplay/decorations/bed_decoration_idle_1.png');

  static Future<SpriteAnimation> loadAnimationUse() => SpriteAnimation.load(
    'gameplay/decorations/bed_decoration_use_10.png',
    SpriteAnimationConfigHelper.createStandardData(
      amount: 10,
      textureSize: _textureSize,
    ),
  );

  static RectangleHitbox createHitbox(GameComponent target) =>
      HitboxUtils.createExpandHitbox(target.size);

  static const String _kRestMessage = 'bed_rest_message';

  static List<Say> createConversationSequence() {
    return [ConversationDef.createPlayerLeft(_kRestMessage)];
  }
}
