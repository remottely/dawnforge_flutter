import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/custom/hands/custom_player_hand_slot.dart';

class CustomPlayerPickaxeHandPreset {
  CustomPlayerPickaxeHandPreset._();

  static CustomPlayerItemData create({
    required String id,
    required String spritePath,
    required Vector2 spriteSize,
    required Vector2 attachmentOffset,
    required Vector2 directionalOffset,
    required Vector2 mirroredDirectionalOffset,
  }) {
    CustomPlayerHandSlotSpec buildSlotSpec(CustomPlayerHandSlot slot) {
      final isRightHand = slot == CustomPlayerHandSlot.right;
      return CustomPlayerHandSlotSpec(
        attachmentOffset: attachmentOffset,
        facingRightOffset: isRightHand
            ? mirroredDirectionalOffset
            : directionalOffset,
        facingLeftOffset: isRightHand
            ? directionalOffset
            : mirroredDirectionalOffset,
      );
    }

    return CustomPlayerItemData(
      id: id,
      spritePath: spritePath,
      size: spriteSize,
      slotSpecs: {
        for (final slot in CustomPlayerHandSlot.values)
          slot: buildSlotSpec(slot),
      },
    );
  }
}
