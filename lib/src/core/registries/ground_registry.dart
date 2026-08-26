import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';

/// The database of every authored ground tile (rule 2).
final class GroundRegistry extends RegistryBase<GroundBuildableData> {
  GroundBuildableData getGround(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = GroundBuildableData.fromJson(json);
    register(data.id, data);
  }
}
