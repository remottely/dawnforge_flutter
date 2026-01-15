enum TimeOfDay {
  morning,
  noon,
  evening,
  night;

  String toJson() => name;

  static TimeOfDay fromJson(String json) => values.byName(json);

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
