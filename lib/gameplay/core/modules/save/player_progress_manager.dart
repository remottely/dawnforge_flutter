import 'package:dawnforge/core/utils/logger/game_logger.dart';

final class PlayerProgressManager {
  PlayerProgressManager._();

  static final instance = PlayerProgressManager._();

  final Set<String> _flags = {};

  final Map<String, int> _achievements = {};

  int totalPlayTimeSeconds = 0;

  int enemiesDefeated = 0;

  int itemsCrafted = 0;

  int distanceTraveled = 0;

  void setFlag(String flag) {
    if (_flags.add(flag)) {
      GameLogger.info('[PlayerProgressManager] Flag set: $flag');
    }
  }

  bool hasFlag(String flag) {
    return _flags.contains(flag);
  }

  void removeFlag(String flag) {
    if (_flags.remove(flag)) {
      GameLogger.info('[PlayerProgressManager] Flag removed: $flag');
    }
  }

  Set<String> getAllFlags() {
    return Set.from(_flags);
  }

  void incrementAchievement(String achievementId, [int amount = 1]) {
    final previousValue = _achievements[achievementId] ?? 0;
    final newValue = previousValue + amount;
    _achievements[achievementId] = newValue;

    GameLogger.info(
      '[PlayerProgressManager] Achievement "$achievementId" incremented: '
      '	$previousValue -> $newValue (+$amount)',
    );
  }

  int getAchievementProgress(String achievementId) {
    return _achievements[achievementId] ?? 0;
  }

  bool isAchievementCompleted(String achievementId, int requiredAmount) {
    final current = getAchievementProgress(achievementId);
    return current >= requiredAmount;
  }

  Map<String, int> getAllAchievements() {
    return Map.from(_achievements);
  }

  void updateStats(Map<String, int> updates) {
    for (final entry in updates.entries) {
      switch (entry.key) {
        case 'totalPlayTimeSeconds':
          totalPlayTimeSeconds += entry.value;
          break;
        case 'enemiesDefeated':
          enemiesDefeated += entry.value;
          break;
        case 'itemsCrafted':
          itemsCrafted += entry.value;
          break;
        case 'distanceTraveled':
          distanceTraveled += entry.value;
          break;
        default:
          GameLogger.warning('[PlayerProgressManager] Unknown stat: ${entry.key}');
      }
    }

    if (updates.isNotEmpty) {
      GameLogger.info('[PlayerProgressManager] Stats updated: $updates');
    }
  }

  List<String> getCompletedQuests() {
    return _flags
        .where(
          (flag) => flag.startsWith('quest_') && flag.endsWith('_completed'),
        )
        .toList();
  }

  List<String> getMetNPCs() {
    return _flags.where((flag) => flag.startsWith('npc_met_')).toList();
  }

  List<String> getUnlockedAreas() {
    return _flags
        .where((flag) => flag.startsWith('area_') && flag.endsWith('_unlocked'))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'flags': _flags.toList(),
      'achievements': _achievements,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'enemiesDefeated': enemiesDefeated,
      'itemsCrafted': itemsCrafted,
      'distanceTraveled': distanceTraveled,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    GameLogger.info('[PlayerProgressManager] Loading player progress from JSON');

    _flags.clear();
    final flagsList = json['flags'] as List<dynamic>?;
    if (flagsList != null) {
      _flags.addAll(flagsList.cast<String>());
    }

    _achievements.clear();
    final achievementsMap = json['achievements'] as Map<String, dynamic>?;
    if (achievementsMap != null) {
      for (final entry in achievementsMap.entries) {
        _achievements[entry.key] = entry.value as int;
      }
    }

    totalPlayTimeSeconds = json['totalPlayTimeSeconds'] as int? ?? 0;
    enemiesDefeated = json['enemiesDefeated'] as int? ?? 0;
    itemsCrafted = json['itemsCrafted'] as int? ?? 0;
    distanceTraveled = json['distanceTraveled'] as int? ?? 0;

    GameLogger.info(
      '[PlayerProgressManager] Loaded: ${_flags.length} flags, '
      '${_achievements.length} achievements, $totalPlayTimeSeconds seconds played',
    );
  }

  void reset() {
    GameLogger.info('[PlayerProgressManager] Resetting all player progress');
    _flags.clear();
    _achievements.clear();
    totalPlayTimeSeconds = 0;
    enemiesDefeated = 0;
    itemsCrafted = 0;
    distanceTraveled = 0;
  }

  @override
  String toString() =>
      'PlayerProgress(Flags: ${_flags.length}, '
      'Achievements: ${_achievements.length}, PlayTime: ${totalPlayTimeSeconds}s)';
}
