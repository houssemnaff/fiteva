/*import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Workout card — full-bleed editorial, 220 × 250 ───────────────────────────
Widget buildHCard({
  required BuildContext context,
  required WorkoutModel w,
  required Color accent,
  required Set<String> favorites,
  required void Function(String) onToggleFav,
  VoidCallback? onTap,
}) {s
  final isFav = favorites.contains(w.id);

  return GestureDetector(
    onTap: onTap ??
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
    child: Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(fit: StackFit.expand, children: [

          // ── Background image ────────────────────────────────
          Image.asset(w.imageUrl, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: accent.withValues(alpha: 0.15),
              child: Center(child: Icon(LucideIcons.dumbbell,
                color: accent, size: 36)))),

          // ── Bottom gradient ─────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xEE000000)],
                stops: [0.35, 1.0]))),

          // ── Top: level badge + heart ────────────────────────
          Positioned(top: 12, left: 12, right: 12,
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(w.level, style: GoogleFonts.inter(
                  color: Colors.white, fontSize: 9,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5))),
              const Spacer(),
              GestureDetector(
                onTap: () => onToggleFav(w.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.20))),
                  child: Icon(
                    isFav ? LucideIcons.heart : LucideIcons.heart,
                    color: isFav ? WorkoutColors.of(context).grossesse : Colors.white,
                    size: 14))),
            ])),

          // ── Bottom: info ────────────────────────────────────
          Positioned(left: 14, right: 14, bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(w.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2, letterSpacing: -0.2),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(LucideIcons.clock, color: Colors.white60, size: 11),
                  const SizedBox(width: 4),
                  Text(w.duration, style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 11)),
                  const SizedBox(width: 10),
                  Icon(LucideIcons.flame, color: accent, size: 11),
                  const SizedBox(width: 4),
                  Text('${w.calories} kcal', style: GoogleFonts.inter(
                    color: Colors.white70, fontSize: 11)),
                ]),
                const SizedBox(height: 10),
                // Start button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(LucideIcons.play, color: Colors.white, size: 12),
                    const SizedBox(width: 6),
                    Text('Démarrer', style: GoogleFonts.inter(
                      color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w700)),
                  ])),
              ],
            )),
        ]),
      ),
    ),
  );
}
*/