import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/modules/ui/conversation_def.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/shared/utils/sprite_animation_config_helper.dart';

final class BedDecorationDef {
  BedDecorationDef._();

  static final Vector2 _textureSize = TileConstants.tileSizeExtraLarge;
  static final Vector2 componentSize = TileConstants.tileSizeExtraLarge;

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
      HitboxUtils.createBottomHitbox(
        componentSize: target.size,
        hitboxStartPositionX: 0.0,
        hitboxStartPositionY: target.height * 0.75,
      );

  static const String _kRestMessage = 'bed_rest_message';

  static List<Say> createConversationSequence() {
    return [ConversationDef.createPlayerLeft(_kRestMessage)];
  }
}
