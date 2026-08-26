import 'dart:math';

import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/items/item_world.dart';
import 'package:dawnforge/src/core/base/world_objects/world_object.dart';
import 'package:dawnforge/src/core/domain/production/drop_rules.dart';
import 'package:dawnforge/src/core/factories/item_factory.dart';
import 'package:dawnforge/src/core/resources/items/item_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';

/// Centralized item-drop spawning — port of `world_drop_helper.gd` (logic
/// slice: the workstation front-face branch joins with `PropWorkstation` in
/// FP4.5; the network authority gate returns with the network layer — every
/// caller here IS the simulating machine, singleplayer by decision D4).
abstract final class WorldDropHelper {
  /// Where a pickup aimed at [desired] may actually come to rest, given that
  /// it was produced at [origin]. Returns [desired] untouched in the
  /// overwhelmingly common case.
  ///
  /// THE TEST IS ELEVATION, NOT WALKABILITY ALONE. `isTileWalkable`
  /// deliberately ignores elevation — a mountain tile keeps the perfectly
  /// good ground underneath it, so a wall reads as walkable and the obvious
  /// check would pass it. What separates "on the plateau" from "inside the
  /// rock" is WHOSE height it is: an item belongs at the height of the thing
  /// that produced it, so the search accepts only tiles at [origin]'s own
  /// elevation.
  ///
  /// When the rings find nothing, the answer is [origin]: whatever produced
  /// the item was itself somewhere, and somewhere is better than inside a
  /// wall. Not a fallback hiding a failure (rule 20) — a sealed pocket with
  /// no free tile within the radius is a legitimate shape for a world to
  /// have, and this is the honest answer for it.
  static WorldPos resolveLandingPosition(WorldPos desired, WorldPos origin) {
    final grid = locator<GridManager>();
    final referenceHeight = grid.getElevationAt(grid.worldToGrid(origin));
    final desiredTile = grid.worldToGrid(desired);
    if (_canHoldPickup(desiredTile, referenceHeight)) return desired;

    for (var radius = 1;
        radius <= EngineConstants.dropLandingSearchRadius;
        radius++) {
      for (var x = -radius; x <= radius; x++) {
        for (var y = -radius; y <= radius; y++) {
          // The ring only, never the filled square — the inner tiles were
          // all tested by a smaller radius already.
          if (x.abs() != radius && y.abs() != radius) continue;
          final candidate = GridPos(desiredTile.x + x, desiredTile.y + y);
          if (_canHoldPickup(candidate, referenceHeight)) {
            return grid.gridToWorld(candidate);
          }
        }
      }
    }
    return origin;
  }

  static bool _canHoldPickup(GridPos tile, int referenceHeight) {
    final grid = locator<GridManager>();
    return grid.isTileWalkable(tile) &&
        grid.getElevationAt(tile) == referenceHeight;
  }

  /// Spawns the physical pickup — THROUGH the factory, never a bare
  /// constructor (rule 1) — and announces it on the bus; the render layer
  /// listens and binds the renderer. This function IS "the simulation
  /// produced an item": every legitimate birth of a pickup comes through
  /// here, which is where the spec hangs its authority gate when the
  /// network layer arrives.
  ///
  /// [origin] is where the item came FROM — the reference height
  /// [resolveLandingPosition] judges [pos] against; a `pos` already inside
  /// a wall would happily validate against itself.
  static ItemWorld spawnPickup(
    ItemData item,
    int amount,
    WorldPos pos,
    WorldPos origin,
  ) {
    assert(amount > 0, '[WorldDropHelper] amount $amount must be > 0');
    final landing = resolveLandingPosition(pos, origin);
    final pickup = ItemFactory.createPickup(item.id, landing, amount);
    locator<Events>().pickupSpawned.emit(pickup);
    return pickup;
  }

  /// The drop anchor for a source host. Actors scatter their pile a random
  /// distance out so it never lands under their own feet; props and grounds
  /// offset toward their footprint's center. The workstation front-face
  /// branch joins with `PropWorkstation` (FP4.5).
  static WorldPos calculateDropPosition(WorldObject source, Random random) {
    final basePos = source.position;
    if (source is IActor) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = _range(
        random,
        EngineConstants.dropFromActorDistanceMin * GameConstants.tileDimension,
        EngineConstants.dropFromActorDistanceMax * GameConstants.tileDimension,
      );
      return DropRules.calculateSpreadPosition(basePos, angle, distance);
    }
    return DropRules.gridOffsetPosition(
      basePos,
      source.data.gridWidth,
      source.data.gridHeight,
      EngineConstants.dropGridOffsetMultiplier,
    );
  }

  static double _range(Random random, double min, double max) =>
      min + random.nextDouble() * (max - min);
}
