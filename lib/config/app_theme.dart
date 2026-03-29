import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Kinetic Warmth Color Palette
  static const Color primary = Color(0xFF8C4A00);
  static const Color primaryFixed = Color(0xFFFD8B00);
  static const Color primaryFixedDim = Color(0xFFEA8000);
  static const Color primaryDim = Color(0xFF7B4000);
  static const Color primaryContainer = Color(0xFFFD8B00);
  static const Color onPrimary = Color(0xFFFFF0E7);
  static const Color onPrimaryContainer = Color(0xFF442100);
  static const Color onPrimaryFixed = Color(0xFF180800);
  static const Color onPrimaryFixedVariant = Color(0xFF512800);
  
  static const Color secondary = Color(0xFF6C5A00);
  static const Color secondaryFixed = Color(0xFFFFD709);
  static const Color secondaryFixedDim = Color(0xFFEFC900);
  static const Color secondaryDim = Color(0xFF5E4E00);
  static const Color secondaryContainer = Color(0xFFFFD709);
  static const Color onSecondary = Color(0xFFFFF2CD);
  static const Color onSecondaryContainer = Color(0xFF5B4B00);
  static const Color onSecondaryFixed = Color(0xFF453900);
  static const Color onSecondaryFixedVariant = Color(0xFF665500);
  
  static const Color tertiary = Color(0xFF6F5900);
  static const Color tertiaryFixed = Color(0xFFFFD33A);
  static const Color tertiaryFixedDim = Color(0xFFEFC52B);
  static const Color tertiaryDim = Color(0xFF614D00);
  static const Color tertiaryContainer = Color(0xFFFFD33A);
  static const Color onTertiary = Color(0xFFFFF2D3);
  static const Color onTertiaryContainer = Color(0xFF5C4900);
  static const Color onTertiaryFixed = Color(0xFF453600);
  static const Color onTertiaryFixedVariant = Color(0xFF675200);
  
  static const Color surface = Color(0xFFFFF5ED);
  static const Color surfaceDim = Color(0xFFFFCB93);
  static const Color surfaceBright = Color(0xFFFFF5ED);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFEEDF);
  static const Color surfaceContainer = Color(0xFFFFE4C9);
  static const Color surfaceContainerHigh = Color(0xFFFFDDBA);
  static const Color surfaceContainerHighest = Color(0xFFFFD6AB);
  static const Color surfaceVariant = Color(0xFFFFD6AB);
  static const Color onSurface = Color(0xFF452800);
  static const Color onSurfaceVariant = Color(0xFF7A5426);
  
  static const Color background = Color(0xFFFFF5ED);
  static const Color onBackground = Color(0xFF452800);
  
  static const Color error = Color(0xFFB02500);
  static const Color errorDim = Color(0xFFB92902);
  static const Color errorContainer = Color(0xFFF95630);
  static const Color onError = Color(0xFFFFEFEC);
  static const Color onErrorContainer = Color(0xFF520C00);
  
  static const Color outline = Color(0xFF986F3F);
  static const Color outlineVariant = Color(0xFFD4A46F);
  
  static const Color inverseSurface = Color(0xFF190B00);
  static const Color inverseOnSurface = Color(0xFFC29461);
  static const Color inversePrimary = Color(0xFFFD8B00);
  
  static const Color surfaceTint = Color(0xFF8C4A00);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: inverseSurface,
      onInverseSurface: inverseOnSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    ),
    
    scaffoldBackgroundColor: background,
    
    // Typography - Plus Jakarta Sans for headlines, Inter for body
    textTheme: TextTheme(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: onSurfaceVariant,
      ),
    ),
    
    // Shapes - Kinetic Warmth uses rounded corners
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      color: surfaceContainerLow,
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9999),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9999),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9999),
        borderSide: const BorderSide(color: primaryFixed, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryFixed,
        foregroundColor: onPrimaryContainer,
        elevation: 8,
        shadowColor: primaryFixed.withOpacity(0.25),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(48),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryFixed,
      foregroundColor: onPrimaryFixed,
      elevation: 8,
      shape: CircleBorder(),
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
    ),
  );
}
