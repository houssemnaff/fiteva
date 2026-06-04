
  import 'package:fiteva/models/home_program_model.dart';
  import 'package:fiteva/models/workout_model.dart';
  import 'package:fiteva/screens/workout/theme/color.dart';
    import 'package:fiteva/screens/workout/widgets/cycle_compatibility.dart';
  import 'package:fiteva/screens/workout/workout_detail_screen.dart';
  import 'package:flutter/material.dart';

  class FavoriteWorkoutItem {
    final WorkoutModel workout;
    final List<String> compatibleCycles;

    const FavoriteWorkoutItem({
      required this.workout,
      required this.compatibleCycles,
    });
  }

  WorkoutModel _programWorkout(HomeProgramModel program) {
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
      category: 'PROGRAMME',
      duration: program.duration,
      level: workouts.isNotEmpty ? workouts.first.level : 'Tous niveaux',
      calories: calories.toString(),
      imageUrl: program.imageUrl,
      exercises: exercises.isNotEmpty
          ? exercises
          : const ['Échauffement', 'Bloc principal', 'Retour au calme'],
    );
  }

  List<FavoriteWorkoutItem> _favoriteWorkouts(
    List<WorkoutModel> workouts,
    List<HomeProgramModel> programs,
    Set<String> favorites,
  ) {
    final items = <FavoriteWorkoutItem>[];

    for (final favoriteId in favorites) {
      final workoutMatch = workouts.where((workout) => workout.id == favoriteId);
      if (workoutMatch.isNotEmpty) {
        items.add(FavoriteWorkoutItem(
          workout: workoutMatch.first,
          compatibleCycles: const [],
        ));
        continue;
      }

      final programMatch = programs.where((program) => program.name == favoriteId);
      if (programMatch.isNotEmpty) {
        final program = programMatch.first;
        items.add(FavoriteWorkoutItem(
          workout: _programWorkout(program),
          compatibleCycles: program.compatibleCycles,
        ));
      }
    }

    return items;
  }

  void openFavoritesSheet(
    BuildContext context,
    List<WorkoutModel> workouts,
    List<HomeProgramModel> programs,
    Set<String> favorites,
  ) {
    final favoriteWorkouts = _favoriteWorkouts(workouts, programs, favorites);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final favoriteColor = colorScheme.error;

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Favoris',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                  if (favoriteWorkouts.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border_rounded,
                                size: 56,
                                color: colorScheme.onSurface.withOpacity(0.35),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun favori pour le moment',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Clique sur le cœur dans les cartes pour les retrouver ici.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: favoriteWorkouts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                        final favorite = favoriteWorkouts[index];
                        final workout = favorite.workout;
                        final isProgram = workout.id.startsWith('program_');

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkoutDetailScreen(workout: workout),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: colorScheme.outlineVariant),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 104,
                                      height: 104,
                                      child: Image.asset(
                                        workout.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: colorScheme.surfaceContainerHighest,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                              color: colorScheme.primary.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    isProgram ? 'PROGRAMME' : 'WORKOUT',
                                                    style: TextStyle(
                                                      color: colorScheme.primary,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.6,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(
                                                  Icons.favorite_rounded,
                                                  color: favoriteColor,
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            buildCycleCompatibilityBadges(
                                              context,
                                              favorite.compatibleCycles,
                                              compact: true,
                                              foregroundColor: colorScheme.onSurface,
                                            ),
                                            if (favorite.compatibleCycles.isNotEmpty)
                                              const SizedBox(height: 8),
                                            Text(
                                              workout.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: colorScheme.onSurface,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${workout.duration} • ${workout.level}',
                                              style: TextStyle(
                                                color: colorScheme.onSurface.withOpacity(0.7),
                                                fontSize: 12,
                                              ),
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
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }