import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_data.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';

class KnightPickaxeHandPreset {
  KnightPickaxeHandPreset._();

  static KnightHandItemData create({
    required String id,
    required String spritePath,
    required Vector2 spriteSize,
    required Vector2 attachmentOffset,
    required Vector2 directionalOffset,
    required Vector2 mirroredDirectionalOffset,
  }) {
    KnightHandSlotSpec buildSlotSpec(KnightHandSlot slot) {
      final isRightHand = slot == KnightHandSlot.right;
      return KnightHandSlotSpec(
        attachmentOffset: attachmentOffset,
        facingRightOffset: isRightHand
            ? mirroredDirectionalOffset
            : directionalOffset,
        facingLeftOffset: isRightHand
            ? directionalOffset
            : mirroredDirectionalOffset,
      );
    }

    return KnightHandItemData(
      id: id,
      spritePath: spritePath,
      size: spriteSize,
      slotSpecs: {
        for (final slot in KnightHandSlot.values) slot: buildSlotSpec(slot),
      },
    );
  }
}
