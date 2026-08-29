import 'package:dawnforge/src/core/base/world_objects/helpers/actor_occupancy_helper.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// Why a blueprint may not be built somewhere — [allowed] when it may.
///
/// The spec's refusal vocabulary, and its header records what it cost to get:
/// every gate used to answer a bare `false`, so a torch refused under the
/// player read as the occupancy rule while the tier gate was the one talking,
/// and finding out which took a throwaway probe. A verdict names its gate now.
///
/// [allowed] is a member rather than a null so a verdict is always a value and
/// a `switch` over it is exhaustive — the spec spells the same idea as an
/// empty `StringName`. Nothing turns these into sentences yet; the player-facing
/// `notification.placement.<reason>` mapping arrives with FP5.1's notification
/// queue, and until then the reason is what the tests read and what the ghost
/// preview colours by.
enum PlacementRefusal {
  /// No gate refused — build it.
  allowed,

  /// Somebody is standing on the ground this would take, and the thing being
  /// placed is not allowed to share a tile with them.
  actorInTheWay,

  /// Another prop already holds one of the tiles.
  tileOccupied,

  /// There is no ground under some tile of the footprint, or the ground there
  /// refuses props — water and cliff say so themselves.
  needsGround,

  /// The tile is beyond what exists. For a PROP that reads as
  /// [needsGround] — there is nothing under it — but a ground blueprint is
  /// asking to become the tile, and "there is no tile" is a different answer
  /// from "the tile refuses you".
  outsideWorld,

  /// The tile already holds real ground, and one ground does not go on top of
  /// another. See [WorldPlacementHelper.placeGroundRefusal] for why this is
  /// currently every such tile.
  cannotStack,
}

/// Placing world objects from a blueprint — the port of
/// `world_placement_helper.gd`.
///
/// It answers ONE question per verb, for both callers that must never disagree:
/// the hand about to spend the item, and the ghost preview drawn under the
/// cursor before it does. A preview that paints green where the placement is
/// refused is the bug this single owner exists to make impossible.
///
/// **The occupancy gate is FIRST and that is the port.** The spec puts it above
/// every early-return so no prop type can route around it, and its comment
/// names the regression that taught it: the rule used to be a comparison
/// further down that only ran for colliding props and only tested the anchor
/// tile against one actor's origin cell — which is how a staircase could be
/// built under the player's own feet.
///
/// PORT DELTAS — every one a gate whose SUBJECT is unported, left out rather
/// than stubbed (rule 5: an unreachable branch is a lie about what the game
/// does):
///   - `REASON_NO_DATA`, which is the spec's `if not data` null guard. Dart's
///     type system makes it unstateable, so it is not a gate that was dropped
///     — it is a gate the language answers;
///   - the world-region check (`WorldResolver.get_world_bounds_around`): this
///     world has no edge, and the streamed window's own edge is what
///     [PlacementRefusal.needsGround] already answers;
///   - the island tier match and the island lock (FP7's tier field, and there
///     are no islands);
///   - the cave shaft's own refusal, the rock-body and solid-rock gates, and
///     the mountain-face pair — all of them layers, slabs and elevation
///     stacking, which is FP7 with ground destruction;
///   - the crop's tilled-soil requirement (FP4.4's `TillableComponent`), which
///     is the one gate that will land INSIDE this order rather than beside it;
///   - `REASON_OUT_OF_RANGE`, which the spec emits from the hand rather than
///     from here. It joins the vocabulary with its emitter (slice 5), measured
///     by `WorldObjectPermissionHelper.isWithinRange` so building and swinging
///     reach exactly as far as each other.
abstract final class WorldPlacementHelper {
  /// Whether a prop blueprint may land at [anchor] — the boolean wrapper every
  /// caller that owes the player no explanation reads.
  static bool canPlaceProp(PropData data, GridPos anchor) =>
      placePropRefusal(data, anchor) == PlacementRefusal.allowed;

  /// Why a prop blueprint may not land at [anchor] — [PlacementRefusal.allowed]
  /// when it may.
  ///
  /// [anchor] is the TOP-LEFT tile of the footprint, the same corner
  /// `GridManager.occupyPropTiles` claims from and `ActorOccupancyHelper`
  /// measures from. A caller holding the tile under the cursor converts it
  /// first — a prop is drawn standing on its BOTTOM row, so the cursor's tile
  /// is the bottom one and the anchor is `(x, y - (height - 1))`.
  static PlacementRefusal placePropRefusal(PropData data, GridPos anchor) {
    // 1. NOBODY IS BUILT ON TOP OF. First, over the WHOLE footprint, and
    // through the object's own `allowsActorOverlap` — the permission
    // `ActorOccupancyHelper` owns for every path on both sides. Ahead of
    // everything below so no blueprint can reach a later gate and return
    // before this one is asked.
    if (ActorOccupancyHelper.isPlacementBlocked(data, anchor)) {
      return PlacementRefusal.actorInTheWay;
    }

    final grid = locator<GridManager>();

    // 2. THE TILES ARE FREE OF PROPS. Actors are skipped here on purpose:
    // that half was answered at 1, against each body's RECT, which is the
    // question — and the occupancy map holds one entry per prop tile and
    // nothing about anybody's permission.
    if (!grid.isPropSpaceAvailable(
      anchor,
      width: data.gridWidth,
      height: data.gridHeight,
    )) {
      return PlacementRefusal.tileOccupied;
    }

    // 3. THERE IS GROUND UNDER ALL OF IT, AND THAT GROUND TAKES PROPS.
    if (!grid.canPlacePropAt(
      anchor,
      width: data.gridWidth,
      height: data.gridHeight,
    )) {
      return PlacementRefusal.needsGround;
    }

    return PlacementRefusal.allowed;
  }

