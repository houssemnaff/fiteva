import 'package:fiteva/screens/cycle/pregnancy/pregnancy_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ---------------------------------------------------------------------------
  // Core Brand Colors (main design system)
  // ---------------------------------------------------------------------------
  static const Color primaryColor = Color(0xFF1C4D30); // #1C4D30
  static const Color accentColor = Color(0xFF7ABB98); // #7ABB98
  static const Color backgroundColor =  Color.fromARGB(255, 254, 254, 254); // #F4F4F2
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF757575);

  // ---------------------------------------------------------------------------
  // Legacy / Alias Names (for progressive migration of old files)
  // ---------------------------------------------------------------------------
  static const Color background = backgroundColor;
  static const Color cardColor = surfaceColor;
  static const Color borderLight = Color(0xFFECECEC);
  static const Color primaryActive = primaryColor;
  static const Color inactiveGrey = Colors.grey;
  static const Color primaryText = textPrimaryColor;
  static const Color secondaryText = Color(0xFF666666);

  // ----------------------------------- ----------------------------------------
  // Neutral / Utility
  // ---------------------------------------------------------------------------
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color neutral50 = Color(0xFFF7F8FC);
  static const Color neutral100 = Color(0xFFF5F5F0);
  static const Color neutral200 = Color(0xFFF2F2F2);
  static const Color neutral300 = Color(0xFFE8EDE8);
  static const Color neutral400 = Color(0xFFE5E5E0);
  static const Color neutral600 = Color(0xFF5A6B62);
  static const Color neutral900 = Color(0xFF0D0D0D);

  // ---------------------------------------------------------------------------
  // Onboarding Palette
  // ---------------------------------------------------------------------------
  static const Color onboardingGreen = Color(0xFF2D4A2D);
  static const Color onboardingBg = Color(0xFFF0F0EC);
  static const Color onboardingPrimary = Color(0xFF1C4D30);
  static const Color onboardingLight = Color(0xFF7ABB98);
  static const Color onboardingDeep = Color(0xFF7ABB98);
  static const Color onboardingPale = Color(0xFFFCE4EC);
  static const Color onboardingCircleDark = Color(0xFF2E5E35);
  static const Color onboardingHeroGreen = Color(0xFF244D2A);
  static const Color onboardingNeon = Color.fromARGB(255, 149, 239, 47);

  // ---------------------------------------------------------------------------
  // Home / Global Accent Extras
  // ---------------------------------------------------------------------------
  static const Color successMint = Color(0xFF52B788);
  static const Color darkTitle = Color(0xFF333333);
  static const Color profileButtonGreen = Color(0xFF1B5E3B);
  static const Color chatbotGradientStart = Color.fromARGB(255, 13, 71, 220);
  static const Color chatbotGradientEnd = Color.fromARGB(255, 235, 135, 53);

  // ---------------------------------------------------------------------------
  // Workout Palette
  // ---------------------------------------------------------------------------
  static const Color workoutMusculation = Color(0xFFEF5350);
  static const Color workoutPilates = Color(0xFF9575CD);
  static const Color workoutHiit = Color.fromARGB(255, 255, 0, 0);
  static const Color workoutDance = Color(0xFFFF6F91);
  static const Color workoutYoga = Color(0xFF4DB6AC);
  static const Color workoutRunning = Color(0xFF42A5F5);
  static const Color workoutDefault = Color(0xFF90A4AE);
  static const Color workoutHeaderBg = Color(0xFF2D4A2D);
  static const Color workoutPageBg = Color(0xFFF2F2F2);
  static const Color workoutCardSoftBg = Color(0xFFE8F5E9);
  static const Color workoutCardSoftBorder = Color(0xFFB2DFB2);
  static const Color workoutSuccess = Color(0xFF4CAF50);
  static const Color workoutTextDark = Color(0xFF1A2E1A);
  static const Color workoutTextMedium = Color(0xFF3A7A3A);
  static const Color workoutTextSoft = Color(0xFF5A8A5A);

  // ---------------------------------------------------------------------------
  // Nutrition Palette
  // ---------------------------------------------------------------------------
  static const Color nutritionBg = Color(0xFFF5F5F0);
  static const Color nutritionPrimary = Color(0xFF2D4A2D);
  static const Color nutritionMacro = Color(0xFF8BC34A);
  static const Color nutritionRisk = Color(0xFFCDDC39);

  // ---------------------------------------------------------------------------
  // Community Palette
  // ---------------------------------------------------------------------------
  static const Color communityBg = Color(0xFFF7F8FC);
  static const Color communityBgAlt = Color(0xFFF8FAFF);

  // ---------------------------------------------------------------------------
  // Cycle Palette
  // ---------------------------------------------------------------------------
  static const Color phaseMenstrual = Color(0xFFD94F6B);
  static const Color phaseFolliculaire = Color(0xFF7ABB98);
  static const Color phaseOvulatoire = Color(0xFFF4A940);
  static const Color phaseLuteal = Color(0xFF5A7FC2);

  static const Color cycleMenstrualLight = Color(0xFFFFD6E0);
  static const Color cycleMenstrualMid = Color(0xFFFF9BB3);
  static const Color cycleFollicularLight = Color(0xFFE8FDF3);
  static const Color cycleFollicularMid = Color(0xFF7BE0B5);
  static const Color cycleFollicularPrimary = Color(0xFF2FBF91);
  static const Color cycleOvulationLight = Color(0xFFE8FFFB);
  static const Color cycleOvulationMid = Color(0xFFB8F2E6);
  static const Color cycleOvulationStrong = Color(0xFF7DE2D1);
  static const Color cycleOvulationPrimary = Color(0xFF5FD3C4);
  static const Color cycleLutealLight = Color(0xFFE3ECFF);
  static const Color cycleLutealMid = Color(0xFF8FAFFF);
  static const Color cycleLutealPrimary = Color(0xFF4A6CF7);
  static const Color cyclePinkText = Color(0xFF3D2033);
  static const Color cycleIconMuted = Color(0xFFB07A9A);

  // ---------------------------------------------------------------------------
  // Overlay / Transparency Helpers (same values used across UI)
  // ---------------------------------------------------------------------------
  static const Color overlayBlack = Color(0xFF000000);
  static const Color overlayWhite = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;
