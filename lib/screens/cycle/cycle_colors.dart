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
    bg:       const Color(0xFFFFFFFF),
    surface:  const Color(0xFFFFFFFF),
    surface2: const Color(0xFFF7F5F6),
    border:   const Color(0xFFEDEAEB),
    text:     const Color(0xFF2D1B20),
    muted:    const Color(0xFF9E8A93),
    body:     const Color(0xFF6B5760),
  );

  static final _dark = CycleColors._(
    isDark:   true,
    bg:       const Color(0xFF0D0D0D),
    surface:  const Color(0xFF1A1A1A),
    surface2: const Color(0xFF242424),
    border:   const Color(0xFF2E2828),
    text:     const Color(0xFFF5F0F2),
    muted:    const Color(0xFF9CA3AF),
    body:     const Color(0xFFC4B0BA),
  );
}
