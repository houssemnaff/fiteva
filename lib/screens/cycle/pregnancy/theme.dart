import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThreadTheme {
  ThreadTheme._();

    // Background palette — deep obsidian
   // Background system — warm luxury neutral
static const Color bg = Colors.white;        // soft ivory base
  static const Color bgSurface = Colors.white;   // clean surface
  static const Color bgCard = Colors.white;     // soft elevated card
  static const Color bgCardBorder = Colors.white;  // warm subtle border

  // ─────────────────────────────
  // Pregnancy progression (natural growth system)
  // ─────────────────────────────

  // T1 — beginning / soft vitality
  static const Color t1Start = Color(0xFF7ABB98);
  static const Color t1End   = Color.fromARGB(255, 116, 163, 139);

  // T2 — strength / stability
  static const Color t2Start = Color(0xFF1C4D30);
  static const Color t2End   = Color(0xFF4F7D66);

  // T3 — warmth / nearing birth (soft organic warmth)
  static const Color t3Start = Color.fromARGB(255, 84, 118, 95);
  static const Color t3End   = Color.fromARGB(255, 116, 163, 139);

  // ─────────────────────────────
  // Text (FIXED — readable & premium)
  // ─────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);   // FIXED
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textTertiary = Color(0xFF9A9A9A);

  // ─────────────────────────────
  // Accent (MATCH YOUR BRAND)
  // ─────────────────────────────
  static const Color accent = Color(0xFF7ABB98);
  static const Color accentSoft = Color(0x227ABB98);

  static Color threadColorForWeek(int week) {
    if (week <= 13) {
      final t = (week - 1) / 12.0;
      return Color.lerp(t1Start, t1End, t)!;
    } else if (week <= 27) {
      final t = (week - 14) / 13.0;
      return Color.lerp(t2Start, t2End, t)!;
    } else {
      final t = (week - 28) / 12.0;
      return Color.lerp(t3Start, t3End, t)!;
    }
  }



static Color threadForWeek(int week) {
    if (week <= 13) return const Color(0xFF7DAF8A);
    if (week <= 27) return const Color(0xFFB97A8A);
    if (week <= 36) return const Color(0xFF9B7DAF);
    return const Color(0xFFB8916E);
  }


  static int strandCountForWeek(int week) {
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  static double threadBaseWidthForWeek(int week) {
    if (week <= 13) {
      return 1.5 + (week / 13.0) * 1.0;
    } else if (week <= 27) {
      return 2.5 + ((week - 14) / 13.0) * 2.0;
    } else {
      return 4.5 + ((week - 28) / 12.0) * 2.5;
    }
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      background: bg,
      surface: bgSurface,
      primary: accent,
      onPrimary: bg,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Playfair Display',
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w300,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w300,
        height: 1.5,
      ),
      labelSmall: TextStyle(
        color: textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(0, 253, 0, 0),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        letterSpacing: 1.5,
      ),
    ),
  );
}