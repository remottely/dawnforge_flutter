import 'package:equatable/equatable.dart';

import 'item.dart';

enum EquipmentSlotType {
  mainHand,
  offHand,
  helmet,
  chest,
  legs,
  boots,
  accessory1,
  accessory2;

  String toJson() => name;

  static EquipmentSlotType fromJson(String json) => values.byName(json);
}

final class EquipmentSlot extends Equatable {
  final EquipmentSlotType slotType;

  final Item? equippedItem;

  const EquipmentSlot({required this.slotType, this.equippedItem});

  bool get isEmpty => equippedItem == null;

  bool get isOccupied => equippedItem != null;

  EquipmentSlot equip(Item item) {
    return EquipmentSlot(slotType: slotType, equippedItem: item);
  }

  EquipmentSlot unequip() {
    return EquipmentSlot(slotType: slotType);
  }

  Map<String, dynamic> toJson() {
    return {'slotType': slotType.toJson(), 'equippedItemId': equippedItem?.id};
  }

  static EquipmentSlot fromJson(
    Map<String, dynamic> json,
    Item? Function(String) itemResolver,
  ) {
    final itemId = json['equippedItemId'] as String?;
    return EquipmentSlot(
      slotType: EquipmentSlotType.fromJson(json['slotType'] as String),
      equippedItem: itemId != null ? itemResolver(itemId) : null,
    );
  }

  @override
  String toString() =>
      'EquipmentSlot(slotType: $slotType, equippedItem: ${equippedItem?.id})';

  @override
  // TODO: implement props
  List<Object?> get props => [slotType, equippedItem];
}
