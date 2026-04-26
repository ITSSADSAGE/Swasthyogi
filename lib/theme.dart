import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - Premium Palette
  static const Color medicalBlue = Color(0xFF007BFF); // Deep Medical Blue
  static const Color emergencyRed = Color(0xFFD91E18); // Urgent Emergency Red
  static const Color bgDark = Color(0xFF020617); // Deepest Navy
  static const Color surfaceDark = Color(0xFF0F172A); // Dark Navy Surface
  static const Color accentCyan = Color(0xFF06B6D4); // For tech/AI feel
  static const Color accentOrange = Color(0xFFF97316);
  
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);

  // Keep aliases for backward compatibility if needed, but better to rename usages
  static const Color primaryGreen = medicalBlue; // Temporary alias
  static const Color accentRed = emergencyRed; // Temporary alias

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: medicalBlue,
      colorScheme: const ColorScheme.light(
        primary: medicalBlue,
        secondary: accentCyan,
        surface: Colors.white,
        onSurface: Color(0xFF020617),
        error: emergencyRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Color(0xFF020617), fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Color(0xFF020617)),
          bodyMedium: TextStyle(color: Color(0xFF475569)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF020617)),
        iconTheme: IconThemeData(color: Color(0xFF020617)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: medicalBlue,
      colorScheme: const ColorScheme.dark(
        primary: medicalBlue,
        secondary: accentCyan,
        surface: surfaceDark,
        onSurface: textPrimary,
        error: emergencyRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: bgDark,
        elevation: 0,
      ),
    );
  }
}
