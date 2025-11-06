import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/knight_player_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/modules/hands/knight_hand_slot.dart';
import 'package:darkness_dungeon/gameplay/core/modules/game/gameplay_tile_constants.dart';

class KnightPickaxeHandPreset {
  KnightPickaxeHandPreset._();

  static KnightHandItemConfig create() {
    final Vector2 attachmentOffset = Vector2(8, 14);
    final Vector2 directionalOffset = Vector2(2, 0);
    final Vector2 mirroredDirectionalOffset = Vector2(-2, 0);

    KnightHandSlotConfig buildConfigForSlot(KnightHandSlot slot) {
      final isRightHand = slot == KnightHandSlot.right;
      return KnightHandSlotConfig(
        attachmentOffset: attachmentOffset,
        facingRightOffset: isRightHand
            ? mirroredDirectionalOffset
            : directionalOffset,
        facingLeftOffset: isRightHand
            ? directionalOffset
            : mirroredDirectionalOffset,
      );
    }

    return KnightHandItemConfig(
      id: 'pickaxe',
      spritePath: KnightPlayerConfig.defaultPickaxeSpritePath,
      size: GameplayTileConstants.tileSizeStandard / 2,
      slotConfigurations: {
        for (final slot in KnightHandSlot.values)
          slot: buildConfigForSlot(slot),
      },
    );
  }
}
