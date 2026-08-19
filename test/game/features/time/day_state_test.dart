import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/time/day_state.dart';
import 'package:dawnforge/game/features/time/time_constants.dart';
import 'package:dawnforge/game/features/time/weather_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builders.dart';

void main() {
  group('DayState', () {
    group('dayOne', () {
      test('starts on spring day 1, sunny, first weekday', () {
        final day = DayState.dayOne();

        expect(day.dayNumber, 1);
        expect(day.requiredSeason, SeasonType.spring);
        expect(day.weather, WeatherType.sunny);
        expect(day.weekdayIndex, 0);
        expect(day.isFestival, isFalse);
      });
    });

    group('nextDay', () {
      test('increments the day number inside a season', () {
        final day = aDayState(dayNumber: 5);

        final next = day.nextDay(weatherRng: fixedWeather());

        expect(next.dayNumber, 6);
        expect(next.requiredSeason, SeasonType.spring);
      });

      test('day 28 wraps to day 1 of the next season', () {
        final day = aDayState(
          dayNumber: TimeConstants.kDaysPerSeason,
          requiredSeason: SeasonType.spring,
        );

        final next = day.nextDay(weatherRng: fixedWeather());

        expect(next.dayNumber, 1);
        expect(next.requiredSeason, SeasonType.summer);
      });

      test('the season only changes on the season boundary', () {
        final day = aDayState(
          dayNumber: TimeConstants.kDaysPerSeason - 1,
          requiredSeason: SeasonType.spring,
        );

        final next = day.nextDay(weatherRng: fixedWeather());

        expect(next.dayNumber, TimeConstants.kDaysPerSeason);
        expect(next.requiredSeason, SeasonType.spring);
      });

      test('weekday cycles through 7 values', () {
        var day = aDayState(weekdayIndex: 0);

        for (var i = 0; i < 7; i++) {
          day = day.nextDay(weatherRng: fixedWeather());
        }

        expect(day.weekdayIndex, 0);
      });

      test('weekday 6 wraps to 0', () {
        final day = aDayState(weekdayIndex: 6);

        expect(day.nextDay(weatherRng: fixedWeather()).weekdayIndex, 0);
      });

      test('uses the injected weather generator', () {
        final day = aDayState(weather: WeatherType.sunny);

        final next = day.nextDay(weatherRng: fixedWeather(WeatherType.storm));

        expect(next.weather, WeatherType.storm);
      });

      test('the weather generator receives the NEXT season and day', () {
        SeasonType? seenSeason;
        int? seenDay;

        aDayState(
          dayNumber: TimeConstants.kDaysPerSeason,
          requiredSeason: SeasonType.spring,
        ).nextDay(
          weatherRng: (season, dayNumber) {
            seenSeason = season;
            seenDay = dayNumber;
            return WeatherType.sunny;
          },
        );

        expect(seenSeason, SeasonType.summer);
        expect(seenDay, 1);
      });

      test('festival flag is cleared on the next day', () {
        final day = aDayState(isFestival: true, festivalId: 'egg_festival');

        final next = day.nextDay(weatherRng: fixedWeather());

        expect(next.isFestival, isFalse);
      });

      // COMPORTAMENTO ATUAL, INCORRETO — ver refactoring/03-fase-3 §3.7.
      // `nextDay` passa `festivalId: null`, mas o `copyWith` usa
      // `festivalId ?? this.festivalId` e mantém o id antigo. O dia seguinte
      // fica com `isFestival: false` e um `festivalId` preenchido — estado
      // inconsistente. Ao corrigir, esperar `isNull`.
      test('festivalId is NOT cleared (copyWith cannot set null)', () {
        final day = aDayState(isFestival: true, festivalId: 'egg_festival');

        final next = day.nextDay(weatherRng: fixedWeather());

        expect(next.festivalId, 'egg_festival');
      });

      test('advancing a full season lands on the following season, day 1', () {
        var day = aDayState(dayNumber: 1, requiredSeason: SeasonType.spring);

        for (var i = 0; i < TimeConstants.kDaysPerSeason; i++) {
          day = day.nextDay(weatherRng: fixedWeather());
        }

        expect(day.dayNumber, 1);
        expect(day.requiredSeason, SeasonType.summer);
      });
    });

    group('defaultWeatherRng', () {
      test('always returns a weather type valid for the season', () {
        for (final season in [
          SeasonType.spring,
          SeasonType.summer,
          SeasonType.fall,
          SeasonType.winter,
        ]) {
          for (var i = 0; i < 50; i++) {
            final weather = DayState.defaultWeatherRng(season, i + 1);

            expect(WeatherType.values, contains(weather));
          }
        }
      });

      test('winter never rains — it snows instead', () {
        for (var i = 0; i < 200; i++) {
          final weather = DayState.defaultWeatherRng(SeasonType.winter, i + 1);

          expect(weather, isNot(WeatherType.rain));
        }
      });

      test('non-winter seasons never snow', () {
        for (final season in [
          SeasonType.spring,
          SeasonType.summer,
          SeasonType.fall,
        ]) {
          for (var i = 0; i < 200; i++) {
            final weather = DayState.defaultWeatherRng(season, i + 1);

            expect(weather, isNot(WeatherType.snow), reason: '$season');
          }
        }
      });
    });

    group('copyWith', () {
      test('replaces only what is given', () {
        final day = aDayState(dayNumber: 5, requiredSeason: SeasonType.fall);

        final updated = day.copyWith(dayNumber: 9);

        expect(updated.dayNumber, 9);
        expect(updated.requiredSeason, SeasonType.fall);
      });
    });

    group('serialization', () {
      test('round-trips every field', () {
        final day = aDayState(
          dayNumber: 12,
          requiredSeason: SeasonType.winter,
          weather: WeatherType.snow,
          weekdayIndex: 3,
          isFestival: true,
          festivalId: 'ice_festival',
        );

        final restored = DayState.fromJson(day.toJson());

        expect(restored.dayNumber, 12);
        expect(restored.requiredSeason, SeasonType.winter);
        expect(restored.weather, WeatherType.snow);
        expect(restored.weekdayIndex, 3);
        expect(restored.isFestival, isTrue);
        expect(restored.festivalId, 'ice_festival');
      });

      test('missing isFestival defaults to false', () {
        final json = aDayState().toJson()..remove('isFestival');

        expect(DayState.fromJson(json).isFestival, isFalse);
      });
    });
  });

  group('WeatherType', () {
    test('every value round-trips', () {
      for (final weather in WeatherType.values) {
        expect(WeatherTypeJson.fromJson(weather.toJson()), weather);
      }
    });

    test('unknown value → throws', () {
      expect(() => WeatherTypeJson.fromJson('hail'), throwsArgumentError);
    });
  });
}
