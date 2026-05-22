
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/models/workout_model.dart';
import 'package:fiteva/screens/workout/theme/color.dart';
import 'package:fiteva/screens/workout/widgets/programcard.dart';
import 'package:fiteva/screens/workout/widgets/sectionheader.dart';
import 'package:fiteva/screens/workout/workout_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';



WorkoutModel _programWorkout(HomeProgramModel program, {required String category}) {
  final workouts = program.workouts;
  final calories = workouts.fold<int>(
    0,
    (sum, workout) => sum + (int.tryParse(workout.calories) ?? 0),
  );
  final exercises = workouts
      .map((workout) => '${workout.title} • ${workout.duration}')
      .toList();

  return WorkoutModel(
    id: 'program_${program.name.replaceAll(' ', '_').toLowerCase()}',
    title: program.name,
    category: category,
    duration: program.duration,
    level: workouts.isNotEmpty ? workouts.first.level : 'Tous niveaux',
    calories: calories.toString(),
    imageUrl: program.imageUrl,
    exercises: exercises.isNotEmpty
        ? exercises
        : const ['Échauffement', 'Bloc principal', 'Retour au calme'],
  );
}

class MaisonSection extends StatelessWidget {
  final List<HomeProgramModel> homePrograms;
  final Set<String> favorites;
  final void Function(String) onToggleFav;

  const MaisonSection({
    super.key,
    required this.homePrograms,
    required this.favorites,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final programListHeight =
        ((sw * 0.45 * 1.25)).clamp(170.0, 260.0);
    final smallGap = sw < 360 ? 6.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildSectionHeader(
          context: context,
          emoji: '🏠',
          title: 'Programmes Maison',
          subtitle: 'Sans matériel · Élastiques · Corps',
          color: WorkoutColors.maison,
          onSeeAll: () {},
        ),
        SizedBox(
          height: programListHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: homePrograms
                .map((program) => buildProgramCard(
                      context: context,
                      name: program.name,
                      duration: program.duration,
                      phases: program.phases,
                      sessions: program.sessions,
                      w: _programWorkout(program, category: 'MAISON'),
                      color: program.color,
                      imageUrl: program.imageUrl,
                      favorites: favorites,
                      onToggleFav: onToggleFav,
                      onStartTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workout: _programWorkout(program, category: 'MAISON'),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
