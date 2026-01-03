import 'dart:collection';

import 'day_state.dart';
import 'game_time.dart';
import 'season_type.dart';
import 'time_constants.dart';

/// Defines repeat constraints for scheduled callbacks.
class RepeatRule {
  final int intervalDays; // e.g., 1 for daily, 7 for weekly.
  final Set<SeasonType>? seasons; // Allowed seasons (null = all).
  final Set<int>? dayNumbers; // Allowed day-of-season (1-28).
  final Set<int>? weekdayIndices; // Allowed weekdays (0 = Monday).

  const RepeatRule({
    this.intervalDays = 1,
    this.seasons,
    this.dayNumbers,
    this.weekdayIndices,
  });

  const RepeatRule.daily({
    Set<SeasonType>? seasons,
    Set<int>? dayNumbers,
    Set<int>? weekdayIndices,
  })  : intervalDays = 1,
        seasons = seasons,
        dayNumbers = dayNumbers,
        weekdayIndices = weekdayIndices;

  bool allows(_DayProjection day) {
    if (seasons != null && !seasons!.contains(day.season)) return false;
    if (dayNumbers != null && !dayNumbers!.contains(day.dayNumber)) return false;
    if (weekdayIndices != null && !weekdayIndices!.contains(day.weekdayIndex)) {
      return false;
    }
    return true;
  }
}

/// Represents a scheduled callback in absolute in-game time.
class ScheduledTask {
  final String id;
  int targetEpochDay; // Monotonic day index from game start (Day 1 = 0).
  final int minuteOfDay; // 0-1439
  final void Function() callback;
  final RepeatRule? repeat;

  ScheduledTask({
    required this.id,
    required this.targetEpochDay,
    required this.minuteOfDay,
    required this.callback,
    this.repeat,
  });
}

/// Scheduler that triggers callbacks when in-game time reaches targets.
class TimeScheduler {
  final Map<String, ScheduledTask> _tasks = HashMap();
  final int _minutesPerDay = TimeConstants.kHoursPerDay * 60;

  int _yearOffset = 0; // Tracks completed years to keep epoch days monotonic.
  int? _lastOrdinalInYear;
  int? _currentEpochDay;
  int? _lastEpochMinute;

  /// Schedule a callback at an absolute day index and clock time.
  ///
  /// [dayIndex] is the absolute day since game start (Day 1 = 0).
  void scheduleAbsolute({
    required String id,
    required int dayIndex,
    required GameTime time,
    required void Function() callback,
    RepeatRule? repeat,
  }) {
    _tasks[id] = ScheduledTask(
      id: id,
      targetEpochDay: dayIndex,
      minuteOfDay: time.totalMinutes % _minutesPerDay,
      callback: callback,
      repeat: repeat,
    );
  }

  /// Schedule a callback relative to the current time.
  void scheduleRelative({
    required String id,
    required DayState currentDay,
    required GameTime currentTime,
    required int minutesFromNow,
    required void Function() callback,
    RepeatRule? repeat,
  }) {
    final baseDay = _updateEpochDay(currentDay);
    final totalMinutes = currentTime.totalMinutes + minutesFromNow;
    final targetDay = baseDay + (totalMinutes ~/ _minutesPerDay);
    final minuteOfDay = totalMinutes % _minutesPerDay;

    _tasks[id] = ScheduledTask(
      id: id,
      targetEpochDay: targetDay,
      minuteOfDay: minuteOfDay,
      callback: callback,
      repeat: repeat,
    );
  }

  /// Cancel a task by id.
  void cancel(String id) => _tasks.remove(id);

  /// Call on every tick to fire due tasks. Handles catch-up on time jumps.
  void handleTick({
    required DayState currentDayState,
    required GameTime currentTime,
  }) {
    final epochDay = _updateEpochDay(currentDayState);
    final currentEpochMinute = _toEpochMinute(epochDay, currentTime.totalMinutes);
    _lastEpochMinute ??= currentEpochMinute - TimeConstants.kMinutesPerTick;

    // Snapshot keys to avoid mutation during iteration.
    final taskIds = List<String>.from(_tasks.keys);
    for (final id in taskIds) {
      final task = _tasks[id];
      if (task == null) continue;

      // Loop to catch up multiple missed occurrences (manual day jumps).
      while (true) {
        final taskEpochMinute = _toEpochMinute(task.targetEpochDay, task.minuteOfDay);
        final inWindow =
            taskEpochMinute > _lastEpochMinute! && taskEpochMinute <= currentEpochMinute;
        if (!inWindow) break;

        final projection = _projectDay(task.targetEpochDay);
        if (task.repeat != null && !task.repeat!.allows(projection)) {
          final nextDay = _nextRepeatDay(task);
          if (nextDay == null) {
            _tasks.remove(task.id);
            break;
          }
          task.targetEpochDay = nextDay;
          continue;
        }

        task.callback();

        if (task.repeat != null) {
          final nextDay = _nextRepeatDay(task);
          if (nextDay == null) {
            _tasks.remove(task.id);
            break;
          }
          task.targetEpochDay = nextDay;
          continue; // Catch-up loop in case we skipped multiple days.
        }

        _tasks.remove(task.id);
        break;
      }
    }

    _lastEpochMinute = currentEpochMinute;
  }

  void clear() => _tasks.clear();

  int _updateEpochDay(DayState state) {
    final ordinal = _ordinalInYear(state);
    final daysPerYear = TimeConstants.kDaysPerSeason * TimeConstants.kSeasonsPerYear;
    if (_lastOrdinalInYear != null && ordinal < _lastOrdinalInYear!) {
      // Wrapped to a new year.
      _yearOffset += daysPerYear;
    }
    _lastOrdinalInYear = ordinal;
    _currentEpochDay = _yearOffset + ordinal;
    return _currentEpochDay!;
  }

  int _ordinalInYear(DayState state) {
    final ordinal =
        state.season.index * TimeConstants.kDaysPerSeason + (state.dayNumber - 1);
    return ordinal;
  }

  int _toEpochMinute(int epochDay, int minuteOfDay) {
    return epochDay * _minutesPerDay + minuteOfDay;
  }

  _DayProjection _projectDay(int epochDay) {
    final daysPerYear = TimeConstants.kDaysPerSeason * TimeConstants.kSeasonsPerYear;
    final dayWithinYear = epochDay % daysPerYear;
    final seasonIndex = dayWithinYear ~/ TimeConstants.kDaysPerSeason;
    final dayNumber = (dayWithinYear % TimeConstants.kDaysPerSeason) + 1;
    final weekdayIndex = epochDay % 7;
    return _DayProjection(
      dayNumber: dayNumber,
      season: SeasonType.values[seasonIndex % SeasonType.values.length],
      weekdayIndex: weekdayIndex < 0 ? (weekdayIndex + 7) % 7 : weekdayIndex,
    );
  }

  int? _nextRepeatDay(ScheduledTask task) {
    final rule = task.repeat!;
    final interval = rule.intervalDays.clamp(1, 365);
    // Limit search to avoid infinite loops if filters are impossible.
    final maxSearch = TimeConstants.kDaysPerSeason * TimeConstants.kSeasonsPerYear * 3;
    var candidate = task.targetEpochDay + interval;
    for (var i = 0; i < maxSearch; i++) {
      final projection = _projectDay(candidate);
      if (rule.allows(projection)) {
        return candidate;
      }
      candidate += interval;
    }
    return null;
  }
}

class _DayProjection {
  final int dayNumber;
  final SeasonType season;
  final int weekdayIndex;

  const _DayProjection({
    required this.dayNumber,
    required this.season,
    required this.weekdayIndex,
  });
}
