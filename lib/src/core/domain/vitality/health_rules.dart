import 'dart:math' as math;

import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';

/// Pure domain rules for health damage/heal/regeneration — the Dart port of
/// `HealthRules.cs`. No host/component/engine dependency.
abstract final class HealthRules {
  /// Godot's `is_equal_approx` tolerance for "the bar reached zero".
  static const double _zeroEpsilon = 1e-5;

  /// Whether a takeDamage() call should proceed given invulnerability/health.
  static bool canTakeDamage(double currentHealth, {required bool isInvulnerable}) =>
      !isInvulnerable && currentHealth > 0;

  /// Whether the entity should be considered dead after some health change.
  static bool isDead(double currentHealth) => currentHealth.abs() < _zeroEpsilon;

  /// Architecture decision: no revive via heal() — healing is a no-op at/below
  /// zero health.
  static bool canHeal(double amount, double currentHealth) =>
      amount > 0 && currentHealth > 0;

  /// The effective amount actually healed, given before/after health values.
  static double effectiveHealed(double healthBefore, double healthAfter) =>
      healthAfter - healthBefore;

  /// How hard a hit LOOKED, in [0, 1] — the number every part of the impact
  /// reaction is scaled by. The damage fraction is square-rooted (spending
  /// most of the range on the small hits that make up almost every swing) and
  /// lifted off the floor, because the weakest hit still has to be visible.
  static double impactIntensity(double damage, double maxHealth) {
    if (maxHealth <= 0) {
      throw ArgumentError.value(
        maxHealth,
        'maxHealth',
        'a body with no maximum health cannot be hit',
      );
    }
    final fraction = (damage / maxHealth).clamp(0.0, 1.0);
    const floor = EngineConstants.impactIntensityFloor;
    return floor + (1.0 - floor) * math.sqrt(fraction);
  }

  /// Whether regeneration should run this tick at all.
  static bool shouldRegenerate(
    double regenerationRate,
    double currentHealth,
    double maxHealth, {
    required bool isInvulnerable,
  }) {
    if (regenerationRate <= 0) return false;
    if (isInvulnerable) return false;
    if (currentHealth <= 0 || currentHealth >= maxHealth) return false;
    return true;
  }
}
