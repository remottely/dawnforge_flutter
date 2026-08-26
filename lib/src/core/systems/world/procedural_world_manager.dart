import 'dart:math' as math;

import 'package:dawnforge/src/core/registries/biome_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/utils/noise/fbm_noise_2d.dart';

/// Deterministic single source of truth for the procedural world — the port
/// of `ProceduralWorldManager.cs` (Godot keeps it under `systems/managers/`;
/// this tree groups world systems under `systems/world/` next to GridManager).
///
/// Samples one grayscale FBM noise field and maps it to the 5 surface levels:
/// 0 = water (darkest), 1 = terrain, 2..4 = mountain heights 1..3. The cut
/// points are quantiles of the field itself, derived from the biome's
/// authored DENSITY shares — asking for 0.15 wall yields ~15% wall.
///
/// Every query is a pure function of (seed, tile): chunks regenerate
/// identically in any order — the property the ChunkStreamingSystem is built
/// on.
///
/// SCOPE (FP3.4, first slice): SURFACE layer, single biome. The tier field
/// (domain-warped Voronoi cells, per-cell tier rolls, cross-biome threshold
/// blending) arrives with t2+ content (FP7); this public API will not change
/// — the tier machinery slots in beneath [getTierAtTile].
///
/// Registered at boot (rule 28); [initialize] runs when a world starts,
/// after the content registries are loaded.
final class ProceduralWorldManager {
  /// Surface level codes produced by the grayscale height noise.
  static const int levelWater = 0;
  static const int levelTerrain = 1;

  /// Unit: chunk rings — how far `findSpawnTile` scans before declaring the
  /// seed unusable.
  static const int _spawnSearchMaxRadius = 256;

  bool _isInitialized = false;
  late FbmNoise2D _heightNoise;
  late List<double> _noiseQuantiles;

  /// The single authored biome and its four ascending cuts (T1 scope — see
  /// the class doc).
  late BiomeData _biome;
  late List<double> _cuts;
  int _worldSeed = 0;

  /// The seed a brand-new world is built from: `requested` when the player
  /// named one, the [EngineConstants.proceduralWorldSeed] debug pin when it
  /// is non-zero, a fresh roll otherwise.
  static int resolveNewWorldSeed(int requested) {
    if (requested != 0) return requested;
    if (EngineConstants.proceduralWorldSeed != 0) {
      return EngineConstants.proceduralWorldSeed;
    }
    return math.Random().nextInt(1 << 31);
  }

  /// Loads the biome configuration and applies the first seed. Called once
  /// per world, after the content registries are loaded.
  void initialize(int seed) {
    assert(!_isInitialized, '[ProceduralWorldManager] already initialized');
    final biomes = locator<BiomeRegistry>();
    // T1 scope: exactly one biome. A second biome REQUIRES the tier field
    // (Voronoi cells + tier rolls + threshold blending) — crash loudly at the
    // port obligation instead of silently generating a one-biome world over
    // multi-biome content.
    if (biomes.count != 1) {
      throw StateError(
        '[ProceduralWorldManager] ${biomes.count} biomes loaded — the FP3.4 '
        'slice generates a single-biome world; port the tier field (FP7) '
        'before shipping more biomes',
      );
    }
    _biome = biomes.getBiome(biomes.ids.single);
    _isInitialized = true;
    setWorldSeed(seed);
  }

  /// Rebuilds the noise field, its quantile table and every cut for [seed].
  /// Public because a loaded save overrides the boot seed (FP6) — revisited
  /// areas must regenerate identically.
  void setWorldSeed(int seed) {
    assert(_isInitialized, '[ProceduralWorldManager] setWorldSeed before initialize');
    _worldSeed = seed;
    _heightNoise = FbmNoise2D(
      seed: seed,
      frequency: EngineConstants.proceduralNoiseFrequency,
      octaves: 4,
    );
    // A cut is a quantile of the seeded field, so the table and every cut
    // derived from it belong to this seed and are rebuilt with it.
    _noiseQuantiles = _buildQuantileTable();
    _cuts = _deriveCuts(_biome);
  }

