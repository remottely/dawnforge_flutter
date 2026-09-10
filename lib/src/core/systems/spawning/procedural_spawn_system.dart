import 'package:dawnforge/src/core/base/world_objects/props/prop.dart';
import 'package:dawnforge/src/core/base/world_objects/props/prop_crop.dart';
import 'package:dawnforge/src/core/factories/prop_factory.dart';
import 'package:dawnforge/src/core/registries/prop_registry.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_crop_data.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/enums.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';
import 'package:dawnforge/src/core/systems/eventing/events.dart';
import 'package:dawnforge/src/core/systems/world/chunk_streaming_system.dart';
import 'package:dawnforge/src/core/systems/world/grid_manager.dart';
import 'package:dawnforge/src/core/utils/noise/perlin_noise_2d.dart';
import 'package:dawnforge/src/core/utils/random/splitmix32.dart';

/// Populates streamed chunks with the biome's authored tables — port of
/// `procedural_spawn_system.gd` (logic slice: prop scatter only; actor packs
/// arrive with their AI, rehydration with the save system, and the
/// time-sliced command queue when the debug overlay shows a spawn spike).
///
/// One-shot and seed-pure per chunk: the roll is a pure function of
/// (world seed, chunk), so a chunk that unloads and returns re-derives the
/// identical scatter. Until persistence (FP6) memoizes player work, that
/// deliberately includes harvested props growing back on recycle — the
/// accepted FP4 semantics.
final class ProceduralSpawnSystem {
  /// Same salt as the Godot system, so the richness field is its own stream
  /// beside the terrain noise.
  static const int _densitySeedSalt = 0x51F0A317;

  /// How many placements a cluster member may try before being skipped.
  static const int _memberPlacementAttempts = 4;

  bool _isInitialized = false;
  late BiomeData _biome;
  late PerlinNoise2D _densityNoise;
  late int _worldSeed;

  /// Roll order: scarcest species first. A full budget then clips only the
  /// filler — rolled after grass, a copper vein is deleted by ground cover
  /// that got there first, and the chunk reads as having no ore rather than
  /// as having a lot of grass (measured at 0.1711.4 in the Godot repo:
  /// 14.8% of chunks lost a scarce species that way).
  late List<int> _propRollOrder;

  /// Tiles the world side asked to keep clear (the player's spawn patch) —
  /// the interim stand-in for the actor-overlap clause that arrives with
  /// ActorOccupancyHelper (FP4.3a).
  final Set<GridPos> _reservedTiles = <GridPos>{};

  /// Live content per chunk, for release on unload.
  ///
  /// Since FP4.3b this is not only what the SCATTER produced: a prop the
  /// player builds is resident in a chunk too, and is adopted here
  /// ([adoptPlacedProp]) so it leaves the world the same way everything else
  /// does.
  final Map<GridPos, List<(GridPos, Prop)>> _chunkContent =
      <GridPos, List<(GridPos, Prop)>>{};

  /// Which chunks have had their scatter rolled.
  ///
  /// Separate from [_chunkContent] because the two facts stopped being the
  /// same one when placement arrived: a chunk can hold content before it is
  /// populated (a prop built on a tile whose column has loaded, in a chunk
  /// whose last column has not), and "is there an entry in the map" would
  /// then read as "already scattered" and skip the roll.
  final Set<GridPos> _populatedChunks = <GridPos>{};

  void Function()? _disconnectLoaded;
  void Function()? _disconnectUnload;
  void Function()? _disconnectDied;

  /// Wires the population to the streaming. Call BEFORE
  /// `ChunkStreamingSystem.initialize` so the boot window's own chunkLoaded
  /// signals are heard. [reservedTiles] stay prop-free (the spawn patch).
  void initialize({
    required int worldSeed,
    required BiomeData biome,
    Iterable<GridPos> reservedTiles = const <GridPos>[],
  }) {
    assert(!_isInitialized, '[ProceduralSpawnSystem] initialized twice');
    _isInitialized = true;
    _worldSeed = worldSeed;
    _biome = biome;
    _densityNoise = PerlinNoise2D(worldSeed ^ _densitySeedSalt);
    _reservedTiles.addAll(reservedTiles);

    final order = List<int>.generate(_biome.propEntries.length, (i) => i)
      ..sort(
        (a, b) => _expectedYield(_biome.propEntries[a])
            .compareTo(_expectedYield(_biome.propEntries[b])),
      );
    _propRollOrder = order;

    final streaming = locator<ChunkStreamingSystem>();
    _disconnectLoaded = streaming.chunkLoaded.connect(_onChunkLoaded);
    _disconnectUnload =
        streaming.chunkUnloadStarted.connect(_onChunkUnloadStarted);
    _disconnectDied =
        locator<Events>().worldObjectDied.connect(_onWorldObjectDied);
  }

