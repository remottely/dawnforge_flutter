import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';

/// Chunk lifecycle — tracked from first request until its terrain is fully
/// freed again (then it leaves the state map entirely).
enum ChunkState { loading, loaded, unloading }

/// Streams the procedural world around the player in square chunks of
/// [GameConstants.proceduralChunkSize] tiles — the port of
/// `chunk_streaming_system.gd`. Chunks within the load radius stay loaded;
/// tracked chunks beyond the unload radius free; the gap is hysteresis.
/// When the camera shows more world than the fixed radius covers, the
/// window widens PER AXIS so content materializes past every screen edge
/// instead of popping inside the viewport.
///
/// TIME SLICING: terrain work is spread across frames. Each [update]
/// processes chunk columns (one column = chunk-size tiles) until the
/// [EngineConstants.proceduralStreamFrameBudgetUsec] budget is spent — at
/// least one column always completes per direction. Runs on the RENDER
/// frame, not the fixed sim step: what this machine materializes is a
/// view-side concern (the sim is multiplayer-shaped; a server streams for
/// its own reasons).
///
/// NODELESS TERRAIN: a streamed tile is a GridManager data entry only — no
/// object per tile. All content comes from [ProceduralWorldManager] — pure
/// functions of (seed, tile) — so chunks regenerate identically in any
/// order.
///
/// Ported deltas, deliberate (singleplayer-first, D4): one window centre
/// (the local player; the host's multi-centre union is MP5), no save/load
/// suspension (FP6), no destroyed-tile flood (FP4), no worker-thread chunk
/// precompute and no per-id registry cache (both existed to pay GDScript
/// marshalling costs; Dart's are a hash lookup — isolates can arrive later
/// if the 60fps hand-run demands them). Player-modified-tile purity checks
/// arrive with the first tool that can modify terrain (FP4) — today every
/// resident tile is procedural-pure by construction.
final class ChunkStreamingSystem {
  /// Emitted when a chunk finishes materializing all its columns —
  /// consumers (the chunk renderer) can then bake it whole.
  final chunkLoaded = EventSignal<GridPos>();

  /// Emitted on an unloading chunk's FIRST column, before any tile frees —
  /// consumers drop their per-chunk artifacts (bakes) in the handler. A
  /// chunk whose unload is cancelled before its first column never emits.
  final chunkUnloadStarted = EventSignal<GridPos>();

  final Map<GridPos, ChunkState> _chunkStates = <GridPos, ChunkState>{};

  /// Next column index to process for chunks currently loading or unloading.
  final Map<GridPos, int> _chunkCursors = <GridPos, int>{};
  final List<GridPos> _loadQueue = <GridPos>[];
  final List<GridPos> _unloadQueue = <GridPos>[];

  GridPos _centerChunk = const GridPos(0, 0);

  /// The centre and radius the last window refresh was built for — the memo
  /// that keeps the refresh off the per-frame path (mirror of the Godot
  /// `_window_centres` / `_last_effective_load_radius` pair).
  GridPos _lastWindowCentre = const GridPos(0, 0);
  GridPos _lastEffectiveLoadRadius = const GridPos(0, 0);
  bool _isInitialized = false;

  /// False while the initial window is still materializing — boot runs at
  /// [EngineConstants.proceduralBootColumnsPerFrame] instead of the gameplay
  /// time budget; the flag clears itself the frame the window is whole.
  bool _initialWindowCompleted = false;

  // ============================================
  // LIFECYCLE
  // ============================================

  /// Centers the window on [spawnTile] and force-loads its chunk
  /// synchronously — the player spawns THIS frame and cannot wait for time
  /// slicing.
  void initialize(GridPos spawnTile) {
    assert(!_isInitialized, '[ChunkStreamingSystem] already initialized');
    assert(
      EngineConstants.proceduralChunkUnloadRadius >
          EngineConstants.proceduralChunkLoadRadius,
      '[ChunkStreamingSystem] unload radius must exceed load radius '
      '(hysteresis)',
    );
    assert(
      EngineConstants.proceduralStreamFrameBudgetUsec > 0,
      '[ChunkStreamingSystem] frame budget must be positive',
    );
    _centerChunk = chunkOf(spawnTile);
    _lastWindowCentre = _centerChunk;
    _isInitialized = true;
    _refreshWindow();
    _forceLoadChunk(_centerChunk);
  }

