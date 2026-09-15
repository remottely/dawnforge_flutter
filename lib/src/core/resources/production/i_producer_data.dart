import 'package:dawnforge/src/core/domain/production/crafting_rules.dart';
import 'package:dawnforge/src/core/domain/production/recipe_catalog.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/production/allocated_material.dart';
import 'package:dawnforge/src/core/resources/production/production_state.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';

/// A soul that can MAKE things — what `WorkstationComponent` requires of
/// whatever it is mounted on.
///
/// There are two of them, which is the whole reason this exists. A station
/// (`PropWorkstationData`) is a bench of its authored type, as fast as its
/// authored multiplier. A player (`IActorData`) is a bench of
/// [WorkstationType.none], at speed 1.0, which is exactly what the pack's
/// `crafted_at: NONE` recipes have always meant and what `D-2` decided the
/// hand-craft should be. One component, one sequence, one behaviour for a
/// player to learn.
///
/// It is a mixin and not an interface so the two souls SHARE the answers
/// rather than each writing their own: a station and a pair of hands
/// disagreeing about what "this bench may make that" means is precisely the
/// bug `RecipeCatalog` exists to prevent.
///
/// [production] is where the mutable half lives (rule 8). Everything below it
/// is a reading of that state or of the authored fields — nothing here stores
/// anything of its own.
mixin IProducerData {
  /// How far up the ladder this bench sits. Declared by `IVisualObjectData`,
  /// restated here because the catalog's tier gate is asked of it.
  int get tier;

  /// The mutable batch. One per soul, never shared.
  ProductionState get production;

  /// Which kind of bench this soul IS.
  WorkstationType get productionType;

  /// How much faster than plain hands this bench works. Hands are 1.0, which
  /// is why that is the default: a bench that authors no multiplier is a bench
  /// that is no better than working without one.
  double get productionSpeedMultiplier => 1;

  /// Whether this bench may make [recipe] — the gate that AUTHORISES
  /// production, and therefore the one the shown list is built from too.
  bool canUseRecipe(ItemCraftableData recipe) =>
      RecipeCatalog.accepts(recipe, productionType, tier);

  /// Every recipe this bench offers, ordered for a player to read.
  List<ItemCraftableData> validRecipes() =>
      RecipeCatalog.availableAt(productionType, tier);

  /// How long [quantity] batches of [recipe] take AT THIS BENCH.
  double effectiveTime(ItemCraftableData recipe, {int quantity = 1}) =>
      CraftingRules.totalTime(recipe.craftTime, quantity) /
      productionSpeedMultiplier;

  /// The recipe on the bench, or null when idle.
  ItemCraftableData? get currentRecipe => production.currentRecipe;

  /// Whether a batch is running.
  bool get isProducing => production.isProducing;

  /// How many units the running batch was ordered with. Zero when idle.
  int get initialQuantity => production.initialQuantity;

  /// How many units are still to be made. Zero when idle.
  int get remainingQuantity => production.remainingQuantity;

  /// Progress of the unit on the bench, in `[0, 1)`. Zero when idle.
  double get currentProgress => production.currentProgress;

  /// What the running batch took from the payer and has not used up yet —
  /// what a cancellation gives back.
  List<AllocatedMaterial> get allocatedMaterials =>
      production.allocatedMaterials;

  /// Opens a batch: [quantity] units of [recipe].
  void storeMaterials(ItemCraftableData recipe, int quantity) =>
      production.storeMaterials(recipe, quantity, owner: producerName);

  /// Advances the unit on the bench by [increment].
  void advanceProgress(double increment) =>
      production.advanceProgress(increment, owner: producerName);

  /// Closes one unit.
  void completeUnit() => production.completeUnit(owner: producerName);

  /// Returns the bench to idle.
  void clearProduction() => production.clear();

  /// What an assertion calls this bench when it fires. The soul's content id.
  String get producerName;
}
