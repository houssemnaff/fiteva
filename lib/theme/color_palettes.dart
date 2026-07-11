import 'package:flutter/material.dart';

class AppColorPalette {
  final String id;
  final String name;
  final String emoji;
  final Color primary;
  final Color accent;
  final bool isFree;

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.emoji,
    required this.primary,
    required this.accent,
    this.isFree = false,
  });

  // Light mode ColorScheme derived from this palette
  ColorScheme get lightScheme => ColorScheme.light(
    primary: primary,
    secondary: accent,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: _tint(primary, 0.04),
    outline: _tint(primary, 0.12),
    outlineVariant: _tint(primary, 0.08),
    secondaryContainer: _tint(accent, 0.25),
    onSecondaryContainer: primary,
    shadow: const Color(0xFF000000),
  );

  // Dark mode ColorScheme derived from this palette
  ColorScheme get darkScheme => ColorScheme.dark(
    primary: accent,
    secondary: primary,
    surface: const Color(0xFF0A0A0A),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    surfaceContainerLowest: const Color(0xFF0A0A0A),
    surfaceContainerLow: const Color(0xFF141414),
    surfaceContainer: const Color(0xFF141414),
    surfaceContainerHigh: const Color(0xFF1E1E1E),
    surfaceContainerHighest: const Color(0xFF1E1E1E),
    outline: const Color(0xFF2C2C2C),
    outlineVariant: const Color(0xFF353535),
    secondaryContainer: _darken(primary, 0.6),
    onSecondaryContainer: accent,
    shadow: const Color(0xFF000000),
  );

  static Color _tint(Color c, double amount) =>
      Color.lerp(c, Colors.white, 1 - amount)!;

  static Color _darken(Color c, double amount) =>
      Color.lerp(c, Colors.black, amount)!;
}

const kPalettes = [
  // ── Free (default) ───────────────────────────────────────────
  AppColorPalette(
    id: 'forest',
    name: 'Forêt',
    emoji: '🌿',
    primary: Color(0xFF1C4D30),
    accent: Color(0xFF7ABB98),
    isFree: true,
  ),

  // ── Pro ──────────────────────────────────────────────────────
  AppColorPalette(
    id: 'rose',
    name: 'Rose Poudré',
    emoji: '🌸',
    primary: Color(0xFFC2185B),
    accent: Color(0xFFF48FB1),
  ),
  AppColorPalette(
    id: 'lavande',
    name: 'Lavande',
    emoji: '💜',
    primary: Color(0xFF5E35B1),
    accent: Color(0xFFB39DDB),
  ),
  AppColorPalette(
    id: 'ocean',
    name: 'Océan',
    emoji: '🌊',
    primary: Color(0xFF0277BD),
    accent: Color(0xFF4FC3F7),
  ),
  AppColorPalette(
    id: 'sunset',
    name: 'Sunset',
    emoji: '🌅',
    primary: Color(0xFFE65100),
    accent: Color(0xFFFFAB91),
  ),
  AppColorPalette(
    id: 'midnight',
    name: 'Midnight',
    emoji: '🌙',
    primary: Color(0xFF1A237E),
    accent: Color(0xFF7986CB),
  ),
];

AppColorPalette paletteById(String id) =>
    kPalettes.firstWhere((p) => p.id == id, orElse: () => kPalettes.first);
