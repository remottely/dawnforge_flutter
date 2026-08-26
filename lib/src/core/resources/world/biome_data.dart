import 'package:dawnforge/src/core/resources/json_reader.dart';

/// One biome's identity and terrain shape — the FP3 slice of the Godot
/// `BiomeData.cs` (islands mode, weather, audio and visuals arrive with their
/// systems). Emitted by pipeline step 11 from
/// `games/<game>/data/world/procedural/procedural_<biome>.md`.
///
/// The four densities are SHARES OF THE WORLD, never noise values: the
/// ProceduralWorldManager converts each share into a noise cut through its
/// own quantile table at boot. Writing cuts directly is what this replaced —
/// nobody could tell what fraction a hand-picked noise value produced.
final class BiomeData {
  BiomeData({
    required this.id,
    required this.tier,
    required this.terrainWaterShare,
    required this.terrainWallShare,
    required this.terrainWallHeight2Share,
    required this.terrainWallHeight3Share,
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
            reader.requiredDouble('terrain_wall_height3_share') {
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
}
