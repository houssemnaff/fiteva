import 'package:flutter/material.dart';

// Palette FitEva Grossesse — adaptive light/dark
// Usage: final p = PgColors.of(context);  →  p.green, p.bg, etc.

@immutable
class PgColors extends ThemeExtension<PgColors> {
  const PgColors({
    required this.green,
    required this.mint,
    required this.mintLight,
    required this.mintSoft,
    required this.warmPink,
    required this.pinkSoft,
    required this.amber,
    required this.amberSoft,
    required this.bg,
    required this.surface,
    required this.textDark,
    required this.textMid,
    required this.textSoft,
    required this.border,
  });

  final Color green;
  final Color mint;
  final Color mintLight;
  final Color mintSoft;
  final Color warmPink;
  final Color pinkSoft;
  final Color amber;
  final Color amberSoft;
  final Color bg;
  final Color surface;   // white in light / dark card in dark
  final Color textDark;
  final Color textMid;
  final Color textSoft;
  final Color border;

  // ── light ──────────────────────────────────────────────────────────────────
  static const light = PgColors(
    green:     Color(0xFF1C4D30),
    mint:      Color(0xFF7ABB98),
    mintLight: Color(0xFFEAF3EC),
    mintSoft:  Color(0xFFF3F9F5),
    warmPink:  Color(0xFFE58F8A),
    pinkSoft:  Color(0xFFFDF0EF),
    amber:     Color(0xFFF4A940),
    amberSoft: Color(0xFFFDF5E6),
    bg:        Color.fromARGB(255, 255, 255, 255),
    surface:   Color(0xFFFFFFFF),
    textDark:  Color(0xFF1A2E20),
    textMid:   Color(0xFF5A7A65),
    textSoft:  Color(0xFF9AB8A5),
    border:    Color(0xFFE0EDE5),
  );

  // ── dark ───────────────────────────────────────────────────────────────────
  static const dark = PgColors(
    green:     Color(0xFF7ABB98),
    mint:      Color(0xFF8ACBA8),
    mintLight: Color(0xFF1A3326),
    mintSoft:  Color(0xFF141414),
    warmPink:  Color(0xFFE8958F),
    pinkSoft:  Color(0xFF1E1E1E),
    amber:     Color(0xFFF4A940),
    amberSoft: Color(0xFF1E1E1E),
    bg:        Color(0xFF0A0A0A),
    surface:   Color(0xFF141414),
    textDark:  Color(0xFFFFFFFF),
    textMid:   Color(0xFF888888),
    textSoft:  Color(0xFF555555),
    border:    Color(0xFF2C2C2C),
  );

  static PgColors of(BuildContext context) =>
      Theme.of(context).extension<PgColors>() ?? light;

  // ── ThemeExtension boilerplate ─────────────────────────────────────────────
  @override
  PgColors copyWith({
    Color? green, Color? mint, Color? mintLight, Color? mintSoft,
    Color? warmPink, Color? pinkSoft, Color? amber, Color? amberSoft,
    Color? bg, Color? surface, Color? textDark, Color? textMid,
    Color? textSoft, Color? border,
  }) => PgColors(
    green:     green     ?? this.green,
    mint:      mint      ?? this.mint,
    mintLight: mintLight ?? this.mintLight,
    mintSoft:  mintSoft  ?? this.mintSoft,
    warmPink:  warmPink  ?? this.warmPink,
    pinkSoft:  pinkSoft  ?? this.pinkSoft,
    amber:     amber     ?? this.amber,
    amberSoft: amberSoft ?? this.amberSoft,
    bg:        bg        ?? this.bg,
    surface:   surface   ?? this.surface,
    textDark:  textDark  ?? this.textDark,
    textMid:   textMid   ?? this.textMid,
    textSoft:  textSoft  ?? this.textSoft,
    border:    border    ?? this.border,
  );

  @override
  PgColors lerp(PgColors? other, double t) {
    if (other == null) return this;
    return PgColors(
      green:     Color.lerp(green,     other.green,     t)!,
      mint:      Color.lerp(mint,      other.mint,      t)!,
      mintLight: Color.lerp(mintLight, other.mintLight, t)!,
      mintSoft:  Color.lerp(mintSoft,  other.mintSoft,  t)!,
      warmPink:  Color.lerp(warmPink,  other.warmPink,  t)!,
      pinkSoft:  Color.lerp(pinkSoft,  other.pinkSoft,  t)!,
      amber:     Color.lerp(amber,     other.amber,     t)!,
      amberSoft: Color.lerp(amberSoft, other.amberSoft, t)!,
      bg:        Color.lerp(bg,        other.bg,        t)!,
      surface:   Color.lerp(surface,   other.surface,   t)!,
      textDark:  Color.lerp(textDark,  other.textDark,  t)!,
      textMid:   Color.lerp(textMid,   other.textMid,   t)!,
      textSoft:  Color.lerp(textSoft,  other.textSoft,  t)!,
      border:    Color.lerp(border,    other.border,    t)!,
    );
  }
}
