import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VisualTheme {
  static const Color primaryColor = Color(0xFF0E4D5A);
  static const Color secondaryColor = Color(0xFFE07A4A);
  static const Color accentColor = Color(0xFFF0C14A);
  static const Color foam = Color(0xFFE8F2F4);
  static const Color mist = Color(0xFFD4E4E8);
  static const Color night = Color(0xFF07161A);
  static const Color deep = Color(0xFF0B242A);
  static const Color ink = Color(0xFF102226);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: foam,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: foam,
      textTheme: GoogleFonts.ibmPlexSansTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: ink,
        displayColor: ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0x330E4D5A)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: BeveledRectangleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: primaryColor,
        indicatorColor: secondaryColor,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        iconTheme: const WidgetStatePropertyAll(IconThemeData(color: Colors.white)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0x330E4D5A))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0x330E4D5A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: primaryColor, width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: const BeveledRectangleBorder(),
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: const Color(0xFF7EB8C4),
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: deep,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: night,
      textTheme: GoogleFonts.ibmPlexSansTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: deep,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: deep,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        shape: BeveledRectangleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: deep,
        indicatorColor: secondaryColor.withValues(alpha: 0.75),
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F2A30),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF7EB8C4), width: 1.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: const BeveledRectangleBorder(),
          textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Color getCategoryColor(String category) {
    final colors = {
      'Lures': const Color(0xFFE07A4A),
      'Flies': const Color(0xFF0E4D5A),
      'Line': const Color(0xFF3A7CA5),
      'Hooks': const Color(0xFF8A6A3D),
      'Sinkers': const Color(0xFF6A746C),
      'Rods': const Color(0xFF2C5F4A),
      'Reels': const Color(0xFFF0C14A),
      'Tools': const Color(0xFF5B4A3A),
      'Apparel': const Color(0xFF4A6FA5),
      'Other': const Color(0xFF6A746C),
    };
    return colors[category] ?? const Color(0xFF6A746C);
  }

  static Color getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'fresh':
        return const Color(0xFF2C5F4A);
      case 'fished':
        return const Color(0xFF3A7CA5);
      case 'rusted':
        return const Color(0xFFE07A4A);
      case 'spare':
        return const Color(0xFFF0C14A);
      default:
        return const Color(0xFF6A746C);
    }
  }
}
