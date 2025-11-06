enum AttackType { melee, ranged, special, combo }

class AttackExecutionInfo {
  AttackExecutionInfo({
    required this.type,
    required this.executionTime,
    required this.cooldownDuration,
    required this.animationDuration,
    required this.playerLevel,
    required this.activeModifiers,
  });

  final AttackType type;
  final DateTime executionTime;
  final Duration cooldownDuration;
  final Duration animationDuration;
  final int playerLevel;
  final Map<String, AttackSpeedModifier> activeModifiers;

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'executionTime': executionTime.toIso8601String(),
      'cooldownDurationMs': cooldownDuration.inMilliseconds,
      'animationDurationMs': animationDuration.inMilliseconds,
      'playerLevel': playerLevel,
      'activeModifiers': {
        for (final entry in activeModifiers.entries)
          entry.key: entry.value.toMap(),
      },
    };
  }
}

class AttackDurations {
  const AttackDurations({required this.cooldown, required this.animation});

  final Duration cooldown;
  final Duration animation;
}

class AttackSpeedModifier {
  AttackSpeedModifier({
    required this.name,
    required this.speedMultiplier,
    this.description = '',
    required this.appliedAt,
    this.duration,
  });

  final String name;
  final double speedMultiplier;
  final String description;
  final DateTime appliedAt;
  final Duration? duration;

  bool get isExpired {
    if (duration == null) return false;
    return DateTime.now().difference(appliedAt) >= duration!;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'speedMultiplier': speedMultiplier,
      'description': description,
      'appliedAt': appliedAt.toIso8601String(),
      'durationMs': duration?.inMilliseconds,
      'isExpired': isExpired,
    };
  }
}
