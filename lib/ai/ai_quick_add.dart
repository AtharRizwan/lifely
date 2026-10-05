import '../utils/time.dart';

class QuickAddResult {
  const QuickAddResult({
    required this.title,
    this.due,
    this.minutes,
    this.category,
  });

  /// The input with any recognised date, time and duration phrases removed.
  final String title;
  final DateTime? due;
  final int? minutes;
  final String? category;

  bool get hasDetections => due != null || minutes != null || category != null;
}

/// Pulls a due date, time, duration and category out of a free-text task such
/// as "Essay draft tomorrow 3pm for 1h".
class QuickAddParser {
  const QuickAddParser();

  static const _weekdays = {
    'mon': DateTime.monday,
    'tue': DateTime.tuesday,
    'wed': DateTime.wednesday,
    'thu': DateTime.thursday,
    'fri': DateTime.friday,
    'sat': DateTime.saturday,
    'sun': DateTime.sunday,
  };

  // Checked in order; the first category with a matching keyword wins.
  static const _categoryKeywords = {
    'Group work': ['group', 'team', 'groupmates', 'teammates'],
    'Academics': [
      'exam', 'quiz', 'midterm', 'final', 'assignment', 'homework',
      'lecture', 'essay', 'lab', 'study', 'thesis', 'paper', 'project',
      'reading', 'chapter', 'revise', 'revision', 'class', 'course', 'notes',
    ],
    'Admin': [
      'pay', 'fee', 'fees', 'form', 'register', 'registration', 'email',
      'bank', 'apply', 'application', 'renew', 'appointment',
    ],
    'Wellness': [
      'gym', 'run', 'workout', 'yoga', 'meditate', 'meditation', 'sleep',
      'walk', 'therapy', 'doctor', 'stretch',
    ],
    'Social': [
      'party', 'dinner', 'friends', 'friend', 'birthday', 'hangout', 'family',
      'mom', 'dad', 'club', 'society',
    ],
    'Routine': ['laundry', 'groceries', 'clean', 'cook', 'dishes'],
  };

  QuickAddResult parse(String input, DateTime now) {
    var working = input;

    // Finds [pattern] in what is left of the input and blanks it out so later
    // patterns can't match the same words and it drops out of the title.
    RegExpMatch? take(String pattern) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(working);
      if (match != null) {
        working = working.replaceRange(
          match.start,
          match.end,
          ' ' * (match.end - match.start),
        );
      }
      return match;
    }

    const unit = r'(hours?|hrs?|h|minutes?|mins?|m)';

    DateTime? due;
    final relative = take('\\bin\\s+(\\d+(?:\\.\\d+)?)\\s*$unit\\b');
    if (relative != null) {
      due = now.add(Duration(
        minutes: _toMinutes(relative.group(1)!, relative.group(2)!),
      ));
    }

    int? minutes;
    final length = take('\\b(?:for\\s+)?(\\d+(?:\\.\\d+)?)\\s*$unit\\b');
    if (length != null) {
      final value = _toMinutes(length.group(1)!, length.group(2)!);
      if (value > 0) minutes = value;
    }

    int? hour;
    var minute = 0;
    final ampm = take(r'(?:\bat\s+|@\s*)?\b(\d{1,2})(?::(\d{2}))?\s*(am|pm)\b');
    if (ampm != null) {
      final h = int.parse(ampm.group(1)!);
      if (h >= 1 && h <= 12) {
        hour = h % 12 + (ampm.group(3)!.toLowerCase() == 'pm' ? 12 : 0);
        minute = int.tryParse(ampm.group(2) ?? '') ?? 0;
      }
    } else {
      final clock = take(r'(?:\bat\s+|@\s*)?\b([01]?\d|2[0-3]):([0-5]\d)\b');
      if (clock != null) {
        hour = int.parse(clock.group(1)!);
        minute = int.parse(clock.group(2)!);
      } else {
        final bare = take(r'(?:\bat\s+|@\s*)(\d{1,2})\b');
        if (bare != null) {
          final h = int.parse(bare.group(1)!);
          if (h <= 23) {
            // "at 3" almost always means the afternoon for a student.
            hour = h >= 1 && h <= 7 ? h + 12 : h;
          }
        } else if (take(r'(?:\bat\s+)?\bnoon\b') != null) {
          hour = 12;
        }
      }
    }

