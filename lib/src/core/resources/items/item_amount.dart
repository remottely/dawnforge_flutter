/// An item id and how many of it — the Dart port of `ItemAmount.cs`
/// (`resources/items/utils/`). One line of a recipe, and the same shape the
/// spec's comment already names for a starting inventory.
///
/// It is DATA and nothing else. The spec hangs three inventory helpers off it
/// (`has_in_inventory`, `consume_from_inventory`, `get_display_string`), each
/// of which reaches into a container and a registry from inside a resource;
/// here those belong to `CraftingRules` and to whoever holds the locale, so
/// this class stays a pair that cannot be wrong.
///
/// *Data that exists is valid data*: the constructor asserts what the spec's
/// `validate()` throws for, so there is no `isValid` to ask. Anything that
/// holds one of these is holding a valid one.
final class ItemAmount {
  ItemAmount({required this.itemId, required this.amount})
      : assert(itemId != '', '[ItemAmount] an ingredient with no item id'),
        assert(amount > 0, '[ItemAmount($itemId)] amount $amount must be > 0');

  /// PORT DELTA in the KEY, not the value: the spec's field is `item`, and the
  /// `.md` pack authors `id` — its emitter maps one to the other on the way to
  /// `.tres`. This port reads what the pack wrote, so the name here follows
  /// the pack rather than the C# field it corresponds to.
  factory ItemAmount.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String) {
      throw StateError('[ItemAmount] ingredient has no "id": $json');
    }
    final amount = json['amount'];
    if (amount is! int) {
      throw StateError('[ItemAmount($id)] ingredient has no "amount": $json');
    }
    return ItemAmount(itemId: id, amount: amount);
  }

  final String itemId;
  final int amount;

  // No `clone()`, deliberately: both fields are final, so there is nothing an
  // instance can drift into. A recipe line is authored content and never
  // per-instance state (rule 8) — what a holder copies is the LIST, and
  // `ItemCraftableData.clone` does exactly that.

  @override
  String toString() => '$amount× $itemId';
}
