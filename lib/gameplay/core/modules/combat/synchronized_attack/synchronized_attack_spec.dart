import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

class SynchronizedAttackSpec {
  final int baseAttackSpeedMs;
  final Map<AttackType, double> attackTypeMultipliers;
  final double speedBonusPerLevel;

  const SynchronizedAttackSpec({
    required this.baseAttackSpeedMs,
    required this.attackTypeMultipliers,
    this.speedBonusPerLevel = 0.05,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseAttackSpeedMs': baseAttackSpeedMs,
      'speedBonusPerLevel': speedBonusPerLevel,
      'attackTypeMultipliers': {
        for (final entry in attackTypeMultipliers.entries)
          entry.key.name: entry.value,
      },
    };
  }
}
