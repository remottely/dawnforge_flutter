import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';
import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_spec.dart';

final class SynchronizedAttackSpecDef {
  SynchronizedAttackSpecDef._();

  static const standard = SynchronizedAttackSpec(
    baseAttackSpeedMs: 800,
    speedBonusPerLevel: 0.05,
    attackTypeMultipliers: {
      AttackType.melee: 1.0,
      AttackType.ranged: 0.8,
      AttackType.special: 1.5,
      AttackType.combo: 0.6,
    },
  );
}
