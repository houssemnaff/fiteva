import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';





Widget buildHCard({
  required BuildContext context,
  required WorkoutModel w,
  required Color accent,
  required Set<String> favorites,
  required void Function(String) onToggleFav,
  VoidCallback? onTap,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final onSurface = colorScheme.onSurface;

  final isFav = favorites.contains(w.id);
  return GestureDetector(
    onTap: onTap ??
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
    child: Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(w.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: colorScheme.surfaceContainerHighest)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    onSurface.withOpacity(0.80),
                  ],
                  stops: const [0.35, 1.0],
                ),
              ),
            ),
            // Top bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withOpacity(0.55), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: onSurface.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border:
                          Border.all(color: colorScheme.onPrimary.withOpacity(0.2)),
                      ),
                      child: Row(children: [
                        Icon(Icons.timer_rounded,
                          color: colorScheme.onPrimary.withOpacity(0.7), size: 11),
                        const SizedBox(width: 3),
                        Text(w.duration,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => onToggleFav(w.id),
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: onSurface.withOpacity(0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: colorScheme.onPrimary.withOpacity(0.2)),
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav ? WorkoutColors.grossesse : colorScheme.onPrimary,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom info
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(w.level,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text(w.title,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(Icons.local_fire_department_rounded,
                      color: colorScheme.primary, size: 13),
                    const SizedBox(width: 3),
                    Text('${w.calories} kcal',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.7), fontSize: 11)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
