import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/components/i_interactable/interactable_component.dart';
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
/// PORT DELTAS: `WorkstationEffectsComponent` and the
/// `working`/`idle` animation are render-side (`WorldObjectRenderer` reads the
/// signals when it learns to); `Events.workstation_interaction` lands with
/// the surface that answers it.
final class PropWorkstation extends Prop {
  PropWorkstation(super.random);

  /// Typed view over the injected soul.
  PropWorkstationData get workstationData => data as PropWorkstationData;

  late final WorkstationComponent workstation;

  /// The half of the interact verb this object owns: it answers a reach.
  /// Mounted HERE and not on `Prop`, because a rock answers no reach and a
  /// component on every prop is a component whose data does not exist
  /// (`L-005`).
  ///
  /// Nothing is connected to its signal YET, and that is the honest shape of
  /// this slice: the bench SURFACE is FP4.5(f), and it is the listener. A
  /// handler written here now would be an empty method dressed as a feature
  /// (rule 5), and the wire it stands in for is one line in the commit that
  /// has something to open.
  late final InteractableComponent interactable;

  @override
  void setupComponents() {
    super.setupComponents();
    workstation = addComponent(WorkstationComponent());
    workstation.itemsSpilled.connect(_onItemsSpilled);
    interactable = addComponent(InteractableComponent());
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
