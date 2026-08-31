import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';
import 'package:dawnforge/src/core/base/world_objects/actors/player/actor_player.dart';
import 'package:dawnforge/src/core/registries/actor_registry.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';
import 'package:dawnforge/src/core/systems/boot.dart';

/// The ONLY construction site of actors (rule 1). Flow: registry provides
/// data → factory builds the shell → factory injects a CLONE of the soul
/// (rule 3) → factory returns the host. Fails fast on an unknown id — the
/// registry throws, and that is the feature (rule 5).
abstract final class ActorFactory {
  static IActor create(String id, WorldPos position) {
    final data = locator<ActorRegistry>().getActor(id);
    // WHICH HOST is decided by the authored group, not by the id: the same
    // `groups: [player]` the bare-hands rule and the permission gate read.
    // The engine never knows a player by name (rule 33's spirit — what a
    // thing is allowed to be is content).
    final actor = (data.groups.contains(GameConstants.playerGroup)
        ? ActorPlayer()
        : IActor())
      ..initialize(data.clone())
      ..position = position;
    return actor;
  }

  /// The same construction, typed for the one actor a person steers. Asserts
  /// rather than casting quietly: an id that is not authored into the `player`
  /// group cannot be the player, and finding that out here beats finding it
  /// out when the first press does nothing (rules 5 and 18).
  static ActorPlayer createPlayer(String id, WorldPos position) {
    final actor = create(id, position);
    assert(
      actor is ActorPlayer,
      '[ActorFactory] $id is not authored into the '
      '`${GameConstants.playerGroup}` group, so it cannot be the player',
    );
    return actor as ActorPlayer;
  }
}
