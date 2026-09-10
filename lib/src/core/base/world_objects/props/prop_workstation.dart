import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/components/i_interactable/workstation_component.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';

/// A prop you make things at — the host half of `prop_workstation.gd`.
/// Created only by `PropFactory.create()` (rule 1), which routes here when
/// the registry hands it [PropWorkstationData].
///
/// What the host adds over a plain [Prop] is exactly the spec's list: the
/// production component, the wire from "the station spilled something" to
/// "a pickup lands in front of it", and a death that gives the half-made
/// batch back before the corpse drops its own loot.
///
/// PORT DELTAS: `InteractableComponent` and `_on_interacted` are the interact
/// verb, FP4.5's next slice; `WorkstationEffectsComponent` and the
/// `working`/`idle` animation are render-side (`WorldObjectRenderer` reads the
/// signals when it learns to); `Events.workstation_interaction` lands with
/// the surface that answers it.
final class PropWorkstation extends Prop {
  PropWorkstation(super.random);

  /// Typed view over the injected soul.
  PropWorkstationData get workstationData => data as PropWorkstationData;

  late final WorkstationComponent workstation;

  @override
  void setupComponents() {
    super.setupComponents();
    workstation = addComponent(WorkstationComponent());
    workstation.itemsSpilled.connect(_onItemsSpilled);
  }

  /// Puts a spilled item into the world at this station's face — the one
  /// part of a drop the component cannot answer, because it is geometry.
  void _onItemsSpilled((ItemData item, int amount) spill) {
    final (item, amount) = spill;
    WorldDropHelper.spawnPickup(
      item,
      amount,
      WorldDropHelper.calculateDropPosition(this, random),
      position,
    );
  }

  /// Cancels the batch FIRST, so its leftovers spill while the station is
  /// still standing on its tiles, then dies as any prop does. The spec's
  /// `_on_died` has the same order.
  @override
  void onDied(Object? source) {
    workstation.cancelProduction();
    super.onDied(source);
  }
}
