import 'package:equatable/equatable.dart';

import 'hand_item.dart';

/// Simple wrapper for the single equipped item (slot type removed)
final class EquipmentSlot extends Equatable {
  final HandItem? equippedItem;

  const EquipmentSlot({this.equippedItem});

  bool get isEmpty => equippedItem == null;
  bool get isOccupied => equippedItem != null;

  EquipmentSlot equip(HandItem item) {
    return EquipmentSlot(equippedItem: item);
  }

  EquipmentSlot unequip() {
    return const EquipmentSlot();
  }

  Map<String, dynamic> toJson() {
    return {'equippedItemId': equippedItem?.id};
  }

  static EquipmentSlot fromJson(
    Map<String, dynamic> json,
    HandItem? Function(String) itemResolver,
  ) {
    final itemId = json['equippedItemId'] as String?;
    return EquipmentSlot(
      equippedItem: itemId != null ? itemResolver(itemId) : null,
    );
  }

  @override
  String toString() => 'EquipmentSlot(equippedItem: ${equippedItem?.id})';

  @override
  List<Object?> get props => [equippedItem];
}
