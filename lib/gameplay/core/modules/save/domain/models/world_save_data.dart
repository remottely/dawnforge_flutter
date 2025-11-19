/// Domain model for world/environment save data.
///
/// Represents the persistent state of the game world including
/// time, season, weather, and world progression.
///
/// **Stardew Valley Inspiration:**
/// - Day/Season progression
/// - Time of day system
/// - Weather patterns
/// - World events and festivals
final class WorldSaveData {
  /// Current in-game day (starts at 1)
  final int currentDay;

  /// Current season (spring, summer, fall, winter)
  final String currentSeason;

  /// Current year
  final int currentYear;

  /// Time in seconds since start of day (0-86400)
  final int timeOfDaySeconds;

  /// Current weather state
  final String weather;

  /// Active world events/festivals
  final List<String> activeEvents;

  /// Completed world events (one-time events)
  final List<String> completedEvents;

  /// Active map states (which maps have been visited/unlocked)
  final Map<String, bool> unlockedMaps;

  /// Current active map ID
  final String? currentMapId;

  /// World settings
  final double timeScale;
  final bool isPaused;

  const WorldSaveData({
    required this.currentDay,
    required this.currentSeason,
    required this.currentYear,
    required this.timeOfDaySeconds,
    required this.weather,
    required this.activeEvents,
    required this.completedEvents,
    required this.unlockedMaps,
    required this.timeScale,
    required this.isPaused,
    this.currentMapId,
  });

  /// Creates default initial world state.
  factory WorldSaveData.initial() {
    return WorldSaveData(
      currentDay: 1,
      currentSeason: 'spring',
      currentYear: 1,
      timeOfDaySeconds: 21600, // 6:00 AM
      weather: 'sunny',
      activeEvents: const [],
      completedEvents: const [],
      unlockedMaps: const {'farm': true, 'town': true},
      timeScale: 1.0,
      isPaused: false,
      currentMapId: 'farm',
    );
  }

  /// Creates from JSON map.
  factory WorldSaveData.fromJson(Map<String, dynamic> json) {
    return WorldSaveData(
      currentDay: json['currentDay'] as int? ?? 1,
      currentSeason: json['currentSeason'] as String? ?? 'spring',
      currentYear: json['currentYear'] as int? ?? 1,
      timeOfDaySeconds: json['timeOfDaySeconds'] as int? ?? 21600,
      weather: json['weather'] as String? ?? 'sunny',
      activeEvents:
          (json['activeEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      completedEvents:
          (json['completedEvents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      unlockedMaps:
          (json['unlockedMaps'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as bool),
          ) ??
          const {'farm': true},
      timeScale: (json['timeScale'] as num?)?.toDouble() ?? 1.0,
      isPaused: json['isPaused'] as bool? ?? false,
      currentMapId: json['currentMapId'] as String?,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'currentDay': currentDay,
      'currentSeason': currentSeason,
      'currentYear': currentYear,
      'timeOfDaySeconds': timeOfDaySeconds,
      'weather': weather,
      'activeEvents': activeEvents,
      'completedEvents': completedEvents,
      'unlockedMaps': unlockedMaps,
      'timeScale': timeScale,
      'isPaused': isPaused,
      if (currentMapId != null) 'currentMapId': currentMapId,
    };
  }

  /// Validates the world state.
  bool isValid() {
    return currentDay > 0 &&
        currentYear > 0 &&
        timeOfDaySeconds >= 0 &&
        timeOfDaySeconds < 86400 &&
        _isValidSeason(currentSeason) &&
        _isValidWeather(weather) &&
        timeScale > 0;
  }

  bool _isValidSeason(String season) {
    return ['spring', 'summer', 'fall', 'winter'].contains(season);
  }

  bool _isValidWeather(String weather) {
    return ['sunny', 'rainy', 'snowy', 'stormy', 'cloudy'].contains(weather);
  }

  /// Gets the current time of day in HH:MM format.
  String getFormattedTime() {
    final hours = timeOfDaySeconds ~/ 3600;
    final minutes = (timeOfDaySeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Gets human-readable season name.
  String get seasonDisplayName {
    return currentSeason[0].toUpperCase() + currentSeason.substring(1);
  }

  WorldSaveData copyWith({
    int? currentDay,
    String? currentSeason,
    int? currentYear,
    int? timeOfDaySeconds,
    String? weather,
    List<String>? activeEvents,
    List<String>? completedEvents,
    Map<String, bool>? unlockedMaps,
    double? timeScale,
    bool? isPaused,
    String? currentMapId,
  }) {
    return WorldSaveData(
      currentDay: currentDay ?? this.currentDay,
      currentSeason: currentSeason ?? this.currentSeason,
      currentYear: currentYear ?? this.currentYear,
      timeOfDaySeconds: timeOfDaySeconds ?? this.timeOfDaySeconds,
      weather: weather ?? this.weather,
      activeEvents: activeEvents ?? this.activeEvents,
      completedEvents: completedEvents ?? this.completedEvents,
      unlockedMaps: unlockedMaps ?? this.unlockedMaps,
      timeScale: timeScale ?? this.timeScale,
      isPaused: isPaused ?? this.isPaused,
      currentMapId: currentMapId ?? this.currentMapId,
    );
  }

  @override
  String toString() {
    return 'WorldSaveData('
        'Day $currentDay of $seasonDisplayName, Year $currentYear, '
        'Time: ${getFormattedTime()}, '
        'Weather: $weather, '
        'Maps: ${unlockedMaps.length}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldSaveData &&
        other.currentDay == currentDay &&
        other.currentSeason == currentSeason &&
        other.currentYear == currentYear &&
        other.timeOfDaySeconds == timeOfDaySeconds &&
        other.weather == weather &&
        _listEquals(other.activeEvents, activeEvents) &&
        _listEquals(other.completedEvents, completedEvents) &&
        _mapEquals(other.unlockedMaps, unlockedMaps) &&
        other.timeScale == timeScale &&
        other.isPaused == isPaused &&
        other.currentMapId == currentMapId;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentDay,
      currentSeason,
      currentYear,
      timeOfDaySeconds,
      weather,
      Object.hashAll(activeEvents),
      Object.hashAll(completedEvents),
      Object.hashAll(
        unlockedMaps.entries.map((e) => Object.hash(e.key, e.value)),
      ),
      timeScale,
      isPaused,
      currentMapId,
    );
  }

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mapEquals(Map<String, bool> a, Map<String, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
