import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';
import 'package:voxel_core/voxel_core.dart';

/// How a body moves on foot.
class MotorTuning {
  /// The kit's defaults: a Minecraft-paced walker.
  const MotorTuning({
    this.jumpVelocity = 8.6,
    this.groundAccel = 14.0,
    this.airAccel = 6.0,
    this.swimStroke = 20.0,
    this.swimRise = 4.0,
    this.climbSpeed = 3.2,
    this.autoStep = true,
  });

  /// Launch speed of a jump, metres a second (8.6 clears a block and a bit).
  final double jumpVelocity;

  /// How fast the walk catches up with the wish on the ground (per second).
  final double groundAccel;

  /// ...and in the air.
  final double airAccel;

  /// Upward acceleration while swimming up.
  final double swimStroke;

  /// The fastest a swimmer rises.
  final double swimRise;

  /// Speed on a ladder.
  final double climbSpeed;

  /// Whether a step (a slab, a block) walked into is jumped by itself.
  final bool autoStep;
}

/// What one [CharacterMotor.step] did that its owner answers: a landing
/// after a fall (for fall damage), a jump.
class MotorEvents {
  /// Metres fallen before this step's landing, 0 without one.
  double landedAfter = 0.0;

  /// Whether the body jumped this step (a key or an auto step).
  bool jumped = false;
}

/// The on-foot rules of a body in a voxel world, shared by the player and
/// every walking creature: gravity and swimming, jumping, climbing ladders,
/// walking toward a wish at a speed, auto-jumping steps (a half step hopped
/// under double gravity, a full block jumped), launching out of water over a
/// bank, and keeping the height a fall started from.
class CharacterMotor {
  /// A motor for [body].
  CharacterMotor(this.body, [this.tuning = const MotorTuning()]) : _fallStart = body.position.y;

  /// The body moved.
  final VoxelBody body;

  /// How it moves.
  final MotorTuning tuning;

  bool _hopping = false;
  bool _leavingWater = false;
  double _sinceWater = 1.0;
  double _fallStart;

  /// Seconds left in which a shove carries the body and the wish does not
  /// steer it (knockback).
  double stagger = 0.0;

  /// Whether the body is on a ladder this step.
  bool climbing = false;

  /// In a liquid and off the floor, or with the head under: swimming, not
  /// wading.
  bool get swimming => body.inLiquid && !body.wading;

  /// Pushes the body by [velocity] and lets it carry for [seconds].
  void shove(Vector3 velocity, [double seconds = 0.3]) {
    body.velocity.setFrom(velocity);
    stagger = seconds;
  }

  /// One step of [dt]: walk toward [wish] (horizontal, length up to 1) at
  /// [speed], jumping while [jump] is held, sneaking (no auto step up a full
  /// block) with [sneak]; [onLadder] makes the body climb.
  MotorEvents step(double dt, {required Vector3 wish, required double speed, bool jump = false, bool sneak = false, bool onLadder = false}) {
    final events = MotorEvents();
    final b = body;
    climbing = false;
    if (onLadder) {
      b.velocity.y = jump ? tuning.climbSpeed : (sneak ? -tuning.climbSpeed : 0.0);
      climbing = jump;
    } else if (_leavingWater) {
      b.velocity.y -= b.gravity * dt;
    } else if (swimming) {
      if (jump) {
        b.velocity.y = math.min(b.velocity.y + tuning.swimStroke * dt, tuning.swimRise);
      } else {
        b.applyGravity(dt);
      }
    } else {
      b.applyGravity(dt);
      if (_hopping) b.applyGravity(dt);
      if (jump && b.onFloor) {
        b.velocity.y = tuning.jumpVelocity;
        _fallStart = b.position.y;
        events.jumped = true;
      }
    }
    final accel = b.onFloor || _hopping ? tuning.groundAccel : tuning.airAccel;
    if (stagger <= 0.0) {
      b.velocity.x = lerpd(b.velocity.x, wish.x * speed, math.min(dt * accel, 1.0));
      b.velocity.z = lerpd(b.velocity.z, wish.z * speed, math.min(dt * accel, 1.0));
    }
    final wasFloor = b.onFloor;
    b.move(dt);
    if (b.onFloor || b.inLiquid || climbing) _hopping = false;
    if (b.onFloor || climbing || b.velocity.y <= 0.0) _leavingWater = false;
    final wishing = wish.x * wish.x + wish.z * wish.z > 0.01;
    if (tuning.autoStep && wishing && !climbing && !b.inLiquid) {
      final lift = b.stepAhead(fullBlock: !sneak);
      if (lift > 0.0) {
        b.velocity.y = tuning.jumpVelocity;
        _hopping = lift == VoxelBody.halfStep;
        _fallStart = b.position.y;
        events.jumped = true;
      }
    }
    _sinceWater = b.inLiquid ? 0.0 : _sinceWater + dt;
    if (b.hitWall && _sinceWater < 0.5 && !b.onFloor && jump && wishing && !climbing && !_leavingWater) {
      // Out of the water over a bank: the lowest lift that fits, and a
      // quarter block to spare. A wall taller than 1.9 is never climbed.
      for (var lift = 0.1; lift <= 1.9; lift += 0.1) {
        if (!b.stepFits(lift)) continue;
        b.velocity.y = math.sqrt(2.0 * b.gravity * (lift + 0.25));
        _leavingWater = true;
        _fallStart = b.position.y;
        break;
      }
    }
    if (!wasFloor && b.onFloor && !b.inLiquid) events.landedAfter = math.max(0.0, _fallStart - b.position.y);
    // The fall is measured from the highest point since the feet last had
    // footing: a jump's peak, a ledge walked off, or wherever the body was put.
    if (b.onFloor || climbing || b.inLiquid) {
      _fallStart = b.position.y;
    } else {
      _fallStart = math.max(_fallStart, b.position.y);
    }
    stagger = math.max(stagger - dt, 0.0);
    return events;
  }

  /// Steps without walking: gravity, swimming and landing only.
  MotorEvents idle(double dt) => step(dt, wish: Vector3.zero(), speed: 0.0);
}