    int? partOfDayHour;
    final partOfDay = take(r'\b(?:this\s+|in\s+the\s+)?(morning|afternoon|evening)\b');
    if (partOfDay != null) {
      switch (partOfDay.group(1)!.toLowerCase()) {
        case 'morning':
          partOfDayHour = 9;
          break;
        case 'afternoon':
          partOfDayHour = 14;
          break;
        default:
          partOfDayHour = 18;
      }
    }

    DateTime? day;
    var tonight = false;
    final today = dateOnly(now);
    final relativeDay = take(r'\b(?:(?:due|by)\s+)?(today|tonight|tomorrow|tmrw|tmr)\b');
    if (relativeDay != null) {
      final word = relativeDay.group(1)!.toLowerCase();
      tonight = word == 'tonight';
      day = word == 'today' || tonight ? today : addDays(today, 1);
    } else if (take(r'\b(?:(?:due|by)\s+)?next\s+week\b') != null) {
      day = addDays(startOfWeek(now), 7);
    } else {
      final weekday = take(
            r'\b(?:(?:due|by|on|this|next)\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
          ) ??
          take(r'\b(?:due|by|on|this|next)\s+(mon|tues?|wed|thu(?:rs?)?|fri|sat|sun)\b');
      if (weekday != null) {
        final target = _weekdays[weekday.group(1)!.toLowerCase().substring(0, 3)]!;
        final isNext = weekday.group(0)!.toLowerCase().startsWith('next');
        var diff = (target - now.weekday) % 7;
        if (diff == 0 && isNext) diff = 7;
        day = addDays(today, diff);
      }
    }

    if (due == null && (day != null || hour != null || partOfDayHour != null)) {
      final baseDay = day ?? today;
      var h = hour ?? partOfDayHour ?? (tonight ? 20 : 17);
      if (tonight && hour != null && hour < 12) h = hour + 12;
      var result = DateTime(
        baseDay.year,
        baseDay.month,
        baseDay.day,
        h,
        hour != null ? minute : 0,
      );
      if (result.isBefore(now)) {
        if (day == null) {
          // A time that has already passed today means tomorrow.
          result = addDays(result, 1);
        } else if (isSameDay(day, now) && hour == null) {
          result = DateTime(now.year, now.month, now.day, now.hour + 1);
        }
      }
      due = result;
    }

    return QuickAddResult(
      title: _cleanTitle(working),
      due: due,
      minutes: minutes,
      category: _detectCategory(input),
    );
  }

  int _toMinutes(String amount, String unit) {
    final value = double.parse(amount);
    return unit.toLowerCase().startsWith('h')
        ? (value * 60).round()
        : value.round();
  }

  String? _detectCategory(String input) {
    final lower = input.toLowerCase();
    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (RegExp('\\b$keyword\\b').hasMatch(lower)) return entry.key;
      }
    }
    return null;
  }

  String _cleanTitle(String text) {
    var title = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final dangling = RegExp(
      r'(?:^|\s)(?:due|by|at|on|for|in|this|next|before)$|[\s,;:\-–—]+$',
      caseSensitive: false,
    );
    while (true) {
      final match = dangling.firstMatch(title);
      if (match == null || match.start == match.end) break;
      title = title.substring(0, match.start).trim();
    }
    return title.replaceAll(RegExp(r'^[\s,;:\-–—]+'), '');
  }
}

/// Tidies a draft task into a short, imperative title.
class TaskRewriter {
  const TaskRewriter();

  static final _filler = RegExp(
    r"^(?:(?:i\s+)?(?:need|have|got|want)\s+to|i\s+(?:must|should|will)|i'll|gotta|remember\s+to|don'?t\s+forget\s+to|remind\s+me\s+to|please|pls|todo:?|to\s+do:?|task:?)\s+",
    caseSensitive: false,
  );

  String rewrite(String input, DateTime now) {
    var text = const QuickAddParser().parse(input, now).title;
    while (true) {
      final match = _filler.firstMatch(text);
      if (match == null) break;
      text = text.substring(match.end);
    }
    text = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[.!]+$'), '')
        .trim();
    if (text.isEmpty) return input.trim();
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
