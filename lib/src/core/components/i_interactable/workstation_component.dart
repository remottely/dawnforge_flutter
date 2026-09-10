import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/domain/production/crafting_rules.dart';
import 'package:dawnforge/src/core/domain/production/production_rules.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_craftable_data.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/allocated_material.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// What a station is DOING — the port of `workstation_component.gd`'s
/// production loop. It takes a batch from a bag, ticks it, and hands each
/// finished unit (and a cancelled batch's leftovers) to whoever installed it.
///
/// **It ANNOUNCES rather than drops**, and the spec records why: dropping is
/// geometry — where a pile comes to rest — and geometry is the host's
/// dimension, not the component's. [itemsSpilled] is the wire; `PropWorkstation`
/// connects it to `WorldDropHelper`. Nothing here imports a world.
///
/// Every number it reads lives on the data soul ([PropWorkstationData], rule 8).
/// The component owns the SEQUENCE and nothing else: which order consume,
/// allocate, tick, spill and clear happen in, and which signal each step
/// fires. The arithmetic is `ProductionRules`; the affordability is
/// `CraftingRules`; the list of what may be made is the data's.
///
/// PORT DELTAS, each a system that is not here yet and is left OUT rather than
/// stubbed: the XP grant on each unit (`TierSystem`, FP7); the four player
/// toasts (`Events.notification_for_player`, FP5.1's queue — the strings land
/// with the surface that shows them); `_producer`, who is credited when a
/// guest queued the batch, and `adopt_replicated_production` (both the
/// network layer); and `refresh_process_gate`, which exists there to stop
/// idle stations dispatching `_process` — here [update] is the fixed step's
/// fan-out over one list, and an idle station's early return IS the gate.
final class WorkstationComponent extends IComponent {
  /// A batch began: the recipe and how many units were ordered.
  final productionStarted = EventSignal<(ItemCraftableData recipe, int quantity)>();

  /// The bench advanced: which unit is on it (from one), how many the batch
  /// has, and how far along this unit is. Fires every tick while producing.
  final productionProgress =
      EventSignal<(int currentItem, int totalItems, double itemProgress)>();

  /// One unit finished and was spilled: the recipe, and how many are left.
  final itemProduced = EventSignal<(ItemCraftableData recipe, int remaining)>();

  /// The last unit finished; the station is idle again.
  final productionCompleted = EventSignal0();

  /// A batch was stopped and what it still held was spilled back.
  final productionCancelled = EventSignal<List<AllocatedMaterial>>();

  /// Something this station wants put into the world beside it — a finished
  /// unit, or a cancelled batch's leftovers. The host answers with a pickup.
  final itemsSpilled = EventSignal<(ItemData item, int amount)>();

  /// Typed view over the soul. Asserted at attach, not on every read: a
  /// station whose data is not workstation data was assembled by the wrong
  /// factory, and that is a wiring bug (rule 5), not a state.
  PropWorkstationData get workstationData => data as PropWorkstationData;

  @override
  void onAttach() {
    assert(
      data is PropWorkstationData,
      '[WorkstationComponent] requires PropWorkstationData, got '
      '${data.runtimeType}',
    );
  }

  bool get isProducing => workstationData.isProducing;
  ItemCraftableData? get currentRecipe => workstationData.currentRecipe;
  int get remainingQuantity => workstationData.remainingQuantity;
  double get currentProgress => workstationData.currentProgress;

  /// The recipes this station offers — the data's list, through one door.
  List<ItemCraftableData> availableRecipes() => workstationData.validRecipes();

  /// Takes [quantity] batches of [recipe] out of [payer] and starts making
  /// them. Returns whether it started.
  ///
  /// The two `false` answers are REFUSALS a caller reads (rule 20), not
  /// invalid states, and the spec says why for each. A recipe this station
  /// does not make is reachable from outside — a surface can be handed any
  /// recipe, and on the wire a guest can name one — so an assert here would
  /// let one bad request stop the host. And not affording a batch is the most
  /// ordinary answer this method gives: the surface asks first and says
  /// `notification.not_enough_materials`; the station asks again because its
  /// count is the one that counts.
  ///
  /// A running batch is CANCELLED first — its leftovers spilled, never eaten —
  /// so a second order on a busy station costs the player nothing they
  /// already paid.
  bool startProduction(
    ItemCraftableData recipe,
    int quantity,
    InventoryComponent payer,
  ) {
    assert(quantity > 0, '[WorkstationComponent] a batch of $quantity');
    final ws = workstationData;
    if (!ws.canUseRecipe(recipe)) return false;
    if (ws.isProducing) cancelProduction();
    if (!CraftingRules.canCraft(
      recipe.ingredients,
      payer.countOf,
      quantity: quantity,
    )) {
      return false;
    }
    _consumeMaterials(recipe, quantity, payer);
    ws.storeMaterials(recipe, quantity);
    productionStarted.emit((recipe, quantity));
    return true;
  }

  /// Stops the running batch and spills what it still held. Idle is a
  /// legitimate state for this to be asked in — a dying station calls it
  /// whether or not it was working — so there is nothing to refuse.
  void cancelProduction() {
    final ws = workstationData;
    if (!ws.isProducing) return;
    final refund = ws.allocatedMaterials;
    for (final line in refund) {
      if (line.amount > 0) {
        itemsSpilled.emit((_itemOf(line.itemId), line.amount));
      }
    }
    ws.clearProduction();
    productionCancelled.emit(refund);
  }

  @override
  void update(double dt) {
    final ws = workstationData;
    // Idle is the common case and a legitimate one: this early return is
    // the whole of the spec's process gate.
    final recipe = ws.currentRecipe;
    if (recipe == null) return;

    ws.advanceProgress(
      ProductionRules.progressIncrement(dt, ws.effectiveTime(recipe)),
    );
    productionProgress.emit((
      ProductionRules.currentItemNumber(
        ws.initialQuantity,
        ws.remainingQuantity,
      ),
      ws.initialQuantity,
      ws.currentProgress,
    ));
    if (ProductionRules.isItemComplete(ws.currentProgress)) {
      _completeSingleItem(recipe);
    }
  }

  void _completeSingleItem(ItemCraftableData recipe) {
    final ws = workstationData;
    itemsSpilled.emit((recipe, recipe.craftAmount));
    ws.completeUnit();
    itemProduced.emit((recipe, ws.remainingQuantity));
    if (ProductionRules.isBatchComplete(ws.remainingQuantity)) {
      ws.clearProduction();
      productionCompleted.emit();
    }
  }

  /// Takes every line of [recipe], [quantity] times, out of [payer].
  ///
  /// [startProduction] asked `canCraft` a moment ago against the same counts,
  /// so a `removeItem` that answers false here is not a poor player — it is a
  /// container that changed between the question and the answer, which on one
  /// machine is a bug. Asserted, as the spec does.
  void _consumeMaterials(
    ItemCraftableData recipe,
    int quantity,
    InventoryComponent payer,
  ) {
    for (final line in recipe.ingredients) {
      final total = line.amount * quantity;
      final removed = payer.removeItem(_itemOf(line.itemId), total);
      assert(
        removed,
        '[WorkstationComponent] could not take $total× ${line.itemId} that '
        'canCraft said were there',
      );
    }
  }

  ItemData _itemOf(String id) => locator<ItemRegistry>().getItem(id);
}
