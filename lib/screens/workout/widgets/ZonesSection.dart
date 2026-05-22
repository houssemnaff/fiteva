
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/corpszone_playerscreen.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/sectionheader.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';


// ═══════════════════════════════════════════════════════════
// WIDGET 5 — SECTION ZONES DU CORPS
// ═══════════════════════════════════════════════════════════
class ZonesSection extends StatelessWidget {
  final List<Map<String, dynamic>> bodyZones;

  const ZonesSection({super.key, required this.bodyZones});

  Widget _buildZoneCard(
      String label, IconData icon, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;

    final z = bodyZones.firstWhere(
      (z) => z['title']
          .toString()
          .toLowerCase()
          .contains(label.toLowerCase().split(' ').first),
      orElse: () => bodyZones[0],
    );
    return GestureDetector(
      onTap: () {
        final w = WorkoutModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: z['title'],
          category: 'Zone',
          duration: '15 min',
          level: 'Tous niveaux',
          calories: '150',
          imageUrl: z['imageUrl'],
          exercises: List<String>.from(z['exercises']),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  CorpsZonePlayerScreen(workout: w, zoneName: label)),
        );
      },
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: AssetImage(z['imageUrl']),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              onSurface.withOpacity(0.52),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
                color: colorScheme.shadow.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.onPrimary, size: 20),
            const SizedBox(width: 7),
            Text(label,
                style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSectionHeader(
          context: context,
          emoji: '🏋️',
          title: 'Zones du corps',
          subtitle: 'Cible une zone précise',
          color: WorkoutColors.zone,
          onSeeAll: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(children: [
                Expanded(child: _buildZoneCard(
                    'Abdos', Icons.health_and_safety, context)),
                const SizedBox(width: 12),
                Expanded(child: _buildZoneCard(
                    'Haut du corps', Icons.fitness_center, context)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildZoneCard(
                    'Bas du corps', Icons.directions_walk, context)),
                const SizedBox(width: 12),
                Expanded(child: _buildZoneCard(
                    'Full body', Icons.accessibility_new, context)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildZoneCard(
                    'Yoga', Icons.self_improvement_rounded, context)),
                const SizedBox(width: 12),
                Expanded(child: _buildZoneCard(
                    'Méditation', Icons.spa_rounded, context)),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
