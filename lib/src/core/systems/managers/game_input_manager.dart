/// The UI blocker stack — the mechanism that replaces pausing (rule 30).
/// A surface that must stop the player from acting pushes itself as a blocker;
/// the simulation keeps running behind it. It is a stack, so nested surfaces
/// (menu → dialog → text entry) compose without any of them knowing what sits
/// underneath.
///
/// Registered once at boot and never null after (rule 28).
final class GameInputManager {
  final List<Object> _blockers = <Object>[];

  /// Gameplay code asks this — it never gets frozen, it gets ignored.
  bool get isGameplayEnabled => _blockers.isEmpty;

  /// [owner] opened a surface that suppresses gameplay input. Pushing twice
  /// for one surface is a bug on the surface's side — crash (rule 5).
  void pushUiBlocker(Object owner) {
    assert(!_blockers.contains(owner), '[GameInputManager] $owner pushed twice');
    _blockers.add(owner);
  }

  /// [owner]'s surface closed. Popping without a matching push is invalid
  /// state — crash (rule 5).
  void popUiBlocker(Object owner) {
    final removed = _blockers.remove(owner);
    assert(removed, '[GameInputManager] $owner popped without push');
  }

  int get blockerCount => _blockers.length;
}
