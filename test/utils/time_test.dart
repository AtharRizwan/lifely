import 'package:flutter_test/flutter_test.dart';
import 'package:lifely/utils/time.dart';
import 'package:lifely/utils/validators.dart';

void main() {
  group('consecutiveDayStreak', () {
    final today = DateTime(2026, 10, 5, 20, 0);

    test('counts back from today', () {
      final days = [
        DateTime(2026, 10, 5, 9),
        DateTime(2026, 10, 4, 22),
        DateTime(2026, 10, 3, 7),
      ];
      expect(consecutiveDayStreak(days, today), 3);
    });

    test('a run ending yesterday is still alive', () {
      final days = [DateTime(2026, 10, 4), DateTime(2026, 10, 3)];
      expect(consecutiveDayStreak(days, today), 2);
    });

    test('a run that ended before yesterday is broken', () {
      final days = [DateTime(2026, 10, 2), DateTime(2026, 10, 1)];
      expect(consecutiveDayStreak(days, today), 0);
    });

    test('several entries on one day count once', () {
      final days = [
        DateTime(2026, 10, 5, 8),
        DateTime(2026, 10, 5, 12),
        DateTime(2026, 10, 5, 18),
      ];
      expect(consecutiveDayStreak(days, today), 1);
    });

    test('crosses month boundaries', () {
      final days = [DateTime(2026, 10, 1), DateTime(2026, 9, 30)];
      expect(consecutiveDayStreak(days, DateTime(2026, 10, 1, 12)), 2);
    });

    test('empty input is zero', () {
      expect(consecutiveDayStreak(const [], today), 0);
    });
  });

  group('date helpers', () {
    test('isoWeekNumber follows ISO-8601', () {
      expect(isoWeekNumber(DateTime(2026, 10, 5)), 41);
      expect(isoWeekNumber(DateTime(2026, 1, 1)), 1);
      expect(isoWeekNumber(DateTime(2027, 1, 1)), 53);
    });

    test('startOfWeek is the Monday', () {
      expect(startOfWeek(DateTime(2026, 10, 4, 15)), DateTime(2026, 9, 28));
      expect(startOfWeek(DateTime(2026, 10, 5)), DateTime(2026, 10, 5));
    });

    test('daysBetween counts calendar days', () {
      expect(daysBetween(DateTime(2026, 3, 28, 23), DateTime(2026, 3, 30, 1)), 2);
      expect(daysBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 4)), -1);
    });

    test('formatRelativeDay', () {
      final now = DateTime(2026, 10, 5, 10);
      expect(formatRelativeDay(DateTime(2026, 10, 5, 23), now), 'Today');
      expect(formatRelativeDay(DateTime(2026, 10, 6, 1), now), 'Tomorrow');
      expect(formatRelativeDay(DateTime(2026, 10, 4), now), 'Yesterday');
      expect(formatRelativeDay(DateTime(2026, 10, 9), now), 'Fri 9 Oct');
    });

    test('formatClock uses a 12-hour clock', () {
      expect(formatClock(DateTime(2026, 10, 5, 0, 5)), '12:05 AM');
      expect(formatClock(DateTime(2026, 10, 5, 15, 30)), '3:30 PM');
    });
  });

  group('Validators', () {
    test('accept common real-world emails', () {
      expect(Validators.validateEmail('student+lifely@uni.edu.pk').isValid, isTrue);
      expect(Validators.validateEmail('not-an-email').isValid, isFalse);
    });

    test('accept names with apostrophes and non-Latin letters', () {
      expect(Validators.validateName("Sinéad O'Brien").isValid, isTrue);
      expect(Validators.validateName('محمد اطہر').isValid, isTrue);
      expect(Validators.validateName('R2D2').isValid, isFalse);
    });
  });
}
