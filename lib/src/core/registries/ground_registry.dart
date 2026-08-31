import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_buildable_data.dart';
import 'package:dawnforge/src/core/resources/world_objects/grounds/ground_empty_data.dart';

/// The database of every authored ground tile (rule 2).
final class GroundRegistry extends RegistryBase<GroundBuildableData> {
  GroundBuildableData getGround(String id) => get(id);

  /// Routes the pack's concrete ground type to its data class. An unknown
  /// subtype is invalid content — the registry gains the class in the same
  /// commit that introduces the type (rule 5).
  void registerJson(Map<String, Object?> json) {
    final type = json['type'];
    final data = switch (type) {
      'ground_empty_data' => GroundEmptyData.fromJson(json),
      'ground_buildable_data' => GroundBuildableData.fromJson(json),
      _ => throw StateError('[GroundRegistry] unknown ground type "$type"'),
    };
    register(data.id, data);
  }
}
