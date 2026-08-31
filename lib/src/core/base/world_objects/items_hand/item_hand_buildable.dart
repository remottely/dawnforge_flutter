import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_placement_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// The hand that BUILDS — the port of `item_hand_buildable.gd`'s building half.
///
/// The deed is four steps and the order of them is the point: work out which
/// tiles the blueprint would take, ask the gate, spend the item, put it there.
/// Spending BEFORE the gate answers is how a player loses a smelter to a tile
/// they were never allowed to build on; putting it there before spending is how
/// they get two.
///
/// PORT DELTAS:
///   - the GHOST PREVIEW, which is the other half of this class in the spec and
///     most of its lines. It is the same question this asks, asked every frame
///     for the tile under the cursor and answered in colour instead of in a
///     refusal — it lands next, and it is why the hand is an object with a life
///     rather than a function (`HeldItemComponent.hand` says so);
///   - the player-facing SENTENCE for a refusal (`_notify_refusal`, and rule
///     33's "a tool that refuses says so"). The reason is named and returned;
///     turning it into `notification.placement.<reason>` needs FP5.1's
///     notification queue, and the ghost's red is the feedback until then;
///   - the two priorities of the spec's range gate. It asks the hovered object
///     first and falls back to rect math; there is no hover component here, and
///     the rect math IS the measurement — [WorldObjectPermissionHelper.isAreaWithinRange],
///     which is the same geometry the swing reaches by;
///   - the staircase's built FACE and the cave shaft's twin, both of which the
///     spec assigns right after placing. Neither prop is ported (FP7).
final class ItemHandBuildable extends ItemHand {
  ItemHandBuildable(ItemBuildableData super.data, super.user);

  /// The typed view over what this hand holds. The constructor takes the
  /// subtype, so this cast cannot fail (rule 18: cast to the declared type).
  ItemBuildableData get buildable => data as ItemBuildableData;

  @override
  ActionOutcome primaryAction(AimSnapshot aim) {
    final cursorTile = locator<GridManager>().worldToGrid(aim.point);
    final blueprint = buildable.blueprint;

    // The two verbs differ in exactly one thing before the gate: where the
    // footprint starts. A prop stands on the bottom row of its own, so the
    // tile under the cursor is that row; a ground tile IS the tile.
    return switch (blueprint) {
      final PropData prop => _build(
          WorldPlacementHelper.anchorForCursorTile(prop, cursorTile),
          width: prop.gridWidth,
          height: prop.gridHeight,
          refusal: (anchor) => WorldPlacementHelper.placePropRefusal(prop, anchor),
          place: (anchor) => WorldPlacementHelper.placeProp(prop, anchor),
        ),
      final GroundBuildableData ground => _build(
          cursorTile,
          refusal: (tile) => WorldPlacementHelper.placeGroundRefusal(ground, tile),
          place: (tile) => WorldPlacementHelper.placeGround(ground, tile),
        ),
      // `ItemBuildableData.blueprint` answers with a prop or a ground and
      // crashes on anything else, so this arm is the type system asking for a
      // total switch rather than a state the game can be in.
      _ => throw StateError(
          '[ItemHandBuildable] ${buildable.id} builds ${blueprint.id}, which is '
          'neither a prop nor a ground',
        ),
    };
  }

  /// The four steps, shared by both verbs because only their geometry differs.
  ActionOutcome _build(
    GridPos anchor, {
    required PlacementRefusal Function(GridPos) refusal,
    required void Function(GridPos) place,
    int width = 1,
    int height = 1,
  }) {
    // 1. REACH, which is this hand's own gate and not the helper's — the spec
    // draws the line in the same place, because how far you can reach is a
    // fact about the actor and the item, while everything else is a fact about
    // the tile. Out of reach is [ActionOutcome.none]: you did not build, and
    // you were not standing close enough to have tried.
    if (!WorldObjectPermissionHelper.isAreaWithinRange(
      user,
      anchor,
      reachPixels,
      width: width,
      height: height,
    )) {
      return ActionOutcome.none;
    }

    // 2. THE GATE. Refused is [ActionOutcome.spent]: the press reached a tile
    // and was turned down there, which is the case that costs the cadence.
    if (refusal(anchor) != PlacementRefusal.allowed) return ActionOutcome.spent;

    // 3. SPEND IT. The bag is asked LAST of the things that can say no, so a
    // build refused by the world never costs an item — and `removeItem`
    // answering false is the honest end of a press by somebody who no longer
    // has what they were holding.
    if (!user.inventory.removeItem(data, 1)) return ActionOutcome.spent;

    // 4. PUT IT THERE.
    place(anchor);
    return ActionOutcome.landed;
  }
}
