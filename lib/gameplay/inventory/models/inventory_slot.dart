import 'item.dart';

/// Representa um slot individual do inventário
///
/// Um slot pode estar vazio (item = null) ou conter um item com quantidade.
final class InventorySlot {
  /// Índice do slot no inventário (0-based)
  final int index;

  /// Item contido no slot (null = vazio)
  final Item? item;

  /// Quantidade de itens no slot
  final int quantity;

  /// Cria um slot de inventário
  const InventorySlot({required this.index, this.item, this.quantity = 0});

  /// Slot está vazio?
  bool get isEmpty => item == null || quantity == 0;

  /// Slot está ocupado?
  bool get isOccupied => !isEmpty;

  /// Slot está cheio (atingiu maxStackSize)?
  bool get isFull => item != null && quantity >= item!.maxStackSize;

  /// Pode adicionar item ao slot?
  ///
  /// Retorna true se:
  /// - Slot está vazio, ou
  /// - Item é o mesmo e é empilhável e há espaço
  bool canAddItem(Item itemToAdd, int quantityToAdd) {
    if (isEmpty) return true;
    if (item!.id != itemToAdd.id) return false;
    if (!item!.isStackable) return false;
    return quantity + quantityToAdd <= item!.maxStackSize;
  }

  /// Cria novo slot adicionando quantidade
  ///
  /// A quantidade é limitada ao [Item.maxStackSize].
  InventorySlot addQuantity(int amount) {
    if (item == null) return this;
    return InventorySlot(
      index: index,
      item: item,
      quantity: (quantity + amount).clamp(0, item!.maxStackSize),
    );
  }

  /// Cria novo slot removendo quantidade
  ///
  /// Se a quantidade resultante for <= 0, retorna slot vazio.
  InventorySlot removeQuantity(int amount) {
    if (item == null) return this;
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) {
      return InventorySlot(index: index); // Slot vazio
    }
    return InventorySlot(index: index, item: item, quantity: newQuantity);
  }

  /// Serialização para JSON
  Map<String, dynamic> toJson() {
    return {'index': index, 'itemId': item?.id, 'quantity': quantity};
  }

  /// Deserialização de JSON
  ///
  /// Requer um [itemResolver] para obter a instância do Item pelo ID.
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
