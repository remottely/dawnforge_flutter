import 'package:dawnforge/src/core/resources/items/item_amount.dart';

/// How many of [itemId] the asking container holds.
///
/// A function and not a container, which is what keeps these rules pure: the
/// only thing this domain needs from an inventory is a count, so that is the
/// whole of what it takes. A test passes a map; `InventoryComponent.countOf`
/// fits without an adapter.
typedef ItemCount = int Function(String itemId);

/// Whether a recipe can be paid for, and how many times — the Dart port of the
/// three affordability methods on `ItemCraftableData.cs` (`can_craft`,
/// `can_craft_quantity`, `get_max_craftable`) and of `get_total_time`.
///
/// PORT DELTA — WHERE THEY LIVE. In the spec they hang off the data class and
/// reach into an inventory node to answer, which makes a resource that cannot
/// be tested without one. Here the recipe stays data (`ItemCraftableData`) and
/// the questions about paying for it come here, where the only input is a
/// count. Nothing else moves: same order, same arithmetic, same answers.
///
/// The tick arithmetic of a running batch is a DIFFERENT port —
/// `ProductionRules.cs`, which arrives with the component that ticks.
abstract final class CraftingRules {
  /// The most batches one order may ask for.
  ///
  /// The spec writes this as `int maxPossible = 100;` under a comment calling
  /// it "Max int32", which it is not — and the VALUE is the behaviour, so 100
  /// is what ports. It is a real ceiling a player can reach: hold 1000 ore and
  /// the answer is still 100 bars per order, not 200.
  static const int maxBatchesPerOrder = 100;

  /// How many whole batches [available] units pay for at [required] each.
  ///
  /// Integer division, which is what the spec's `(int)(available / (float)
  /// amount)` comes to — the float round-trip cannot change the answer at any
  /// quantity a 30-slot bag of 100-stacks can hold. [required] is never zero:
  /// `ItemAmount` asserts it on the way in, so the invariant does the guarding
  /// rather than a check here.
  static int batchesFrom(int available, int required) => available ~/ required;

  /// Whether [countOf] covers every line of [ingredients], [quantity] times.
  ///
  /// PORT DELTA — one method, not two. The spec's `can_craft` and
  /// `can_craft_quantity` differ only in that the first fixes the quantity at
  /// one, so they are the same sentence and this is it.
  ///
  /// **An EMPTY recipe answers false.** That is the case worth naming: `every`
  /// over nothing is vacuously TRUE, which would say a thing nobody wrote a
  /// recipe for can be made out of nothing. The spec reaches the same answer
  /// through its `is_craftable()` guard; the guard is not optional either way.
  static bool canCraft(
    List<ItemAmount> ingredients,
    ItemCount countOf, {
    int quantity = 1,
  }) {
    if (ingredients.isEmpty || quantity <= 0) return false;
    return ingredients.every(
      (line) => countOf(line.itemId) >= line.amount * quantity,
    );
  }

  /// The largest order [countOf] can pay for, capped by [maxBatchesPerOrder].
  ///
  /// The scarcest line decides, which is why this is a minimum and not a sum:
  /// five bars' worth of ore and one bar's worth of coal makes one bar.
  ///
  /// **An EMPTY recipe answers 0**, and here the trap is louder than in
  /// [canCraft]: a minimum over nothing leaves the ceiling untouched, so
  /// without this an unmakeable thing would report a hundred.
  static int maxCraftable(List<ItemAmount> ingredients, ItemCount countOf) {
    if (ingredients.isEmpty) return 0;
    var possible = maxBatchesPerOrder;
    for (final line in ingredients) {
      final batches = batchesFrom(countOf(line.itemId), line.amount);
      if (batches < possible) possible = batches;
    }
    return possible;
  }

  /// How long [quantity] batches take at [craftTime] each.
  static double totalTime(double craftTime, int quantity) =>
      craftTime * quantity;
}
