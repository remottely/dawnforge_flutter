import 'package:darkness_dungeon/gameplay/inventory/entities/enums/season.dart';
import 'package:flutter/foundation.dart';

import 'day_state.dart';
import 'game_time.dart';
import 'time_manager.dart';
import 'weather_type.dart';

/// Lightweight HUD adapter that exposes formatted time/day strings.
class TimeHudAdapter {
  final TimeManager _timeManager;

  final ValueNotifier<String> timeLabel = ValueNotifier('');
  final ValueNotifier<String> dayLabel = ValueNotifier('');
  final ValueNotifier<String> seasonLabel = ValueNotifier('');
  final ValueNotifier<String> weatherLabel = ValueNotifier('');

  late final VoidCallback _timeListener;
  late final VoidCallback _dayListener;

  TimeHudAdapter(TimeManager manager) : _timeManager = manager {
    _timeListener = () => _updateTime(_timeManager.timeNotifier.value);
    _dayListener = () => _updateDay(_timeManager.dayStateNotifier.value);

    _timeManager.timeNotifier.addListener(_timeListener);
    _timeManager.dayStateNotifier.addListener(_dayListener);

    _updateTime(_timeManager.timeNotifier.value);
    _updateDay(_timeManager.dayStateNotifier.value);
  }

  void dispose() {
    _timeManager.timeNotifier.removeListener(_timeListener);
    _timeManager.dayStateNotifier.removeListener(_dayListener);
  }

  void _updateTime(GameTime time) {
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    timeLabel.value = '$hh:$mm';
  }

  void _updateDay(DayState day) {
    dayLabel.value = 'Day ${day.dayNumber}';
    seasonLabel.value = _seasonName(day.seasonType);
    weatherLabel.value = _weatherName(day.weather);
  }

  String _seasonName(SeasonType seasonType) {
    switch (seasonType) {
      case SeasonType.spring:
        return 'Spring';
      case SeasonType.summer:
        return 'Summer';
      case SeasonType.fall:
        return 'Fall';
      case SeasonType.winter:
        return 'Winter';
      case SeasonType.any:
        return 'Any';
      case SeasonType.unknown:
        return 'Unknown';
    }
  }

  String _weatherName(WeatherType weather) {
    switch (weather) {
      case WeatherType.sunny:
        return 'Sunny';
      case WeatherType.rain:
        return 'Rain';
      case WeatherType.storm:
        return 'Storm';
      case WeatherType.snow:
        return 'Snow';
      case WeatherType.festival:
        return 'Festival';
    }
  }
}