static ThemeMode themeMode = ThemeMode.system;
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        onPrimary: white,
        onSecondary: white,
        onSurface: textPrimaryColor,
        surfaceContainerHighest: Color(0xFFF5F5F0),
        outline: Color(0xFFE0E0DA),
        outlineVariant: Color(0xFFDDDDD8),
        secondaryContainer: Color(0xFFD6EDE0),
        onSecondaryContainer: Color(0xFF1C4D30),
        shadow: Color(0xFF000000),
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.inter(
          color: textPrimaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(color: textPrimaryColor, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textSecondaryColor, fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Color(0x0D000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      extensions: const [PgColors.light],
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: textSecondaryColor),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A ),
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: primaryColor,
        surface: Color(0xFF141414),
        onPrimary: white,
        onSecondary: white,
        onSurface: white,
        surfaceContainerHighest: Color(0xFF1E1E1E),
        outline: Color(0xFF2C2C2C),
        outlineVariant: Color(0xFF353535),
        secondaryContainer: Color(0xFF1A3326),
        onSecondaryContainer: Color(0xFF7ABB98),
        shadow: Color(0xFF000000),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: white,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.outfit(
          color: white,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        titleLarge: GoogleFonts.outfit(
          color: white,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.inter(
          color: white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.inter(color: white, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFFAAAAAA), fontSize: 14),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: white),
        titleTextStyle: GoogleFonts.outfit(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF141414),
        elevation: 0,
        shadowColor: Color(0x33000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      extensions: const [PgColors.dark],
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF141414),
        selectedItemColor: accentColor,
        unselectedItemColor: Color(0xFF888888),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF141414 ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF888888)),
      ),
    );
  }
}

/// Single source of truth for legacy cycle screens that still reference the old palette name.
/// Keep this here so the app only needs one theme file.
class FitEvaColors {
  FitEvaColors._();

  static const Color primary = AppTheme.primaryColor;
  static const Color accent = AppTheme.accentColor;
  static const Color cardBg = Color(0xFFEAF3EC);
  static const Color bgApp = AppTheme.backgroundColor;
  static const Color text = AppTheme.neutral900;
  static const Color surface = AppTheme.surfaceColor;
  static const Color textMuted = AppTheme.neutral600;

  static const Color phaseMenstrual = AppTheme.phaseMenstrual;
  static const Color phaseFolliculaire = AppTheme.phaseFolliculaire;
  static const Color phaseOvulatoire = AppTheme.phaseOvulatoire;
  static const Color phaseLuteal = AppTheme.phaseLuteal;
}
