import 'package:dawnforge/game/core/modules/combat/synchronized_attack/synchronized_attack_config.dart';
import 'package:dawnforge/game/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

final class SynchronizedAttackDef {
  SynchronizedAttackDef._();

  static const standard = SynchronizedAttackConfig(
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
