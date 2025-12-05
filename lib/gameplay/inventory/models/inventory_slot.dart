import 'item.dart';

final class InventorySlot {
  final int index;
  final Item? item;
  final int quantity;

  const InventorySlot({required this.index, this.item, this.quantity = 0});

  bool get isEmpty => item == null || quantity == 0;
  bool get isOccupied => !isEmpty;
  bool get isFull => item != null && quantity >= item!.maxStackSize;

  bool canAddItem(Item itemToAdd, int quantityToAdd) {
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

  Map<String, dynamic> toJson() {
    return {'index': index, 'itemId': item?.id, 'quantity': quantity};
  }

  static InventorySlot fromJson(
    Map<String, dynamic> json,
    Item? Function(String) itemResolver,
  ) {
    final itemId = json['itemId'] as String?;
    return InventorySlot(
      index: json['index'] as int,
      item: itemId != null ? itemResolver(itemId) : null,
      quantity: json['quantity'] as int? ?? 0,
    );
  }

  @override
  String toString() =>
      'InventorySlot(index: $index, item: ${item?.id}, quantity: $quantity)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventorySlot &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          item == other.item &&
          quantity == other.quantity;

  @override
  int get hashCode => Object.hash(index, item, quantity);
}