  /// One render frame of streaming work. [playerTile] recenters the window;
  /// [visibleWorldWidth]/[visibleWorldHeight] (world units the camera shows)
  /// widen the effective radius — pass 0 when no camera exists (headless
  /// tests), which keeps the constant radius on both axes.
  void update({
    required GridPos playerTile,
    double visibleWorldWidth = 0,
    double visibleWorldHeight = 0,
  }) {
    assert(_isInitialized, '[ChunkStreamingSystem] update before initialize');

    final playerChunk = chunkOf(playerTile);
    if (playerChunk != _centerChunk) _centerChunk = playerChunk;

    // Zooming out widens the visible world without moving the centre, so the
    // effective radius is a refresh trigger of its own.
    final effectiveRadius =
        _effectiveLoadRadius(visibleWorldWidth, visibleWorldHeight);
    if (playerChunk != _lastWindowCentre ||
        effectiveRadius != _lastEffectiveLoadRadius) {
      _lastWindowCentre = playerChunk;
      _refreshWindow(
        visibleWorldWidth: visibleWorldWidth,
        visibleWorldHeight: visibleWorldHeight,
      );
    }

    // Boot/post-load refill is hidden by the loading screen — burn columns.
    if (!_initialWindowCompleted) {
      var bootBudget = EngineConstants.proceduralBootColumnsPerFrame;
      while (bootBudget > 0 && _unloadQueue.isNotEmpty) {
        _processUnloadColumn(_unloadQueue.first);
        bootBudget--;
      }
      bootBudget = EngineConstants.proceduralBootColumnsPerFrame;
      while (bootBudget > 0 && _loadQueue.isNotEmpty) {
        _processLoadColumn(_loadQueue.first);
        bootBudget--;
      }
      if (isWindowLoaded(
        visibleWorldWidth: visibleWorldWidth,
        visibleWorldHeight: visibleWorldHeight,
      )) {
        _initialWindowCompleted = true;
      }
      return;
    }

    // Gameplay: both loops share one time budget. Each always completes at
    // least its first column — the window must advance every frame no matter
    // how deep a dip — and stops once streaming time crosses the budget.
    // Unloads run first (peak resident count stays down), and the load-side
    // cap keeps loading from ever outpacing unloading — a border crossing
    // queues the same column count both ways, so loads winning would turn
    // every frame-rate dip into a permanent terrain backlog.
    final stopwatch = Stopwatch()..start();
    const budgetUsec = EngineConstants.proceduralStreamFrameBudgetUsec;
    var unloadedColumns = 0;
    while (_unloadQueue.isNotEmpty) {
      _processUnloadColumn(_unloadQueue.first);
      unloadedColumns++;
      if (stopwatch.elapsedMicroseconds >= budgetUsec) break;
    }
    var loadedColumns = 0;
    while (_loadQueue.isNotEmpty) {
      _processLoadColumn(_loadQueue.first);
      loadedColumns++;
      if (_unloadQueue.isNotEmpty && loadedColumns >= unloadedColumns) break;
      if (stopwatch.elapsedMicroseconds >= budgetUsec) break;
    }
  }

  // ============================================
  // WINDOW MANAGEMENT
  // ============================================

  /// The load radius that actually covers this machine's screen, per axis —
  /// everything must exist at least the screen margin beyond every edge
  /// before the camera reaches it. Per axis, because a screen is not square
  /// and a window covering it has no reason to be. No camera (0 extent)
  /// keeps the constant on both axes.
  GridPos _effectiveLoadRadius(
    double visibleWorldWidth,
    double visibleWorldHeight,
  ) {
    const floorRadius = EngineConstants.proceduralChunkLoadRadius;
    if (visibleWorldWidth <= 0 || visibleWorldHeight <= 0) {
      return const GridPos(floorRadius, floorRadius);
    }
    const chunkWorldSide =
        GameConstants.proceduralChunkSize * GameConstants.tileDimension;
    const margin = 1.0 + EngineConstants.proceduralStreamScreenMargin;
    final neededX = visibleWorldWidth * 0.5 * margin;
    final neededY = visibleWorldHeight * 0.5 * margin;
    return GridPos(
      (neededX / chunkWorldSide).ceil().clamp(floorRadius, 1 << 16),
      (neededY / chunkWorldSide).ceil().clamp(floorRadius, 1 << 16),
    );
  }

