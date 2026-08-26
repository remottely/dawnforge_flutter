import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// The ONLY construction site of actors (rule 1). Flow: registry provides
/// data → factory builds the shell → factory injects a CLONE of the soul
/// (rule 3) → factory returns the host. Fails fast on an unknown id — the
/// registry throws, and that is the feature (rule 5).
abstract final class ActorFactory {
  static IActor create(String id, WorldPos position) {
    final data = locator<ActorRegistry>().getActor(id);
    final actor = IActor()
      ..initialize(data.clone())
      ..position = position;
    return actor;
  }
}
