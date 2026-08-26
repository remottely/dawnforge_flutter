import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world_objects/props/prop_data.dart';

/// The database of every authored prop (rule 2).
final class PropRegistry extends RegistryBase<PropData> {
  PropData getProp(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = PropData.fromJson(json);
    register(data.id, data);
  }
}
