import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/hcard.dart';
import 'package:fiteva/screens/workout/widgets/sectionheader.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';


// ═══════════════════════════════════════════════════════════
// WIDGET 3 — SECTION DANSE & CARDIO
// ═══════════════════════════════════════════════════════════
class DanceSection extends StatelessWidget {
  final List<WorkoutModel> danceWorkouts;
  final Set<String> favorites;
  final void Function(String) onToggleFav;

  const DanceSection({
    super.key,
    required this.danceWorkouts,
    required this.favorites,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSectionHeader(
          context: context,
          emoji: '💃',
          title: 'Danse & Cardio',
          subtitle: 'Vidéos isolées · Zumba · Afrobeat',
          color: WorkoutColors.dance,
          onSeeAll: () {},
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: WorkoutColors.dance.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WorkoutColors.dance.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_rounded,
                    color: WorkoutColors.dance, size: 16),
                const SizedBox(width: 6),
                Text('Vidéos isolées · Pas de programme',
                    style: TextStyle(
                        color: WorkoutColors.dance,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: danceWorkouts.length,
            itemBuilder: (_, i) => buildHCard(
              context: context,
              w: danceWorkouts[i],
              accent: WorkoutColors.dance,
              favorites: favorites,
              onToggleFav: onToggleFav,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CorpsZonePlayerScreen(
                    workout: danceWorkouts[i],
                    zoneName: 'Danse',
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
