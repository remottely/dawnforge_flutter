import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_actor_entry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives the streaming headless (no camera: constant radius). The world
/// under it is the REAL generator over a fixed seed — the properties pinned
/// here (window shape, hysteresis, budget, regeneration) are exactly what
/// the FP3 gate's walkable world stands on.
void main() {
  const chunkSize = GameConstants.proceduralChunkSize;
  const loadRadius = EngineConstants.proceduralChunkLoadRadius;
  const unloadRadius = EngineConstants.proceduralChunkUnloadRadius;

  setUp(() {
    registerCoreSystems();
    // Minimal content: the forest biome and the three grounds the generator
    // can emit, id-faithful to the pack.
    locator<BiomeRegistry>().register(
      'biome_forest_data',
      BiomeData(
        id: 'biome_forest_data',
        tier: 1,
        terrainWaterShare: 0.08,
        terrainWallShare: 0.15,
        terrainWallHeight2Share: 0.25,
        terrainWallHeight3Share: 0.08,
        // Terrain-only fixture: an explicitly barren population half.
        maxPropsPerChunk: 0,
        maxActorsPerChunk: 0,
        densityNoiseFrequency: 0.005,
        propEntries: const <BiomePropEntry>[],
        actorEntries: const <BiomeActorEntry>[],
      ),
    );
    <Map<String, Object?>>[
      {'id': 't1_ground_buildable_terrain', 'type': 'ground_buildable_data'},
      {
        'id': 't1_ground_empty_water',
        'type': 'ground_empty_data',
        'is_water': true,
      },
      {'id': 't1_ground_empty_cliff', 'type': 'ground_empty_data'},
    ].forEach(locator<GroundRegistry>().registerJson);
    locator<ProceduralWorldManager>().initialize(20260826);
  });
  tearDown(resetCoreSystems);

  /// Runs [ChunkStreamingSystem.update] until both queues drain (bounded).
  /// Always updates at least once — the queues for a moved centre only fill
  /// INSIDE update (the window refresh), so a busy-check-first loop would
  /// exit before the move ever reached the system.
  void drain(ChunkStreamingSystem streaming, GridPos playerTile) {
    for (var i = 0; i < 500; i++) {
      streaming.update(playerTile: playerTile);
      if (!streaming.isStreamingBusy) return;
    }
    fail('streaming never quiesced — a queue is stuck');
  }

  test('initialize force-loads the spawn chunk THIS frame', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    locator<ChunkStreamingSystem>().initialize(spawn);
    // The player spawns now — its ground cannot wait for time slicing.
    expect(locator<GridManager>().hasGroundAt(spawn), isTrue);
    expect(
      locator<ChunkStreamingSystem>()
          .chunkStateOf(ChunkStreamingSystem.chunkOf(spawn)),
      ChunkState.loaded,
    );
  });

  test('boot fills the whole window, tiles and elevation both', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    drain(streaming, spawn);

    expect(streaming.isWindowLoaded(), isTrue);
    final grid = locator<GridManager>();
    final generator = locator<ProceduralWorldManager>();
    final center = ChunkStreamingSystem.chunkOf(spawn);
    var sawElevation = false;
    for (var dx = -loadRadius; dx <= loadRadius; dx++) {
      for (var dy = -loadRadius; dy <= loadRadius; dy++) {
        final origin = GridPos(
          (center.x + dx) * chunkSize,
          (center.y + dy) * chunkSize,
        );
        for (var x = 0; x < chunkSize; x++) {
          for (var y = 0; y < chunkSize; y++) {
            final tile = GridPos(origin.x + x, origin.y + y);
            expect(grid.hasGroundAt(tile), isTrue,
                reason: 'hole in the loaded window at $tile');
            expect(grid.getGroundDataAt(tile)!.id, generator.getGroundIdAt(tile));
            expect(grid.getElevationAt(tile), generator.getHeightAt(tile),
                reason: 'elevation drifted from the generator at $tile');
            sawElevation = sawElevation || grid.getElevationAt(tile) > 0;
          }
        }
      }
    }
    // The window is 40x40 tiles of forest — a wall-less one would mean the
    // elevation path never ran at all.
    expect(sawElevation, isTrue);
  });

  test('walking a chunk border never load/unload-thrashes (hysteresis)', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    drain(streaming, spawn);
    final residentAfterBoot = streaming.residentChunkCount;

    // Oscillate across the border between the spawn chunk and its right
    // neighbor — the load window moves by one, but nothing crosses the
    // unload radius, so no chunk may ever unload.
    var unloadStarts = 0;
    streaming.chunkUnloadStarted.connect((_) => unloadStarts++);
    final left = spawn;
    final right = GridPos(spawn.x + chunkSize, spawn.y);
    for (var lap = 0; lap < 6; lap++) {
      drain(streaming, lap.isEven ? right : left);
    }
    expect(unloadStarts, 0,
        reason: 'a border walk unloaded chunks inside the hysteresis gap');
    // The union of both windows stays resident: one extra column of chunks.
    expect(
      streaming.residentChunkCount,
      residentAfterBoot + (2 * loadRadius + 1),
    );
  });

  test('a long jump unloads what fell beyond the unload radius', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    drain(streaming, spawn);

    final farTile = GridPos(spawn.x + chunkSize * 20, spawn.y);
    drain(streaming, farTile);

    final grid = locator<GridManager>();
    expect(grid.hasGroundAt(spawn), isFalse,
        reason: 'the old window survived a 20-chunk jump');
    expect(grid.hasElevationAt(spawn), isFalse);
    // Exactly the new window remains — resident count is bounded.
    expect(
      streaming.residentChunkCount,
      (2 * loadRadius + 1) * (2 * loadRadius + 1),
    );
    expect(streaming.isWindowLoaded(), isTrue);
  });

  test('gameplay budget: one frame advances but never swallows a flood', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    drain(streaming, spawn); // boot completes → gameplay budget from here

    // A 20-chunk jump queues a whole fresh window (~200 load columns at
    // ~30µs each, measured) plus the entire old window's unloads — an order
    // of magnitude over the 1.2 ms budget on any machine this suite runs on.
    streaming.update(playerTile: GridPos(spawn.x + chunkSize * 20, spawn.y));

    // Unloads run FIRST and always advance: the old centre chunk heads the
    // unload queue, so one frame is enough to see it freed…
    expect(locator<GridManager>().hasGroundAt(spawn), isFalse,
        reason: 'the unload side of the frame never ran');
    // …while the load backlog must survive the frame — the budget bit.
    expect(streaming.isStreamingBusy, isTrue,
        reason: 'a 400-column flood fit one frame budget — either the budget '
            'is not being consulted or columns stopped costing time');
  });

  test('unload → reload regenerates the identical chunk (pure function)', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    drain(streaming, spawn);
    final grid = locator<GridManager>();

    final spawnChunk = ChunkStreamingSystem.chunkOf(spawn);
    final origin = GridPos(spawnChunk.x * chunkSize, spawnChunk.y * chunkSize);
    Map<GridPos, (String, int)> snapshot() => {
          for (var x = 0; x < chunkSize; x++)
            for (var y = 0; y < chunkSize; y++)
              GridPos(origin.x + x, origin.y + y): (
                grid
                    .getGroundDataAt(GridPos(origin.x + x, origin.y + y))!
                    .id,
                grid.getElevationAt(GridPos(origin.x + x, origin.y + y)),
              ),
        };

    final before = snapshot();
    drain(streaming, GridPos(spawn.x + chunkSize * 20, spawn.y)); // away
    expect(grid.hasGroundAt(spawn), isFalse);
    drain(streaming, spawn); // back
    expect(snapshot(), before);
  });

  test('chunkLoaded fires once per materialized chunk', () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>();
    final loads = <GridPos>[];
    streaming.chunkLoaded.connect(loads.add);
    streaming.initialize(spawn);
    drain(streaming, spawn);

    const windowChunks = (2 * loadRadius + 1) * (2 * loadRadius + 1);
    expect(loads.length, windowChunks);
    expect(loads.toSet().length, windowChunks, reason: 'a chunk loaded twice');
  });

  test('a wide camera widens the window per axis, past the constant radius',
      () {
    final spawn = locator<ProceduralWorldManager>().findSpawnTile();
    final streaming = locator<ChunkStreamingSystem>()..initialize(spawn);
    // A view 9 chunks wide and 1 chunk tall: the x radius must grow past the
    // constant; y keeps the floor.
    const chunkWorldSide = chunkSize * GameConstants.tileDimension;
    for (var i = 0; i < 500 && streaming.isStreamingBusy; i++) {
      streaming.update(
        playerTile: spawn,
        visibleWorldWidth: 9.0 * chunkWorldSide,
        visibleWorldHeight: 1.0 * chunkWorldSide,
      );
    }
    final center = ChunkStreamingSystem.chunkOf(spawn);
    // ceil(9/2 * 1.2) = 6 chunks of x reach.
    expect(
      streaming.chunkStateOf(GridPos(center.x + loadRadius + 1, center.y)),
      ChunkState.loaded,
      reason: 'x radius did not follow the wide view',
    );
    expect(
      streaming.chunkStateOf(GridPos(center.x, center.y + unloadRadius + 1)),
      isNull,
      reason: 'y radius grew although the view is one chunk tall',
    );
  });
}
