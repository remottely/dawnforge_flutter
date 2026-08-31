import 'package:dawnforge/src/core/components/i_interactable/inventory_component.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// A physical pickup lying in the world — port of `item_world.gd` (logic
/// slice: magnet flight and collection; ground-lifetime expiry, stack
/// merging, tick culling and the remote-follow tail arrive with their
/// systems).
///
/// NOT a `WorldObject`: an item is not a placeable — `ItemData` sits outside
/// the `IWorldObjectData` hierarchy on purpose, so this host carries its own
/// small contract instead of a component container. Rules 1 and 3 still
/// hold: only `ItemFactory` constructs one, `initialize` receives a CLONE
/// (the Godot `clone_for_instance()` — collection isolation), and the host
/// is unusable before it.
///
/// The collection handshake mirrors the spec: RESERVE inventory space when
/// an eligible collector is near (a full bag refuses, and the pickup stays
/// put — retried while the collector remains near), fly at the item's
/// authored magnet speed, and COLLECT inside half a tile — the add consumes
/// the reservation. The Godot `wants_pickup` gate (a player must hold
/// interact) arrives with `ActorPlayer`; until then every collector is on
/// the auto-collect branch, as non-player collectors are in the spec.
final class ItemWorld {
  ItemData? _data;

  ItemData get itemData {
    final soul = _data;
    assert(soul != null, '[ItemWorld] read data before initialize()');
    return soul!;
  }

  bool get isInitialized => _data != null;

  int _amount = 0;
  int get amount => _amount;

  WorldPos position = WorldPos.zero;

  bool _beingCollected = false;
  late InventoryComponent _reservationHolder;

  /// Seconds this pickup has spent on the ground. A per-frame transient of the
  /// host's own life, never serialized — a legitimate local under rule 8.
  double _groundedFor = 0;

  /// True once the collector took the contents — the world side removes the
  /// host and its renderer on the next sweep.
  bool collected = false;

  /// Called by `ItemFactory.createPickup`, exactly once, with an instance
  /// the factory already cloned (rule 3).
  void initialize(ItemData initialData, int initialAmount) {
    assert(_data == null, '[ItemWorld] already initialized');
    assert(initialAmount > 0, '[ItemWorld] amount $initialAmount must be > 0');
    _data = initialData;
    _amount = initialAmount;
  }

  double get _magnetSpeedPx =>
      itemData.magnetSpeed * GameConstants.tileDimension;

  /// One fixed step of pickup life against the (single) collector the sim
  /// offers: start collection when near and the bag can promise the space,
  /// fly while collecting, collect inside the threshold. A refused
  /// reservation leaves the pickup grounded and is retried while the
  /// collector stays near — a full bag is an answer, not an error.
  void tick(
    double dt, {
    required WorldPos collectorPosition,
    required InventoryComponent collectorInventory,
  }) {
    assert(isInitialized, '[ItemWorld] tick before initialize()');
    if (collected) return;

    // The authored `pickup_delay` has to run down before anyone may reserve
    // this. It is what makes putting something DOWN possible at all: a drop
    // lands at the dropper's own feet, well inside the magnet radius, so
    // without the wait it is reserved on the very next step and flies
    // straight back. Counted here rather than in the drop path because the
    // item authors it — a heavy thing may take longer to settle than a light
    // one, and neither the dropper nor the loot table gets to decide.
    if (_groundedFor < itemData.pickupDelay) {
      _groundedFor += dt;
      return;
    }

    if (_beingCollected) {
      position = _moveToward(position, collectorPosition, _magnetSpeedPx * dt);
      const threshold = EngineConstants.pickupCollectThresholdTiles *
          GameConstants.tileDimension;
      if ((collectorPosition - position).length < threshold) {
        final remaining = _reservationHolder.addItem(itemData, _amount);
        assert(
          remaining == 0,
          '[ItemWorld] the reservation promised space for $_amount '
          '${itemData.id} but $remaining did not fit',
        );
        collected = true;
      }
      return;
    }

    final near = (collectorPosition - position).length <=
        EngineConstants.playerPickupRadius;
    if (near && collectorInventory.reserveSpace(itemData, _amount)) {
      _reservationHolder = collectorInventory;
      _beingCollected = true;
    }
  }

  static WorldPos _moveToward(WorldPos from, WorldPos to, double maxStep) {
    final delta = to - from;
    final distance = delta.length;
    if (distance <= maxStep || distance == 0) return to;
    return from + delta * (maxStep / distance);
  }
}
