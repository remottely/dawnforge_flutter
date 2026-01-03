/// Constants for the in-game clock and calendar.
final class TimeConstants {
  TimeConstants._();

  /// In-game hours in a full day. We still model 24h, but the playable span is
  /// effectively 20h (from 6:00 to 2:00 next day) before forced sleep.
  static const int kHoursPerDay = 24;

  /// Granularity of each tick in in-game minutes.
  static const int kMinutesPerTick = 10;

  /// Real seconds per in-game minute (configurable to tune pacing).
  static const double kRealSecondsPerGameMinute = 0.7;

  /// Forced sleep cutoff hour (2 AM).
  static const int kSleepHour = 2;

  /// Default start hour (6 AM).
  static const int kStartHour = 6;

  /// Days per season (Stardew Valley rules).
  static const int kDaysPerSeason = 28;

  /// Seasons per year.
  static const int kSeasonsPerYear = 4;

  /// Energy drain expectation per hour (hook only; implementation elsewhere).
  static const double kExpectedEnergyDrainPerHour = 1.0;

  /// Weather types (kept here for quick reference; actual enum lives in
  /// weather_type.dart).
  static const List<String> kWeatherTypes = [
    'sunny',
    'rain',
    'storm',
    'snow',
    'festival',
  ];

  /// Helper: wrap day number within a season.
  static int wrapDay(int dayNumber) {
    final wrapped = ((dayNumber - 1) % kDaysPerSeason) + 1;
    return wrapped;
  }

  /// Helper: advance season index with wrap.
  static int wrapSeasonIndex(int seasonIndex) {
    return seasonIndex % kSeasonsPerYear;
  }
}
