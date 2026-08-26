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
    final groundData = getGroundDataAt(tilePos);
    if (groundData == null) return false;
    if (groundData is GroundEmptyData && !groundData.isPassable) return true;
    return hasElevationAt(tilePos);
  }
}
