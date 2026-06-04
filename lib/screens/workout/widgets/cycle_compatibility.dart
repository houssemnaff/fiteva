import 'package:fiteva/theme/app_theme.dart';
import 'package:flutter/material.dart';

Color cycleColorFor(String cycleName) {
  switch (cycleName) {
    case 'Règles':
      return AppTheme.phaseMenstrual;
    case 'Folliculaire':
      return AppTheme.phaseFolliculaire;
    case 'Ovulation':
      return AppTheme.phaseOvulatoire;
    case 'Lutéale':
      return AppTheme.phaseLuteal;
    default:
      return AppTheme.workoutDefault;
  }
}



String cycleShortLabelFor(String cycleName) {
  switch (cycleName) {
    case 'Règles':
      return 'Règles';
    case 'Folliculaire':
      return 'Fol.';
    case 'Ovulation':
      return 'Ovu.';
    case 'Lutéale':
      return 'Lut.';
    default:
      return cycleName;
  }
}

Widget buildCycleCompatibilityBadges(
  BuildContext context,
  List<String> compatibleCycles, {
  bool compact = false,
  Color? foregroundColor,
}) {
  if (compatibleCycles.isEmpty) {
    return const SizedBox.shrink();
  }

  final colorScheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Text on colored phase badges: black for light, white for dark
  final badgeTextColor = isDark ? Colors.white : Colors.black;

  // "+N" overflow badge colors
  final overflowBg = colorScheme.surfaceVariant;
  final overflowText = colorScheme.onSurfaceVariant;

  final visibleCycles = compatibleCycles.take(compact ? 3 : 4).toList();
  final remaining = compatibleCycles.length - visibleCycles.length;

  return Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      ...visibleCycles.map(
        (cycle) {
          final phaseColor = cycleColorFor(cycle);

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 8,
              vertical: compact ? 4 : 5,
            ),
            decoration: BoxDecoration(
              // ✅ Phase color as background
              color: isDark
                  ? phaseColor.withOpacity(0.85)
                  : phaseColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Small white dot as accent
                Container(
                  width: compact ? 6 : 7,
                  height: compact ? 6 : 7,
                  decoration: BoxDecoration(
                    color: badgeTextColor.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  cycleShortLabelFor(cycle),
                  style: TextStyle(
                    // ✅ Black in light mode, white in dark mode
                    color: badgeTextColor,
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // ✅ Overflow badge uses colorScheme (adapts to dark/light)
      if (remaining > 0)
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 7 : 8,
            vertical: compact ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: overflowBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '+$remaining',
            style: TextStyle(
              color: overflowText,
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
    ],
  );
}