  int get worldSeed {
    assert(_isInitialized, '[ProceduralWorldManager] read before initialize');
    return _worldSeed;
  }

  // ============================================
  // DENSITY → CUTS
  // ============================================

  /// The field sampled on a grid and sorted ascending: index i holds the
  /// value that i/(n-1) of the world falls below — the inverse of the
  /// question a density share asks.
  List<double> _buildQuantileTable() {
    const side = EngineConstants.proceduralDensitySampleSide;
    const stride = EngineConstants.proceduralDensitySampleStride;
    final values = List<double>.filled(side * side, 0);
    var i = 0;
    for (var x = 0; x < side; x++) {
      for (var y = 0; y < side; y++) {
        values[i++] =
            (_heightNoise.at((x * stride).toDouble(), (y * stride).toDouble()) +
                    1) *
                0.5;
      }
    }
    values.sort();
    return values;
  }

  /// Noise value that [share] of the world falls below.
  double _cutForShare(double share) {
    final index = (share * (_noiseQuantiles.length - 1))
        .toInt()
        .clamp(0, _noiseQuantiles.length - 1);
    return _noiseQuantiles[index];
  }

  /// The biome's four ascending cuts, derived from its density shares. Read
  /// from both ends: `water` grows the bottom band, `wall` the top one, floor
  /// is what remains between them; inside the wall band the two `*OfWall`
  /// fractions carve heights 2 and 3 from the top down.
  ///
  /// Validated to exactly the contract the level scan needs — strictly
  /// ascending, strictly inside (0, 1). A tie means two shares landed in the
  /// same quantile bucket: an authoring problem, named, never rounded away.
  List<double> _deriveCuts(BiomeData biome) {
    final wall = biome.terrainWallShare;
    final cuts = <double>[
      _cutForShare(biome.terrainWaterShare),
      _cutForShare(1 - wall),
      _cutForShare(1 -
          wall *
              (biome.terrainWallHeight2Share + biome.terrainWallHeight3Share)),
      _cutForShare(1 - wall * biome.terrainWallHeight3Share),
    ];
    assert(
      cuts.length == EngineConstants.proceduralTerrainCutCount,
      '[ProceduralWorldManager] cut construction drifted from the level count',
    );
    for (var i = 0; i < cuts.length; i++) {
      if (cuts[i] <= 0 || cuts[i] >= 1) {
        throw StateError(
          '[ProceduralWorldManager] ${biome.id}: derived cut[$i] = ${cuts[i]} '
          'is outside (0, 1)',
        );
      }
      if (i > 0 && cuts[i] <= cuts[i - 1]) {
        throw StateError(
          '[ProceduralWorldManager] ${biome.id}: derived cuts are not '
          'strictly ascending (${cuts[i - 1]} then ${cuts[i]}) — two density '
          'shares fell in the same quantile bucket',
        );
      }
    }
    return cuts;
  }

  // ============================================
  // NOISE SAMPLING
  // ============================================

  /// Raw level (0..4) at a tile: how many ascending cuts the normalized
  /// grayscale value passes. 0=water, 1=floor, 2..4=wall.
  int getLevelAt(GridPos tile) {
    assert(_isInitialized, '[ProceduralWorldManager] query before initialize');
    final value01 =
        (_heightNoise.at(tile.x.toDouble(), tile.y.toDouble()) + 1) * 0.5;
    var level = 0;
    while (level < _cuts.length && value01 >= _cuts[level]) {
      level++;
    }
    return level;
  }

