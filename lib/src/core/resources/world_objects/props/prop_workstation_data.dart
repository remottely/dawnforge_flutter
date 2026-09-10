import 'package:dawnforge/src/core/domain/production/crafting_rules.dart';
import 'package:dawnforge/src/core/domain/production/production_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/allocated_material.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/drop/drop_entry.dart';

/// A prop you make things at — the Dart port of `PropWorkstationData.cs`.
///
/// Recipe discovery is **item-centric**, which is the design worth keeping:
/// a station holds no recipe list of its own. It asks the item registry which
/// items name it, so authoring a new recipe is authoring one document and
/// touching nothing else. The pack's smelter has said `workstation_type:
/// SMELTER` since it was imported; this is the first class to read it.
///
/// What a station is DOING — the running batch, its allocated materials, its
/// progress — lives here too, below the authored half, because it is MUTABLE
/// GAME STATE and rule 8 gives that exactly one home. `WorkstationComponent`
/// is the behaviour over it and keeps nothing of its own.
class PropWorkstationData extends PropData {
  PropWorkstationData({
    required super.id,
    required this.workstationType,
    this.productionSpeedMultiplier = 1.0,
    super.spritesheetPath,
    super.frameWidth,
    super.frameHeight,
    super.animationSpeed,
    super.idleFrames,
    super.walkFrames,
    super.backwardFrames,
    super.soundsVolume,
    super.tier,
    super.allowedTools,
    super.groups,
    super.gridWidth,
    super.gridHeight,
    super.isFlat,
    super.hasCollision,
    super.allowsActorOverlap,
    super.isProjectilePassable,
    super.baseMaxHealth,
    super.drops,
    super.inventorySize,
    super.currentHealth,
    super.hasIdleSway,
    super.isPushable,
    super.weight,
    super.heatRadius,
    super.respawnTime,
    super.hidesActors,
  }) {
    _validate();
  }

  PropWorkstationData.fromReader(super.reader)
      : workstationType = reader.enumOr(
          'workstation_type',
          WorkstationType.values,
          WorkstationType.none,
        ),
        productionSpeedMultiplier =
            reader.doubleOr('production_speed_multiplier', 1),
        super.fromReader() {
    _validate();
  }

  factory PropWorkstationData.fromJson(Map<String, Object?> json) =>
      PropWorkstationData.fromReader(
        JsonReader(json, 'PropWorkstationData'),
      );

  void _validate() {
    // PORT DELTA — the spec asserts neither of these, and both are worth it.
    //
    // A station typed NONE would match the recipes made BY HAND, so it would
    // stand in the world offering the one list it must never own. That is a
    // content bug with no symptom, which is the kind rule 5 exists for.
    assert(
      workstationType != WorkstationType.none,
      '[$runtimeType($id)] workstation_type is NONE — that is the value a '
      'RECIPE uses to say "made by hand", and a station that answers to it '
      'would offer the hand list',
    );
    // The spec guards this INLINE, every time it divides: `multiplier > 0 ?
    // multiplier : 1.0`. That is a fallback patched over bad data at the point
    // of use (rules 5 and 20). Asserted once here instead, so the division
    // downstream is plain arithmetic that cannot be handed a zero.
    assert(
      productionSpeedMultiplier > 0,
      '[$runtimeType($id)] production_speed_multiplier must be > 0',
    );
  }

  /// Which recipes name this station. Tier 1 = 1.0, tier 5 = 5.0 in the pack.
  final WorkstationType workstationType;

  /// How much faster than the authored time this station works: the effective
  /// time is the base time DIVIDED by this, so bigger is faster.
  final double productionSpeedMultiplier;

  /// Whether this station may make [recipe] — the gate that AUTHORISES
  /// production, and therefore the one the shown list must be built from too.
  /// They were two sentences in the spec once and disagreed; here there is one.
  ///
  /// Tier is CUMULATIVE, not exact: a station of tier N makes every recipe of
  /// its type from the first tier up to N, so a tier 5 smelter still melts
  /// tier 1 bars. Written as `<=` and never as a list of accepted tiers, so
  /// the rule holds for however many tiers a pack declares.
  ///
  /// PORT DELTA — the spec adds a third clause, `TierSystem.is_content_unlocked`
  /// (the Forge Almanac / skill tree). Progression is unported (FP7), so the
  /// clause is left out rather than stubbed true: a stub would be a gate that
  /// says yes to everything while looking like a gate.
  bool canUseRecipe(ItemCraftableData recipe) =>
      recipe.isCraftable &&
      recipe.craftedAt == workstationType &&
      recipe.tier <= tier;

  /// Every recipe this station offers, best-ordered for a player to read.
  ///
  /// Sorted by tier and THEN by id, because the list is not one tier deep: a
  /// station of tier N shows every tier up to N, and ids sort as TEXT, where
  /// `t10_` falls between `t1_` and `t2_`.
  ///
  /// PORT DELTA — the spec's `get_valid_recipes_cached` is not ported. It has
  /// no caller there either; the surface calls the uncached one. A cache
  /// nobody asks for is a second answer waiting to disagree with the first.
  List<ItemCraftableData> validRecipes() {
    final items = locator<ItemRegistry>();
    final found = <ItemCraftableData>[];
    for (final id in items.ids) {
      final item = items.getItem(id);
      if (item is ItemCraftableData && canUseRecipe(item)) found.add(item);
    }
    found.sort(
      (a, b) => a.tier != b.tier ? a.tier.compareTo(b.tier) : a.id.compareTo(b.id),
    );
    return found;
  }

