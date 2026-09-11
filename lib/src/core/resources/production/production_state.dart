import 'package:dawnforge/src/core/domain/production/production_rules.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/production/allocated_material.dart';

/// What something is MAKING — the batch on the bench, and what it has not used
/// up yet.
///
/// It is mutable game state, so by rule 8 it lives on a data soul and nowhere
/// else. It is a class of its own rather than five fields on one soul because
/// there are now TWO souls that hold a batch: a station's
/// (`PropWorkstationData`) and a player's own two hands (`IActorData`, the
/// hand-craft, `D-2`). The alternative was writing the same five fields, the
/// same four verbs and the same clone twice, which is how two benches end up
/// disagreeing about what "one unit finished" means.
///
/// It owns the STATE and its invariants. The SEQUENCE — consume, allocate,
/// tick, spill, clear, and which signal each step fires — is
/// `ProductionQueue`'s, and the arithmetic inside a tick is
/// `ProductionRules`'.
///
/// Extracted from `PropWorkstationData` at 0.76.0 without a behaviour change:
/// every method below was that class's, and that class now delegates to this
/// one, so a station's public API is untouched.
final class ProductionState {
  ItemCraftableData? _currentRecipe;
  int _initialQuantity = 0;
  int _remainingQuantity = 0;
  double _currentProgress = 0;
  final List<AllocatedMaterial> _allocatedMaterials = <AllocatedMaterial>[];

  /// The recipe on the bench, or null when idle.
  ItemCraftableData? get currentRecipe => _currentRecipe;

  /// Whether a batch is running.
  ///
  /// PORT DELTA — DERIVED, never stored. The spec keeps `is_producing` as a
  /// fourth field beside the recipe, and the two are written separately in
  /// three places; a flag that can disagree with the fact it stands for is
  /// the loose boolean rule 9 forbids. Something is producing exactly when it
  /// holds a recipe, so that is the whole definition.
  bool get isProducing => _currentRecipe != null;

  /// How many units the running batch was ordered with. Zero when idle.
  ///
  /// PORT DELTA — the spec does not store this, and its `_get_initial_quantity`
  /// says so in a comment and then returns the REMAINING count, so the
  /// progress signal there announces "item 1 of N" for every unit of the
  /// batch. Stored at start here, which is the fix the comment asked for.
  int get initialQuantity => _initialQuantity;

  /// How many units are still to be made. Zero when idle.
  int get remainingQuantity => _remainingQuantity;

  /// Progress of the unit on the bench, in `[0, 1)`. Zero when idle.
  double get currentProgress => _currentProgress;

  /// What the running batch took from the payer and has not used up yet —
  /// what a cancellation gives back.
  List<AllocatedMaterial> get allocatedMaterials =>
      List<AllocatedMaterial>.unmodifiable(_allocatedMaterials);

  /// Opens a batch: [quantity] units of [recipe], with every ingredient line
  /// multiplied out into an allocation this batch now holds.
  ///
  /// Asserts it is idle. The spec overwrites silently; here the queue cancels
  /// first, and a call that skips that step would drop the allocated
  /// materials on the floor — a refund that never happens.
  void storeMaterials(ItemCraftableData recipe, int quantity, {String? owner}) {
    assert(!isProducing, '[ProductionState($owner)] store while producing');
    assert(quantity > 0, '[ProductionState($owner)] a batch of $quantity');
    assert(recipe.isCraftable, '[ProductionState($owner)] ${recipe.id} empty');
    _currentRecipe = recipe;
    _initialQuantity = quantity;
    _remainingQuantity = quantity;
    _currentProgress = 0;
    _allocatedMaterials
      ..clear()
      ..addAll(
        recipe.ingredients.map(
          (line) => AllocatedMaterial(
            itemId: line.itemId,
            amount: line.amount * quantity,
          ),
        ),
      );
  }

  /// Advances the unit on the bench by [increment].
  void advanceProgress(double increment, {String? owner}) {
    assert(isProducing, '[ProductionState($owner)] advance while idle');
    assert(increment >= 0, '[ProductionState($owner)] negative $increment');
    _currentProgress += increment;
  }

  /// Closes one unit: one fewer to make, the bench cleared for the next, and
  /// every allocated line reduced by what one unit costs.
  void completeUnit({String? owner}) {
    final recipe = _currentRecipe;
    assert(recipe != null, '[ProductionState($owner)] complete while idle');
    assert(_remainingQuantity > 0, '[ProductionState($owner)] past zero');
    _remainingQuantity -= 1;
    _currentProgress = 0;
    // Lines and ingredients were written from the same list in the same
    // order by [storeMaterials], so index i of one IS index i of the other.
    for (var i = 0; i < _allocatedMaterials.length; i++) {
      final line = _allocatedMaterials[i];
      line.amount = ProductionRules.reduceAllocatedAmount(
        line.amount,
        recipe!.ingredients[i].amount,
      );
    }
  }

  /// Returns to idle. What was allocated is the caller's to refund BEFORE
  /// this call — after it, the list is gone.
  void clear() {
    _currentRecipe = null;
    _initialQuantity = 0;
    _remainingQuantity = 0;
    _currentProgress = 0;
    _allocatedMaterials.clear();
  }

  /// Takes on [other]'s batch, allocations and all — what a soul's `clone()`
  /// owes, since a clone is a full copy.
  void adoptFrom(ProductionState other) {
    _currentRecipe = other._currentRecipe;
    _initialQuantity = other._initialQuantity;
    _remainingQuantity = other._remainingQuantity;
    _currentProgress = other._currentProgress;
    _allocatedMaterials
      ..clear()
      ..addAll(other._allocatedMaterials.map((line) => line.clone()));
  }

  /// What a save file stores about a running batch. Keyless on purpose: the
  /// soul that owns this state decides where these five entries sit inside
  /// its own map.
  Map<String, Object?> serialize() => <String, Object?>{
        'current_recipe_id': _currentRecipe?.id,
        'initial_quantity': _initialQuantity,
        'remaining_quantity': _remainingQuantity,
        'current_progress': _currentProgress,
        'allocated_materials':
            _allocatedMaterials.map((line) => line.serialize()).toList(),
      };
}
