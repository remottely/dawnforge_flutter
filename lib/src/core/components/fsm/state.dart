import 'package:dawnforge/src/core/components/fsm/state_machine.dart';

/// One named state of a [StateMachine] (rule 9: FSM for any complex or
/// sequential state — never loose boolean flags). Plain Dart: no engine node
/// needed, which is the whole simplification over the Godot version.
abstract class State {
  StateMachine? _machine;

  /// The machine this state belongs to. Crash on read before registration.
  StateMachine get machine {
    final owner = _machine;
    assert(owner != null, '[$runtimeType] read machine before registration');
    return owner!;
  }

  /// The registry key: the concrete class name — same convention as
  /// components (rule 16).
  String get stateKey => runtimeType.toString();

  /// Called by [StateMachine.addState] — never directly.
  void register(StateMachine owner) {
    assert(_machine == null, '[$runtimeType] registered twice');
    _machine = owner;
  }

  /// The machine entered this state.
  void enter() {}

  /// The machine is leaving this state.
  void exit() {}

  /// Fixed-step tick while active.
  void update(double dt) {}
}
