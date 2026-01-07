import 'dart:async';
import 'package:flutter/foundation.dart';

import 'day_state.dart';
import 'game_time.dart';
import 'time_constants.dart';
import 'time_scheduler.dart';
import 'weather_type.dart';

/// Central authority for time/day progression.
class TimeManager {
  TimeManager._();

  static final TimeManager instance = TimeManager._();

  final ValueNotifier<GameTime> timeNotifier =
      ValueNotifier<GameTime>(GameTime(hour: TimeConstants.kStartHour, minute: 0));
  final ValueNotifier<DayState> dayStateNotifier =
      ValueNotifier<DayState>(DayState.dayOne());

  final StreamController<GameTime> _tickStream = StreamController.broadcast();
  Stream<GameTime> get tickStream => _tickStream.stream;

  final TimeScheduler scheduler = TimeScheduler();

  final List<void Function(DayState previous, DayState current)>
      _dayChangeListeners = [];

  Timer? _timer;
  bool _isRunning = false;
  double _accumulator = 0;
  bool _isPaused = false;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  GameTime get currentTime => timeNotifier.value;
  DayState get currentDayState => dayStateNotifier.value;
  int get currentHour => timeNotifier.value.hour;
  int get currentMinute => timeNotifier.value.minute;

  void addDayChangeListener(
    void Function(DayState previous, DayState current) listener,
  ) {
    if (_dayChangeListeners.contains(listener)) return;
    _dayChangeListeners.add(listener);
  }

  void removeDayChangeListener(
    void Function(DayState previous, DayState current) listener,
  ) {
    _dayChangeListeners.remove(listener);
  }

  /// Start ticking the clock.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    final secondsPerTick =
        TimeConstants.kMinutesPerTick * TimeConstants.kRealSecondsPerGameMinute;
    _timer = Timer.periodic(
      Duration(milliseconds: (secondsPerTick * 1000).round()),
      _onTimer,
    );
  }

  /// Stop ticking the clock.
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Pause ticking without disposing timers (useful for menus/cutscenes).
  void pause() {
    _isPaused = true;
  }

  /// Resume ticking after a pause.
  void resume() {
    _isPaused = false;
  }

  /// Manual tick for integration tests or external drive.
  void tick(double dtSeconds) {
    _advanceBySeconds(dtSeconds);
  }

  void _onTimer(Timer _) {
    final secondsPerTick =
        TimeConstants.kMinutesPerTick * TimeConstants.kRealSecondsPerGameMinute;
    _advanceBySeconds(secondsPerTick);
  }

  void _advanceBySeconds(double dtSeconds) {
    if (_isPaused) return;

    _accumulator += dtSeconds;
    final secondsPerTick = TimeConstants.kMinutesPerTick *
        TimeConstants.kRealSecondsPerGameMinute;
    while (_accumulator + 1e-6 >= secondsPerTick) {
      _accumulator -= secondsPerTick;
      _advanceByMinutes(TimeConstants.kMinutesPerTick);
    }
  }

  void _advanceByMinutes(int minutes) {
    final currentTime = timeNotifier.value;
    final newTime = currentTime.addMinutes(minutes);
    timeNotifier.value = newTime;
    _tickStream.add(newTime);

    scheduler.handleTick(
      currentDayState: dayStateNotifier.value,
      currentTime: newTime,
    );

    // Detect cutoff (2:00 next day) relative to the start hour (6:00).
    final totalMinutesPerDay = TimeConstants.kHoursPerDay * 60;
    final startOffset = TimeConstants.kStartHour * 60;
    final playableMinutes =
        ((TimeConstants.kHoursPerDay - TimeConstants.kStartHour + TimeConstants.kSleepHour) %
                TimeConstants.kHoursPerDay) *
            60; // 20h => 1200 minutes

    int _elapsedSinceStart(GameTime t) {
      return (t.totalMinutes - startOffset + totalMinutesPerDay) % totalMinutesPerDay;
    }

    final previousElapsed = _elapsedSinceStart(currentTime);
    final newElapsed = _elapsedSinceStart(newTime);

    final crossedCutoff = previousElapsed < playableMinutes && newElapsed >= playableMinutes;

    if (crossedCutoff) {
      advanceToNextDay();
    }
  }

  /// Advance to the next day and reset clock to start hour.
  void advanceToNextDay() {
    final previousDay = dayStateNotifier.value;
    final nextDay = _nextDayState();
    // Reset clock before notifying listeners so saves/load capture 06:00.
    timeNotifier.value = GameTime(hour: TimeConstants.kStartHour, minute: 0);
    dayStateNotifier.value = nextDay;
    _notifyDayChange(previousDay, nextDay);
  }

  DayState _nextDayState() {
    return dayStateNotifier.value.nextDay(
      weatherRng: DayState.defaultWeatherRng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': timeNotifier.value.toJson(),
      'day': dayStateNotifier.value.toJson(),
      'isRunning': _isRunning,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    final time = GameTime.fromJson(json['time'] as Map<String, dynamic>);
    final day = DayState.fromJson(json['day'] as Map<String, dynamic>);
    timeNotifier.value = time;
    dayStateNotifier.value = day;

    final wasRunning = json['isRunning'] as bool? ?? false;
    if (wasRunning) start();
  }

  /// Reset to day-one, 6:00 AM and clear scheduled tasks.
  void reset() {
    stop();
    scheduler.clear();
    _accumulator = 0;
    _isPaused = false;
    timeNotifier.value = GameTime(hour: TimeConstants.kStartHour, minute: 0);
    dayStateNotifier.value = DayState.dayOne();
  }

  void _notifyDayChange(DayState previous, DayState current) {
    for (final listener in List.from(_dayChangeListeners)) {
      try {
        listener(previous, current);
      } catch (_) {
        // Swallow listener errors to avoid breaking the time loop.
      }
    }
  }
}
