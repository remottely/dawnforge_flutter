import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';

/// What a press BECAME — the port making explicit a rule FP4.3a wrote as prose.
///
/// A bool cannot carry it, because "did the blow land" and "did the press cost
/// the actor its cadence" are different questions with different answers: a
/// swing at armour it cannot dent lands nothing and still takes the cooldown,
/// while a click on bare ground takes neither. With the deed moved into the
/// hand, only the hand knows which of the two happened, so it has to say.
///
/// PORT DELTA: the spec has no such type — `use_held_item_primary_action`
/// resets the cooldown unconditionally, so a misclick on empty ground costs a
/// full swing there. That is a harsher rule than it sounds at this project's
/// authored pace (`base_action_speed: 0.5` is TWO SECONDS a swing), and
/// FP4.3a already chose against it. This makes the choice enforceable instead
/// of commented.
enum ActionOutcome {
  /// The press found nothing to act on. It costs the actor nothing.
  none,

  /// The hand acted and the act had no effect. It costs the cadence anyway.
  spent,

  /// The hand acted and it landed.
  landed,
}

/// What an item DOES when you press with it in hand — the port of
/// `item_hand.gd`.
///
/// One class per kind of deed, chosen by the item (see
/// `HeldItemComponent.hand`), because a swing and a build are not two settings
/// of one function: they resolve different targets, ask different gates, and
/// spend different things. The spec makes the same split and for the same
/// reason; what it adds on top — and this port does not have — is the visual
/// half.
///
/// This base is not an abstract seam waiting for its first user. It is the
/// hand of an item that DOES nothing when pressed, which is most of the game's
/// items: a log, an ore, a bundle of fibre. The spec answers those with this
/// same base class.
///
/// PORT DELTAS:
///   - the spec's `ItemHand` is a `Node2D` carrying the item's sprite and its
///     `AnimationPlayer`, and `primary_action` plays a swing before it
///     resolves anything. Nothing here has motion on screen (FP4.3a left that
///     out by name), so this is a plain object and the node arrives with the
///     animation that needs one;
///   - the spec CLONES the item data per hand (`clone_for_instance`), because
///     durability is per-instance state. Nothing mutates a hand's data yet, so
///     this holds the registry entry and the clone arrives with the state that
///     makes two copies mean something;
///   - `secondary_action`, `action_completed`/`target_hit` and the action
///     costs (energy, mana, combo points) wait with the rest of
///     `HeldItemComponent`'s unported half.
class ItemHand {
  ItemHand(this.data, this.user);

  /// The authored item this hand IS. The shared registry entry — see the
  /// clone delta above.
  final ItemData data;

  /// Whose hand this is. The spec's `current_user`, injected the same way and
  /// for the same reason: every gate downstream asks about the SOURCE, and an
  /// item that had to be told who is swinging it at each call would be one
  /// more place for the answer to be wrong.
  final IActor user;

  /// How far this hand reaches, in PIXELS, from the authored `action_range`.
  double get reachPixels => data.actionRange * GameConstants.tileDimension;

  /// The press. [aim] was measured at the instant the button went down and
  /// carries three readings of it (see [AimSnapshot]): `direction` for
  /// anything that travels, `point` for anything that names a tile, `origin`
  /// for anything that measures reach. An override reads the one it means and
  /// never re-derives another from the actor's position, which by the time
  /// this runs has moved on.
  ///
  /// The base answers [ActionOutcome.none]: pressing with a log in hand is not
  /// a failed action, it is no action, and it costs nothing.
  ActionOutcome primaryAction(AimSnapshot aim) => ActionOutcome.none;
}
