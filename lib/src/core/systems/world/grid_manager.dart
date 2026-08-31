import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Grid ↔ world math and the tile-occupancy authority — all conversion goes
/// through here, never raw vector arithmetic at call sites (Godot repo §6
/// Grid System), and a tile's ground/elevation state has exactly one owner.
///
/// FP3.4 slice: the NODELESS registry (streamed procedural terrain exists as
/// data only — no node per tile) and the elevation map. Node-backed tiles
/// (materialize-on-demand, player placement) arrive with FP4.
///
/// Registered once at boot and never null after (rule 28).
final class GridManager {
  static const int _tile = GameConstants.tileDimension;

  /// Every nodeless tile's data — the SHARED GroundRegistry resource, never
  /// a clone: nodeless tiles are immutable by definition (any modification
  /// materializes a node first, FP4).
  final Map<GridPos, GroundBuildableData> _registeredGroundData =
      <GridPos, GroundBuildableData>{};

  /// Mountain elevation per tile (height >= 1; a flat tile has no entry).
  final Map<GridPos, int> _elevationMap = <GridPos, int>{};

  // ============================================
  // GRID ↔ WORLD MATH
  // ============================================

  /// The world-space position of the CENTER of tile [gridPos].
  WorldPos gridToWorld(GridPos gridPos) => WorldPos(
        gridPos.x * _tile + _tile / 2,
        gridPos.y * _tile + _tile / 2,
      );

  /// The world-space position of the top-left CORNER of tile [gridPos] —
  /// what a tile renderer anchors at.
  WorldPos gridToWorldCorner(GridPos gridPos) =>
      WorldPos((gridPos.x * _tile).toDouble(), (gridPos.y * _tile).toDouble());

  /// The tile containing world-space [worldPos].
  GridPos worldToGrid(WorldPos worldPos) =>
      GridPos((worldPos.x / _tile).floor(), (worldPos.y / _tile).floor());

  // ============================================
  // NODELESS GROUND REGISTRY
  // ============================================

  /// Registers a tile as pure data — the streamed procedural terrain path.
  /// Registering over an existing tile is a wiring bug, never content state:
  /// the streaming's load column skips resident tiles before calling this.
  void registerGroundData(GridPos gridPos, GroundBuildableData data) {
    if (_registeredGroundData.containsKey(gridPos)) {
      throw StateError(
        '[GridManager] registerGroundData at $gridPos — tile already '
        'registered',
      );
    }
    _registeredGroundData[gridPos] = data;
  }

  /// Releases a nodeless tile — the streamed unload path. An absent tile is
  /// a LEGITIMATE branch, not a fallback: an unload whose cursor restarted
  /// (re-queued chunk) replays columns over tiles it already freed.
  void unregisterGroundData(GridPos gridPos) {
    _registeredGroundData.remove(gridPos);
  }

  bool hasGroundAt(GridPos gridPos) =>
      _registeredGroundData.containsKey(gridPos);

  /// The tile's ground data, or null when the tile has no ground — "not
  /// materialized" is a real state the streaming and the renderer branch on.
  /// This is the SSOT for every flag-only consumer.
  GroundBuildableData? getGroundDataAt(GridPos gridPos) =>
      _registeredGroundData[gridPos];

  /// Every registered nodeless tile — the renderer's bake iterates this via
  /// chunk coordinates; exposed read-only.
  Iterable<GridPos> get registeredGroundTiles => _registeredGroundData.keys;

  // ============================================
  // ELEVATION MAP
  // ============================================

  /// Registers a mountain wall of [height] (>= 1) at [pos]. Height 0 is not
  /// a registration — a flat tile simply has no entry.
  void registerElevationTile(GridPos pos, int height) {
    if (height < 1) {
      throw StateError(
        '[GridManager] registerElevationTile: height must be >= 1, '
        'got $height',
      );
    }
    _elevationMap[pos] = height;
  }

  /// Releases a wall registration — the streamed unload path. Releasing a
  /// flat tile is a caller bug: the unload guards with [hasElevationAt].
  void releaseElevationTile(GridPos pos) {
    final removed = _elevationMap.remove(pos);
    assert(
      removed != null,
      '[GridManager] releaseElevationTile at $pos — no elevation there',
    );
  }

  bool hasElevationAt(GridPos pos) => _elevationMap.containsKey(pos);

  /// The wall height at [pos]; 0 means flat — a value, not an absence.
  int getElevationAt(GridPos pos) => _elevationMap[pos] ?? 0;

  // ============================================
  // BODY BLOCKING (FP3.5)
  // ============================================

  /// True when a REGISTERED tile blocks a moving body: an impassable empty
  /// (water and cliff both author `is_passable: false`) or a mountain wall.
  ///
  /// An UNREGISTERED tile blocks nothing — the physics mirror of the Godot
  /// side, where only materialized terrain creates colliders: the streaming
  /// keeps the window loaded around every body, and the world edge is
  /// `WorldBoundaryEnforcer`'s job (unported). The stricter "can a body
  /// STAND here" question (A*'s `is_tile_walkable`, where the void is
  /// unreachable) arrives with its consumers — pathfinding and placement.
  ///
  /// FP3.5 slice: the colliding-prop clause joins with prop occupancy
  /// (FP4); slabs and mountain climbing with their systems (FP7) — until
  /// then a wall blocks outright.
  bool blocksBodyAt(GridPos tilePos) {
    final prop = _occupiedPropTiles[tilePos];
    if (prop != null && prop.data.hasCollision) return true;
    final groundData = getGroundDataAt(tilePos);
    if (groundData == null) return false;
    if (groundData is GroundEmptyData && !groundData.isPassable) return true;
    return hasElevationAt(tilePos);
  }

