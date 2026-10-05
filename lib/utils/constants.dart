import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const int slateBlue = 0xFF4A5C8A;
  static const int ink = 0xFF111318;
  static const int offWhite = 0xFFF6F5F3;
  static const int surfaceLight = 0xFFF1F2F6;
  static const int surfaceDark = 0xFF1C1F24;

  static const int primaryGreen = 0xFF5B8E7D;
  static const int accentPurple = 0xFF7986CB;
  static const int accentOrange = 0xFFD8A15C;
  static const int accentPink = 0xFFE57373;
  static const int neutralSlate = 0xFF6C8A7B;

  static const int positiveGreen = 0xFF4CAF50;
  static const int warningOrange = 0xFFFFB74D;
  static const int errorRed = 0xFFD65A5A;

  static const int priorityCritical = 0xFFE57373;
  static const int priorityHigh = 0xFFD8A15C;
  static const int priorityMedium = 0xFF5B8E7D;
  static const int priorityLow = 0xFF6C8A7B;

  static Color get primary => const Color(slateBlue);
  static Color get green => const Color(primaryGreen);
  static Color get purple => const Color(accentPurple);
  static Color get orange => const Color(accentOrange);
  static Color get pink => const Color(accentPink);
  static Color get slate => const Color(neutralSlate);
  static Color get success => const Color(positiveGreen);
  static Color get warning => const Color(warningOrange);
  static Color get error => const Color(errorRed);

  static Color get priorityCriticalColor => const Color(priorityCritical);
  static Color get priorityHighColor => const Color(priorityHigh);
  static Color get priorityMediumColor => const Color(priorityMedium);
  static Color get priorityLowColor => const Color(priorityLow);

  static int categoryAccent(String category) {
    switch (category) {
      case 'Academics':
        return primaryGreen;
      case 'Group work':
        return accentPurple;
      case 'Admin':
        return accentOrange;
      case 'Wellness':
        return accentPink;
      case 'Social':
        return slateBlue;
      default:
        return neutralSlate;
    }
  }

  static Color forCategory(String category) => Color(categoryAccent(category));
}

class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1600);
}

class AppDimensions {
  AppDimensions._();

  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 24.0;
  static const double paddingXl = 32.0;

  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 18.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}

class AppStrings {
  AppStrings._();

  static const String appName = 'Lifely';
  static const String defaultUserName = 'Student';
  static const String defaultEmail = 'student@lifely.app';
  static const String appVersion = '1.0.0';

  static const List<String> categories = [
    'Academics',
    'Group work',
    'Admin',
    'Wellness',
    'Routine',
    'Social',
  ];

  static const List<String> moods = [
    'Focused',
    'Steady',
    'Stressed',
    'Low energy',
  ];

  static const List<int> taskDurations = [15, 30, 45, 60, 90, 120];

  static const String deepWorkDetail = '90 min deep work';
  static const int defaultFocusAccent = 0xFF5B8E7D;
}

class AiScoring {
  AiScoring._();

  static const double overdueScore = 50.0;
  static const double within24hScore = 40.0;
  static const double within48hScore = 30.0;
  static const double within72hScore = 20.0;
  static const double withinWeekScore = 10.0;

  static const double urgencyKeywordScore = 15.0;
  static const double impactKeywordScore = 10.0;
  static const double quickTaskBonus = 5.0;
  static const double longTaskBonus = 3.0;

  static const double academicsBonus = 5.0;
  static const double adminBonus = 3.0;
  static const double wellnessBonus = 2.0;
  static const double routinePenalty = -5.0;

  static const double criticalThreshold = 50.0;
  static const double highThreshold = 30.0;
  static const double mediumThreshold = 15.0;

  static const int maxKeyPoints = 5;
  static const int maxActionItems = 5;
  static const int maxDeadlines = 5;
  static const int sentimentPositiveThreshold = 60;
  static const int sentimentNegativeThreshold = 40;

  static const double focusedLoadMultiplier = 1.2;
  static const double steadyLoadMultiplier = 1.0;
  static const double stressedLoadMultiplier = 0.5;
  static const double lowEnergyLoadMultiplier = 0.3;

  // Upper bound on scheduled minutes per day, by mood.
  static const int focusedDailyMinutes = 360;
  static const int steadyDailyMinutes = 300;
  static const int stressedDailyMinutes = 180;
  static const int lowEnergyDailyMinutes = 120;

  static const int peakHours = 9;
  static const int peakHoursEnd = 11;
  static const int afternoonPeakStart = 14;
  static const int afternoonPeakEnd = 15;
  static const int lowEnergyHour1 = 13;
  static const int lowEnergyHour2 = 20;
  static const int lowEnergyHour3 = 21;
  static const int lowEnergyHour4 = 22;
}