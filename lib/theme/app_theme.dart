import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== COLORS =====

  static const Color pureWhite = Color(0xFFFFFFFF);

  static const Color primaryBlue = Color(0xFF0670A9);
  static const Color primaryBlueDark = Color(0xFF034D74);
  static const Color primaryBlueLight = Color(0xFFD6EEF8);

  static const Color accentOrange = Color(0xFFFF8021);
  static const Color accentOrangeDark = Color(0xFFCC5E00);
  static const Color accentOrangeLight = Color(0xFFFFE1CC);

  static const Color textDark = Color(0xFF1D242B);
  static const Color textMedium = Color(0xFF5E6772);

  static const Color borderGray = Color(0xFFE2E8EE);

  static const Color lightSurface = Color(0xFFF7FAFC);

  static const Color darkBackground = Color(0xFF11161C);
  static const Color darkSurface = Color(0xFF1A2027);
  static const Color darkContainer = Color(0xFF242C36);

  // ===== LIGHT THEME =====

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      brightness: Brightness.light,

      scaffoldBackgroundColor: pureWhite,

      textTheme: GoogleFonts.alexandriaTextTheme(
        base.textTheme,
      ).apply(bodyColor: textDark, displayColor: textDark),

      colorScheme: const ColorScheme.light(
        primary: primaryBlue,

        secondary: accentOrange,

        tertiary: accentOrange,

        surface: pureWhite,

        onSurface: textDark,

        primaryContainer: primaryBlueLight,

        onPrimaryContainer: primaryBlueDark,

        secondaryContainer: accentOrangeLight,

        onSecondaryContainer: accentOrangeDark,

        outline: borderGray,

        surfaceContainerHighest: lightSurface,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: pureWhite,
        foregroundColor: textDark,
        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
      ),

      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: pureWhite,

          minimumSize: const Size(64, 54),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: GoogleFonts.alexandria(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,

          side: const BorderSide(color: primaryBlue),

          minimumSize: const Size(64, 54),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: lightSurface,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: borderGray),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: borderGray),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),

      dividerColor: borderGray,
    );
  }

  // ===== DARK THEME =====

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      brightness: Brightness.dark,

      scaffoldBackgroundColor: darkBackground,

      textTheme: GoogleFonts.alexandriaTextTheme(base.textTheme),

      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,

        secondary: accentOrange,

        tertiary: accentOrange,

        surface: darkSurface,

        onSurface: pureWhite,

        primaryContainer: primaryBlueDark,

        onPrimaryContainer: primaryBlueLight,

        secondaryContainer: accentOrangeDark,

        onSecondaryContainer: accentOrangeLight,

        outline: Color(0xFF39414A),

        surfaceContainerHighest: darkContainer,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: darkBackground,

        foregroundColor: pureWhite,

        titleTextStyle: GoogleFonts.alexandria(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: darkSurface,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,

          foregroundColor: pureWhite,

          minimumSize: const Size(64, 54),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: darkContainer,

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
