// import 'package:darkness_dungeon/core/utils/logger/game_logger.dart';

// import 'package:darkness_dungeon/gameplay/core/modules/time/time_constants.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/time/time_helper.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/time/time_of_day.dart';
// import 'package:darkness_dungeon/gameplay/core/modules/world/world_state_manager.dart';

// final class TimeManager {
//   TimeManager._();

//   static final instance = TimeManager._();

//   double _currentTime = TimeConstants.morningStartTime;

//   double _timeScale = TimeConstants.defaultTimeScale;

//   bool _isPaused = false;

//   TimeOfDay _currentTimeOfDay = TimeOfDay.morning;

//   final List<Function(TimeOfDay)> _onTimeOfDayChanged = [];

//   double get currentTime => _currentTime;

//   double get timeScale => _timeScale;

//   bool get isPaused => _isPaused;

//   TimeOfDay get currentTimeOfDay => _currentTimeOfDay;

//   int get currentHour => (_currentTime / 3600).floor();

//   int get currentMinute => ((_currentTime % 3600) / 60).floor();

//   void update(double dt) {
//     if (_isPaused) return;

//     final previousTime = _currentTime;
//     final previousDay = WorldStateManager.instance.currentDay;

//     _currentTime += dt * _timeScale;

//     if (previousTime < TimeConstants.secondsPerDay &&
//         _currentTime >= TimeConstants.secondsPerDay) {
//       GameLogger.info('[TimeManager] New day begins! Advancing to day ${previousDay + 1}');
//       WorldStateManager.instance.advanceDay();
//     }

//     _currentTime = _currentTime % TimeConstants.secondsPerDay;

//     _updateTimeOfDay();
//   }

//   void _updateTimeOfDay() {
//     final newTimeOfDay = _calculateTimeOfDay(_currentTime);

//     if (newTimeOfDay != _currentTimeOfDay) {
//       final previousTimeOfDay = _currentTimeOfDay;
//       _currentTimeOfDay = newTimeOfDay;

//       GameLogger.info('[TimeManager] Time of day changed: $previousTimeOfDay -> $newTimeOfDay '
//         '(${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')})');

//       WorldStateManager.instance.setTimeOfDay(newTimeOfDay);

//       for (final callback in _onTimeOfDayChanged) {
//         try {
//           callback(newTimeOfDay);
//         } catch (e) {
//           GameLogger.warning('[TimeManager] Error in time of day callback: $e');
//         }
//       }
//     }
//   }

//   TimeOfDay _calculateTimeOfDay(double timeInSeconds) {
//     if (timeInSeconds >= TimeConstants.morningStartTime &&
//         timeInSeconds < TimeConstants.noonStartTime) {
//       return TimeOfDay.morning;
//     } else if (timeInSeconds >= TimeConstants.noonStartTime &&
//         timeInSeconds < TimeConstants.eveningStartTime) {
//       return TimeOfDay.noon;
//     } else if (timeInSeconds >= TimeConstants.eveningStartTime &&
//         timeInSeconds < TimeConstants.nightStartTime) {
//       return TimeOfDay.evening;
//     } else {
//       return TimeOfDay.night;
//     }
//   }

//   void setTimeScale(double scale) {
//     if (scale < 0) {
//       GameLogger.warning('[TimeManager] Warning: Time scale cannot be negative, using absolute value');
//       scale = scale.abs();
//     }

//     GameLogger.info('[TimeManager] Time scale changed: $_timeScale -> $scale');
//     _timeScale = scale;
//   }

//   void pause() {
//     if (!_isPaused) {
//       GameLogger.info('[TimeManager] Time paused');
//       _isPaused = true;
//     }
//   }

//   void resume() {
//     if (_isPaused) {
//       GameLogger.info('[TimeManager] Time resumed');
//       _isPaused = false;
//     }
//   }

//   void setTime(double timeInSeconds) {
//     if (timeInSeconds < 0 || timeInSeconds >= TimeConstants.secondsPerDay) {
//       GameLogger.warning('[TimeManager] Warning: Invalid time value, wrapping to valid range');
//     }

//     final previousTime = _currentTime;
//     _currentTime = timeInSeconds % TimeConstants.secondsPerDay;

//     GameLogger.info('[TimeManager] Time set: ${TimeHelper.secondsToHours(previousTime).toStringAsFixed(2)}h -> '
//       '${TimeHelper.secondsToHours(_currentTime).toStringAsFixed(2)}h');

//     _updateTimeOfDay();
//   }

//   double getProgress() {
//     return _currentTime / TimeConstants.secondsPerDay;
//   }

//   void addTimeOfDayListener(Function(TimeOfDay) callback) {
//     if (!_onTimeOfDayChanged.contains(callback)) {
//       _onTimeOfDayChanged.add(callback);
//       GameLogger.info('[TimeManager] Time of day listener added (total: ${_onTimeOfDayChanged.length})');
//     }
//   }

//   void removeTimeOfDayListener(Function(TimeOfDay) callback) {
//     if (_onTimeOfDayChanged.remove(callback)) {
//       GameLogger.info('[TimeManager] Time of day listener removed (total: ${_onTimeOfDayChanged.length})');
//     }
//   }

//   void clearListeners() {
//     final count = _onTimeOfDayChanged.length;
//     _onTimeOfDayChanged.clear();
//     GameLogger.info('[TimeManager] Cleared $count listener(s)');
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'currentTime': _currentTime,
//       'timeScale': _timeScale,
//       'isPaused': _isPaused,
//       'currentTimeOfDay': _currentTimeOfDay.toJson(),
//     };
//   }

//   void fromJson(Map<String, dynamic> json) {
//     GameLogger.info('[TimeManager] Loading time state from JSON');

//     _currentTime =
//         json['currentTime'] as double? ?? TimeConstants.morningStartTime;
//     _timeScale = json['timeScale'] as double? ?? TimeConstants.defaultTimeScale;
//     _isPaused = json['isPaused'] as bool? ?? false;
//     _currentTimeOfDay = TimeOfDay.fromJson(
//       json['currentTimeOfDay'] as String? ?? 'morning',
//     );

//     GameLogger.info(
//       '[TimeManager] Loaded: ${currentHour.toString().padLeft(2, '0')}:'
//       '${currentMinute.toString().padLeft(2, '0')}, $_currentTimeOfDay, '
//       'scale: $_timeScale, paused: $_isPaused',
//     );
//   }

//   void reset() {
//     GameLogger.info('[TimeManager] Resetting time state');
//     _currentTime = TimeConstants.morningStartTime;
//     _timeScale = TimeConstants.defaultTimeScale;
//     _isPaused = false;
//     _currentTimeOfDay = TimeOfDay.morning;
//     clearListeners();
//   }

//   @override
//   String toString() =>
//       'TimeManager(${currentHour.toString().padLeft(2, '0')}:'
//       '${currentMinute.toString().padLeft(2, '0')}, $_currentTimeOfDay, '
//       'scale: $_timeScale, paused: $_isPaused)';
// }