  /// Unload = effective load + the constants' gap on each axis — the
  /// hysteresis must survive the widening, in the direction being crossed.
  GridPos _effectiveUnloadRadius(GridPos loadRadius) {
    const gap = EngineConstants.proceduralChunkUnloadRadius -
        EngineConstants.proceduralChunkLoadRadius;
    return GridPos(loadRadius.x + gap, loadRadius.y + gap);
  }

  /// Requeues chunk work after the window moved: queues every missing chunk
  /// inside the load radius, queues unload for tracked chunks beyond the
  /// unload radius, keeps the load queue sorted nearest-first.
  void _refreshWindow({
    double visibleWorldWidth = 0,
    double visibleWorldHeight = 0,
  }) {
    final loadRadius =
        _effectiveLoadRadius(visibleWorldWidth, visibleWorldHeight);
    _lastEffectiveLoadRadius = loadRadius;
    for (var dx = -loadRadius.x; dx <= loadRadius.x; dx++) {
      for (var dy = -loadRadius.y; dy <= loadRadius.y; dy++) {
        _requestLoad(GridPos(_centerChunk.x + dx, _centerChunk.y + dy));
      }
    }

    final unloadRadius = _effectiveUnloadRadius(loadRadius);
    for (final chunk in _chunkStates.keys.toList()) {
      final outside = (chunk.x - _centerChunk.x).abs() > unloadRadius.x ||
          (chunk.y - _centerChunk.y).abs() > unloadRadius.y;
      if (outside) _requestUnload(chunk);
    }

    _loadQueue.sort(
      (a, b) => a
          .chebyshevDistanceTo(_centerChunk)
          .compareTo(b.chebyshevDistanceTo(_centerChunk)),
    );
  }

  void _requestLoad(GridPos chunk) {
    switch (_chunkStates[chunk]) {
      case ChunkState.loaded || ChunkState.loading:
        return;
      case ChunkState.unloading:
        // Back inside the window mid-unload: restart loading — the column
        // loader skips surviving tiles, refilling the partial unload.
        _unloadQueue.remove(chunk);
      case null:
        break;
    }
    _chunkStates[chunk] = ChunkState.loading;
    _chunkCursors[chunk] = 0;
    _loadQueue.add(chunk);
  }

  void _requestUnload(GridPos chunk) {
    switch (_chunkStates[chunk]) {
      case ChunkState.unloading:
        return;
      case ChunkState.loading:
        _loadQueue.remove(chunk);
      case ChunkState.loaded || null:
        break;
    }
    _chunkStates[chunk] = ChunkState.unloading;
    _chunkCursors[chunk] = 0;
    _unloadQueue.add(chunk);
  }

  // ============================================
  // TIME-SLICED COLUMN WORK
  // ============================================

  /// Registers one column (chunk-size tiles) of a chunk as nodeless data —
  /// a GridManager entry per tile plus its elevation. No object is created.
  void _processLoadColumn(GridPos chunk) {
    const chunkSize = GameConstants.proceduralChunkSize;
    final origin = GridPos(chunk.x * chunkSize, chunk.y * chunkSize);
    final col = _chunkCursors[chunk]!;
    final generator = locator<ProceduralWorldManager>();
    final grounds = locator<GroundRegistry>();
    final grid = locator<GridManager>();

    final pendingHeights = <GridPos, int>{};
    for (var y = 0; y < chunkSize; y++) {
      final tile = GridPos(origin.x + col, origin.y + y);
      // Existing tiles are never touched — survivors of a cancelled unload
      // already carry their own state (and, from FP4 on, player work).
      if (grid.hasGroundAt(tile)) continue;
      grid.registerGroundData(tile, grounds.getGround(generator.getGroundIdAt(tile)));
      final height = generator.getHeightAt(tile);
      if (height > 0) pendingHeights[tile] = height;
    }

    // Ascending height order — the elevation visual layers expect inferior
    // levels first (same order the Godot column loader registers).
    for (var height = 1; height <= EngineConstants.mountainMaxHeight; height++) {
      pendingHeights.forEach((tile, tileHeight) {
        if (tileHeight == height) grid.registerElevationTile(tile, height);
      });
    }

    _advanceCursor(chunk, isLoading: true);
  }

