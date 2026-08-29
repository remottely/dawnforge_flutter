import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/registries/item_registry.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// What this actor is holding — the port of `held_item_component.gd`'s first
/// concern, and only that one.
///
/// The spec's component is 955 lines because it answers four questions at
/// once: what is in the hand, how the hand MOVES (tweens, motion steps, impact
/// delay), what an action COSTS (energy, mana, combo points), and which
/// `ItemHand` subclass does the deed. This is the first — every path that
/// later asks "what tool is this actor swinging" (`WorldObjectToolHelper`,
/// then `WorldObjectPermissionHelper`) reads it here and nowhere else. The
/// other three arrive with the damage verb and the item-hand hierarchy.
///
/// **The hand is derived, never stored.** The selection already lives in the
/// data soul (`InventoryData.selectedSlot`, rule 8) and the slot already
/// stores an item id, so a copy of "what is held" kept here would be the same
/// state written twice, free to drift. [currentItem] resolves on every read;
/// the only thing this component remembers is what it last ANNOUNCED, which
/// is the memory a change signal cannot do without.
final class HeldItemComponent extends IComponent {
  HeldItemComponent(this._inventory);

  /// The bag the hand draws from. Constructor DI in dependency order, the same
  /// way `MovementComponent` takes its `DirectionComponent` (Godot repo §4.6).
  final InventoryComponent _inventory;

  /// The spec's `held_item_changed`. Carries null for an empty hand — an
  /// actor holding nothing is a real answer, not a missing one.
  ///
  /// Fires only when the hand ACTUALLY changed. The spec calls that its
  /// "redundancy check" and its `IActor.set_held_item` announces only when the
  /// component reports true: a hand that did not change is not a held-item
  /// change, and every listener downstream pays for the ones that lie.
  final currentItemChanged = EventSignal<ItemData?>();

  /// The id last handed to [currentItemChanged], so a re-selection onto the
  /// same item is silent. Never serialized — a legitimate component-local
  /// under rule 8, and the only field here.
  String? _announcedItemId;

  void Function()? _unsubscribeSelection;

  /// The item in hand, or null when the hand is empty. Resolved through the
  /// registry (rule 2): the slot stores an id, so the hand and the bag can
  /// never disagree about what an id means.
  ItemData? get currentItem => _itemOf(_heldId());

  /// The held id, or null for an empty hand — [_resolveItemId]'s empty string
  /// read as the answer it is, once, so nothing downstream compares against
  /// `''` again.
  String? _heldId() {
    final id = _resolveItemId();
    return id.isEmpty ? null : id;
  }

  ItemData? _itemOf(String? id) =>
      id == null ? null : locator<ItemRegistry>().getItem(id);

  IActorData get _actorData {
    final soul = data;
    assert(
      soul is IActorData,
      '[HeldItemComponent] host ${soul.id} is not an actor — only actors have '
      'hands',
    );
    return soul as IActorData;
  }

  @override
  void onAttach() {
    // ONE subscription, because `selectionChanged` already carries both halves
    // of the news (0.24.0): the selection MOVED, and the selected slot's
    // CONTENTS changed under it. To a hand they are the same event — what this
    // actor is holding is now something else — and this is that signal's first
    // consumer.
    _unsubscribeSelection =
        _inventory.selectionChanged.connect((_) => _announceIfChanged());
    // Seeded, not announced: the component is being assembled by the factory,
    // so nobody is listening yet and there is no previous hand to have left.
    _announcedItemId = _heldId();
  }

  @override
  void onDetach() {
    _unsubscribeSelection?.call();
    _unsubscribeSelection = null;
  }

  void _announceIfChanged() {
    final next = _heldId();
    if (next == _announcedItemId) return;
    _announcedItemId = next;
    currentItemChanged.emit(_itemOf(next));
  }

  /// The spec's `set_held_item` resolution order, collapsed into the question
  /// it was always answering: which id is in this hand right now.
  ///
  ///   1. **The selected slot**, when this actor carries a bag and that slot
  ///      holds something. This is the hotbar becoming the hand. It reads the
  ///      same way for an NPC that carries a bag and no hotbar — its selection
  ///      never moves off slot zero — until `ActorHumanoid`'s "pick the best
  ///      tool I own" arrives with the AI that needs it.
  ///   2. **The authored hand** — `IActorData.held_item_id`. A boar's tusks
  ///      (`t1_item_tool_melee_boar`) are authored this way, and a creature
  ///      with no bag has no other source.
  ///   3. **Bare hands**, for a player whose selected slot is empty. An empty
  ///      slot is NOT an empty hand for a person: the spec puts
  ///      `t{tier}_item_tool_melee_hand` there, which is the `INNATE` tool that
  ///      lets you pull a bush up with nothing equipped. Drop this branch and
  ///      the damage verb inherits a player who cannot touch the world until
  ///      they craft something to touch it with.
  ///
  /// Empty string is the fourth answer and a legitimate one: both forest
  /// guardians author `held_item_id: ""` and carry no bag, so they hold
  /// nothing.
  String _resolveItemId() {
    if (_inventory.maxSlots > 0) {
      final selected = _inventory.selectedStack;
      if (!selected.isEmpty) return selected.itemId;
    }

    final soul = _actorData;
    if (soul.heldItemId.isNotEmpty) return soul.heldItemId;

    // PORT DELTA: the spec asks `TierSystem.get_player_tier_of(actor)` — a
    // PROGRESSION tier the player earns. Nothing progresses yet (the tier
    // field is FP7), so the id is built from the tier this actor was authored
    // with, which is the same number for a t1 player and the one place FP7
    // has to change to make bare hands grow with their owner.
    if (soul.groups.contains(GameConstants.playerGroup)) {
      return GameConstants.innateHandItemId(soul.tier);
    }

    return '';
  }
}
