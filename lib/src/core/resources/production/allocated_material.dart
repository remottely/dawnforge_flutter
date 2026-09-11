/// One line of what a running batch has taken from the player and not yet
/// used up — the typed port of the `{"item": …, "amount": …}` dictionaries
/// `PropWorkstationData.cs` keeps in `allocated_materials`.
///
/// It is the one MUTABLE line in the production state: each unit that
/// finishes eats its share, and what is left is what a cancelled batch gives
/// back. The item is an id and not a resource (rule 2: the registry resolves
/// it when a pickup has to be made), which is also what a save writes.
final class AllocatedMaterial {
  AllocatedMaterial({required this.itemId, required int amount})
      : assert(itemId != '', '[AllocatedMaterial] an allocation with no item'),
        assert(amount >= 0, '[AllocatedMaterial($itemId)] amount $amount < 0'),
        _amount = amount;

  factory AllocatedMaterial.fromJson(Map<String, Object?> json) {
    final id = json['item_id'];
    if (id is! String) {
      throw StateError('[AllocatedMaterial] entry has no "item_id": $json');
    }
    final amount = json['amount'];
    if (amount is! int) {
      throw StateError('[AllocatedMaterial($id)] entry has no "amount": $json');
    }
    return AllocatedMaterial(itemId: id, amount: amount);
  }

  final String itemId;

  int _amount;

  /// How much of this line is still held by the station.
  int get amount => _amount;

  /// Replaces the held count. Asserted non-negative rather than clamped: the
  /// arithmetic that feeds it (`ProductionRules.reduceAllocatedAmount`)
  /// already floors at zero, so a negative here is a caller bug.
  set amount(int value) {
    assert(value >= 0, '[AllocatedMaterial($itemId)] amount $value < 0');
    _amount = value;
  }

  AllocatedMaterial clone() => AllocatedMaterial(itemId: itemId, amount: _amount);

  Map<String, Object?> serialize() => <String, Object?>{
        'item_id': itemId,
        'amount': _amount,
      };

  @override
  String toString() => '$_amount× $itemId (allocated)';
}
