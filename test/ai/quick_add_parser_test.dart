import 'package:flutter_test/flutter_test.dart';
import 'package:lifely/ai/ai_quick_add.dart';

void main() {
  // Monday 5 October 2026, 10:00.
  final now = DateTime(2026, 10, 5, 10, 0);
  const parser = QuickAddParser();

  group('QuickAddParser', () {
    test('reads day, time and duration, and strips them from the title', () {
      final result = parser.parse('Essay draft tomorrow 3pm for 1h', now);
      expect(result.title, 'Essay draft');
      expect(result.due, DateTime(2026, 10, 6, 15, 0));
      expect(result.minutes, 60);
      expect(result.category, 'Academics');
    });

    test('a weekday without a time defaults to 5 PM that day', () {
      final result = parser.parse('Read chapter 4 by friday', now);
      expect(result.title, 'Read chapter 4');
      expect(result.due, DateTime(2026, 10, 9, 17, 0));
    });

    test('abbreviated weekdays need a lead-in word', () {
      final withLeadIn = parser.parse('lab report due fri', now);
      expect(withLeadIn.title, 'lab report');
      expect(withLeadIn.due, DateTime(2026, 10, 9, 17, 0));

      // "SAT" is an exam, not Saturday.
      final bare = parser.parse('SAT practice', now);
      expect(bare.due, isNull);
      expect(bare.title, 'SAT practice');
    });

    test('"next <weekday>" on that same weekday means a week later', () {
      final result = parser.parse('next monday meeting', now);
      expect(result.due, DateTime(2026, 10, 12, 17, 0));
    });

    test('"at 5" means the afternoon', () {
      final result = parser.parse('Call mom at 5', now);
      expect(result.title, 'Call mom');
      expect(result.due, DateTime(2026, 10, 5, 17, 0));
      expect(result.category, 'Social');
    });

    test('a time that already passed today rolls over to tomorrow', () {
      expect(parser.parse('gym at 7am', now).due, DateTime(2026, 10, 6, 7, 0));
      expect(parser.parse('standup 9:30', now).due, DateTime(2026, 10, 6, 9, 30));
    });

    test('"in 2 hours" is a due time, not a duration', () {
      final result = parser.parse('quiz in 2 hours', now);
      expect(result.title, 'quiz');
      expect(result.due, DateTime(2026, 10, 5, 12, 0));
      expect(result.minutes, isNull);
    });

    test('a bare duration sets minutes only', () {
      final result = parser.parse('study 90 min', now);
      expect(result.minutes, 90);
      expect(result.due, isNull);
      expect(result.title, 'study');
    });

    test('next week means next Monday', () {
      final result = parser.parse('Submit form next week', now);
      expect(result.title, 'Submit form');
      expect(result.due, DateTime(2026, 10, 12, 17, 0));
      expect(result.category, 'Admin');
    });

    test('tonight defaults to 8 PM', () {
      final result = parser.parse('Laundry tonight', now);
      expect(result.title, 'Laundry');
      expect(result.due, DateTime(2026, 10, 5, 20, 0));
      expect(result.category, 'Routine');
    });

    test('plain text has no detections', () {
      final result = parser.parse('Buy a new notebook cover', now);
      expect(result.hasDetections, isFalse);
      expect(result.title, 'Buy a new notebook cover');
    });
  });

  group('TaskRewriter', () {
    const rewriter = TaskRewriter();

    test('drops filler, date words and trailing punctuation', () {
      expect(
        rewriter.rewrite('i need to finish the essay tomorrow.', now),
        'Finish the essay',
      );
      expect(rewriter.rewrite('remember to email prof', now), 'Email prof');
    });

    test('leaves a clean title alone', () {
      expect(rewriter.rewrite('Already clean', now), 'Already clean');
    });
  });
}
