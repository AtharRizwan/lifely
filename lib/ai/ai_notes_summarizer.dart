import '../utils/constants.dart';

class AiSummaryResult {
  const AiSummaryResult({
    required this.keyPoints,
    required this.actionItems,
    required this.deadlines,
    required this.categories,
    required this.sentimentScore,
    required this.overallSummary,
  });

  final List<String> keyPoints;
  final List<String> actionItems;
  final List<String> deadlines;
  final List<String> categories;
  final double sentimentScore;
  final String overallSummary;
}

class AiNotesSummarizer {
  static const _stopWords = {
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'as', 'is', 'was', 'are', 'were', 'been',
    'be', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'shall', 'can', 'need',
    'that', 'this', 'these', 'those', 'it', 'its', 'they', 'them',
    'their', 'we', 'our', 'us', 'i', 'my', 'me', 'you', 'your',
    'he', 'she', 'him', 'her', 'his', 'hers',
    'which', 'what', 'who', 'whom', 'whose', 'when', 'where', 'why', 'how',
    'all', 'each', 'every', 'both', 'few', 'more', 'most', 'other',
    'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so',
    'than', 'too', 'very', 'just', 'also', 'now', 'here', 'there',
    'then', 'once', 'if', 'because', 'while', 'although', 'though',
    'after', 'before', 'above', 'below', 'between', 'under', 'over',
  };

  static const _academicKeywords = {
    'exam', 'quiz', 'midterm', 'final', 'assignment', 'homework',
    'lecture', 'class', 'course', 'study', 'read', 'chapter', 'notes',
    'research', 'paper', 'essay', 'project', 'presentation', 'seminar',
    'lab', 'practical', 'tutorial', 'workshop', 'deadline', 'submit',
    'professor', 'ta', 'office hours', 'grade', 'gpa', 'credit',
    'syllabus', 'outline', 'draft', 'revision', 'bibliography',
    'citation', 'plagiarism', 'academic', 'semester', 'week',
  };

  static const _imperativeVerbs = {
    'do', 'complete', 'submit', 'read', 'review', 'study',
    'write', 'prepare', 'practice', 'start', 'begin',
    'organize', 'plan', 'schedule', 'attend', 'visit', 'meet',
    'email', 'send', 'call', 'check', 'ensure', 'make', 'create',
    'draft', 'revise', 'edit', 'polish', 'hand in',
    'work on', 'focus on', 'look at', 'go over', 'set up',
  };

  static const _urgencyWords = {
    'urgent', 'asap', 'immediately', 'tomorrow', 'today',
    'this week', 'due', 'deadline', 'critical', 'important',
    'priority', 'overdue', 'late', 'emergency', 'rush',
  };

