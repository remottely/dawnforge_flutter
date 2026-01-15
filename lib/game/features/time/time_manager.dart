import 'dart:async' as async;
import 'package:bonfire/bonfire.dart';
import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:dawnforge/game/core/systems/map/map_def.dart';
import 'package:dawnforge/game/core/systems/map/map_transition_controller.dart';
import 'package:dawnforge/game/core/utils/app_environment.dart';
import 'package:flutter/foundation.dart';

import 'day_state.dart';
import 'game_time.dart';
import 'time_constants.dart';
import 'time_scheduler.dart';

/// Central authority for time/day progression.
class TimeManager {
  TimeManager._();

  static final TimeManager instance = TimeManager._();

  final ValueNotifier<GameTime> timeNotifier = ValueNotifier<GameTime>(
    GameTime(hour: TimeConstants.kStartHour, minute: 0),
  );
  final ValueNotifier<DayState> dayStateNotifier = ValueNotifier<DayState>(
    DayState.dayOne(),
  );

  final async.StreamController<GameTime> _tickStream =
      async.StreamController.broadcast();
  Stream<GameTime> get tickStream => _tickStream.stream;

  final TimeScheduler scheduler = TimeScheduler();

  final List<void Function(DayState previous, DayState current)>
  _dayChangeListeners = [];

  async.Timer? _timer;
  bool _isRunning = false;
  double _accumulator = 0;
  bool _isPaused = false;

  BonfireGameInterface? _game;

  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;
  GameTime get currentTime => timeNotifier.value;
  DayState get currentDayState => dayStateNotifier.value;
  int get currentHour => timeNotifier.value.hour;
  int get currentMinute => timeNotifier.value.minute;

  void setGame(BonfireGameInterface game) {
    _game = game;
  }

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

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    final secondsPerTick =
        TimeConstants.kMinutesPerTick * TimeConstants.kRealSecondsPerGameMinute;
    _timer = async.Timer.periodic(
      Duration(milliseconds: (secondsPerTick * 1000).round()),
      _onTimer,
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  void tick(double dtSeconds) {
    _advanceBySeconds(dtSeconds);
  }

  void _onTimer(async.Timer _) {
    final secondsPerTick =
        TimeConstants.kMinutesPerTick * TimeConstants.kRealSecondsPerGameMinute;
    _advanceBySeconds(secondsPerTick);
  }

  void _advanceBySeconds(double dtSeconds) {
    if (_isPaused) return;

    _accumulator += dtSeconds;
    final secondsPerTick =
        TimeConstants.kMinutesPerTick * TimeConstants.kRealSecondsPerGameMinute;
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

    final playableMinutes =
        ((TimeConstants.kHoursPerDay -
                TimeConstants.kStartHour +
                TimeConstants.kSleepHour) %
            TimeConstants.kHoursPerDay) *
        60;

    int _elapsedSinceStart(GameTime t) {
      return (t.totalMinutes -
              TimeConstants.startOffset +
              TimeConstants.totalMinutesPerDay) %
          TimeConstants.totalMinutesPerDay;
    }

    final previousElapsed = _elapsedSinceStart(currentTime);
    final newElapsed = _elapsedSinceStart(newTime);

    final crossedCutoff =
        previousElapsed < playableMinutes && newElapsed >= playableMinutes;

    if (crossedCutoff) {
      advanceToNextDay();
    }
  }

  void advanceToNextDay() {
    final previousDay = dayStateNotifier.value;
    final nextDay = _nextDayState();

    timeNotifier.value = GameTime(hour: TimeConstants.kStartHour, minute: 0);
    dayStateNotifier.value = nextDay;

    if (!AppEnvironment.kIsDevToolsMode) {
      _teleportPlayerToHome();
    }

    _notifyDayChange(previousDay, nextDay);
  }

  void _teleportPlayerToHome() {
    try {
      // Solicita transição de mapa via controller
      MapTransitionController.instance.requestTransition(
        mapId: MapDef.kHomeMapId,
        playerPosition: Vector2(5, 5), // Posição inicial em tiles
        playerDirection: Direction.down,
      );

      GameLogger.info('[TimeManager] Solicitada transição para Home');
    } catch (e, stack) {
      GameLogger.error('[TimeManager] Erro ao solicitar transição: $e\n$stack');
    }
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

  void dispose() {
    _timer?.cancel();
    _tickStream.close();
    _game = null;
  }
}
