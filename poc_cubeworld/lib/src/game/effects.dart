import 'dart:math' as math;

import 'package:vector_math/vector_math.dart';

/// One timed buff or debuff: what it is called, how it looks, and the tick it
/// carries. A row with a `period` fires an event every `period` seconds.
class EffectDef {
  const EffectDef(this.id, this.name, this.r, this.g, this.b,
      {this.period = 0.0, this.damage = 0.0, this.heal = 0.0, this.bad = false});

  final String id;
  final String name;
  final double r, g, b;

  /// Seconds between ticks; 0 for an effect that only modifies stats.
  final double period;
  final double damage;
  final double heal;
  final bool bad;

  bool get ticks => period > 0.0;
  Vector3 get color => Vector3(r, g, b);
}

/// What one tick of an effect did this frame: the owner decides how it shows.
class EffectEvent {
  const EffectEvent(this.id, this.damage, this.heal);
  final String id;
  final double damage;
  final double heal;
}

class EffectRow {
  EffectRow(this.time, this.power);
  double time;
  double power;
  double tick = 0.0;
}

/// Timed buffs and debuffs on a body. Each effect is one row: seconds left plus
/// power. Ticking damage and healing are applied by the owner through [tick],
/// which returns the events that happened this frame so the owner decides how
/// they show (damage numbers, sounds).
class StatusEffects {
  static const Map<String, EffectDef> defs = {
    'poison': EffectDef('poison', 'Poisoned', 0.35, 0.80, 0.30, period: 2.0, damage: 1.0, bad: true),
    'burning': EffectDef('burning', 'Burning', 1.00, 0.55, 0.15, period: 1.0, damage: 1.0, bad: true),
    // Stage 29: the dark skeleton's touch.
    'wither': EffectDef('wither', 'Withering', 0.25, 0.22, 0.28, period: 1.5, damage: 1.0, bad: true),
    'slow': EffectDef('slow', 'Slowed', 0.50, 0.60, 0.85, bad: true),
    'regen': EffectDef('regen', 'Regeneration', 0.95, 0.40, 0.60, period: 1.5, heal: 1.0),
    'speed': EffectDef('speed', 'Swiftness', 0.45, 0.85, 0.95),
    'strength': EffectDef('strength', 'Strength', 0.90, 0.30, 0.25),
    'resistance': EffectDef('resistance', 'Resistance', 0.70, 0.70, 0.75),
    'haste': EffectDef('haste', 'Haste', 0.95, 0.85, 0.35),
    'well_fed': EffectDef('well_fed', 'Well Fed', 0.85, 0.60, 0.30, period: 3.0, heal: 1.0),
  };

  static EffectDef def(String id) {
    final d = defs[id];
    if (d == null) throw ArgumentError('unknown effect $id');
    return d;
  }

  final Map<String, EffectRow> rows = {};

  void apply(String id, double seconds, [double power = 1.0]) {
    def(id);
    final r = rows[id];
    if (r != null) {
      r.time = math.max(r.time, seconds);
      r.power = math.max(r.power, power);
      return;
    }
    rows[id] = EffectRow(seconds, power);
  }

  void clear(String id) => rows.remove(id);

  /// Drops every bad effect (what an antidote or a bucket of milk does).
  int clearBad() {
    final bad = [for (final id in rows.keys) if (def(id).bad) id];
    for (final id in bad) {
      rows.remove(id);
    }
    return bad.length;
  }

  bool has(String id) => rows.containsKey(id);
  double power(String id) => rows[id]?.power ?? 0.0;
  double timeLeft(String id) => rows[id]?.time ?? 0.0;

  /// Advance every row. Returns the ticks that fired this frame.
  List<EffectEvent> tick(double dt) {
    final events = <EffectEvent>[];
    for (final id in rows.keys.toList()) {
      final r = rows[id]!;
      r.time -= dt;
      if (r.time <= 0.0) {
        rows.remove(id);
        continue;
      }
      final d = def(id);
      if (!d.ticks) continue;
      r.tick += dt;
      if (r.tick >= d.period) {
        r.tick -= d.period;
        events.add(EffectEvent(id, d.damage * r.power, d.heal * r.power));
      }
    }
    return events;
  }

  double speedMultiplier() {
    var m = 1.0;
    if (has('speed')) m *= 1.0 + 0.30 * power('speed');
    if (has('slow')) m *= 1.0 / (1.0 + 0.40 * power('slow'));
    return m;
  }

  double damageMultiplier() => has('strength') ? 1.0 + 0.30 * power('strength') : 1.0;
  int armorBonus() => has('resistance') ? (4.0 * power('resistance')).toInt() : 0;
  double mineMultiplier() => has('haste') ? 1.0 + 0.6 * power('haste') : 1.0;

  Map<String, Object> toJson() => {
        for (final e in rows.entries) e.key: [e.value.time, e.value.power],
      };

  void fromJson(Map<String, dynamic> d) {
    rows.clear();
    for (final e in d.entries) {
      if (!defs.containsKey(e.key)) continue;
      final pair = (e.value as List<dynamic>).map((v) => (v as num).toDouble()).toList();
      rows[e.key] = EffectRow(pair[0], pair[1]);
    }
  }
}
