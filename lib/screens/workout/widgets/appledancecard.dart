import 'package:fiteva/models/workout_model.dart';
import 'package:flutter/material.dart';

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