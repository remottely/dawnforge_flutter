/// One inventory slot — the Dart port of the Godot `InventoryComponent`'s
/// inner `ItemStack`, lifted into the data layer because slot contents are
/// MUTABLE GAME STATE (rule 8) and live in the data soul, never in the
/// component.
///
/// The slot stores the item ID, never the resource: the registry resolves it
/// on read (rule 2). Instance state a unique item carries (durability, a
/// world identity) arrives with the item-hand system and will widen this
/// class then — the same faithful-slice discipline the data classes follow.
final class ItemStack {
  /// An empty slot — the legitimate "nothing here" value every container
  /// starts full of.
  ItemStack.empty()
      : itemId = '',
        amount = 0;

  ItemStack.of(this.itemId, this.amount)
      : assert(
          itemId != '',
          '[ItemStack] use ItemStack.empty() for nothing',
        ),
        assert(amount > 0, '[ItemStack] amount $amount must be > 0');

  factory ItemStack.deserialize(Map<String, Object?> json) {
    final itemId = json['item_id'];
    if (itemId == null) return ItemStack.empty();
    if (itemId is! String || itemId.isEmpty) {
      throw StateError('[ItemStack] malformed slot: $json');
    }
    final amount = json['amount'];
    if (amount is! int || amount <= 0) {
      throw StateError('[ItemStack($itemId)] malformed amount: $json');
    }
    return ItemStack.of(itemId, amount);
  }

  String itemId;
  int amount;

  bool get isEmpty => itemId.isEmpty || amount <= 0;

  void clear() {
    itemId = '';
    amount = 0;
  }

  /// Mutable state only — an empty slot serializes as an empty object.
  Map<String, Object?> serialize() => isEmpty
      ? const <String, Object?>{}
      : <String, Object?>{'item_id': itemId, 'amount': amount};

  ItemStack clone() =>
      isEmpty ? ItemStack.empty() : ItemStack.of(itemId, amount);
}
