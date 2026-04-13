import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // App Colors
  static const Color background = Color(0xFF0A1628);
  static const Color surface = Color(0xFF132238);
  static const Color surfaceLight = Color(0xFF1E324F);
  
  static const Color accentHighRisk = Color(0xFFFF4444);
  static const Color accentModerateRisk = Color(0xFFFFA500);
  static const Color accentSafe = Color(0xFF00C896);
  static const Color primaryBlue = Color(0xFF2A84FF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA0B3CC);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      cardColor: surface,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        surface: surface,
        background: background,
        error: accentHighRisk,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
