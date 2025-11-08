import 'package:darkness_dungeon/gameplay/core/modules/combat/synchronized_attack/synchronized_attack_entities.dart';

class SynchronizedAttackData {
  const SynchronizedAttackData({
    required this.baseAttackSpeedMs,
    this.attackTypeMultipliers,
    this.speedBonusPerLevel = 0.05,
  });

  final int baseAttackSpeedMs;
  final Map<AttackType, double>? attackTypeMultipliers;
  final double speedBonusPerLevel;

  Map<String, dynamic> toMap() {
    return {
      'baseAttackSpeedMs': baseAttackSpeedMs,
      'speedBonusPerLevel': speedBonusPerLevel,
      'attackTypeMultipliers': attackTypeMultipliers == null
          ? null
          : {
              for (final entry in attackTypeMultipliers!.entries)
                entry.key.name: entry.value,
            },
    };
  }
}
