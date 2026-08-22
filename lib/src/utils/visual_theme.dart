import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF1C1C1E);
  static const Color secondaryColor = Color(0xFFE39B3A);
  static const Color accentColor = Color(0xFFC43C3C);
  static const Color paper = Color(0xFFF3EEE4);
  static const Color mist = Color(0xFFE4DDD0);
  static const Color silver = Color(0xFFB8BCC2);
  static const Color night = Color(0xFF0E0E10);
  static const Color deep = Color(0xFF161618);
  static const Color ink = Color(0xFF1A1814);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: paper,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: Color(0x331C1C1E)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.instrumentSerif(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: primaryColor,
        indicatorColor: secondaryColor,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Colors.white)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Color(0x331C1C1E))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: Color(0x331C1C1E))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: const Color(0xFF1C1C1E),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: silver,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: deep,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.instrumentSerif(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: deep,
        indicatorColor: secondaryColor.withValues(alpha: 0.8),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF222224),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: const BorderSide(color: silver, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: const Color(0xFF1C1C1E),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      '35mm': const Color(0xFFE39B3A),
      '120': const Color(0xFFC43C3C),
      'Instant': const Color(0xFF6B7C8A),
      'Sheet': const Color(0xFF8A6A3D),
      'Camera': const Color(0xFF1C1C1E),
      'Lens': const Color(0xFF4A6FA5),
      'Chem': const Color(0xFF2C5F4A),
      'Paper': const Color(0xFFB8BCC2),
      'Filter': const Color(0xFF7A4A6A),
      'Other': const Color(0xFF6A746C),
    };
    return colors[category] ?? const Color(0xFF6A746C);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'unshot':
        return const Color(0xFF2C5F4A);
      case 'loaded':
        return const Color(0xFFE39B3A);
      case 'developed':
        return const Color(0xFF4A6FA5);
      case 'expired':
        return const Color(0xFFC43C3C);
      default:
        return const Color(0xFF6A746C);
    }
  }
}
