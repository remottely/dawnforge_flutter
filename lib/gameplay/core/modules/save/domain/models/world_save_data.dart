final class WorldSaveData {
  final int currentDay;

  final String currentSeason;

  final int currentYear;

  final int timeOfDaySeconds;

  final String weather;

  final List<String> activeEvents;

  final List<String> completedEvents;

  final Map<String, bool> unlockedMaps;

  final String? currentMapId;

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

  factory WorldSaveData.initial() {
    return WorldSaveData(
      currentDay: 1,
      currentSeason: 'spring',
      currentYear: 1,
      timeOfDaySeconds: 21600,
      weather: 'sunny',
      activeEvents: const [],
      completedEvents: const [],
      unlockedMaps: const {'farm': true, 'town': true},
      timeScale: 1.0,
      isPaused: false,
      currentMapId: 'farm',
    );
  }

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
          (json['unlockedMaps'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value as bool),
          ) ??
          const {'farm': true},
      timeScale: (json['timeScale'] as num?)?.toDouble() ?? 1.0,
      isPaused: json['isPaused'] as bool? ?? false,
      currentMapId: json['currentMapId'] as String?,
    );
  }

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

  String getFormattedTime() {
    final hours = timeOfDaySeconds ~/ 3600;
    final minutes = (timeOfDaySeconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

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
