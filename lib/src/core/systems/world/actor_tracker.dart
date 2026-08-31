import 'package:dawnforge/src/core/base/world_objects/actors/i_actor.dart';

/// Every actor currently in the world — the Dart twin of the spec's
/// `&"character"` scene-tree group.
///
/// Godot could ask its scene tree "who is in this group"; Dart has no tree to
/// ask, so the membership is kept here instead. Actors join when they are
/// initialized (the factory is the only place that happens, rule 1) and leave
/// when they leave the world.
///
/// What it is FOR is the one question the occupancy rules ask over and over:
/// is anybody standing there. That question has to reach every actor, not the
/// ones some caller happened to have a reference to — which is exactly why the
/// spec asked a group rather than a list somebody maintained.
///
/// Registered at boot and never null after (rule 28).
final class ActorTracker {
  final List<IActor> _actors = <IActor>[];

  /// Read-only view. A copy, because the rules iterate it while gameplay may
  /// spawn or kill something mid-sweep.
  List<IActor> get actors => List<IActor>.unmodifiable(_actors);

  int get count => _actors.length;

  /// [actor] entered the world. Joining twice is a bug on the caller's side —
  /// crash (rule 5), because a doubled entry silently doubles every sweep.
  void add(IActor actor) {
    assert(
      !_actors.any((existing) => identical(existing, actor)),
      '[ActorTracker] ${actor.data.id} joined twice',
    );
    _actors.add(actor);
  }

  /// [actor] left the world. Removing one that never joined is invalid state,
  /// not a tolerated no-op: unlike a UI surface, nothing else can have
  /// removed it first.
  void remove(IActor actor) {
    final removed = _actors.indexWhere((existing) => identical(existing, actor));
    assert(removed >= 0, '[ActorTracker] ${actor.data.id} left without joining');
    if (removed >= 0) _actors.removeAt(removed);
  }
}