  /// Teardown path (the one legitimate unregistration, rule 28).
  void dispose() {
    _disconnectLoaded?.call();
    _disconnectUnload?.call();
    _disconnectDied?.call();
  }

  /// Props this entry produces per chunk on average, ignoring the cap —
  /// exactly how much of the shared budget it can take from everyone else.
  static double _expectedYield(BiomePropEntry entry) =>
      entry.attemptsPerChunk *
      entry.spawnChance *
      (entry.clusterMin + entry.clusterMax) *
      0.5;

  void _onChunkLoaded(GridPos chunk) {
    assert(
      !_populatedChunks.contains(chunk),
      '[ProceduralSpawnSystem] chunk $chunk populated twice',
    );
    _populatedChunks.add(chunk);
    // Added to whatever is already resident rather than replacing it: a prop
    // the player built here while the chunk was still streaming is content
    // this list owes an unload to, and overwriting would strand it.
    final content = _chunkContent.putIfAbsent(chunk, () => <(GridPos, Prop)>[]);
    for (final (tile, propId, stage) in _rollChunkPopulation(chunk)) {
      final prop = PropFactory.create(
        propId,
        locator<GridManager>().gridToWorld(tile),
      );
      if (stage != null) {
        // The command carries a stage exactly when the registry said the
        // prop is a crop, so the host the factory built IS a crop.
        (prop as PropCrop).setGrowthStage(stage);
      }
      locator<GridManager>().occupyPropTiles(tile, prop);
      content.add((tile, prop));
      locator<Events>().worldObjectSpawned.emit(prop);
    }
  }

  /// Takes responsibility for a prop somebody else put in the world — the
  /// player, through `WorldPlacementHelper.placeProp` (FP4.3b).
  ///
  /// The scatter is one of two ways a prop comes to exist now, but there is
  /// still only one way for a prop to LEAVE: its chunk unloads and hands the
  /// tiles back. A built prop that never joined this list would hold its
  /// ground after the chunk was gone and keep being drawn and ticked at a
  /// place the player has left.
  void adoptPlacedProp(GridPos anchor, Prop prop) {
    _chunkContent
        .putIfAbsent(
          ChunkStreamingSystem.chunkOf(anchor),
          () => <(GridPos, Prop)>[],
        )
        .add((anchor, prop));
  }

  void _onChunkUnloadStarted(GridPos chunk) {
    _populatedChunks.remove(chunk);
    final content = _chunkContent.remove(chunk);
    if (content == null) return; // a chunk beyond where population began
    for (final (tile, prop) in content) {
      locator<GridManager>().freePropTiles(tile, prop);
      locator<Events>().worldObjectDespawned.emit(prop);
    }
  }

  /// Forgets a prop that died (FP4.3a). Bookkeeping ONLY: the prop hands its
  /// own tiles back and announces its own despawn, because a prop can die
  /// wherever it was placed — this system placed most of them, but not the
  /// ones a player will build (FP4.3b). What this system still owes is to
  /// stop listing a corpse as live content, or the chunk's unload would free
  /// tiles somebody else has since been given.
  ///
  /// An actor's death arrives here too and is not this system's business —
  /// a legitimate branch, not a fallback.
  void _onWorldObjectDied(Object payload) {
    if (payload is! Prop) return;
    for (final content in _chunkContent.values) {
      final index = content.indexWhere((entry) => identical(entry.$2, payload));
      if (index < 0) continue;
      content.removeAt(index);
      return;
    }
  }

