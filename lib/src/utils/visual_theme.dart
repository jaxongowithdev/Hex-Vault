import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF5B7A6A);
  static const Color secondaryColor = Color(0xFFC47B7B);
  static const Color accentColor = Color(0xFFC9845A);
  static const Color fog = Color(0xFFF4F0EB);
  static const Color blush = Color(0xFFF3E4E0);
  static const Color night = Color(0xFF1C1A18);
  static const Color moss = Color(0xFF1F2622);
  static const Color ink = Color(0xFF2A2422);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: fog,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: fog,
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: fog,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: blush,
        indicatorColor: Colors.white,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.karla(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF9BB8A8),
      secondary: const Color(0xFFE0A0A0),
      tertiary: accentColor,
      surface: moss,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.karlaTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: moss,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: night,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: moss,
        indicatorColor: primaryColor.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.karla(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2825),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF9BB8A8), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF9BB8A8),
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.karla(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Wool': const Color(0xFFC47B7B),
      'Cotton': const Color(0xFF5B7A6A),
      'Alpaca': const Color(0xFFC9845A),
      'Silk': const Color(0xFF8A6B8A),
      'Blends': const Color(0xFF7A8B6A),
      'Tools': const Color(0xFF6B5B4F),
      'Patterns': const Color(0xFF4A6FA5),
      'Notions': const Color(0xFFB07A5A),
      'Other': const Color(0xFF7A6E6A),
    };
    return colors[category] ?? const Color(0xFF7A6E6A);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'new':
        return const Color(0xFF5B7A6A);
      case 'wound':
        return const Color(0xFF4A6FA5);
      case 'partial':
        return const Color(0xFFC9845A);
      case 'scrap':
        return const Color(0xFFC47B7B);
      default:
        return const Color(0xFF7A6E6A);
    }
  }
}
