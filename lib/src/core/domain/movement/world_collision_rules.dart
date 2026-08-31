import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// One resolved integration step: where the body ended up and the velocity
/// that survived it (a blocked axis zeroes; the other slides).
typedef ResolvedStep = ({WorldPos position, WorldPos velocity});

/// Pure grid-collision resolution — the study's replacement for
/// `move_and_slide` (§3.2: "top-down: grid occupancy is already the
/// authority"). No engine types, no grid access of its own: the caller
/// hands in a walkability oracle, so the rule is unit-testable against any
/// fake world.
abstract final class WorldCollisionRules {
  /// A hair of body inset when mapping the AABB to tiles, so a body flush
  /// against a tile border does not read the neighboring tile as occupied.
  static const double _edgeInset = 1e-7;

  /// Resolves one fixed step of an AABB body (half-extents
  /// [bodyHalfExtent], centered at [position]) moving by
  /// `velocity * dt` over a tile grid. AXIS-SEPARATED, X then Y: an axis
  /// moves only if no tile the moved body covers answers [blocksBody]; a
  /// blocked axis keeps its coordinate and zeroes its velocity component,
  /// which is what lets the other axis slide along a wall — the
  /// `move_and_slide` behavior this rule replaces.
  ///
  /// The oracle answers "does this tile carry a collider?" — an absent tile
  /// blocks nothing, exactly like the engine physics it stands in for.
  static ResolvedStep resolveStep({
    required WorldPos position,
    required WorldPos velocity,
    required double dt,
    required double bodyHalfExtent,
    required int tileDimension,
    required bool Function(GridPos tile) blocksBody,
  }) {
    var resolvedX = position.x + velocity.x * dt;
    var velocityX = velocity.x;
    if (_bodyHitsBlocker(
      resolvedX,
      position.y,
      bodyHalfExtent,
      tileDimension,
      blocksBody,
    )) {
      resolvedX = position.x;
      velocityX = 0;
    }

    var resolvedY = position.y + velocity.y * dt;
    var velocityY = velocity.y;
    if (_bodyHitsBlocker(
      resolvedX,
      resolvedY,
      bodyHalfExtent,
      tileDimension,
      blocksBody,
    )) {
      resolvedY = position.y;
      velocityY = 0;
    }

    return (
      position: WorldPos(resolvedX, resolvedY),
      velocity: WorldPos(velocityX, velocityY),
    );
  }

  /// True when any tile covered by the body at (x, y) carries a collider.
  static bool _bodyHitsBlocker(
    double x,
    double y,
    double bodyHalfExtent,
    int tileDimension,
    bool Function(GridPos tile) blocksBody,
  ) {
    final half = bodyHalfExtent - _edgeInset;
    final left = ((x - half) / tileDimension).floor();
    final right = ((x + half) / tileDimension).floor();
    final top = ((y - half) / tileDimension).floor();
    final bottom = ((y + half) / tileDimension).floor();
    for (var tileX = left; tileX <= right; tileX++) {
      for (var tileY = top; tileY <= bottom; tileY++) {
        if (blocksBody(GridPos(tileX, tileY))) return true;
      }
    }
    return false;
  }
}
