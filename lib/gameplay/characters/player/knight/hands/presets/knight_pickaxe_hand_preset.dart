import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_item_config.dart';
import 'package:darkness_dungeon/gameplay/characters/player/knight/hands/knight_hand_slot.dart';

class KnightPickaxeHandPreset {
  KnightPickaxeHandPreset._();

  static KnightHandItemConfig create({
    required String id,
    required String spritePath,
    required Vector2 spriteSize,
    required Vector2 attachmentOffset,
    required Vector2 directionalOffset,
    required Vector2 mirroredDirectionalOffset,
  }) {
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
      id: id,
      spritePath: spritePath,
      size: spriteSize,
      slotConfigurations: {
        for (final slot in KnightHandSlot.values)
          slot: buildConfigForSlot(slot),
      },
    );
  }
}
