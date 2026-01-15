// final class TimeHelper {
//   TimeHelper._();

//   static const double realSecondsPerDay = 1200.0;

//   static const double secondsPerDay = 86400.0;

//   static const double morningStartTime = 21600.0;

//   static const double noonStartTime = 43200.0;

//   static const double eveningStartTime = 64800.0;

//   static const double nightStartTime = 75600.0;

//   static double get defaultTimeScale => secondsPerDay / realSecondsPerDay;

//   static double secondsToHours(double seconds) => seconds / 3600.0;

//   static double hoursToSeconds(double hours) => hours * 3600.0;

//   static String getTimePeriodName(double timeInSeconds) {
//     final normalizedTime = timeInSeconds % secondsPerDay;

//     if (normalizedTime >= morningStartTime && normalizedTime < noonStartTime) {
//       return 'Morning';
//     } else if (normalizedTime >= noonStartTime &&
//         normalizedTime < eveningStartTime) {
//       return 'Noon';
//     } else if (normalizedTime >= eveningStartTime &&
//         normalizedTime < nightStartTime) {
//       return 'Evening';
//     } else {
//       return 'Night';
//     }
//   }
// }
