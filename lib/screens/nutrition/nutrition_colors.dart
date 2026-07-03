import 'package:flutter/material.dart';

/// Theme-aware color tokens for all nutrition screens.
/// Usage: final nc = NutritionColors.of(context);
class NutritionColors {
  final bool   isDark;
  final Color  bg;       // scaffold / page background
  final Color  surface;  // card / panel background
  final Color  surface2; // slightly elevated surface (search bar, chips)
  final Color  border;   // dividers & borders
  final Color  text1;    // primary text
  final Color  text2;    // secondary / muted text
  final Color  chipBg;   // neutral chip/pill
  final Color  mintBg;   // green tinted background
  final Color  greenFg;  // green text / icon
  final Color  blueBg;   // blue tinted background
  final Color  blueFg;   // blue text / icon
  final Color  amberBg;  // amber tinted background
  final Color  amberFg;  // amber text / icon
  final Color  redBg;    // red tinted background
  final Color  redFg;    // red text / icon

  // Brand — same in both modes
  static const green = Color(0xFF1C4D30);
  static const mint  = Color(0xFF7ABB98);
  static const red   = Color(0xFFE03050);

  NutritionColors._({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text1,
    required this.text2,
    required this.chipBg,
    required this.mintBg,
    required this.greenFg,
    required this.blueBg,
    required this.blueFg,
    required this.amberBg,
    required this.amberFg,
    required this.redBg,
    required this.redFg,
  });

  factory NutritionColors.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static final _light = NutritionColors._(
    isDark:   false,
    bg:       const Color.fromARGB(255, 255, 255, 255),
    surface:  Colors.white,
    surface2: const Color(0xFFF4F4F2),
    border:   const Color(0xFFECECEC),
    text1:    const Color(0xFF111110),
    text2:    const Color.fromARGB(255, 37, 49, 36),
    chipBg:   const Color(0xFFF2F2F0),
    mintBg:   const Color(0xFFEAF3EC),
    greenFg:  const Color(0xFF1C4D30),
    blueBg:   const Color(0xFFEBF2FC),
    blueFg:   const Color(0xFF2563EB),
    amberBg:  const Color(0xFFFFF3DC),
    amberFg:  const Color(0xFFC47A00),
    redBg:    const Color(0xFFFFEEEE),
    redFg:    const Color(0xFFE03050),
  );

  static final _dark = NutritionColors._(
    isDark:   true,
    bg:       const Color(0xFF0A0A0A),
    surface:  const Color(0xFF141414),
    surface2: const Color(0xFF1E1E1E),
    border:   const Color(0xFF2C2C2C),
    text1:    Colors.white,
    text2:    const Color(0xFF9CA3AF),
    chipBg:   const Color(0xFF1E1E1E),
    mintBg:   const Color(0xFF0D2018),
    greenFg:  const Color(0xFF5CD57A),
    blueBg:   const Color(0xFF0B1929),
    blueFg:   const Color(0xFF60A5FA),
    amberBg:  const Color(0xFF1C1400),
    amberFg:  const Color(0xFFFBBF24),
    redBg:    const Color(0xFF1F0A0A),
    redFg:    const Color(0xFFF87171),
  );
}
