import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildSectionHeader({
  required BuildContext context,
  IconData? icon,
  String? emoji,
  required String title,
  required String subtitle,
  required Color color,
  String? overline,
  VoidCallback? onSeeAll,
}) {
  assert(icon != null || emoji != null, 'Provide either icon or emoji');
  final cs = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left accent bar + icon/emoji
        Row(children: [
          Container(
            width: 3, height: 38,
            decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 12),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.20))),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 18, color: color)
                  : Text(emoji!, style: const TextStyle(fontSize: 18)))),
        ]),
        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null)
                Text(overline, style: GoogleFonts.inter(
                  color: color, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 2)),
              Text(title, style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800, fontSize: 18,
                color: cs.onSurface, letterSpacing: -0.3)),
              Text(subtitle, style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.55),
                fontWeight: FontWeight.w500)),
            ],
          ),
        ),

        // See all
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.18))),
              child: Text('Voir tout', style: GoogleFonts.inter(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)))),
      ],
    ),
  );
}
