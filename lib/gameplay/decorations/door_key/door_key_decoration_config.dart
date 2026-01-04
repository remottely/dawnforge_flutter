import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/tile_constants.dart';
import 'package:darkness_dungeon/gameplay/core/utils/hitbox_utils.dart';
import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item_type.dart';

final class DoorKeyDecorationDef {
  DoorKeyDecorationDef._();

  static const HandItemType kItemId = HandItemType.dungeon_key;

  static final Vector2 _textureSize = TileConstants.tileSizeStandard;
  static final Vector2 componentSize = _textureSize;

  static Future<Sprite> loadSprite() =>
      Sprite.load('gameplay/decorations/door_key_decoration_1.png');

  static RectangleHitbox createHitbox() => HitboxUtils.createCenterHitbox(
    componentSize: componentSize,
    hitboxStartPositionX: 2.0,
    hitboxStartPositionY: 6.0,
  );
}
