import 'package:flutter/material.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/hcard.dart';
import 'package:fiteva/screens/workout/widgets/sectionheader.dart';

// ═══════════════════════════════════════════════════════════
// DANCE & CARDIO — APPLE FITNESS STYLE
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
    final color = WorkoutColors.dance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─────────────────────────────
        // Section Header (Apple style: clean + bold)
        // ─────────────────────────────
        buildSectionHeader(
          context: context,
          emoji: '',
          title: 'Danse & Cardio',
          subtitle: 'Zumba • Afrobeat • HIIT dance',
          color: color,
          onSeeAll: () {},
        ),

        const SizedBox(height: 14),

        // ─────────────────────────────
        // Horizontal premium feed
        // ─────────────────────────────
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: danceWorkouts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final workout = danceWorkouts[i];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration:
                          const Duration(milliseconds: 300),
                      pageBuilder: (_, __, ___) =>
                          CorpsZonePlayerScreen(
                        workout: workout,
                        zoneName: 'Danse',
                      ),
                      transitionsBuilder:
                          (_, animation, __, child) {
                        final curved = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        );

                        return FadeTransition(
                          opacity: curved,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - curved.value)),
                            child: child,
                          ),
                        );
                      },
                    ),
                  );
                },
                child: _AppleDanceCard(
                  workout: workout,
                  color: color,
                  favorites: favorites,
                  onToggleFav: onToggleFav,
                ),
                
              );
            },
          ),
        ),
      ],
      
    );
  }
}

class _AppleDanceCard extends StatelessWidget {
  final WorkoutModel workout;
  final Color color;
  final Set<String> favorites;
  final void Function(String) onToggleFav;

  const _AppleDanceCard({
    required this.workout,
    required this.color,
    required this.favorites,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    final isFav = favorites.contains(workout.id);

    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: DecorationImage(
          image: NetworkImage(workout.imageUrl ?? ''),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // gradient overlay (Apple Fitness style depth)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.25),
                  Colors.black.withOpacity(0.75),
                ],
              ),
            ),
          ),

          // top right favorite
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => onToggleFav(workout.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFav ? color : Colors.white,
                ),
              ),
            ),
          ),

          // bottom content
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.duration ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}