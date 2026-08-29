import 'package:dawnforge/src/core/base/world_objects/helpers/actor_occupancy_helper.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
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
}
