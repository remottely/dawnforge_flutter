import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/spatial.dart';

/// Pure domain rules for actor movement (speed/acceleration/backpedal) — the
/// Dart port of `MovementRules.cs`. No host/component/engine dependency: plain
/// data in, plain data out.
abstract final class MovementRules {
  /// Whether the actor is moving opposite (or beyond-perpendicular) to its
  /// look direction — dot product below the backpedal threshold.
  static bool isBackpedaling(WorldPos inputVector, WorldPos lookDirection) =>
      inputVector.dot(lookDirection) < EngineConstants.backpedalDotThreshold;

  /// The effective speed after the backpedal penalty (half speed).
  static double applyBackpedalPenalty(double speed, {required bool isBackpedaling}) =>
      isBackpedaling ? speed * 0.5 : speed;

  /// The target velocity in world-units/sec for a given input, speed
  /// (tiles/sec) and tile dimension.
  static WorldPos calculateTargetVelocity(
    WorldPos inputVector,
    double speed,
    double tileDimension,
  ) =>
      inputVector * (speed * tileDimension);

  /// Minimum squared speed above which the actor counts as "moving":
  /// 0.625 tiles/s (= 10 px/s at a 16 px tile).
  static double movingThresholdSquared(double tileDimension) {
    final minSpeed = 0.625 * tileDimension;
    return minSpeed * minSpeed;
  }
}
