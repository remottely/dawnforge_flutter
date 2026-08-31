import 'package:dawnforge/src/core/base/world_objects/helpers/world_object_permission_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/helpers/world_placement_helper.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/aim_snapshot.dart';
import 'package:dawnforge/src/core/base/world_objects/items_hand/item_hand.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/resources/items/item_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// What a build at one tile WOULD be — everything the press and the preview
/// both need, worked out once.
///
/// The two callers reaching the same answer is the whole invariant: a ghost
/// painted green where the press would be refused is the bug this type makes
/// unstateable, because the press does not compute its own verdict — it reads
/// this one.
final class BuildPreview {
  const BuildPreview({
    required this.anchor,
    required this.centre,
    required this.refusal,
  });

  /// Top-left tile of the footprint the blueprint would take.
  final GridPos anchor;

  /// Where the thing would be drawn: the centre of that footprint.
  final WorldPos centre;

  final PlacementRefusal refusal;

  bool get isAllowed => refusal == PlacementRefusal.allowed;
}

/// The hand that BUILDS — the port of `item_hand_buildable.gd`.
///
/// The deed is four steps and the order of them is the point: work out which
/// tiles the blueprint would take, ask the gate, spend the item, put it there.
/// Spending BEFORE the gate answers is how a player loses a smelter to a tile
/// they were never allowed to build on; putting it there before spending is how
/// they get two.
///
/// PORT DELTAS:
///   - the ghost is DRAWN elsewhere. In the spec this class is a `Node2D` and
///     owns its preview sprite; here the sim never draws, so it answers
///     [previewAt] and `BuildGhostRenderer` paints the answer. The cache the
///     spec keeps in this class (`_last_preview_grid_pos`) went with the
///     drawing, because what it saves is a per-FRAME cost and the frame belongs
///     to the renderer;
///   - the player-facing SENTENCE for a refusal (`_notify_refusal`, and rule
///     33's "a tool that refuses says so"). The reason is named and returned;
///     turning it into `notification.placement.<reason>` needs FP5.1's
///     notification queue, and the ghost's red is the feedback until then;
///   - the two priorities of the spec's range gate. It asks the hovered object
///     first and falls back to rect math; there is no hover component here, and
///     the rect math IS the measurement — [WorldObjectPermissionHelper.isAreaWithinRange],
///     the same geometry the swing reaches by;
///   - directional frames (a staircase choosing which mountain face it faces
///     from where inside the tile the cursor sits), the staircase's built FACE
///     and the cave shaft's twin. All of them FP7's props.
final class ItemHandBuildable extends ItemHand {
  ItemHandBuildable(ItemBuildableData super.data, super.user)
      : blueprint = data.blueprint {
    assert(
      blueprint is PropData || blueprint is GroundBuildableData,
      '[ItemHandBuildable] ${data.id} builds ${blueprint.id}, which is neither '
      'a prop nor a ground',
    );
  }

  /// What this hand builds, resolved ONCE. The item in the hand never changes
  /// — a different item is a different hand — so neither does what it builds,
  /// and the per-frame preview reads a field instead of a registry.
  final IWorldObjectData blueprint;

  /// The typed view over what this hand holds. The constructor takes the
  /// subtype, so this cast cannot fail (rule 18: cast to the declared type).
  ItemBuildableData get buildable => data as ItemBuildableData;

  /// What a build aimed at [cursorTile] would be — the ONE resolution, read by
  /// the press below and by the ghost every time the cursor changes tile.
  BuildPreview previewAt(GridPos cursorTile) {
    final grid = locator<GridManager>();
    final bp = blueprint;

    // The two verbs differ in exactly one thing: where the footprint starts. A
    // prop stands on the BOTTOM row of its own, so the tile under the cursor is
    // that row; a ground tile IS the tile.
    final anchor = bp is PropData
        ? WorldPlacementHelper.anchorForCursorTile(bp, cursorTile)
        : cursorTile;
    final centre = bp is PropData
        ? WorldPlacementHelper.propWorldPosition(bp, anchor)
        : grid.gridToWorld(anchor);

    BuildPreview verdict(PlacementRefusal refusal) =>
        BuildPreview(anchor: anchor, centre: centre, refusal: refusal);

    // 1. REACH, this hand's own gate — see the class doc. Asked first because
    // it is the only one that is about the actor rather than the tile, and
    // because a player out of reach should see the ghost go red for the reason
    // they can actually fix by walking.
    if (!WorldObjectPermissionHelper.isAreaWithinRange(
      user,
      anchor,
      reachPixels,
      width: bp.gridWidth,
      height: bp.gridHeight,
    )) {
      return verdict(PlacementRefusal.outOfRange);
    }

    // 2. THE TILE ITSELF, which is the helper's whole subject.
    return verdict(
      bp is PropData
          ? WorldPlacementHelper.placePropRefusal(bp, anchor)
          : WorldPlacementHelper.placeGroundRefusal(
              bp as GroundBuildableData,
              anchor,
            ),
    );
  }

  @override
  ActionOutcome primaryAction(AimSnapshot aim) {
    final preview =
        previewAt(locator<GridManager>().worldToGrid(aim.point));

    // Out of reach is no action: you did not build, and you were not standing
    // close enough to have tried. Every other refusal IS an action — the press
    // reached a tile and was turned down there, which is what costs the cadence.
    if (preview.refusal == PlacementRefusal.outOfRange) return ActionOutcome.none;
    if (!preview.isAllowed) return ActionOutcome.spent;

    // The bag is asked LAST of the things that can say no, so a build refused
    // by the world never costs an item — and `removeItem` answering false is
    // the honest end of a press by somebody who no longer has what they held.
    if (!user.inventory.removeItem(data, 1)) return ActionOutcome.spent;

    _place(preview.anchor);
    return ActionOutcome.landed;
  }

  /// Puts it there. The constructor already asserted which of the two kinds
  /// this blueprint is, so the cast below is the declared type (rule 18).
  void _place(GridPos anchor) {
    final bp = blueprint;
    if (bp is PropData) {
      WorldPlacementHelper.placeProp(bp, anchor);
      return;
    }
    WorldPlacementHelper.placeGround(bp as GroundBuildableData, anchor);
  }
}
