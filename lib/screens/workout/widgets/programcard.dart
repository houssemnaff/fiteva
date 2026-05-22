
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';



Widget _infoRow(BuildContext context, IconData icon, String text) {
  final colorScheme = Theme.of(context).colorScheme;
  return Row(children: [
      Icon(icon, color: colorScheme.onPrimary.withOpacity(0.7), size: 11),
      const SizedBox(width: 5),
      Flexible(
        child: Text(text,
            style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.85), fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    ]);
}



Widget buildProgramCard({
  required BuildContext context,
  required String name,
  required String duration,
  required String phases,
  required String sessions,
  required WorkoutModel w,
  required Color color,
  required String imageUrl,
  required Set<String> favorites,
  required void Function(String) onToggleFav,
  required VoidCallback onStartTap,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final onSurface = colorScheme.onSurface;
  final surface = colorScheme.surface;

  final sw        = MediaQuery.of(context).size.width;
  final cardWidth = math.min(185.0, math.max(140.0, sw * 0.45));
  final cardHeight =
      math.min(260.0, math.max(170.0, cardWidth * 1.25));

  return GestureDetector(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => WorkoutDetailScreen(workout: w))),
    child: Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: colorScheme.shadow.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox(
              height: cardHeight,
              child: Image.asset(imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      Container(color: colorScheme.surfaceContainerHighest)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.2),
                      onSurface.withOpacity(0.82),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0, right: 0, top: 0, bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('PROGRAMME',
                              style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8)),
                        ),
                        GestureDetector(
                          onTap: () => onToggleFav(name),
                          child: Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: onSurface.withOpacity(0.35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              favorites.contains(name)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: favorites.contains(name)
                                  ? WorkoutColors.grossesse
                                  : colorScheme.onPrimary,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2),
                            maxLines: 2),
                        const SizedBox(height: 8),
                        _infoRow(context, Icons.calendar_today_rounded, duration),
                        const SizedBox(height: 3),
                        _infoRow(context, Icons.fitness_center_rounded, sessions),
                        const SizedBox(height: 3),
                        _infoRow(context, Icons.loop_rounded, phases),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: onStartTap,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text('Commencer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
