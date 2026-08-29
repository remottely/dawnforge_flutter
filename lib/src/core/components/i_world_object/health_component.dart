import 'package:dawnforge/src/core/components/i_world_object/i_component_vital.dart';
import 'package:dawnforge/src/core/domain/vitality/health_rules.dart';
import 'package:dawnforge/src/core/domain/vitality/vital_regen_rules.dart';
import 'package:dawnforge/src/core/shared_logic/definitions/engine_constants.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// Health logic — port of `health_component.gd` (logic slice: the feedback
/// chain, difficulty scaling and replication adoption arrive with their
/// systems). All state lives in the data soul (rule 8); this component is the
/// behavior over it, driven by `HealthRules`/`VitalRegenRules`.
final class HealthComponent extends IComponentVital {
  bool isInvulnerable = false;

  /// Points per second; 0 = no regeneration.
  double regenerationRate = 0;

  final healthChanged = EventSignal<(double current, double maximum)>();
  final died = EventSignal<Object?>();
  final damaged = EventSignal<(double amount, Object? source)>();

  @override
  double get current => data.currentHealth;

  @override
  double get maximum => data.maxHealth;

  @override
  EventSignal<(double current, double maximum)> get changedSignal =>
      healthChanged;

  /// Whether this object still stands — the question every blow asks before
  /// it is thrown and after it lands (the spec's `is_alive`).
  bool get isAlive => !HealthRules.isDead(current);

  /// Applies [amount] of damage. Returns whether the hit landed (an
  /// invulnerable or already-dead target refuses it — a refusal, not a
  /// fallback: the caller reads the answer).
  bool takeDamage(double amount, {Object? source}) {
    if (!HealthRules.canTakeDamage(current, isInvulnerable: isInvulnerable)) {
      return false;
    }
    data.takeDamage(amount);
    damaged.emit((amount, source));
    healthChanged.emit((current, maximum));
    if (HealthRules.isDead(current)) {
      died.emit(source);
    }
    return true;
  }

  /// Heals [amount]. No revive: a no-op at/below zero health (HealthRules).
  void heal(double amount) {
    if (!HealthRules.canHeal(amount, current)) return;
    final before = current;
    data.heal(amount);
    if (HealthRules.effectiveHealed(before, current) > 0) {
      healthChanged.emit((current, maximum));
    }
  }

  /// How hard a hit of [amount] looked, in [0, 1] — for the render layer.
  double impactIntensity(double amount) =>
      HealthRules.impactIntensity(amount, maximum);

  @override
  void update(double dt) {
    if (!HealthRules.shouldRegenerate(
      regenerationRate,
      current,
      maximum,
      isInvulnerable: isInvulnerable,
    )) {
      return;
    }
    final (amount, remainder) = VitalRegenRules.accumulateRegen(
      regenerationRate,
      dt,
      regenAccumulator,
      EngineConstants.healthRegenStep,
    );
    regenAccumulator = remainder;
    if (amount > 0) heal(amount);
  }
}
