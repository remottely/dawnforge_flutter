import 'dart:convert';
import 'dart:io';

import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/registries/ground_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_actor_entry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/content_paths.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/data/almanac_loader.dart';
import 'package:dawnforge/src/core/systems/world/procedural_world_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// The generator is the ChunkStreamingSystem's foundation: every query must be
/// a pure function of (seed, tile) so chunks regenerate identically in any
/// order — that property, the density contract and the pyramid rule are what
/// these tests pin.
void main() {
  setUp(registerCoreSystems);
  tearDown(resetCoreSystems);

  /// The forest's authored densities (procedural_forest.md), hand-registered
  /// so unit tests need no file I/O.
  void registerForestBiome() {
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
  }

  ProceduralWorldManager bootedManager({int seed = 1234}) {
    registerForestBiome();
    return locator<ProceduralWorldManager>()..initialize(seed);
  }

  test('a query before initialize is a programming error', () {
    expect(
      () => locator<ProceduralWorldManager>().getLevelAt(const GridPos(0, 0)),
      throwsA(isA<AssertionError>()),
    );
  });

  test('the T1 slice demands exactly one biome — more is the FP7 port cue',
      () {
    // Zero biomes: nothing to generate from.
    expect(
      () => locator<ProceduralWorldManager>().initialize(1),
      throwsStateError,
    );
    // Two biomes: requires the tier field this slice deliberately lacks.
    registerForestBiome();
    locator<BiomeRegistry>().register(
      'biome_swamp_data',
      BiomeData(
        id: 'biome_swamp_data',
        tier: 2,
        terrainWaterShare: 0.3,
        terrainWallShare: 0.1,
        terrainWallHeight2Share: 0.2,
        terrainWallHeight3Share: 0.1,
        maxPropsPerChunk: 0,
        maxActorsPerChunk: 0,
        densityNoiseFrequency: 0.005,
        propEntries: const <BiomePropEntry>[],
        actorEntries: const <BiomeActorEntry>[],
      ),
    );
    expect(
      () => locator<ProceduralWorldManager>().initialize(1),
      throwsStateError,
    );
  });

  test('same seed regenerates the identical world, in any order', () {
    final manager = bootedManager(seed: 777);
    final first = <String>[
      for (var y = -10; y < 10; y++)
        for (var x = -10; x < 10; x++)
          manager.getGroundIdAt(GridPos(x, y)),
    ];
    // Re-seed away and back — the save-load path (FP6) does exactly this.
    manager
      ..setWorldSeed(999)
      ..setWorldSeed(777);
    final second = <String>[
      for (var y = -10; y < 10; y++)
        for (var x = -10; x < 10; x++)
          manager.getGroundIdAt(GridPos(x, y)),
    ];
    expect(second, first);
  });

  test('a different seed moves the coastlines', () {
    final manager = bootedManager(seed: 1);
    final before = <bool>[
      for (var i = 0; i < 400; i++)
        manager.isGeneratedWaterAt(GridPos(i % 20 * 9, i ~/ 20 * 9)),
    ];
    manager.setWorldSeed(2);
    final after = <bool>[
      for (var i = 0; i < 400; i++)
        manager.isGeneratedWaterAt(GridPos(i % 20 * 9, i ~/ 20 * 9)),
    ];
    expect(after, isNot(before));
  });

  test('authored densities are honored — shares of the world, not noise values',
      () {
    final manager = bootedManager(seed: 4242);
    var water = 0;
    var wall = 0;
    const side = 128;
    for (var x = 0; x < side; x++) {
      for (var y = 0; y < side; y++) {
        final level = manager.getLevelAt(GridPos(x - side ~/ 2, y - side ~/ 2));
        if (level == ProceduralWorldManager.levelWater) water++;
        if (level > ProceduralWorldManager.levelTerrain) wall++;
      }
    }
    const total = side * side;
    // Authored: water 0.08, wall 0.15. One window of a fractal field wanders
    // around the global share, so the bands are wide — what they must refute
    // is the old failure mode (hand-picked cuts drifting to 0.5% or 35%).
    expect(water / total, inExclusiveRange(0.02, 0.20));
    expect(wall / total, inExclusiveRange(0.05, 0.30));
  });

  test('pyramid rule: neighbors step by one, and water keeps its distance',
      () {
    final manager = bootedManager(seed: 31415);
    const side = 40;
    final heights = <GridPos, int>{
      for (var x = 0; x < side; x++)
        for (var y = 0; y < side; y++)
          GridPos(x, y): manager.getHeightAt(GridPos(x, y)),
    };
    heights.forEach((tile, height) {
      // Adjacent tiles never differ by more than one height step.
      for (final neighbor in [
        GridPos(tile.x + 1, tile.y),
        GridPos(tile.x, tile.y + 1),
        GridPos(tile.x + 1, tile.y + 1),
      ]) {
        final other = heights[neighbor];
        if (other != null) {
          expect((height - other).abs(), lessThanOrEqualTo(1),
              reason: 'cliff wall between $tile (h$height) and '
                  '$neighbor (h$other)');
        }
      }
      // A height-H wall has no generated water within Chebyshev distance H —
      // walls only; a flat tile (h0) may perfectly well be water itself.
      if (height == 0) return;
      for (var dx = -height; dx <= height; dx++) {
        for (var dy = -height; dy <= height; dy++) {
          expect(
            manager.isGeneratedWaterAt(GridPos(tile.x + dx, tile.y + dy)),
            isFalse,
            reason: 'water at distance ${dx.abs() > dy.abs() ? dx.abs() : dy.abs()} '
                'from $tile (h$height)',
          );
        }
      }
    });
    // The rule must erode SOMETHING somewhere, or the scan is dead code —
    // any wall at all proves levels above terrain exist in this window.
    expect(heights.values.any((h) => h > 0), isTrue);
  });

  test('findSpawnTile lands on a chunk center with a flat 3x3', () {
    final manager = bootedManager(seed: 2026);
    final spawn = manager.findSpawnTile();
    const chunkSize = GameConstants.proceduralChunkSize;
    const center = chunkSize ~/ 2;
    expect((spawn.x - center) % chunkSize, 0);
    expect((spawn.y - center) % chunkSize, 0);
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        expect(
          manager.getLevelAt(GridPos(spawn.x + dx, spawn.y + dy)),
          ProceduralWorldManager.levelTerrain,
        );
      }
    }
  });

  test('every generated ground id resolves in the real content (FP3.4 seam)',
      () {
    // Registries boot from the REAL pipeline output — the generator and the
    // content commit must agree on ids, or streaming crashes at first chunk.
    final almanacDir =
        Directory(ContentPaths.almanacRoot(GameConstants.gameName));
    Map<String, Object?> readAlmanac(String relativePath) =>
        jsonDecode(File('${almanacDir.path}/$relativePath').readAsStringSync())!
            as Map<String, Object?>;
    final biomesDir =
        Directory(ContentPaths.worldBiomesRoot(GameConstants.gameName));
    Map<String, Object?> readBiome(String relativePath) =>
        jsonDecode(File('${biomesDir.path}/$relativePath').readAsStringSync())!
            as Map<String, Object?>;
    const AlmanacLoader()
      ..loadFromManifest(readAlmanac('manifest.json'), readAlmanac)
      ..loadFromManifest(readBiome('manifest.json'), readBiome);

    final manager = locator<ProceduralWorldManager>()..initialize(90210);
    final grounds = locator<GroundRegistry>();
    for (var x = -24; x < 24; x += 3) {
      for (var y = -24; y < 24; y += 3) {
        final id = manager.getGroundIdAt(GridPos(x, y));
        expect(grounds.has(id), isTrue,
            reason: 'generator emitted "$id" but the pack has no such ground');
      }
    }
  });
}
