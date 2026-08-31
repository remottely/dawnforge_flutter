import 'package:dawnforge/src/core/resources/json_reader.dart';

/// One line of a biome's actor population table — authored in
/// `procedural_<biome>.md` (`actor_entries:`), emitted by pipeline step 11.
///
/// Same one-shot, seed-pure contract as `BiomePropEntry`: a chunk rolls
/// [packChance] once per entry when it streams in; success spawns a pack of
/// [packMin]..[packMax] actors within [packRadius] tiles of the anchor.
final class BiomeActorEntry {
  BiomeActorEntry({
    required this.actorId,
    required this.packChance,
    required this.packMin,
    required this.packMax,
    required this.packRadius,
  }) {
    _validate();
  }

  BiomeActorEntry.fromReader(JsonReader reader)
      : actorId = reader.requiredString('actor_id'),
        packChance = reader.requiredDouble('pack_chance'),
        packMin = reader.requiredInt('pack_min'),
        packMax = reader.requiredInt('pack_max'),
        packRadius = reader.requiredInt('pack_radius') {
    _validate();
  }

  factory BiomeActorEntry.fromJson(Map<String, Object?> json) =>
      BiomeActorEntry.fromReader(JsonReader(json, 'BiomeActorEntry'));

  /// Twin of the step-11 entry validation — the pipeline names the file,
  /// this names the boot; both refuse the same shapes.
  void _validate() {
    assert(actorId.isNotEmpty, '[BiomeActorEntry] actor_id required');
    assert(
      packChance > 0 && packChance <= 1,
      '[BiomeActorEntry($actorId)] pack_chance $packChance outside (0, 1]',
    );
    assert(
      packMin >= 1 && packMin <= packMax,
      '[BiomeActorEntry($actorId)] pack $packMin..$packMax invalid',
    );
    assert(
      packRadius >= 1,
      '[BiomeActorEntry($actorId)] pack_radius $packRadius < 1',
    );
  }

  final String actorId;

  /// Odds per chunk (0 exclusive to 1 inclusive).
  final double packChance;
  final int packMin;
  final int packMax;

  /// Tiles around the anchor a pack member may land on.
  final int packRadius;
}
