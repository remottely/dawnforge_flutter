import 'package:dawnforge/src/core/components/fsm/state.dart';

/// A finite state machine over named [State]s (rule 9). States are registered
/// once, addressed by their class-name key, and exactly one is active after
/// [start]. Transitions are explicit — there is no implicit fallback state
/// (rule 5).
final class StateMachine {
  final Map<String, State> _states = <String, State>{};
  State? _current;

  /// The active state. Crash on read before [start] (rule 5).
  State get current {
    final active = _current;
    assert(active != null, '[StateMachine] read current before start()');
    return active!;
  }

  bool get isStarted => _current != null;

  T addState<T extends State>(T state) {
    final key = state.stateKey;
    assert(!_states.containsKey(key), '[StateMachine] duplicate state: $key');
    _states[key] = state;
    state.register(this);
    return state;
  }

  /// Enters [initialKey]. Must be called exactly once, after registration.
  void start(String initialKey) {
    assert(_current == null, '[StateMachine] started twice');
    final initial = _states[initialKey];
    assert(initial != null, '[StateMachine] unknown initial state: $initialKey');
    _current = initial;
    initial!.enter();
  }

  /// Leaves the active state and enters [key]. Transitioning to the active
  /// state itself is a legal no-op re-entry: exit then enter, matching the
  /// Godot machine.
  void transitionTo(String key) {
    final next = _states[key];
    assert(next != null, '[StateMachine] unknown state: $key');
    current.exit();
    _current = next;
    next!.enter();
  }

  /// Fixed-step tick, delegated to the active state.
  void update(double dt) => current.update(dt);
}
