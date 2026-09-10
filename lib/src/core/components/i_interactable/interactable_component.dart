import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_interactable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// "Somebody reached for this" — the port of `interactable_component.gd`.
///
/// The component owns exactly one thing: the fact that an interaction
/// HAPPENED, and to whom it happened. What an interaction MEANS is the host's
/// (a station opens a bench, a crop is picked), which is why this class knows
/// no host type and fires a signal instead of calling one.
///
/// It is mounted by the hosts whose data says they are interactable, never by
/// every prop — the `L-005` lesson, and the reason [PropInteractableData]
/// exists as a type rather than as two more fields nobody reads.
///
/// PORT DELTAS: `can_interact` and `display_indicator` (the data class records
/// why the first is out; the second belongs to the hover indicator, FP5.1e,
/// together with the `notification.get_closer` toast a refused reach shows);
/// `_on_interact`, the spec's virtual twin of its own signal — one wire per
/// fact (rule 25's spirit), and the hosts here connect to [interacted].
final class InteractableComponent extends IComponent {
  /// Someone interacted with this object, and here is who.
  final interacted = EventSignal<IActor>();

  /// Typed view over the soul. Asserted at attach, never on every read — a
  /// component on a prop that authors no interaction was mounted by the wrong
  /// host, and that is a wiring bug (rule 5), not a state.
  PropInteractableData get interactableData => data as PropInteractableData;

  @override
  void onAttach() {
    assert(
      data is PropInteractableData,
      '[InteractableComponent] requires PropInteractableData, got '
      '${data.runtimeType}',
    );
  }

  /// The authored reach, in PIXELS. The pack writes tiles; the conversion
  /// happens HERE and only here, which is the mistake the spec's own comment
  /// documents: a tile count sitting in a pixel field silently shortened
  /// every reach nobody had written to.
  double get rangePixels =>
      interactableData.interactionRange * GameConstants.tileDimension;

  /// What the indicator will say. Read by nothing yet (FP5.1e).
  String get prompt => interactableData.interactionPrompt;

  /// [interactor] reached this object. The REACH IS NOT ASKED HERE: the actor
  /// asks it, because the actor is the one who knows where it is standing and
  /// the same gate has to answer the swing, the build and the tap
  /// (`IActor.tryInteract`). A component that re-measured would be a second
  /// geometry waiting to disagree with the first.
  void interact(IActor interactor) => interacted.emit(interactor);
}
