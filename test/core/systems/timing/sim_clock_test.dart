import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';
import 'package:dawnforge/src/core/systems/timing/sim_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const step = GameConstants.simFixedStep;

  group('SimClock', () {
    test('accumulates partial frames into whole fixed steps', () {
      final clock = SimClock();
      var ticks = 0;

      // Three frames of ~half a step each → 1 whole step after frame 2.
      clock
        ..advance(step * 0.5, (_) => ticks++)
        ..advance(step * 0.5, (_) => ticks++)
        ..advance(step * 0.5, (_) => ticks++);

      expect(ticks, 1);
      expect(clock.totalSteps, 1);
      expect(clock.alpha, closeTo(0.5, 1e-9));
    });

    test('a long stall is capped and the dropped steps are REPORTED', () {
      final clock = SimClock();
      var ticks = 0;

      final dropped = clock.advance(
        step * (GameConstants.simMaxStepsPerFrame + 3),
        (_) => ticks++,
      );

      expect(ticks, GameConstants.simMaxStepsPerFrame);
      expect(dropped, 3);
    });

    test('every tick receives exactly the fixed step', () {
      final clock = SimClock();
      final received = <double>[];

      clock.advance(step * 2, received.add);

      expect(received, [step, step]);
    });
  });
}