  /// How long [quantity] batches of [recipe] take AT THIS STATION.
  double effectiveTime(ItemCraftableData recipe, {int quantity = 1}) =>
      CraftingRules.totalTime(recipe.craftTime, quantity) /
      productionSpeedMultiplier;

  // ---------------------------------------------------------------------------
  // PRODUCTION STATE — what the station is DOING (rule 8: it lives here).
  // ---------------------------------------------------------------------------

  ItemCraftableData? _currentRecipe;
  int _initialQuantity = 0;
  int _remainingQuantity = 0;
  double _currentProgress = 0;
  final List<AllocatedMaterial> _allocatedMaterials = <AllocatedMaterial>[];

  /// The recipe on the bench, or null when the station is idle.
  ItemCraftableData? get currentRecipe => _currentRecipe;

  /// Whether a batch is running.
  ///
  /// PORT DELTA — DERIVED, never stored. The spec keeps `is_producing` as a
  /// fourth field beside the recipe, and the two are written separately in
  /// three places; a flag that can disagree with the fact it stands for is
  /// the loose boolean rule 9 forbids. A station is producing exactly when it
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

  /// What the running batch took from the player and has not used up yet —
  /// what a cancellation gives back. Read-only from outside; the component
  /// reduces the lines through [allocatedMaterials]' own setters.
  List<AllocatedMaterial> get allocatedMaterials =>
      List<AllocatedMaterial>.unmodifiable(_allocatedMaterials);

  /// Opens a batch: [quantity] units of [recipe], with every ingredient line
  /// multiplied out into an allocation the station now holds.
  ///
  /// Asserts the station is idle. The spec overwrites silently; here the
  /// component cancels first, and a call that skips that step would drop the
  /// allocated materials on the floor — a refund that never happens.
  void storeMaterials(ItemCraftableData recipe, int quantity) {
    assert(!isProducing, '[$runtimeType($id)] storeMaterials while producing');
    assert(quantity > 0, '[$runtimeType($id)] a batch of $quantity');
    assert(recipe.isCraftable, '[$runtimeType($id)] ${recipe.id} has no recipe');
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
  void advanceProgress(double increment) {
    assert(isProducing, '[$runtimeType($id)] advanceProgress while idle');
    assert(increment >= 0, '[$runtimeType($id)] negative progress $increment');
    _currentProgress += increment;
  }

  /// Closes one unit: one fewer to make, the bench cleared for the next, and
  /// every allocated line reduced by what one unit costs.
  void completeUnit() {
    final recipe = _currentRecipe;
    assert(recipe != null, '[$runtimeType($id)] completeUnit while idle');
    assert(_remainingQuantity > 0, '[$runtimeType($id)] completeUnit past zero');
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

  /// Returns the station to idle. What was allocated is the caller's to
  /// refund BEFORE this call — after it, the list is gone.
  void clearProduction() {
    _currentRecipe = null;
    _initialQuantity = 0;
    _remainingQuantity = 0;
    _currentProgress = 0;
    _allocatedMaterials.clear();
  }

  @override
  Map<String, Object?> serialize() => <String, Object?>{
        ...super.serialize(),
        'current_recipe_id': _currentRecipe?.id,
        'initial_quantity': _initialQuantity,
        'remaining_quantity': _remainingQuantity,
        'current_progress': _currentProgress,
        'allocated_materials': _allocatedMaterials
            .map((line) => line.serialize())
            .toList(),
      };

  /// Copies every field, the production state included: a clone is a full
  /// copy, the same bargain `currentHealth` makes one class up. The registry
  /// template is never producing, so the factory's clone starts idle; a save
  /// restoring a mid-batch station is FP6's, and lands on these same fields.
  @override
  PropWorkstationData clone() => _cloneAuthored().._adoptProductionFrom(this);

  void _adoptProductionFrom(PropWorkstationData other) {
    _currentRecipe = other._currentRecipe;
    _initialQuantity = other._initialQuantity;
    _remainingQuantity = other._remainingQuantity;
    _currentProgress = other._currentProgress;
    _allocatedMaterials
      ..clear()
      ..addAll(other._allocatedMaterials.map((line) => line.clone()));
  }

  PropWorkstationData _cloneAuthored() => PropWorkstationData(
        id: id,
        workstationType: workstationType,
        productionSpeedMultiplier: productionSpeedMultiplier,
        spritesheetPath: spritesheetPath,
        frameWidth: frameWidth,
        frameHeight: frameHeight,
        animationSpeed: animationSpeed,
        idleFrames: idleFrames,
        walkFrames: walkFrames,
        backwardFrames: backwardFrames,
        soundsVolume: soundsVolume,
        tier: tier,
        allowedTools: List<ToolType>.of(allowedTools),
        groups: List<String>.of(groups),
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        isFlat: isFlat,
        hasCollision: hasCollision,
        allowsActorOverlap: allowsActorOverlap,
        isProjectilePassable: isProjectilePassable,
        baseMaxHealth: baseMaxHealth,
        drops: List<DropEntry>.of(drops),
        inventorySize: inventorySize,
        currentHealth: currentHealth,
        hasIdleSway: hasIdleSway,
        isPushable: isPushable,
        weight: weight,
        heatRadius: heatRadius,
        respawnTime: respawnTime,
        hidesActors: hidesActors,
      );
}
