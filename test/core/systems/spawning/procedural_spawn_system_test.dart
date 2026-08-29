import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_actor_entry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/spawning/procedural_spawn_system.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// FP4.1d: the one-shot, seed-pure chunk population — scarcity-first roll,
/// per-chunk cap, spawnability, occupancy, and full release on unload.
void main() {
  const chunkSize = GameConstants.proceduralChunkSize;

  setUp(() {
    registerCoreSystems();
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_grass_probe',
      'has_collision': false,
    });
    locator<PropRegistry>().registerJson(<String, Object?>{
      'id': 't1_prop_vein_probe',
      'has_collision': true,
    });
  });
  tearDown(resetCoreSystems);

  /// Registers walkable terrain for every tile of [chunk].
  void materializeChunkTerrain(GridPos chunk) {
    final grid = locator<GridManager>();
    for (var x = 0; x < chunkSize; x++) {
      for (var y = 0; y < chunkSize; y++) {
        grid.registerGroundData(
          GridPos(chunk.x * chunkSize + x, chunk.y * chunkSize + y),
          GroundBuildableData(id: 't1_ground_buildable_terrain'),
        );
      }
    }
  }

  BiomeData fixtureBiome({int maxProps = 5}) => BiomeData(
        id: 'biome_probe_data',
        tier: 1,
        terrainWaterShare: 0.08,
        terrainWallShare: 0.15,
        terrainWallHeight2Share: 0.25,
        terrainWallHeight3Share: 0.08,
        maxPropsPerChunk: maxProps,
        maxActorsPerChunk: 0,
        densityNoiseFrequency: 0.005,
        propEntries: <BiomePropEntry>[
          // Filler: expected yield 8 — rolled LAST despite being authored
          // first (scarcity order).
          BiomePropEntry(
            propId: 't1_prop_grass_probe',
            attemptsPerChunk: 8,
            spawnChance: 1,
            clusterMin: 1,
            clusterMax: 1,
            clusterRadius: 1,
          ),
          // Scarce: expected yield 2 — rolled first, so the cap can never
          // delete it behind ground cover.
          BiomePropEntry(
            propId: 't1_prop_vein_probe',
            attemptsPerChunk: 1,
            spawnChance: 1,
            clusterMin: 2,
            clusterMax: 2,
            clusterRadius: 1,
          ),
        ],
        actorEntries: const <BiomeActorEntry>[],
      );

  test('populates a loaded chunk: scarcity first, cap respected, occupancy '
      'registered', () {
    const chunk = GridPos(0, 0);
    materializeChunkTerrain(chunk);
    final spawned = <Prop>[];
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));

    locator<ProceduralSpawnSystem>()
        .initialize(worldSeed: 20260826, biome: fixtureBiome());
    locator<ChunkStreamingSystem>().chunkLoaded.emit(chunk);

    // Cap 5: the scarce vein cluster (2) landed whole, grass filled the rest.
    expect(spawned, hasLength(5));
    expect(spawned.where((p) => p.data.id == 't1_prop_vein_probe'), hasLength(2),
        reason: 'the scarce species must never be deleted by the filler');
    final grid = locator<GridManager>();
    for (final prop in spawned) {
      final anchor = grid.worldToGrid(prop.position);
      expect(identical(grid.getPropAt(anchor), prop), isTrue);
    }
  });

  test('unload releases everything; a recycled chunk re-derives the same '
      'scatter', () {
    const chunk = GridPos(2, -1);
    materializeChunkTerrain(chunk);
    final spawnedTiles = <GridPos>[];
    var despawns = 0;
    locator<Events>()
        .worldObjectSpawned
        .connect((p) => spawnedTiles
            .add(locator<GridManager>().worldToGrid((p as Prop).position)));
    locator<Events>().worldObjectDespawned.connect((_) => despawns++);

    locator<ProceduralSpawnSystem>()
        .initialize(worldSeed: 7, biome: fixtureBiome());
    final streaming = locator<ChunkStreamingSystem>();
    streaming.chunkLoaded.emit(chunk);
    final firstRoll = List<GridPos>.of(spawnedTiles);
    expect(firstRoll, isNotEmpty);

    streaming.chunkUnloadStarted.emit(chunk);
    expect(despawns, firstRoll.length);
    for (final tile in firstRoll) {
      expect(locator<GridManager>().getPropAt(tile), isNull,
          reason: 'unload must free every claim');
    }

    spawnedTiles.clear();
    streaming.chunkLoaded.emit(chunk);
    expect(spawnedTiles, firstRoll,
        reason: 'the roll is a pure function of (seed, chunk)');
  });

  test('a prop felled mid-chunk is forgotten, so unload frees nothing twice',
      () {
    // FP4.3a: a harvested prop hands its own tiles back and announces its own
    // despawn. What this system still owes is to stop LISTING it as live
    // content — a corpse left on the list has its tiles freed a second time
    // when the chunk recycles, long after the grid handed them to somebody
    // else. `freePropTiles` asserts on exactly that, so the double release is
    // a crash rather than a quiet corruption.
    const chunk = GridPos(3, 4);
    materializeChunkTerrain(chunk);
    final spawned = <Prop>[];
    var despawns = 0;
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));
    locator<Events>().worldObjectDespawned.connect((_) => despawns++);

    locator<ProceduralSpawnSystem>()
        .initialize(worldSeed: 20260826, biome: fixtureBiome());
    final streaming = locator<ChunkStreamingSystem>();
    streaming.chunkLoaded.emit(chunk);
    expect(spawned, isNotEmpty);

    final felled = spawned.first;
    final felledTile = locator<GridManager>().worldToGrid(felled.position);
    felled.health.takeDamage(felled.health.maximum);
    expect(despawns, 1, reason: 'the corpse left the world when it died');
    expect(locator<GridManager>().getPropAt(felledTile), isNull);

    // The rest of the chunk unloads normally, and the corpse is not released
    // a second time.
    streaming.chunkUnloadStarted.emit(chunk);
    expect(despawns, spawned.length,
        reason: 'every prop left exactly once — the dead one at its death, '
            'the living ones with their chunk');
  });

  test('spawnability: water, elevation and reserved tiles stay clear', () {
    const chunk = GridPos(0, 0);
    // Only ONE tile of the chunk is terrain; everything else is void.
    final grid = locator<GridManager>()
      ..registerGroundData(
        const GridPos(3, 3),
        GroundBuildableData(id: 't1_ground_buildable_terrain'),
      )
      ..registerGroundData(
        const GridPos(4, 3),
        GroundBuildableData(id: 't1_ground_buildable_terrain'),
      )
      ..registerElevationTile(const GridPos(4, 3), 1);

    final spawned = <Prop>[];
    locator<Events>().worldObjectSpawned.connect((p) => spawned.add(p as Prop));
    locator<ProceduralSpawnSystem>().initialize(
      worldSeed: 99,
      biome: fixtureBiome(maxProps: 24),
      reservedTiles: const <GridPos>[GridPos(3, 3)],
    );
    locator<ChunkStreamingSystem>().chunkLoaded.emit(chunk);

    // The one walkable tile is reserved and the elevated one is a wall:
    // a whole chunk of attempts lands nothing.
    expect(spawned, isEmpty);
    expect(grid.getPropAt(const GridPos(3, 3)), isNull);
    expect(grid.getPropAt(const GridPos(4, 3)), isNull);
  });
}
