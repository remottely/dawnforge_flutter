final class TimeConstants {
  TimeConstants._();

  static const double realSecondsPerDay = 1200.0;

  static const double secondsPerDay = 86400.0;

  static const double morningStartTime = 21600.0;

  static const double noonStartTime = 43200.0;

  static const double eveningStartTime = 64800.0;

  static const double nightStartTime = 75600.0;

  static double get defaultTimeScale => secondsPerDay / realSecondsPerDay;
}
