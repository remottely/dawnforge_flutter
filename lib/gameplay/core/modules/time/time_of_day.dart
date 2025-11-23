/// Enum representing different times of day in the game
///
/// Each time period has specific characteristics:
/// - Morning: 6h-12h (06:00-12:00)
/// - Noon: 12h-18h (12:00-18:00)
/// - Evening: 18h-21h (18:00-21:00)
/// - Night: 21h-6h (21:00-06:00)
enum TimeOfDay {
  morning,
  noon,
  evening,
  night;

  /// Serialize to JSON
  String toJson() => name;

  /// Deserialize from JSON
  static TimeOfDay fromJson(String json) => values.byName(json);

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case TimeOfDay.morning:
        return 'Morning';
      case TimeOfDay.noon:
        return 'Noon';
      case TimeOfDay.evening:
        return 'Evening';
      case TimeOfDay.night:
        return 'Night';
    }
  }
}
