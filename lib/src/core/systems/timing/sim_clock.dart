import 'package:dawnforge/src/core/shared_logic/definitions/game_constants.dart';

/// Fixed-step accumulator over Flame's variable `update(dt)` (study risk #5).
/// The simulation only ever advances in whole steps of
/// [GameConstants.simFixedStep], so ported logic keeps deterministic,
/// multiplayer-shaped timing even though the render loop is variable.
///
/// The render layer (FP3) calls [advance] once per frame and may interpolate
/// visuals with [alpha].
final class SimClock {
  double _accumulator = 0;
  int _totalSteps = 0;

  /// Steps executed since boot — the simulation's own monotonic time.
  int get totalSteps => _totalSteps;

  /// Fraction of a step accumulated but not yet simulated, in `[0, 1)` —
  /// the render-interpolation factor.
  double get alpha => _accumulator / GameConstants.simFixedStep;

  /// Feeds one frame's [frameDt] and runs [tick] once per whole step elapsed,
  /// capped at [GameConstants.simMaxStepsPerFrame] so a long stall cannot fire
  /// a burst of thousands of ticks. Returns how many steps were DROPPED by the
  /// cap (0 in normal operation) — the caller surfaces it, never swallows it
  /// (rule 20: silence is a fallback in disguise).
  int advance(double frameDt, void Function(double stepDt) tick) {
    assert(frameDt >= 0, '[SimClock] negative frame dt: $frameDt');
    _accumulator += frameDt;

    var stepsRun = 0;
    while (_accumulator >= GameConstants.simFixedStep &&
        stepsRun < GameConstants.simMaxStepsPerFrame) {
      _accumulator -= GameConstants.simFixedStep;
      _totalSteps += 1;
      stepsRun += 1;
      tick(GameConstants.simFixedStep);
    }

    var dropped = 0;
    while (_accumulator >= GameConstants.simFixedStep) {
      _accumulator -= GameConstants.simFixedStep;
      dropped += 1;
    }
    return dropped;
  }
}
