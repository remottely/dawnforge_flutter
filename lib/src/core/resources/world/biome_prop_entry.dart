import 'package:dawnforge/src/core/resources/json_reader.dart';

/// One line of a biome's prop population table — authored in
/// `procedural_<biome>.md` (`prop_entries:`), emitted by pipeline step 11.
///
/// The table is one-shot and seed-pure: each chunk rolls it deterministically
/// from the world seed when it streams in, so the same chunk always answers
/// with the same scatter. Anchors are rolled [attemptsPerChunk] times at
/// [spawnChance] odds; a successful anchor grows a cluster of
/// [clusterMin]..[clusterMax] members within [clusterRadius] tiles.
final class BiomePropEntry {
  BiomePropEntry({
    required this.propId,
    required this.attemptsPerChunk,
    required this.spawnChance,
    required this.clusterMin,
    required this.clusterMax,
    required this.clusterRadius,
    this.densityInfluence = 0.0,
  }) {
    _validate();
  }

  BiomePropEntry.fromReader(JsonReader reader)
      : propId = reader.requiredString('prop_id'),
        attemptsPerChunk = reader.requiredInt('attempts_per_chunk'),
        spawnChance = reader.requiredDouble('spawn_chance'),
        clusterMin = reader.requiredInt('cluster_min'),
        clusterMax = reader.requiredInt('cluster_max'),
        clusterRadius = reader.requiredInt('cluster_radius'),
        densityInfluence = reader.doubleOr('density_influence', 0) {
    _validate();
  }

  factory BiomePropEntry.fromJson(Map<String, Object?> json) =>
      BiomePropEntry.fromReader(JsonReader(json, 'BiomePropEntry'));

  /// Twin of the step-11 entry validation: the pipeline names the file, this
  /// names the boot — both refuse the same shapes.
  void _validate() {
    assert(propId.isNotEmpty, '[BiomePropEntry] prop_id required');
    assert(
      attemptsPerChunk >= 1,
      '[BiomePropEntry($propId)] attempts_per_chunk $attemptsPerChunk < 1',
    );
    assert(
      spawnChance > 0 && spawnChance <= 1,
      '[BiomePropEntry($propId)] spawn_chance $spawnChance outside (0, 1]',
    );
    assert(
      clusterMin >= 1 && clusterMin <= clusterMax,
      '[BiomePropEntry($propId)] cluster $clusterMin..$clusterMax invalid',
    );
    assert(
      clusterRadius >= 1,
      '[BiomePropEntry($propId)] cluster_radius $clusterRadius < 1',
    );
    assert(
      densityInfluence >= 0 && densityInfluence <= 1,
      '[BiomePropEntry($propId)] density_influence $densityInfluence '
      'outside [0, 1]',
    );
  }

  final String propId;
  final int attemptsPerChunk;

  /// Odds per anchor attempt (0 exclusive to 1 inclusive).
  final double spawnChance;
  final int clusterMin;
  final int clusterMax;

  /// Tiles around the anchor a cluster member may land on.
  final int clusterRadius;

  /// How much the biome's richness field scales this entry's odds: 0 (the
  /// declared default) is an even spread; 1 rides the field fully — rich
  /// pockets and barren stretches. Only ore opts in, by design.
  final double densityInfluence;
}
