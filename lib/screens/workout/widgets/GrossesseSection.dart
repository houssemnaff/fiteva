
// ═══════════════════════════════════════════════════════════
// WIDGET 6 — SECTION GROSSESSE & POSTPARTUM
// ═══════════════════════════════════════════════════════════
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/hcard.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';

class GrossesseSection extends StatelessWidget {
  final List<WorkoutModel> grossesseWorkouts;
  final Set<String> favorites;
  final void Function(String) onToggleFav;

  const GrossesseSection({
    super.key,
    required this.grossesseWorkouts,
    required this.favorites,
    required this.onToggleFav,
  });

  Widget _softChip(String label, IconData icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: WorkoutColors.grossesse.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: WorkoutColors.grossesse),
            const SizedBox(width: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: WorkoutColors.grossesse,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _buildGrossesseCard(WorkoutModel w, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final isFav = favorites.contains(w.id);
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
      child: Container(
        width: 190,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surface,
          border: Border.all(color: WorkoutColors.grossesse.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: WorkoutColors.grossesse.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(w.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHighest)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            WorkoutColors.grossesse.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: () => onToggleFav(w.id),
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: colorScheme.surface,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(w.title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        color: onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(children: [
                    _softChip(w.duration, Icons.timer_rounded),
                    const SizedBox(width: 6),
                    _softChip(w.level, Icons.bar_chart_rounded),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sw = MediaQuery.of(context).size.width;
    final programListHeight =
        ((sw * 0.45 * 1.25)).clamp(170.0, 260.0);
    final smallGap = sw < 360 ? 6.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Séparateur visuel banner
        Padding(
          padding: EdgeInsets.fromLTRB(16, smallGap + 4, 16, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceContainerHighest,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: WorkoutColors.grossesse.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Text('🤰', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grossesse & Postpartum',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Séances douces · Périnée · Bien-être',
                        style: TextStyle(
                            color: WorkoutColors.grossesse,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: smallGap),
        SizedBox(
          height: programListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: grossesseWorkouts.length,
            itemBuilder: (_, i) => buildHCard(
              context: context,
              w: grossesseWorkouts[i],
              accent: WorkoutColors.grossesse,
              favorites: favorites,
              onToggleFav: onToggleFav,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CorpsZonePlayerScreen(
                    workout: grossesseWorkouts[i],
                    zoneName: 'Grossesse',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
