import 'package:flutter/material.dart';

// ─── Theme-aware nutrition colors ────────────────────────────
// Use `NColors.of(context)` instead of the old `k*` constants.
class NColors {
  final ColorScheme _cs;
  NColors._(this._cs);

  static NColors of(BuildContext context) =>
      NColors._(Theme.of(context).colorScheme);

  Color get primary       => _cs.primary;
  Color get accent        => _cs.primary;
  Color get secondary     => _cs.secondary;
  Color get bg            => _cs.surface;
  Color get surface       => _cs.surface;
  Color get cardBg        => _cs.brightness == Brightness.dark
      ? _cs.surfaceContainerLow : Colors.white;
  Color get darkCard      => _cs.surfaceContainerHigh;
  Color get textPrimary   => _cs.onSurface;
  Color get textDark      => _cs.onSurface;
  Color get textSecondary => _cs.onSurface.withValues(alpha: 0.5);
  Color get textGrey      => _cs.onSurface.withValues(alpha: 0.5);
  Color get divider       => _cs.outline.withValues(alpha: 0.2);
  Color get white         => _cs.brightness == Brightness.dark
      ? _cs.surface : Colors.white;
}

// ─── Legacy constants (kept for compatibility, prefer NColors.of) ─────
const kBg         = Color(0xFFF5F1EE);
const kWhite      = Color(0xFFFFFFFF);
const kBrown      = Color(0xFF1C4D30);
const kBrownLight = Color(0xFFA07060);
const kGreen      = Color(0xFF2D5A45);
const kGreenMid   = Color(0xFF4A7C5F);
const kGreenLight = Color(0xFF6EAB84);
const kPink       = Color.fromARGB(255, 11, 248, 98);
const kBlue       = Color(0xFF2D5A45);
const kLime       = Color.fromARGB(255, 166, 253, 108);
const kYellow     = Color(0xFFF5D876);
const kTextDark   = Color(0xFF2C1F14);
const kTextGrey   = Color(0xFF9E8E80);
const kDivider    = Color(0xFFF0EBE5);

const Color kSurface      = Color(0xFFF5F1EE);
const Color kTextPrimary  = Color(0xFF18120E);
const Color kTextSecondary = Color(0xFF9A8880);
const Color kDrop         = Color(0xFF3B9EE8);
const Color kAccent       = Color(0xFF1C4D30);
const Color kDarkCard     = Color(0xFF2C1F1A);
