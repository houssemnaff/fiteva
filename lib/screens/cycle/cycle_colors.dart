import 'package:flutter/material.dart';

/// Theme-aware color tokens for all cycle screens.
/// Usage: final cc = CycleColors.of(context);
class CycleColors {
  final bool  isDark;
  final Color bg;       // scaffold background
  final Color surface;  // card / panel background
  final Color surface2; // elevated surface (chips, fields)
  final Color border;   // dividers & borders
  final Color text;     // primary text
  final Color muted;    // secondary / muted text
  final Color body;     // description paragraphs (slightly warmer muted)

  CycleColors._({
    required this.isDark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.text,
    required this.muted,
    required this.body,
  });

  factory CycleColors.of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static final _light = CycleColors._(
    isDark:   false,
    bg:       const Color(0xFFFCFBFB),
    surface:  const Color(0xFFFFFFFF),
    surface2: const Color(0xFFF5F5F5),
    border:   const Color(0xFFE8E8E8),
    text:     const Color(0xFF1A1A2E),
    muted:    const Color(0xFF8E8E9A),
    body:     const Color(0xFF5C5C6E),
  );

  static final _dark = CycleColors._(
    isDark:   true,
    bg:       const Color(0xFF111114),
    surface:  const Color(0xFF1C1C22),
    surface2: const Color(0xFF26262E),
    border:   const Color(0xFF32323A),
    text:     const Color(0xFFF0F0F4),
    muted:    const Color(0xFF8A8A96),
    body:     const Color(0xFFB0B0BC),
  );
}
