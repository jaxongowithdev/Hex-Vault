import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF5A1A2A);
  static const Color secondaryColor = Color(0xFFC9A24A);
  static const Color accentColor = Color(0xFFD4A5A5);
  static const Color ivory = Color(0xFFF7F1E8);
  static const Color linen = Color(0xFFEDE3D4);
  static const Color night = Color(0xFF1A1014);
  static const Color wine = Color(0xFF2A1218);
  static const Color ink = Color(0xFF2B1A1F);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: ivory,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: linen,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ivory,
      textTheme: GoogleFonts.figtreeTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x1A5A1A2A)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ivory,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.1),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.figtree(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x335A1A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x335A1A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFFE2B3BE),
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: wine,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.figtreeTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: wine,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: night,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: night,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 70,
        backgroundColor: wine,
        indicatorColor: secondaryColor.withValues(alpha: 0.22),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.figtree(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A161C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2B3BE), width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: night,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Jazz': const Color(0xFFC9A24A),
      'Rock': const Color(0xFF8B2E2E),
      'Soul': const Color(0xFF5A1A2A),
      'Classical': const Color(0xFF6B5B4F),
      'Hip-Hop': const Color(0xFF2C3E50),
      'Electronic': const Color(0xFF4A6FA5),
      'Folk': const Color(0xFF7A6A4F),
      'Soundtrack': const Color(0xFF8A6B8A),
      'World': const Color(0xFF4F7A62),
      'Other': const Color(0xFF7A6E6A),
    };
    return colors[category] ?? const Color(0xFF7A6E6A);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'mint':
        return const Color(0xFF4F7A62);
      case 'near mint':
        return const Color(0xFF4A6FA5);
      case 'played':
        return const Color(0xFFC9A24A);
      case 'worn':
        return const Color(0xFF8B2E2E);
      default:
        return const Color(0xFF7A6E6A);
    }
  }
}