  /// Effective mountain elevation (0..[EngineConstants.mountainMaxHeight])
  /// after enforcing the 8-neighbor pyramid rules: water within Chebyshev
  /// distance d caps the height at d-1 (H=1 needs all 8 neighbors on passable
  /// ground), and any land neighbor caps it at its own raw height + d. The
  /// scan window is local (±the cap) and deterministic, so adjacent chunks
  /// always agree on their shared border tiles.
  int getHeightAt(GridPos tile) {
    final level = getLevelAt(tile);
    if (level <= levelTerrain) return 0;

    const maxHeight = EngineConstants.mountainMaxHeight;
    var height = math.min(level - 1, maxHeight);
    for (var dx = -maxHeight; dx <= maxHeight && height > 0; dx++) {
      for (var dy = -maxHeight; dy <= maxHeight && height > 0; dy++) {
        if (dx == 0 && dy == 0) continue;
        final d = math.max(dx.abs(), dy.abs());
        final neighborLevel = getLevelAt(GridPos(tile.x + dx, tile.y + dy));
        final cap = neighborLevel == levelWater
            ? d - 1
            : math.min(neighborLevel - 1, maxHeight) + d;
        if (cap < height) height = cap;
      }
    }
    return math.max(height, 0);
  }

  // ============================================
  // TIER / TERRAIN CONTENT
  // ============================================

  /// Tier at a tile. T1 scope: the single biome answers everywhere — the
  /// Voronoi tier field slots in beneath this exact signature (FP7).
  int getTierAtTile(GridPos tile) {
    assert(_isInitialized, '[ProceduralWorldManager] query before initialize');
    return _biome.tier;
  }

  /// GroundRegistry id generated at a tile: the tier's water for level 0 and
  /// the tier's terrain for every land level. Walls sit ON one of these and
  /// are expressed through the elevation map instead (see [getHeightAt]) —
  /// which is why there is no ground id for them.
  String getGroundIdAt(GridPos tile) => isGeneratedWaterAt(tile)
      ? getEmptyGroundIdAt(tile, isWater: true)
      : 't${getTierAtTile(tile)}_ground_buildable_terrain';

  /// True when the generator puts water at this tile — answers for tiles
  /// outside any streaming window too, without materializing anything.
  bool isGeneratedWaterAt(GridPos tile) => getLevelAt(tile) == levelWater;

  /// GroundRegistry id of the empty tile at this tile's tier — what a
  /// destroyed ground leaves behind: water when the hole reaches the ocean,
  /// cliff when land encloses it (the flood that decides arrives with FP4).
  String getEmptyGroundIdAt(GridPos tile, {required bool isWater}) {
    final tier = getTierAtTile(tile);
    return isWater ? 't${tier}_ground_empty_water' : 't${tier}_ground_empty_cliff';
  }

  // ============================================
  // SPAWN SEARCH
  // ============================================

  /// First CHUNK-CENTER tile (ring scan over chunk coordinates from the
  /// origin, deterministic) whose full 3x3 neighborhood is flat terrain —
  /// the player boots in the middle of the streaming window's center chunk
  /// with a full chunk of margin in every direction.
  GridPos findSpawnTile() {
    assert(_isInitialized, '[ProceduralWorldManager] query before initialize');
    const chunkSize = GameConstants.proceduralChunkSize;
    const centerOffset = chunkSize ~/ 2;

    for (var radius = 0; radius <= _spawnSearchMaxRadius; radius++) {
      for (var x = -radius; x <= radius; x++) {
        for (var y = -radius; y <= radius; y++) {
          if (x.abs() != radius && y.abs() != radius) continue;
          final candidate = GridPos(
            x * chunkSize + centerOffset,
            y * chunkSize + centerOffset,
          );
          if (_isSafeSpawnArea(candidate)) return candidate;
        }
      }
    }
    throw StateError(
      '[ProceduralWorldManager] no 3x3 flat-terrain spawn area on any chunk '
      'center within $_spawnSearchMaxRadius chunks of the origin — adjust '
      'the biome densities or the world seed',
    );
  }

  bool _isSafeSpawnArea(GridPos center) {
    for (var dx = -1; dx <= 1; dx++) {
      for (var dy = -1; dy <= 1; dy++) {
        if (getLevelAt(GridPos(center.x + dx, center.y + dy)) != levelTerrain) {
          return false;
        }
      }
    }
    return true;
  }
}
