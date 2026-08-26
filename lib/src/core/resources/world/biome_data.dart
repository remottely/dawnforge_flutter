import 'package:dawnforge/src/core/resources/json_reader.dart';
import 'package:dawnforge/src/core/resources/world/biome_actor_entry.dart';
import 'package:dawnforge/src/core/resources/world/biome_prop_entry.dart';

/// One biome's identity, terrain shape and population — the FP3/FP4 slice of
/// the Godot `BiomeData.cs` (islands mode, weather, audio and visuals arrive
/// with their systems). Emitted by pipeline step 11 from
/// `games/<game>/data/world/procedural/procedural_<biome>.md`.
///
/// The four densities are SHARES OF THE WORLD, never noise values: the
/// ProceduralWorldManager converts each share into a noise cut through its
/// own quantile table at boot. Writing cuts directly is what this replaced —
/// nobody could tell what fraction a hand-picked noise value produced.
///
/// The population half ([propEntries], [actorEntries], the per-chunk caps and
/// the richness field) is this track's authored replacement for the Godot
/// `island_spawns` table — same job, table-per-biome, but one-shot and
/// seed-pure per chunk (FP4.1).
final class BiomeData {
  BiomeData({
    required this.id,
    required this.tier,
    required this.terrainWaterShare,
    required this.terrainWallShare,
    required this.terrainWallHeight2Share,
    required this.terrainWallHeight3Share,
    required this.maxPropsPerChunk,
    required this.maxActorsPerChunk,
    required this.densityNoiseFrequency,
    required this.propEntries,
    required this.actorEntries,
  }) {
    _validate();
  }

  BiomeData.fromReader(JsonReader reader)
      : id = reader.requiredString('id'),
        tier = reader.requiredInt('tier'),
        terrainWaterShare = reader.requiredDouble('terrain_water_share'),
        terrainWallShare = reader.requiredDouble('terrain_wall_share'),
        terrainWallHeight2Share =
            reader.requiredDouble('terrain_wall_height2_share'),
        terrainWallHeight3Share =
            reader.requiredDouble('terrain_wall_height3_share'),
        maxPropsPerChunk = reader.requiredInt('max_props_per_chunk'),
        maxActorsPerChunk = reader.requiredInt('max_actors_per_chunk'),
        densityNoiseFrequency =
            reader.requiredDouble('density_noise_frequency'),
        propEntries = reader
            .requiredObjectList('prop_entries')
            .map(BiomePropEntry.fromJson)
            .toList(),
        actorEntries = reader
            .requiredObjectList('actor_entries')
            .map(BiomeActorEntry.fromJson)
            .toList() {
    _validate();
  }

  factory BiomeData.fromJson(Map<String, Object?> json) =>
      BiomeData.fromReader(JsonReader(json, 'BiomeData'));

  /// Rejects a density the cut derivation could not express. Every case is an
  /// authoring mistake in the pack — named here, never clamped into a world
  /// nobody asked for (rule 5). Step 11 repeats these at import time so the
  /// failure names the file; this is the boot-side twin.
  void _validate() {
    assert(tier >= 1, '[BiomeData($id)] tier $tier must be >= 1');
    assert(
      terrainWaterShare > 0 && terrainWaterShare < 1,
      '[BiomeData($id)] water share $terrainWaterShare outside (0, 1)',
    );
    assert(
      terrainWallShare > 0 && terrainWallShare < 1,
      '[BiomeData($id)] wall share $terrainWallShare outside (0, 1)',
    );
    assert(
      terrainWaterShare + terrainWallShare < 1,
      '[BiomeData($id)] water $terrainWaterShare + wall $terrainWallShare '
      'leaves no floor',
    );
    assert(
      terrainWallHeight2Share > 0 &&
          terrainWallHeight3Share > 0 &&
          terrainWallHeight2Share + terrainWallHeight3Share < 1,
      '[BiomeData($id)] wall height shares $terrainWallHeight2Share and '
      '$terrainWallHeight3Share must each be > 0 and sum to < 1, or a height '
      'would be unreachable',
    );
    assert(
      maxPropsPerChunk >= 0 && maxActorsPerChunk >= 0,
      '[BiomeData($id)] per-chunk caps must be >= 0',
    );
    assert(
      densityNoiseFrequency > 0,
      '[BiomeData($id)] density_noise_frequency $densityNoiseFrequency '
      'must be > 0',
    );
    assert(
      propEntries.isEmpty || maxPropsPerChunk >= 1,
      '[BiomeData($id)] prop_entries authored but max_props_per_chunk is 0 — '
      'nothing could ever spawn',
    );
    assert(
      actorEntries.isEmpty || maxActorsPerChunk >= 1,
      '[BiomeData($id)] actor_entries authored but max_actors_per_chunk is 0 '
      '— nothing could ever spawn',
    );
  }

  final String id;

  /// The tier this biome answers for — biomes map 1:1 to tiers (T1=Forest …),
  /// same convention as the Godot `TierResolver`.
  final int tier;

  /// Share of this biome's surface tiles the generator floods.
  final double terrainWaterShare;

  /// Share of this biome's surface tiles that become mountain, all heights
  /// together — the one number that gives a biome its silhouette.
  final double terrainWallShare;

  /// Fractions OF [terrainWallShare] raised to heights 2 and 3. The pyramid
  /// rule in `getHeightAt` erodes what these ask for, so the measured share is
  /// always the smaller number.
  final double terrainWallHeight2Share;
  final double terrainWallHeight3Share;

  /// Hard caps the population roll respects per chunk, whatever the tables
  /// would have produced — the knob that keeps a lucky chunk readable.
  final int maxPropsPerChunk;
  final int maxActorsPerChunk;

  /// Scale of the biome's richness field: how WIDE a rich district is,
  /// ~1/frequency tiles. How many species show the pattern is each prop
  /// entry's own `densityInfluence`.
  final double densityNoiseFrequency;

  /// The one-shot, seed-pure population tables (empty = barren, authored so).
  final List<BiomePropEntry> propEntries;
  final List<BiomeActorEntry> actorEntries;
}
