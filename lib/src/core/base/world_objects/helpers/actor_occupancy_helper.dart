import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/resources/i_world_object_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/actor_tracker.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// Is anybody standing there? — the port of `actor_occupancy_helper.gd`.
///
/// The ONE definition of "an actor's body is on this ground", asked by every
/// build and every destruction before it changes the world.
///
/// Both halves ask the OBJECT for permission, through the same authored field:
/// `IWorldObjectData.allowsActorOverlap`, true by default. The question it
/// answers is the same on both sides — *does this object appearing or
/// vanishing change what that actor is standing on?* A torch, a bush, a rock
/// or a crop does not, so it may be planted at your feet and broken there. The
/// terrain tile and the cave shaft do, so they say false and are refused on
/// both sides.
///
/// The spec's header records why this is one file rather than a check at each
/// site: the rule was once written three times with three different breadths,
/// and three copies is how the holes got in — a floor cut from under a player
/// dropped them into water, and a staircase broken under their feet handed the
/// mountain face back and sealed them inside the rock.
///
/// Two things the definition insists on, both of which a tile-vs-tile test
/// would get wrong:
///
///   - **The body rect, never the origin tile.** A collider straddles the
///     neighbouring tile long before the position crosses into it, so an actor
///     with its feet half on a tile reads as standing on the other one.
///   - **The whole area, never just the anchor.** A 3×2 prop appearing around
///     an actor traps it just as well as one appearing on it.
///
/// PORT DELTAS, both awaiting their subject:
///   - Airborne actors are exempt in the spec — nothing on the ground strands
///     something that is not on it. Nothing here flies yet; the exemption
///     arrives with flight rather than as an unreachable branch (rule 5).
///   - `is_host_destruction_blocked` (an attachment dying with the cell it
///     hangs off) has no `AttachmentComponent` to ask. It comes with one.
abstract final class ActorOccupancyHelper {
  /// The world-space footprint of one actor's body — the same half-extent the
  /// collision step resolves against, so what stops you and what counts you as
  /// standing somewhere cannot drift apart.
  static WorldRect bodyRectOf(WorldObject actor) => WorldRect.centred(
        actor.position,
        EngineConstants.actorBodyHalfExtentTiles * GameConstants.tileDimension,
      );

  /// World-space rect covering [width]×[height] tiles from [origin] — the
  /// footprint a build or a destruction is about to change.
  static WorldRect areaRect(GridPos origin, {int width = 1, int height = 1}) {
    assert(
      width > 0 && height > 0,
      '[ActorOccupancyHelper] an area needs a positive size, got $width×$height',
    );
    const dimension = GameConstants.tileDimension;
    // `gridToWorld` answers with a tile's CENTRE, and an area starts at its
    // corner — half a tile up and left of the first centre.
    final centre = locator<GridManager>().gridToWorld(origin);
    return WorldRect(
      centre.x - dimension / 2,
      centre.y - dimension / 2,
      (width * dimension).toDouble(),
      (height * dimension).toDouble(),
    );
  }

  /// True when any actor's body overlaps the [width]×[height] tiles starting
  /// at [origin].
  static bool isAreaOccupied(
    GridPos origin, {
    int width = 1,
    int height = 1,
  }) {
    final area = areaRect(origin, width: width, height: height);
    for (final actor in locator<ActorTracker>().actors) {
      if (area.intersects(bodyRectOf(actor))) return true;
    }
    return false;
  }

  /// Whether this PLACEMENT must be refused: somebody is standing on the
  /// ground it would take, and the thing being placed is not allowed to share
  /// a tile with them.
  ///
  /// The build-side twin of [isDestructionBlocked], and the reason a
  /// buildable's blueprint draws as valid under your own feet — the preview
  /// and the placement reach the same answer because they reach the same
  /// function.
  static bool isPlacementBlocked(IWorldObjectData data, GridPos origin) {
    if (data.allowsActorOverlap) return false;
    return isAreaOccupied(
      origin,
      width: data.gridWidth,
      height: data.gridHeight,
    );
  }

  /// Whether this DESTRUCTION must be refused: somebody is standing on the
  /// object AND the object is one of the few that may not be taken out from
  /// under them.
  ///
  /// The permission is content, never code. Breaking a bush, a rock or a crop
  /// under someone leaves them on the ground they were already on; breaking
  /// the terrain tile itself changes what that ground IS, and those are the
  /// ones that say no.
  static bool isDestructionBlocked(WorldObject target) {
    if (target.data.allowsActorOverlap) return false;
    return _isObjectAreaOccupied(target);
  }

  /// The area a world object holds.
  ///
  /// Returns false for a target that occupies no ground at all — an actor, a
  /// pickup. Those are not the ground anybody stands on, and refusing to hit
  /// an enemy because it overlaps its own tile would disarm the game.
  static bool _isObjectAreaOccupied(WorldObject target) {
    if (target is! Prop) return false;
    final grid = locator<GridManager>();
    final anchor = grid.worldToGrid(target.position);
    // A prop the grid does not hold is a prop that occupies no ground yet:
    // nothing is standing ON it, whatever is standing near it.
    if (!identical(grid.getPropAt(anchor), target)) return false;
    return isAreaOccupied(
      anchor,
      width: target.data.gridWidth,
      height: target.data.gridHeight,
    );
  }
}