  /// Whether a ground blueprint may become the tile at [tile].
  static bool canPlaceGround(GroundBuildableData data, GridPos tile) =>
      placeGroundRefusal(data, tile) == PlacementRefusal.allowed;

  /// Why a ground blueprint may not become the tile at [tile] —
  /// [PlacementRefusal.allowed] when it may.
  ///
  /// Ground is one tile in this port (every `ground_*` document authors
  /// `grid_size: [1, 1]`), so there is no footprint to walk — the loop the
  /// prop half needs has nothing to iterate here.
  ///
  /// The reachable verb is REPLACEMENT AT THE SAME LEVEL: a bridge over water,
  /// a floor over a cliff. The spec's other verb — stacking one more level of
  /// elevation onto a tile that already has ground — is FP7, and it takes
  /// four gates with it (`_covers_solid_rock`, the max height, the elevation
  /// border, and the whole `_slab_margin_refusal`). So a tile already holding
  /// real ground is refused outright rather than partly: the spec's own first
  /// stacking gate is `allows_resource_spawning`, which the bridge authors
  /// false and would be refused by anyway, and porting only that one would
  /// leave a branch that answers yes to terrain and then has nowhere to go.
  static PlacementRefusal placeGroundRefusal(
    GroundBuildableData data,
    GridPos tile,
  ) {
    // 1. NOBODY IS BUILT ON TOP OF — before every early-return below, which
    // is the spec's emphasis and matters more here than on the prop path. The
    // branches below RETURN ALLOWED, so an occupancy rule placed after them is
    // an occupancy rule that never runs on the one verb that reaches them.
    //
    // Terrain authors `allowsActorOverlap: false` and a bridge authors true,
    // and that is the whole difference: a bridge is a thing you walk onto, so
    // it may appear under the foot already overhanging the water; solid
    // terrain appearing there would be the actor sealed into what it becomes.
    if (ActorOccupancyHelper.isPlacementBlocked(data, tile)) {
      return PlacementRefusal.actorInTheWay;
    }

    final ground = locator<GridManager>().getGroundDataAt(tile);

    // 2. THE VOID. In the spec an unregistered tile is a HOLE inside the
    // world — ground somebody dug out — and filling it is what a blueprint is
    // for. Here nothing digs yet (FP7) and the generator gives every tile in
    // the streamed window a ground, so the only unregistered tile is one
    // beyond the window: not a hole, the edge. That edge is what stands in for
    // the spec's `WorldResolver` world bounds, which this world does not have.
    if (ground == null) return PlacementRefusal.outsideWorld;

    // 3. WATER AND CLIFF — the same-level replacement, and the reachable half
    // of this verb. `GroundEmptyData` is exactly the pair the spec asks for by
    // name (`is_water_at` or `is_cliff_at`): one type test instead of two
    // questions, because here the two are one class and the class is what the
    // generator writes.
    if (ground is GroundEmptyData) return PlacementRefusal.allowed;

    // 4. REAL GROUND. See the doc above: stacking is FP7.
    return PlacementRefusal.cannotStack;
  }

  /// Makes [data] the ground at [tile]. Asks nothing — the caller has already
  /// been told yes by [canPlaceGround], and asking twice is how the answer the
  /// player was shown and the answer the world acted on come apart.
  ///
  /// PORT DELTA, and it is the shape of the whole terrain layer: the spec
  /// creates a `GroundBuildable` NODE and adds it to the ground layer, because
  /// only a node-backed tile survives an unload and reaches its SaveManager.
  /// Terrain is nodeless here (FP3.4) — the tile IS its entry in the registry,
  /// and everything that reads ground (the bake, body blocking, walkability)
  /// reads that entry. A node would be an object nothing looks at. The
  /// node-backed tile arrives with the save that needs it (FP6).
  ///
  /// Which means the honest consequence, stated rather than hidden: a bridge
  /// laid down and then walked away from is gone when its chunk recycles, and
  /// the water comes back. That is the same bargain a harvested prop already
  /// makes, and the same commit closes both — FP6.
  static void placeGround(GroundBuildableData data, GridPos tile) {
    final grid = locator<GridManager>();
    assert(
      canPlaceGround(data, tile),
      '[WorldPlacementHelper] placeGround at $tile was refused '
      '(${placeGroundRefusal(data, tile)}) — the gate is asked BEFORE the '
      'placement, never inside it',
    );
    // The registry entry is replaced, not mutated: nodeless tiles hold the
    // SHARED authored resource (`GridManager`'s own contract), so writing
    // through one would rewrite that ground everywhere it is used.
    grid
      ..unregisterGroundData(tile)
      ..registerGroundData(tile, data);
    locator<Events>().groundTileChanged.emit(tile);
  }
}
