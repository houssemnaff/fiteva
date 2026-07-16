/*import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/cycle_compatibility.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF1A1A1A);
const _kText2  = Color(0xFF6B7280);

// ── Program card — split image / white info section ───────────────────────────
Widget buildProgramCard({
  required BuildContext context,
  required String name,
  required String duration,
  required String phases,
  required String sessions,
  required List<String> compatibleCycles,
  required WorkoutModel w,
  required Color color,
  required String imageUrl,
  required Set<String> favorites,
  required void Function(String) onToggleFav,
  required VoidCallback onStartTap,
}) {
  final isFav = favorites.contains(name);

  return GestureDetector(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
    child: Container(
      width: 210,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 16, offset: const Offset(0, 5))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Top image (160px) ─────────────────────────────────
          SizedBox(
            height: 150,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: color.withValues(alpha: 0.12))),

              // Subtle top-left gradient tint
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.30),
                        Colors.transparent])))),

              // PROGRAMME badge
              Positioned(top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('PROGRAMME', style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 8,
                    fontWeight: FontWeight.w800, letterSpacing: 1.0)))),

              // Heart bookmark
              Positioned(top: 10, right: 10,
                child: GestureDetector(
                  onTap: () => onToggleFav(name),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 6)]),
                    child: Icon(
                      isFav ? LucideIcons.heart : LucideIcons.heart,
                      color: isFav ? WorkoutColors.of(context).grossesse : _kText2,
                      size: 14)))),
            ]),
          ),

          // ── White info section ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.outfit(
                  color: _kText1, fontSize: 15, fontWeight: FontWeight.w800,
                  letterSpacing: -0.3, height: 1.2),
                  maxLines: 2),
                const SizedBox(height: 8),

                // Info chips
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _InfoChip(LucideIcons.calendarDays, duration, color),
                  _InfoChip(LucideIcons.dumbbell, sessions, color),
                ]),

                const SizedBox(height: 12),

                // Start button
                GestureDetector(
                  onTap: onStartTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 10, offset: const Offset(0, 4))]),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Icon(LucideIcons.play, color: Colors.white, size: 12),
                      const SizedBox(width: 6),
                      Text('Commencer', style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.w700)),
                    ])),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}
*/