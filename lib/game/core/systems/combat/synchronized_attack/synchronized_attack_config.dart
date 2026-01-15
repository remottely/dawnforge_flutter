import 'package:dawnforge/game/core/systems/combat/synchronized_attack/synchronized_attack_entities.dart';

class SynchronizedAttackConfig {
  final int baseAttackSpeedMs;
  final Map<AttackType, double> attackTypeMultipliers;
  final double speedBonusPerLevel;

  const SynchronizedAttackConfig({
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