  /// The A*-side question [blocksBodyAt]'s doc promised (FP4.1): can
  /// something STAND (or lie) on this tile? Here the VOID is unreachable —
  /// an unregistered tile answers false, the opposite of the physics
  /// question — and an impassable empty (water, cliff) answers false too.
  ///
  /// Elevation is deliberately NOT consulted: a mountain tile keeps the
  /// perfectly good ground underneath it, so walkability is the ground
  /// half of the answer and the caller judges heights against its own
  /// reference (see `WorldDropHelper.resolveLandingPosition` for why that
  /// split is what keeps drops out of cave walls).
  ///
  /// FP4.1 slice: the colliding-prop clause joins with prop occupancy
  /// (FP4.1d).
  bool isTileWalkable(GridPos tilePos) {
    final prop = _occupiedPropTiles[tilePos];
    if (prop != null && prop.data.hasCollision) return false;
    final groundData = getGroundDataAt(tilePos);
    if (groundData == null) return false;
    if (groundData is GroundEmptyData) return groundData.isPassable;
    return true;
  }

  // -- Prop occupancy (FP4.1d) — the grid is the authority on which prop
  // -- holds which tile; a multi-tile prop claims every tile of its
  // -- footprint, and every claim maps back to the same host.

  final Map<GridPos, Prop> _occupiedPropTiles = <GridPos, Prop>{};

  /// Whether a footprint of [width]×[height] tiles anchored at [anchor] is
  /// free of props. Terrain validity is the caller's own question — spawn,
  /// placement and farming each ask a different combination.
  bool isPropSpaceAvailable(GridPos anchor, {int width = 1, int height = 1}) {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        if (_occupiedPropTiles.containsKey(GridPos(anchor.x + x, anchor.y + y))) {
          return false;
        }
      }
    }
    return true;
  }

  /// Claims [prop]'s footprint. Claiming over a resident prop is a wiring
  /// bug — the caller asks [isPropSpaceAvailable] first (crash, rule 5).
  void occupyPropTiles(GridPos anchor, Prop prop) {
    final width = prop.data.gridWidth;
    final height = prop.data.gridHeight;
    assert(
      isPropSpaceAvailable(anchor, width: width, height: height),
      '[GridManager] occupyPropTiles at $anchor — footprint already claimed',
    );
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        _occupiedPropTiles[GridPos(anchor.x + x, anchor.y + y)] = prop;
      }
    }
  }

  /// Releases [prop]'s footprint anchored at [anchor]. Releasing tiles the
  /// prop does not hold is a wiring bug (crash, rule 5).
  void freePropTiles(GridPos anchor, Prop prop) {
    for (var x = 0; x < prop.data.gridWidth; x++) {
      for (var y = 0; y < prop.data.gridHeight; y++) {
        final tile = GridPos(anchor.x + x, anchor.y + y);
        assert(
          identical(_occupiedPropTiles[tile], prop),
          '[GridManager] freePropTiles at $tile — held by somebody else',
        );
        _occupiedPropTiles.remove(tile);
      }
    }
  }

  /// Whether the GROUND under a [width]×[height] footprint anchored at
  /// [anchor] accepts a prop: a tile exists there, and it does not refuse
  /// props (FP4.3b).
  ///
  /// Two questions the occupancy one above cannot answer. The void refuses
  /// because there is nothing to stand on — an unregistered tile is outside
  /// the streamed window, which is the honest "no" for a footprint that runs
  /// off the edge of what exists. And the tile's own `blocksProps` refuses
  /// because the ground says so: water and cliff both author it true, which is
  /// the whole reason nothing here has a water branch (rule 33 — the
  /// permission is content, never an `if` at the call site).
  ///
  /// PORT DELTA: the spec asks a `GroundBuildable` NODE its `can_place_prop()`
  /// and only reads the data when the tile has no node. Terrain is nodeless
  /// here (FP3.4), so the two branches are one.
  ///
  /// Prop occupancy is deliberately NOT re-asked here, though the spec asks it
  /// in this very loop: [isPropSpaceAvailable] already owns that question and
  /// every caller asks it first. A second copy of one rule is how the two
  /// eventually disagree.
  bool canPlacePropAt(GridPos anchor, {int width = 1, int height = 1}) {
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final data = getGroundDataAt(GridPos(anchor.x + x, anchor.y + y));
        if (data == null || data.blocksProps) return false;
      }
    }
    return true;
  }

  /// The prop holding [tilePos], or null — absence is a legitimate answer.
  Prop? getPropAt(GridPos tilePos) => _occupiedPropTiles[tilePos];
}