  static final _datePatterns = [
    RegExp(r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b', caseSensitive: false),
    RegExp(r'\b(january|february|march|april|may|june|july|august|september|october|november|december)\s+\d{1,2}\b', caseSensitive: false),
    RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b'),
    RegExp(r'\b(tomorrow|today|tonight|next week|this week|in \d+ days|in \d+ hours)\b', caseSensitive: false),
    RegExp(r'\bby\s+\w+\s+\d{1,2}\b', caseSensitive: false),
    RegExp(r'\bdue\s+(?:on\s+)?(.+?)(?:\.|$)', caseSensitive: false),
  ];

  static final _categoryPatterns = {
    'Academics': {
      'exam', 'quiz', 'midterm', 'final', 'assignment', 'homework',
      'lecture', 'class', 'course', 'study', 'read', 'chapter',
      'research', 'paper', 'essay', 'project', 'presentation',
      'professor', 'grade', 'submit', 'deadline', 'lab', 'tutorial',
    },
    'Wellness': {
      'sleep', 'exercise', 'gym', 'walk', 'meditate', 'rest',
      'break', 'health', 'mental', 'stress', 'relax', 'yoga',
      'workout', 'run', 'jog', 'sport', 'meal', 'eat', 'food',
    },
    'Admin': {
      'email', 'register', 'enroll', 'fee', 'payment', 'form',
      'document', 'appointment', 'meeting', 'schedule', 'calendar',
      'visa', 'insurance', 'bank', 'ID', 'card',
    },
    'Social': {
      'friend', 'family', 'call', 'text', 'message', 'hangout',
      'party', 'event', 'club', 'society', 'group', 'team',
      'volunteer', 'community',
    },
  };

  AiSummaryResult summarize(String text) {
    if (text.trim().isEmpty) {
      return const AiSummaryResult(
        keyPoints: [],
        actionItems: [],
        deadlines: [],
        categories: [],
        sentimentScore: 0.0,
        overallSummary: '',
      );
    }

    final sentences = _splitIntoSentences(text);
    if (sentences.isEmpty) {
      return const AiSummaryResult(
        keyPoints: [],
        actionItems: [],
        deadlines: [],
        categories: [],
        sentimentScore: 0.0,
        overallSummary: '',
      );
    }

    final words = _tokenize(text);
    final wordFreq = _computeWordFrequencies(words);
    final scoredSentences = _scoreSentences(sentences, wordFreq);

    final keyPoints = _extractKeyPoints(sentences, scoredSentences);
    final actionItems = _extractActionItems(sentences);
    final deadlines = _extractDeadlines(text);
    final categories = _detectCategories(text);
    final sentiment = _computeSentiment(text);
    final summary = _generateOverallSummary(keyPoints, actionItems, deadlines, sentiment);

    return AiSummaryResult(
      keyPoints: keyPoints,
      actionItems: actionItems,
      deadlines: deadlines,
      categories: categories,
      sentimentScore: sentiment,
      overallSummary: summary,
    );
  }

  List<String> _splitIntoSentences(String text) {
    final sentences = text
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.split(' ').length >= 3)
        .toList();
    return sentences;
  }

