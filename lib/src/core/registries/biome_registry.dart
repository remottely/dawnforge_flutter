import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world/biome_data.dart';

/// The database of every authored biome (rule 2). Keyed by id
/// (`biome_forest_data`); the ProceduralWorldManager builds its own tier
/// index over these at boot, mirroring the Godot `_biomesByTier`.
final class BiomeRegistry extends RegistryBase<BiomeData> {
  BiomeData getBiome(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = BiomeData.fromJson(json);
    register(data.id, data);
  }
}
