import 'package:dawnforge/src/core/registries/registry_base.dart';
import 'package:dawnforge/src/core/resources/world_objects/actors/i_actor_data.dart';

/// The database of every authored actor (rule 2). Populated from the
/// pipeline's generated JSON (FP2); until then, tests and boot code register
/// entries explicitly.
final class ActorRegistry extends RegistryBase<IActorData> {
  IActorData getActor(String id) => get(id);

  void registerJson(Map<String, Object?> json) {
    final data = IActorData.fromJson(json);
    register(data.id, data);
  }
}
