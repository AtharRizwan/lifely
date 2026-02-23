import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(Brightness brightness) {
  const slateBlue = Color(0xFF4A5C8A);
  const ink = Color(0xFF111318);
  const offWhite = Color(0xFFF6F5F3);
  const surfaceLight = Color(0xFFF1F2F6);
  const surfaceDark = Color(0xFF1C1F24);
  const dividerLight = Color(0xFFE5E7EB);
  const dividerDark = Color(0xFF2A2F36);

  final isDark = brightness == Brightness.dark;
  final baseTextTheme = GoogleFonts.newsreaderTextTheme();
  final bodyTextTheme = GoogleFonts.interTextTheme();
  final textColor = isDark ? const Color(0xFFE7E7EA) : ink;
  final displayTextTheme = baseTextTheme.apply(
    bodyColor: textColor,
    displayColor: textColor,
  );
  final appliedBodyTextTheme = bodyTextTheme.apply(
    bodyColor: textColor,
    displayColor: textColor,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: slateBlue,
      onPrimary: Colors.white,
      secondary: slateBlue.withOpacity(0.16),
      onSecondary: isDark ? Colors.white : ink,
      error: const Color(0xFFD65A5A),
      onError: Colors.white,
      surface: isDark ? surfaceDark : offWhite,
      onSurface: isDark ? const Color(0xFFE7E7EA) : ink,
      surfaceContainerHighest: isDark ? const Color(0xFF262B33) : surfaceLight,
    ),
    scaffoldBackgroundColor: isDark ? const Color(0xFF15181D) : offWhite,
    textTheme: displayTextTheme.copyWith(
      headlineLarge: displayTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      headlineMedium: displayTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
      titleLarge: displayTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: displayTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: appliedBodyTextTheme.bodyLarge,
      bodyMedium: appliedBodyTextTheme.bodyMedium,
      bodySmall: appliedBodyTextTheme.bodySmall,
      labelLarge: appliedBodyTextTheme.labelLarge,
      labelMedium: appliedBodyTextTheme.labelMedium,
      labelSmall: appliedBodyTextTheme.labelSmall,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: isDark ? Colors.white : ink),
      titleTextStyle: baseTextTheme.titleLarge?.copyWith(
        color: isDark ? Colors.white : ink,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: isDark ? dividerDark : dividerLight,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF232831) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: slateBlue, width: 1.2),
      ),
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF9FA6B2) : const Color(0xFF8A8F9A),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: isDark ? const Color(0xFF1E232A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? dividerDark : dividerLight),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? const Color(0xFF15181D) : offWhite,
      selectedItemColor: slateBlue,
      unselectedItemColor: isDark
          ? const Color(0xFF8F95A1)
          : const Color(0xFF8A8F9A),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
