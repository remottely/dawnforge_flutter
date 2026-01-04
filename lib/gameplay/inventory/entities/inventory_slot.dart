import 'package:darkness_dungeon/gameplay/inventory/entities/hand_item_id.dart';
import 'package:equatable/equatable.dart';

import 'hand_item.dart';

/// Entity representing a slot in the inventory (D2: Entity with Serialization)
final class InventorySlot extends Equatable {
  final int index;
  final HandItem? item;
  final int quantity;

  const InventorySlot({required this.index, this.item, this.quantity = 0});

  bool get isEmpty => item == null || quantity == 0;
  bool get isOccupied => !isEmpty;
  bool get isFull => item != null && quantity >= item!.maxStackSize;

  bool canAddItem(HandItem itemToAdd, int quantityToAdd) {
    if (isEmpty) return true;
    if (item!.id != itemToAdd.id) return false;
    if (!item!.isStackable) return false;
    return quantity + quantityToAdd <= item!.maxStackSize;
  }

  InventorySlot addQuantity(int amount) {
    if (item == null) return this;
    return InventorySlot(
      index: index,
      item: item,
      quantity: (quantity + amount).clamp(0, item!.maxStackSize),
    );
  }

  InventorySlot removeQuantity(int amount) {
    if (item == null) return this;
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) {
      return InventorySlot(index: index);
    }
    return InventorySlot(index: index, item: item, quantity: newQuantity);
  }

  /// Serialization (D2)
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'itemId': item?.id.name,
      'quantity': quantity,
    };
  }

  /// Deserialization with item resolver
  static InventorySlot fromJson(
    Map<String, dynamic> json,
    HandItem? Function(HandItemId) itemResolver,
  ) {
    final itemId = json['itemId'] as String?;
    return InventorySlot(
      index: json['index'] as int,
      item: itemId != null ? itemResolver(HandItemId.fromJson(itemId)) : null,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'InventorySlot(index: $index, item: ${item?.id.name}, quantity: $quantity)';

  @override
  List<Object?> get props => [index, item, quantity];
}
