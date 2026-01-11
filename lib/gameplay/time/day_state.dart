import 'dart:math';

import 'package:dawnforge/gameplay/inventory/entities/enums/season.dart';

import 'weather_type.dart';
import 'time_constants.dart';

/// Captures calendar state (day, season, weather) for the current day.
class DayState {
  final int dayNumber; // 1-based within the season
  final SeasonType requiredSeason;
  final WeatherType weather;
  final int weekdayIndex; // 0 = Monday
  final bool isFestival;
  final String? festivalId;

  static final Random _rng = Random();

  const DayState({
    required this.dayNumber,
    required this.requiredSeason,
    required this.weather,
    required this.weekdayIndex,
    this.isFestival = false,
    this.festivalId,
  });

  DayState copyWith({
    int? dayNumber,
    SeasonType? requiredSeason,
    WeatherType? weather,
    int? weekdayIndex,
    bool? isFestival,
    String? festivalId,
  }) {
    return DayState(
      dayNumber: dayNumber ?? this.dayNumber,
      requiredSeason: requiredSeason ?? this.requiredSeason,
      weather: weather ?? this.weather,
      weekdayIndex: weekdayIndex ?? this.weekdayIndex,
      isFestival: isFestival ?? this.isFestival,
      festivalId: festivalId ?? this.festivalId,
    );
  }

  Map<String, dynamic> toJson() => {
        'dayNumber': dayNumber,
        'requiredSeason': requiredSeason.toJson(),
        'weather': weather.toJson(),
        'weekdayIndex': weekdayIndex,
        'isFestival': isFestival,
        'festivalId': festivalId,
      };

  static DayState fromJson(Map<String, dynamic> json) {
    return DayState(
      dayNumber: json['dayNumber'] as int,
      requiredSeason: SeasonType.fromJson(json['requiredSeason'] as String),
      weather: WeatherTypeJson.fromJson(json['weather'] as String),
      weekdayIndex: json['weekdayIndex'] as int,
      isFestival: json['isFestival'] as bool? ?? false,
      festivalId: json['festivalId'] as String?,
    );
  }

  /// Creates the default day-one state.
  factory DayState.dayOne() => DayState(
        dayNumber: 1,
        requiredSeason: SeasonType.spring,
        weather: WeatherType.sunny,
        weekdayIndex: 0,
      );

  /// Compute the next day state, wrapping seasons every 28 days.
  DayState nextDay({WeatherType Function(SeasonType, int)? weatherRng}) {
    final nextDayNumber = dayNumber % TimeConstants.kDaysPerSeason + 1;
    final nextSeason =
        nextDayNumber == 1 ? requiredSeason.next() : requiredSeason;
    final nextWeekday = (weekdayIndex + 1) % 7;
    final nextWeather = weatherRng != null
      ? weatherRng(nextSeason, nextDayNumber)
      : DayState.defaultWeatherRng(nextSeason, nextDayNumber);

    return copyWith(
      dayNumber: nextDayNumber,
      requiredSeason: nextSeason,
      weather: nextWeather,
      weekdayIndex: nextWeekday,
      isFestival: false,
      festivalId: null,
    );
  }

  /// Default simple weather generator (rule-based, minimal viable).
  /// - Summer: higher storm and rain chance.
  /// - Winter: snow common, storms rare.
  /// - Spring/Fall: moderate rain, occasional storm.
  static WeatherType defaultWeatherRng(SeasonType requiredSeason, int dayNumber) {
    final roll = _rng.nextDouble();
    switch (requiredSeason) {
      case SeasonType.winter:
        if (roll < 0.10) return WeatherType.storm;
        if (roll < 0.65) return WeatherType.snow;
        return WeatherType.sunny;
      case SeasonType.summer:
        if (roll < 0.20) return WeatherType.storm;
        if (roll < 0.55) return WeatherType.rain;
        return WeatherType.sunny;
      case SeasonType.fall:
        if (roll < 0.15) return WeatherType.storm;
        if (roll < 0.50) return WeatherType.rain;
        return WeatherType.sunny;
      case SeasonType.spring:
      default:
        if (roll < 0.10) return WeatherType.storm;
        if (roll < 0.45) return WeatherType.rain;
        return WeatherType.sunny;
    }
  }
}