  /// Frees one column of a chunk. Every resident tile today is
  /// procedural-pure by construction (no tool can modify terrain yet), so
  /// the unload is an erase; the purity checks that preserve player work
  /// arrive with FP4.
  void _processUnloadColumn(GridPos chunk) {
    const chunkSize = GameConstants.proceduralChunkSize;
    final origin = GridPos(chunk.x * chunkSize, chunk.y * chunkSize);
    final col = _chunkCursors[chunk]!;
    final grid = locator<GridManager>();

    if (col == 0) chunkUnloadStarted.emit(chunk);

    for (var y = 0; y < chunkSize; y++) {
      final tile = GridPos(origin.x + col, origin.y + y);
      if (!grid.hasGroundAt(tile)) continue;
      if (grid.hasElevationAt(tile)) grid.releaseElevationTile(tile);
      grid.unregisterGroundData(tile);
    }

    _advanceCursor(chunk, isLoading: false);
  }

  void _advanceCursor(GridPos chunk, {required bool isLoading}) {
    final nextCol = _chunkCursors[chunk]! + 1;
    if (nextCol < GameConstants.proceduralChunkSize) {
      _chunkCursors[chunk] = nextCol;
      return;
    }
    _chunkCursors.remove(chunk);
    if (isLoading) {
      _loadQueue.remove(chunk);
      _chunkStates[chunk] = ChunkState.loaded;
      chunkLoaded.emit(chunk);
    } else {
      _unloadQueue.remove(chunk);
      _chunkStates.remove(chunk);
    }
  }

  void _forceLoadChunk(GridPos chunk) {
    while (_chunkStates[chunk] == ChunkState.loading) {
      _processLoadColumn(chunk);
    }
  }

  // ============================================
  // QUERIES
  // ============================================

  /// True when every chunk within the effective load radius is fully
  /// materialized — the world holds its loading screen on this.
  bool isWindowLoaded({
    double visibleWorldWidth = 0,
    double visibleWorldHeight = 0,
  }) {
    final radius = _effectiveLoadRadius(visibleWorldWidth, visibleWorldHeight);
    for (var dx = -radius.x; dx <= radius.x; dx++) {
      for (var dy = -radius.y; dy <= radius.y; dy++) {
        final chunk = GridPos(_centerChunk.x + dx, _centerChunk.y + dy);
        if (_chunkStates[chunk] != ChunkState.loaded) return false;
      }
    }
    return true;
  }

  /// True while chunk columns are still queued in either direction —
  /// consumers throttle their own per-change reactions during a flood.
  bool get isStreamingBusy =>
      _loadQueue.isNotEmpty || _unloadQueue.isNotEmpty;

  /// Chunks whose terrain is still registered. This is the number that must
  /// stay bounded — the debug overlay (FP3.6) surfaces it so a streaming
  /// regression shows up as a rising count, not only a falling frame rate.
  int get residentChunkCount => _chunkStates.length;

  ChunkState? chunkStateOf(GridPos chunk) => _chunkStates[chunk];

  /// Every fully materialized chunk — what a consumer that mounts AFTER the
  /// initial fill (the chunk renderer) seeds itself from before listening to
  /// [chunkLoaded].
  Iterable<GridPos> get loadedChunks => _chunkStates.entries
      .where((entry) => entry.value == ChunkState.loaded)
      .map((entry) => entry.key);

  GridPos get centerChunk => _centerChunk;

  /// The chunk holding [tile] (floor division, so negative space chunks
  /// correctly).
  static GridPos chunkOf(GridPos tile) {
    const chunkSize = GameConstants.proceduralChunkSize;
    return GridPos(
      (tile.x / chunkSize).floor(),
      (tile.y / chunkSize).floor(),
    );
  }
}
