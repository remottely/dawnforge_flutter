import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/components/i_interactable/interactable_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/workstation_component.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_workstation_data.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/drop/world_drop_helper.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';

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
/// signals when it learns to).
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
  /// Since 0.75.0 its signal has a listener, which is what FP4.5(e) said it
  /// was waiting for: a reach is announced on the bus and the shell answers by
  /// putting the bench on screen.
  late final InteractableComponent interactable;

  @override
  void setupComponents() {
    super.setupComponents();
    workstation = addComponent(WorkstationComponent());
    workstation.itemsSpilled.connect(_onItemsSpilled);
    interactable = addComponent(InteractableComponent())
      ..interacted.connect(_onInteracted);
  }

  /// Says on the bus that this station was reached for, and by whom.
  ///
  /// It announces and does not open, for the reason the spill above announces
  /// and does not drop: a widget is the shell's dimension, not a prop's, and
  /// a `Prop` that imported a screen would be a simulation that cannot run
  /// without one.
  void _onInteracted(IActor interactor) =>
      locator<Events>().workstationInteracted.emit((this, interactor));

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
