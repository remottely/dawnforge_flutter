import 'package:dawnforge/game/features/time/game_time.dart';
import 'package:dawnforge/game/features/time/time_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameTime', () {
    group('totalMinutes', () {
      test('midnight → 0', () {
        expect(const GameTime(hour: 0, minute: 0).totalMinutes, 0);
      });

      test('06:30 → 390', () {
        expect(const GameTime(hour: 6, minute: 30).totalMinutes, 390);
      });

      test('23:59 → one minute short of a full day', () {
        expect(
          const GameTime(hour: 23, minute: 59).totalMinutes,
          TimeConstants.totalMinutesPerDay - 1,
        );
      });
    });

    group('addMinutes', () {
      test('within the same hour', () {
        final time = const GameTime(hour: 6, minute: 0).addMinutes(30);

        expect(time.hour, 6);
        expect(time.minute, 30);
      });

      test('rolls over into the next hour', () {
        final time = const GameTime(hour: 6, minute: 50).addMinutes(20);

        expect(time.hour, 7);
        expect(time.minute, 10);
      });

      test('wraps past midnight', () {
        final time = const GameTime(hour: 23, minute: 30).addMinutes(60);

        expect(time.hour, 0);
        expect(time.minute, 30);
      });

      test('adding a full day returns to the same clock time', () {
        const start = GameTime(hour: 14, minute: 15);

        final time = start.addMinutes(TimeConstants.totalMinutesPerDay);

        expect(time.hour, start.hour);
        expect(time.minute, start.minute);
      });

      test('adding zero is a no-op', () {
        final time = const GameTime(hour: 6, minute: 0).addMinutes(0);

        expect(time.totalMinutes, 360);
      });

      test('several ticks accumulate correctly', () {
        var time = const GameTime(hour: 6, minute: 0);

        for (var i = 0; i < 6; i++) {
          time = time.addMinutes(TimeConstants.kMinutesPerTick);
        }

        expect(time.hour, 7);
        expect(time.minute, 0);
      });
    });

    group('copyWith', () {
      test('replaces only what is given', () {
        const time = GameTime(hour: 6, minute: 30);

        expect(time.copyWith(hour: 9).minute, 30);
        expect(time.copyWith(minute: 45).hour, 6);
      });
    });

    group('serialization', () {
      test('round-trips', () {
        const time = GameTime(hour: 13, minute: 37);

        final restored = GameTime.fromJson(time.toJson());

        expect(restored.hour, 13);
        expect(restored.minute, 37);
      });
    });

    group('toString', () {
      test('pads both fields to two digits', () {
        expect(const GameTime(hour: 6, minute: 5).toString(), '06:05');
      });

      test('renders a full time unpadded', () {
        expect(const GameTime(hour: 23, minute: 59).toString(), '23:59');
      });
    });
  });

  group('TimeConstants', () {
    test('a season is 28 days and a year is 4 seasons', () {
      expect(TimeConstants.kDaysPerSeason, 28);
      expect(TimeConstants.kSeasonsPerYear, 4);
    });

    group('wrapDay', () {
      test('days inside a season are unchanged', () {
        expect(TimeConstants.wrapDay(1), 1);
        expect(TimeConstants.wrapDay(28), 28);
      });

      test('day 29 wraps to the first day of the next season', () {
        expect(TimeConstants.wrapDay(29), 1);
      });

      test('day 56 is the last day of the second season', () {
        expect(TimeConstants.wrapDay(56), 28);
      });
    });

    group('wrapSeasonIndex', () {
      test('indices inside a year are unchanged', () {
        expect(TimeConstants.wrapSeasonIndex(0), 0);
        expect(TimeConstants.wrapSeasonIndex(3), 3);
      });

      test('index 4 wraps back to the first season', () {
        expect(TimeConstants.wrapSeasonIndex(4), 0);
      });
    });

    test('totalMinutesPerDay is consistent with kHoursPerDay', () {
      expect(TimeConstants.totalMinutesPerDay, TimeConstants.kHoursPerDay * 60);
    });

    test('startOffset is consistent with kStartHour', () {
      expect(TimeConstants.startOffset, TimeConstants.kStartHour * 60);
    });
  });
}
