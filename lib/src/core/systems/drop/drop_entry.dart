import 'package:dawnforge/src/core/resources/json_reader.dart';

/// One line of a loot table — port of `DropEntry.cs` (`systems/drop/`).
///
/// Immutable definition data: what MAY drop, at what odds, in what amounts.
/// The registry resolution the Godot class performs in `validate()` stays
/// lazy here too — the item id is resolved through `ItemRegistry.get` at roll
/// time (rule 2), and the almanac seam test proves every authored id resolves
/// long before a roll can.
final class DropEntry {
  DropEntry({
    required this.itemId,
    this.chance = 1.0,
    this.minAmount = 1,
    this.maxAmount = 1,
  }) {
    _validate();
  }

  DropEntry.fromReader(JsonReader reader)
      : itemId = reader.requiredString('item_id'),
        chance = reader.doubleOr('chance', 1),
        minAmount = reader.intOr('min_amount', 1),
        maxAmount = reader.intOr('max_amount', 1) {
    _validate();
  }

  factory DropEntry.fromJson(Map<String, Object?> json) =>
      DropEntry.fromReader(JsonReader(json, 'DropEntry'));

  void _validate() {
    assert(itemId.isNotEmpty, '[DropEntry] item_id required');
    // A chance of 0 is dead content — an entry that can never roll is an
    // authoring mistake, not a legitimate table line.
    assert(
      chance > 0 && chance <= 1,
      '[DropEntry($itemId)] chance $chance outside (0, 1]',
    );
    assert(
      minAmount >= 1 && minAmount <= maxAmount,
      '[DropEntry($itemId)] amounts $minAmount..$maxAmount invalid',
    );
  }

  final String itemId;

  /// Odds this entry rolls at all (0 exclusive to 1 inclusive).
  final double chance;
  final int minAmount;
  final int maxAmount;
}
