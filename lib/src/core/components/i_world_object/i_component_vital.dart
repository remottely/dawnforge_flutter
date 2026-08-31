import 'package:dawnforge/src/core/components/i_component.dart';
import 'package:dawnforge/src/core/systems/eventing/event_signal.dart';

/// The shared base of health, energy and mana — port of `i_component_vital.gd`
/// (logic slice: popups, capabilities and difficulty scaling arrive with their
/// systems). What the three vitals share is not their maths — mana
/// regenerates, energy does not, health can be invulnerable — but the
/// contract below, which is what lets one bar implementation serve all of
/// them: each vital names its own value, maximum and signal, and nothing
/// outside has to spell "health" or "mana" to read them.
abstract class IComponentVital extends IComponent {
  /// Accumulated fractional regeneration carried between ticks. Subclasses
  /// that do not regenerate never touch it. Internal, never serialized.
  double regenAccumulator = 0;

  /// The vital's current value.
  double get current;

  /// The vital's ceiling.
  double get maximum;

  /// Current over maximum, clamped to [0, 1].
  double get percentage =>
      maximum > 0 ? (current / maximum).clamp(0.0, 1.0) : 0.0;

  /// The vital's `(current, maximum)` changed signal, so a consumer can
  /// connect without naming the vital.
  EventSignal<(double current, double maximum)> get changedSignal;
}
