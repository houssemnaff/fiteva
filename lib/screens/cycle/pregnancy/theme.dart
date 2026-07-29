import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThreadTheme {
  ThreadTheme._();

  // Theme-aware getters
  static Color bgOf(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color bgSurfaceOf(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color bgCardOf(BuildContext c) => Theme.of(c).brightness == Brightness.dark
      ? Theme.of(c).colorScheme.surfaceContainerLow : Colors.white;
  static Color textPrimaryOf(BuildContext c) => Theme.of(c).colorScheme.onSurface;
  static Color accentOf(BuildContext c) => Theme.of(c).colorScheme.secondary;

  // Legacy statics
  static const Color bg = Colors.white;
  static const Color bgSurface = Colors.white;
  static const Color bgCard = Colors.white;
  static const Color bgCardBorder = Colors.white;

  // ─────────────────────────────
  // Pregnancy progression (natural growth system)
  // ─────────────────────────────

  // T1 — beginning / soft vitality (dynamic via accent)
  static Color t1Start(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color t1End(BuildContext c)   => Color.lerp(Theme.of(c).colorScheme.primary, Colors.white, 0.25)!;

  // T2 — strength / stability (dynamic via accent)
  static Color t2Start(BuildContext c) => Color.lerp(Theme.of(c).colorScheme.primary, Colors.black, 0.35)!;
  static Color t2End(BuildContext c)   => Color.lerp(Theme.of(c).colorScheme.primary, Colors.grey, 0.25)!;

  // T3 — warmth / nearing birth (dynamic via accent)
  static Color t3Start(BuildContext c) => Color.lerp(Theme.of(c).colorScheme.primary, Colors.black, 0.2)!;
  static Color t3End(BuildContext c)   => Color.lerp(Theme.of(c).colorScheme.primary, Colors.white, 0.25)!;

  // ─────────────────────────────
  // Text (FIXED — readable & premium)
  // ─────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A1A);   // FIXED
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textTertiary = Color(0xFF9A9A9A);

  // ─────────────────────────────
  // Accent (MATCH YOUR BRAND)
  // ─────────────────────────────
  static Color accentFor(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color accentSoftFor(BuildContext c) => Theme.of(c).colorScheme.primary.withValues(alpha: 0.13);

  static Color threadColorForWeek(int week, BuildContext c) {
    if (week <= 13) {
      final t = (week - 1) / 12.0;
      return Color.lerp(t1Start(c), t1End(c), t)!;
    } else if (week <= 27) {
      final t = (week - 14) / 13.0;
      return Color.lerp(t2Start(c), t2End(c), t)!;
    } else {
      final t = (week - 28) / 12.0;
      return Color.lerp(t3Start(c), t3End(c), t)!;
    }
  }



static Color threadForWeek(int week, {BuildContext? context}) {
    final accent = context != null ? Theme.of(context).colorScheme.primary : const Color(0xFF7DAF8A);
    if (week <= 13) return accent;
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
      primary: Color(0xFF7ABB98),
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