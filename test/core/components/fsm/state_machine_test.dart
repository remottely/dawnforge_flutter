import 'package:dawnforge/src/core/components/fsm/state.dart';
import 'package:dawnforge/src/core/components/fsm/state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

final class _IdleProbe extends State {
  _IdleProbe(this.log);

  final List<String> log;

  @override
  void enter() => log.add('idle.enter');

  @override
  void exit() => log.add('idle.exit');

  @override
  void update(double dt) => log.add('idle.update');
}

final class _WalkProbe extends State {
  _WalkProbe(this.log);

  final List<String> log;

  @override
  void enter() => log.add('walk.enter');
}

void main() {
  group('StateMachine', () {
    test('start enters the initial state; update delegates to it', () {
      final log = <String>[];
      final fsm = StateMachine()
        ..addState(_IdleProbe(log))
        ..start('_IdleProbe')
        ..update(1 / 60);

      expect(log, ['idle.enter', 'idle.update']);
      expect(fsm.current, isA<_IdleProbe>());
    });

    test('transitionTo exits the active state then enters the next', () {
      final log = <String>[];
      final fsm = StateMachine()
        ..addState(_IdleProbe(log))
        ..addState(_WalkProbe(log))
        ..start('_IdleProbe')
        ..transitionTo('_WalkProbe');

      expect(log, ['idle.enter', 'idle.exit', 'walk.enter']);
      expect(fsm.current, isA<_WalkProbe>());
    });
  });
}
