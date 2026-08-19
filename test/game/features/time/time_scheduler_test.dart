import 'package:dawnforge/game/features/inventory/entities/enums/season.dart';
import 'package:dawnforge/game/features/time/game_time.dart';
import 'package:dawnforge/game/features/time/time_constants.dart';
import 'package:dawnforge/game/features/time/time_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builders.dart';

void main() {
  group('TimeScheduler', () {
    late TimeScheduler scheduler;
    late List<String> fired;

    setUp(() {
      scheduler = TimeScheduler();
      fired = <String>[];
    });

    /// Avança o relógio até [time] no dia [dayNumber] e devolve o controle.
    void tickAt(int dayNumber, GameTime time, {SeasonType? season}) {
      scheduler.handleTick(
        currentDayState: aDayState(
          dayNumber: dayNumber,
          requiredSeason: season ?? SeasonType.spring,
        ),
        currentTime: time,
      );
    }

    group('scheduleAbsolute', () {
      test('fires when the clock reaches the target minute', () {
        scheduler.scheduleAbsolute(
          id: 'wake',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('wake'),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, ['wake']);
      });

      test('does not fire before the target time', () {
        scheduler.scheduleAbsolute(
          id: 'wake',
          dayIndex: 0,
          time: const GameTime(hour: 8, minute: 0),
          callback: () => fired.add('wake'),
        );

        tickAt(1, const GameTime(hour: 7, minute: 50));

        expect(fired, isEmpty);
      });

      test('a one-shot task fires exactly once', () {
        scheduler.scheduleAbsolute(
          id: 'wake',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('wake'),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));
        tickAt(1, const GameTime(hour: 6, minute: 10));
        tickAt(1, const GameTime(hour: 7, minute: 0));

        expect(fired, ['wake']);
      });

      test('a task scheduled for a later day does not fire today', () {
        scheduler.scheduleAbsolute(
          id: 'later',
          dayIndex: 5,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('later'),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, isEmpty);
      });

      test('scheduling the same id twice replaces the first task', () {
        scheduler
          ..scheduleAbsolute(
            id: 'dup',
            dayIndex: 0,
            time: const GameTime(hour: 6, minute: 0),
            callback: () => fired.add('first'),
          )
          ..scheduleAbsolute(
            id: 'dup',
            dayIndex: 0,
            time: const GameTime(hour: 6, minute: 0),
            callback: () => fired.add('second'),
          );

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, ['second']);
      });
    });

    group('scheduleRelative', () {
      test('fires after the requested number of in-game minutes', () {
        scheduler.scheduleRelative(
          id: 'soon',
          currentDay: aDayState(dayNumber: 1),
          currentTime: const GameTime(hour: 6, minute: 0),
          minutesFromNow: 30,
          callback: () => fired.add('soon'),
        );

        tickAt(1, const GameTime(hour: 6, minute: 20));
        expect(fired, isEmpty);

        tickAt(1, const GameTime(hour: 6, minute: 30));
        expect(fired, ['soon']);
      });

      test('an offset crossing midnight lands on the next day', () {
        scheduler.scheduleRelative(
          id: 'tomorrow',
          currentDay: aDayState(dayNumber: 1),
          currentTime: const GameTime(hour: 23, minute: 0),
          minutesFromNow: 120,
          callback: () => fired.add('tomorrow'),
        );

        tickAt(1, const GameTime(hour: 23, minute: 30));
        expect(fired, isEmpty);

        tickAt(2, const GameTime(hour: 1, minute: 0));
        expect(fired, ['tomorrow']);
      });
    });

    group('cancel and clear', () {
      test('a cancelled task never fires', () {
        scheduler
          ..scheduleAbsolute(
            id: 'wake',
            dayIndex: 0,
            time: const GameTime(hour: 6, minute: 0),
            callback: () => fired.add('wake'),
          )
          ..cancel('wake');

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, isEmpty);
      });

      test('cancelling an unknown id is harmless', () {
        expect(() => scheduler.cancel('ghost'), returnsNormally);
      });

      test('clear removes every task', () {
        scheduler
          ..scheduleAbsolute(
            id: 'a',
            dayIndex: 0,
            time: const GameTime(hour: 6, minute: 0),
            callback: () => fired.add('a'),
          )
          ..scheduleAbsolute(
            id: 'b',
            dayIndex: 0,
            time: const GameTime(hour: 6, minute: 0),
            callback: () => fired.add('b'),
          )
          ..clear();

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, isEmpty);
      });
    });

    group('repeating tasks', () {
      test('a daily task fires on consecutive days', () {
        scheduler.scheduleAbsolute(
          id: 'daily',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('daily'),
          repeat: const RepeatRule(),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));
        tickAt(2, const GameTime(hour: 6, minute: 0));
        tickAt(3, const GameTime(hour: 6, minute: 0));

        expect(fired, ['daily', 'daily', 'daily']);
      });

      test('intervalDays 2 skips every other day', () {
        scheduler.scheduleAbsolute(
          id: 'every_other',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('tick'),
          repeat: const RepeatRule(intervalDays: 2),
        );

        for (var day = 1; day <= 5; day++) {
          tickAt(day, const GameTime(hour: 6, minute: 0));
        }

        expect(fired.length, 3, reason: 'days 1, 3 and 5');
      });

      test('a season-restricted task does not fire outside its season', () {
        scheduler.scheduleAbsolute(
          id: 'summer_only',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('summer'),
          repeat: const RepeatRule(seasons: {SeasonType.summer}),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));

        expect(fired, isEmpty);
      });

      test('a weekday-restricted task only fires on those weekdays', () {
        scheduler.scheduleAbsolute(
          id: 'market_day',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('market'),
          repeat: const RepeatRule(weekdayIndices: {0}),
        );

        for (var day = 1; day <= 14; day++) {
          tickAt(day, const GameTime(hour: 6, minute: 0));
        }

        expect(fired.length, 2, reason: 'once per 7-day week over 14 days');
      });

      test('a day-number-restricted task fires only on those days', () {
        scheduler.scheduleAbsolute(
          id: 'first_of_season',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('first'),
          repeat: const RepeatRule(dayNumbers: {1}),
        );

        for (var day = 1; day <= 10; day++) {
          tickAt(day, const GameTime(hour: 6, minute: 0));
        }

        expect(fired, ['first']);
      });

      test('an impossible rule drops the task instead of looping forever', () {
        scheduler.scheduleAbsolute(
          id: 'impossible',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('never'),
          // Dia 99 não existe numa estação de 28 dias.
          repeat: const RepeatRule(dayNumbers: {99}),
        );

        expect(
          () => tickAt(1, const GameTime(hour: 6, minute: 0)),
          returnsNormally,
        );
        expect(fired, isEmpty);
      });
    });

    group('catch-up on time jumps', () {
      test('a manual multi-day jump fires each missed occurrence', () {
        scheduler.scheduleAbsolute(
          id: 'daily',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('daily'),
          repeat: const RepeatRule(),
        );

        // Primeiro tick estabelece a janela, depois salta 3 dias.
        tickAt(1, const GameTime(hour: 6, minute: 0));
        tickAt(4, const GameTime(hour: 6, minute: 0));

        expect(fired.length, 4, reason: 'days 1, 2, 3 and 4');
      });

      test('a large in-day jump still fires a task inside the window', () {
        scheduler.scheduleAbsolute(
          id: 'noon',
          dayIndex: 0,
          time: const GameTime(hour: 12, minute: 0),
          callback: () => fired.add('noon'),
        );

        tickAt(1, const GameTime(hour: 6, minute: 0));
        tickAt(1, const GameTime(hour: 18, minute: 0));

        expect(fired, ['noon']);
      });
    });

    group('year rollover', () {
      test('epoch days stay monotonic across a full year', () {
        scheduler.scheduleAbsolute(
          id: 'daily',
          dayIndex: 0,
          time: const GameTime(hour: 6, minute: 0),
          callback: () => fired.add('tick'),
          repeat: const RepeatRule(),
        );

        const seasons = [
          SeasonType.spring,
          SeasonType.summer,
          SeasonType.fall,
          SeasonType.winter,
        ];

        // Um ano completo, depois a volta para a primavera do ano seguinte.
        for (final season in seasons) {
          for (var day = 1; day <= TimeConstants.kDaysPerSeason; day++) {
            tickAt(day, const GameTime(hour: 6, minute: 0), season: season);
          }
        }

        final firedInFirstYear = fired.length;

        tickAt(
          1,
          const GameTime(hour: 6, minute: 0),
          season: SeasonType.spring,
        );

        expect(
          fired.length,
          firedInFirstYear + 1,
          reason: 'the new year must not replay the whole calendar',
        );
      });
    });
  });

  group('RepeatRule', () {
    test('defaults to a daily interval with no restrictions', () {
      const rule = RepeatRule();

      expect(rule.intervalDays, 1);
      expect(rule.seasons, isNull);
      expect(rule.dayNumbers, isNull);
      expect(rule.weekdayIndices, isNull);
    });

    test('the daily named constructor keeps the interval at 1', () {
      const rule = RepeatRule.daily(seasons: {SeasonType.spring});

      expect(rule.intervalDays, 1);
      expect(rule.seasons, {SeasonType.spring});
    });
  });
}
