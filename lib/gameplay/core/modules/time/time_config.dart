/// Configuration constants for the time system
///
/// Defines the duration of each time period and the speed of time passage
final class TimeConfig {
  TimeConfig._();

  // ========== REAL TIME CONFIGURATION ==========

  /// Real seconds for one in-game day
  /// Default: 1200 seconds (20 minutes) = 1 day
  static const double realSecondsPerDay = 1200.0;

  /// Seconds in one in-game day (24 hours)
  static const double secondsPerDay = 86400.0;

  // ========== TIME OF DAY BOUNDARIES (in seconds) ==========

  /// Morning starts at 6:00 (6 hours * 3600 seconds)
  static const double morningStartTime = 21600.0; // 6h

  /// Noon starts at 12:00 (12 hours * 3600 seconds)
  static const double noonStartTime = 43200.0; // 12h

  /// Evening starts at 18:00 (18 hours * 3600 seconds)
  static const double eveningStartTime = 64800.0; // 18h

  /// Night starts at 21:00 (21 hours * 3600 seconds)
  static const double nightStartTime = 75600.0; // 21h

  // ========== HELPER METHODS ==========

  /// Get the time scale factor (how fast in-game time passes)
  ///
  /// Example: If 20 real minutes = 1 day, then 1 real second = 72 in-game seconds
  static double get defaultTimeScale => secondsPerDay / realSecondsPerDay;

  /// Convert in-game seconds to hours
  static double secondsToHours(double seconds) => seconds / 3600.0;

  /// Convert hours to in-game seconds
  static double hoursToSeconds(double hours) => hours * 3600.0;

  /// Get time period name for debugging
  static String getTimePeriodName(double timeInSeconds) {
    final normalizedTime = timeInSeconds % secondsPerDay;

    if (normalizedTime >= morningStartTime && normalizedTime < noonStartTime) {
      return 'Morning';
    } else if (normalizedTime >= noonStartTime &&
        normalizedTime < eveningStartTime) {
      return 'Noon';
    } else if (normalizedTime >= eveningStartTime &&
        normalizedTime < nightStartTime) {
      return 'Evening';
    } else {
      return 'Night';
    }
  }
}