  /// Rolls the chunk's prop content, deterministically from the world seed +
  /// chunk coords. Runs on chunkLoaded — terrain is materialized, so anchors
  /// land only on tiles that are actually spawnable.
  ///
  /// A CROP surfaces at a stage — anywhere between PLANTED and its
  /// `peak_stage`, rolled here from the same stream — so a forest is not all
  /// saplings and not all giants (the spec's `_make_prop_command`). The roll
  /// happens per command, after the anchor or member tile is known, which is
  /// the spec's order too; a stage-less prop takes nothing from the stream.
  List<(GridPos, String, CropStage?)> _rollChunkPopulation(GridPos chunk) {
    const chunkSize = GameConstants.proceduralChunkSize;
    final rng = Splitmix32(Splitmix32.combine(_worldSeed, chunk.x, chunk.y));
    final center = GridPos(
      chunk.x * chunkSize + chunkSize ~/ 2,
      chunk.y * chunkSize + chunkSize ~/ 2,
    );
    final richness = _richnessAt(center);

    final commands = <(GridPos, String, CropStage?)>[];
    final taken = <GridPos>{};
    var propBudget = _biome.maxPropsPerChunk;

    for (final entryIndex in _propRollOrder) {
      if (propBudget <= 0) break;
      final entry = _biome.propEntries[entryIndex];
      final footprint = locator<PropRegistry>().getProp(entry.propId);
      final peakStage =
          footprint is PropCropData ? footprint.peakStage : null;
      // Each species decides how much of the richness field it feels: ore
      // rides it (rich districts worth prospecting), vegetation ignores it.
      final density = 1.0 -
          entry.densityInfluence +
          2.0 * entry.densityInfluence * richness;
      for (var attempt = 0; attempt < entry.attemptsPerChunk; attempt++) {
        if (propBudget <= 0) break;
        if (rng.nextDouble() >
            (entry.spawnChance * density).clamp(0.0, 1.0)) {
          continue;
        }
        final anchor = _randomTileInChunk(chunk, rng);
        if (taken.contains(anchor) ||
            !_isFootprintSpawnable(
              anchor,
              footprint.gridWidth,
              footprint.gridHeight,
            )) {
          continue;
        }
        final clusterSize =
            rng.nextIntInRange(entry.clusterMin, entry.clusterMax);
        commands.add((anchor, entry.propId, _rollStage(peakStage, rng)));
        taken.add(anchor);
        propBudget--;
        for (var member = 0; member < clusterSize - 1; member++) {
          if (propBudget <= 0) break;
          final memberTile = _rollMemberTile(
            anchor,
            entry.clusterRadius,
            chunk,
            taken,
            rng,
            footprint.gridWidth,
            footprint.gridHeight,
          );
          if (memberTile == anchor) continue; // no free spot found
          commands.add((memberTile, entry.propId, _rollStage(peakStage, rng)));
          taken.add(memberTile);
          propBudget--;
        }
      }
    }
    // Actor packs: parsed and budgeted, but spawning arrives with their AI —
    // the roll stream is unaffected because props roll first.
    return commands;
  }

  /// The stage a wild crop surfaces at, or null for a prop without a life.
  static CropStage? _rollStage(CropStage? peakStage, Splitmix32 rng) {
    if (peakStage == null) return null;
    return CropStage.values[
        rng.nextIntInRange(CropStage.planted.index, peakStage.index)];
  }

  /// The biome's richness field at the chunk center, in [0, 1] — sampled
  /// once per chunk: a district is a region, and a field that changed inside
  /// a chunk would be a texture, not a district.
  double _richnessAt(GridPos centerTile) =>
      (_densityNoise.at(
            centerTile.x * _biome.densityNoiseFrequency,
            centerTile.y * _biome.densityNoiseFrequency,
          ) +
          1.0) *
      0.5;

  static GridPos _randomTileInChunk(GridPos chunk, Splitmix32 rng) {
    const chunkSize = GameConstants.proceduralChunkSize;
    return GridPos(
      chunk.x * chunkSize + rng.nextIntInRange(0, chunkSize - 1),
      chunk.y * chunkSize + rng.nextIntInRange(0, chunkSize - 1),
    );
  }

  /// Rolls a free spawnable tile near the anchor, clamped inside the chunk
  /// so clusters never depend on neighbor chunks being materialized. Returns
  /// the anchor itself when every attempt fails (callers skip that member).
  GridPos _rollMemberTile(
    GridPos anchor,
    int radius,
    GridPos chunk,
    Set<GridPos> taken,
    Splitmix32 rng,
    int width,
    int height,
  ) {
    const chunkSize = GameConstants.proceduralChunkSize;
    final minX = chunk.x * chunkSize;
    final minY = chunk.y * chunkSize;
    for (var attempt = 0; attempt < _memberPlacementAttempts; attempt++) {
      final tile = GridPos(
        (anchor.x + rng.nextIntInRange(-radius, radius))
            .clamp(minX, minX + chunkSize - 1),
        (anchor.y + rng.nextIntInRange(-radius, radius))
            .clamp(minY, minY + chunkSize - 1),
      );
      if (tile == anchor || taken.contains(tile)) continue;
      if (!_isFootprintSpawnable(tile, width, height)) continue;
      return tile;
    }
    return anchor;
  }

  /// Whether a prop of [width]×[height] may stand at [anchor] — every tile
  /// of the footprint answers, because the anchor being free says nothing
  /// about the tile next to it (the spec's 2×1 charwood-on-a-wall lesson).
  bool _isFootprintSpawnable(GridPos anchor, int width, int height) {
    final grid = locator<GridManager>();
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        final tile = GridPos(anchor.x + x, anchor.y + y);
        // Walkable covers missing/impassable ground AND colliding props;
        // elevation keeps plateaus clear; a ghost prop (no collision) still
        // claims occupancy; reserved tiles are the spawn patch.
        if (!grid.isTileWalkable(tile) ||
            grid.hasElevationAt(tile) ||
            grid.getPropAt(tile) != null ||
            _reservedTiles.contains(tile)) {
          return false;
        }
      }
    }
    return true;
  }
}
