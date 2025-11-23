import 'dart:developer' as developer;

/// Singleton manager for player progress tracking
///
/// Manages achievements, progress flags, and player statistics that persist
/// across game sessions. Used to track quests, NPCs met, areas unlocked, etc.
///
/// Usage:
/// ```dart
/// // Complete quest
/// PlayerProgressManager.instance.setFlag('quest_1_completed');
///
/// // Check progress
/// if (PlayerProgressManager.instance.hasFlag('quest_1_completed')) {
///   // Unlock content
/// }
///
/// // Update achievement
/// PlayerProgressManager.instance.incrementAchievement('enemies_defeated');
/// ```
final class PlayerProgressManager {
  PlayerProgressManager._();

  /// Singleton instance
  static final instance = PlayerProgressManager._();

  // ========== STATE ==========

  /// Boolean flags for tracking binary progress states
  /// Examples: "quest_1_completed", "npc_met_blacksmith", "area_forest_unlocked"
  final Set<String> _flags = {};

  /// Achievements with numeric progress tracking
  /// Examples: {"enemies_defeated": 50, "items_crafted": 10}
  final Map<String, int> _achievements = {};

  /// Total playtime in seconds
  int totalPlayTimeSeconds = 0;

  /// Total enemies defeated
  int enemiesDefeated = 0;

  /// Total items crafted
  int itemsCrafted = 0;

  /// Total distance traveled (in pixels or units)
  int distanceTraveled = 0;

  // ========== FLAGS SYSTEM ==========

  /// Set a progress flag
  ///
  /// [flag] - Unique identifier for the flag (e.g., "quest_1_completed")
  void setFlag(String flag) {
    if (_flags.add(flag)) {
      developer.log('[PlayerProgressManager] Flag set: $flag');
    }
  }

  /// Check if a flag is set
  ///
  /// [flag] - Flag identifier to check
  /// Returns true if the flag exists
  bool hasFlag(String flag) {
    return _flags.contains(flag);
  }

  /// Remove a progress flag
  ///
  /// [flag] - Flag identifier to remove
  void removeFlag(String flag) {
    if (_flags.remove(flag)) {
      developer.log('[PlayerProgressManager] Flag removed: $flag');
    }
  }

  /// Get all current flags
  Set<String> getAllFlags() {
    return Set.from(_flags);
  }

  // ========== ACHIEVEMENTS SYSTEM ==========

  /// Increment achievement progress
  ///
  /// [achievementId] - Unique identifier for the achievement
  /// [amount] - Amount to increment (default: 1)
  void incrementAchievement(String achievementId, [int amount = 1]) {
    final previousValue = _achievements[achievementId] ?? 0;
    final newValue = previousValue + amount;
    _achievements[achievementId] = newValue;

    developer.log(
      '[PlayerProgressManager] Achievement "$achievementId" incremented: '
      '$previousValue -> $newValue (+$amount)',
    );
  }

  /// Get current progress for an achievement
  ///
  /// [achievementId] - Achievement identifier
  /// Returns current progress value (0 if achievement doesn't exist)
  int getAchievementProgress(String achievementId) {
    return _achievements[achievementId] ?? 0;
  }

  /// Check if an achievement is completed
  ///
  /// [achievementId] - Achievement identifier
  /// [requiredAmount] - Required amount to complete the achievement
  /// Returns true if current progress >= required amount
  bool isAchievementCompleted(String achievementId, int requiredAmount) {
    final current = getAchievementProgress(achievementId);
    return current >= requiredAmount;
  }

  /// Get all achievements with their current progress
  Map<String, int> getAllAchievements() {
    return Map.from(_achievements);
  }

  // ========== STATISTICS ==========

  /// Update multiple statistics at once
  ///
  /// [updates] - Map of stat names to increment values
  /// Supported keys: 'totalPlayTimeSeconds', 'enemiesDefeated',
  ///                 'itemsCrafted', 'distanceTraveled'
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
          developer.log(
            '[PlayerProgressManager] Unknown stat: ${entry.key}',
            level: 900,
          );
      }
    }

    if (updates.isNotEmpty) {
      developer.log('[PlayerProgressManager] Stats updated: $updates');
    }
  }

  // ========== HELPER METHODS ==========

  /// Get all completed quest flags (flags starting with 'quest_' and ending with '_completed')
  List<String> getCompletedQuests() {
    return _flags
        .where(
          (flag) => flag.startsWith('quest_') && flag.endsWith('_completed'),
        )
        .toList();
  }

  /// Get all met NPC flags (flags starting with 'npc_met_')
  List<String> getMetNPCs() {
    return _flags.where((flag) => flag.startsWith('npc_met_')).toList();
  }

  /// Get all unlocked area flags (flags starting with 'area_' and ending with '_unlocked')
  List<String> getUnlockedAreas() {
    return _flags
        .where((flag) => flag.startsWith('area_') && flag.endsWith('_unlocked'))
        .toList();
  }

  // ========== SERIALIZATION ==========

  /// Serialize player progress to JSON
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

  /// Deserialize player progress from JSON
  void fromJson(Map<String, dynamic> json) {
    developer.log('[PlayerProgressManager] Loading player progress from JSON');

    // Load flags
    _flags.clear();
    final flagsList = json['flags'] as List<dynamic>?;
    if (flagsList != null) {
      _flags.addAll(flagsList.cast<String>());
    }

    // Load achievements
    _achievements.clear();
    final achievementsMap = json['achievements'] as Map<String, dynamic>?;
    if (achievementsMap != null) {
      for (final entry in achievementsMap.entries) {
        _achievements[entry.key] = entry.value as int;
      }
    }

    // Load statistics
    totalPlayTimeSeconds = json['totalPlayTimeSeconds'] as int? ?? 0;
    enemiesDefeated = json['enemiesDefeated'] as int? ?? 0;
    itemsCrafted = json['itemsCrafted'] as int? ?? 0;
    distanceTraveled = json['distanceTraveled'] as int? ?? 0;

    developer.log(
      '[PlayerProgressManager] Loaded: ${_flags.length} flags, '
      '${_achievements.length} achievements, $totalPlayTimeSeconds seconds played',
    );
  }

  /// Reset all progress to initial state
  void reset() {
    developer.log('[PlayerProgressManager] Resetting all player progress');
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