  List<String> _tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2 && !_stopWords.contains(word))
        .toList();
  }

  Map<String, int> _computeWordFrequencies(List<String> words) {
    final freq = <String, int>{};
    for (final word in words) {
      freq[word] = (freq[word] ?? 0) + 1;
    }
    final maxFreq = freq.values.fold(0, (a, b) => a > b ? a : b);
    return freq.map((k, v) => MapEntry(k, (v / maxFreq * 10).round()));
  }

  Map<String, double> _scoreSentences(List<String> sentences, Map<String, int> wordFreq) {
    final scores = <String, double>{};
    for (int i = 0; i < sentences.length; i++) {
      double score = 0;
      final sentence = sentences[i];
      final words = _tokenize(sentence);

      for (final word in words) {
        score += wordFreq[word] ?? 0;
      }

      if (words.isNotEmpty) {
        score /= words.length;
      }

      if (i == 0 || i == sentences.length - 1) {
        score += 2.0;
      }

      for (final keyword in _academicKeywords) {
        if (sentence.toLowerCase().contains(keyword)) {
          score += 1.5;
        }
      }

      for (final urgency in _urgencyWords) {
        if (sentence.toLowerCase().contains(urgency)) {
          score += 2.0;
        }
      }

      for (final pattern in _datePatterns) {
        if (pattern.hasMatch(sentence)) {
          score += 1.5;
        }
      }

      final length = words.length;
      if (length < 4) {
        score *= 0.5;
      } else if (length <= 15) {
        score *= 1.2;
      } else if (length > 30) {
        score *= 0.7;
      }

      scores[sentence] = score;
    }
    return scores;
  }

  List<String> _extractKeyPoints(List<String> sentences, Map<String, double> scores) {
    if (sentences.isEmpty) return [];

    final maxScore = scores.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxScore == 0) return sentences.take(3).toList();

    final sorted = sentences.toList()
      ..sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));

    final topCount = sentences.length.clamp(1, 5);
    return sorted.take(topCount).toList();
  }

  List<String> _extractActionItems(List<String> sentences) {
    final actions = <String>[];
    for (final sentence in sentences) {
      final lower = sentence.toLowerCase();
      for (final verb in _imperativeVerbs) {
        if (lower.startsWith(verb) || lower.contains('should $verb') || lower.contains('need to $verb') || lower.contains('must $verb')) {
          final trimmed = sentence.trim();
          if (!actions.contains(trimmed) && trimmed.isNotEmpty) {
            actions.add(trimmed);
          }
          break;
        }
      }
    }
    return actions.take(5).toList();
  }

  List<String> _extractDeadlines(String text) {
    final found = <String>{};
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(text)) {
        final deadline = match.group(0)?.trim();
        if (deadline != null && deadline.isNotEmpty && deadline.length < 50) {
          found.add(deadline);
        }
      }
    }
    if (found.isEmpty) {
      final words = text.toLowerCase().split(RegExp(r'\s+'));
      for (int i = 0; i < words.length - 1; i++) {
        if (words[i] == 'due' || words[i] == 'deadline') {
          final deadline = '${words[i]} ${words[i + 1]}';
          if (deadline.length < 30) {
            found.add(deadline);
          }
        }
      }
    }
    return found.take(5).toList().toList();
  }

  List<String> _detectCategories(String text) {
    final lower = text.toLowerCase();
    final detected = <String>[];
    for (final entry in _categoryPatterns.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          if (!detected.contains(entry.key)) {
            detected.add(entry.key);
          }
          break;
        }
      }
    }
    if (detected.isEmpty) {
      detected.add('General');
    }
    return detected;
  }

  double _computeSentiment(String text) {
    const positiveWords = {
      'good', 'great', 'excellent', 'amazing', 'clear', 'understand',
      'confident', 'prepared', 'organized', 'motivated', 'excited',
      'productive', 'focused', 'accomplished', 'happy', 'ready',
    };
    const negativeWords = {
      'hard', 'difficult', 'confused', 'lost', 'struggle', 'stress',
      'anxious', 'overwhelm', 'tired', 'behind', 'panic',
      'worry', 'concern', 'frustrat', 'bad', 'fail', 'late',
    };
    const neutralWords = {
      'neutral', 'okay', 'fine', 'alright', 'average', 'normal',
    };

    final lower = text.toLowerCase();
    int posCount = 0, negCount = 0;
    for (final word in positiveWords) {
      posCount += RegExp('\\b$word\\w*\\b', caseSensitive: false).allMatches(lower).length;
    }
    for (final word in negativeWords) {
      negCount += RegExp('\\b$word\\w*\\b', caseSensitive: false).allMatches(lower).length;
    }
    for (final word in neutralWords) {
      negCount -= RegExp('\\b$word\\w*\\b', caseSensitive: false).allMatches(lower).length;
    }

    final total = posCount + negCount;
    if (total == 0) return 0.5;
    return (posCount / total).clamp(0.0, 1.0);
  }

  String _generateOverallSummary(List<String> keyPoints, List<String> actions, List<String> deadlines, double sentiment) {
    final parts = <String>[];

    if (keyPoints.isNotEmpty) {
      parts.add('${keyPoints.length} key topics identified.');
    }
    if (actions.isNotEmpty) {
      parts.add('${actions.length} action items found.');
    }
    if (deadlines.isNotEmpty) {
      parts.add('${deadlines.length} deadlines detected.');
    }

    if (sentiment > AiScoring.sentimentPositiveThreshold / 100) {
      parts.add('Overall tone is positive.');
    } else if (sentiment < AiScoring.sentimentNegativeThreshold / 100) {
      parts.add('Consider lighter tasks given the challenging tone.');
    } else {
      parts.add('Content is balanced and manageable.');
    }

    return parts.join(' ');
  }
}
