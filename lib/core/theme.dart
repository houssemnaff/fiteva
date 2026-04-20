import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF4F4F2);
  static const Color cardColor = Colors.white;
  static const Color borderLight = Color(0xFFECECEC);
  static const Color primaryActive = Color(0xFF1C4D30);
  static const Color inactiveGrey = Colors.grey;
  static const Color primaryText = Color(0xFF222222);
  static const Color secondaryText = Color(0xFF666666);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primaryActive,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryActive),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: primaryText,
        displayColor: primaryText,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryActive,
        unselectedItemColor: inactiveGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryActive,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }

  static TextStyle get logoStyle {
    return const TextStyle(
   fontFamily: '.SF Pro Text',
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
      fontSize: 24,
      color: primaryText,
    );
  }
}
