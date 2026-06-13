import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/workout_model.dart';
import '../../services/workout_progress_service.dart';
import 'exercise_player_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _completedExercises = 0;
  bool _workoutMarkedComplete = false;
  Set<String> _completedVideos = {};

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }


  Future<void> _loadCompletionStatus() async {
    final completedVideos = await WorkoutProgressService.getCompletedVideos();
    final exercises = widget.workout.exercises;

    int completedCount = 0;
    for (int i = 0; i < exercises.length; i++) {
      final videoId = '${widget.workout.title}_exercise_$i';
      if (completedVideos.contains(videoId)) {
        completedCount++;
      }
    }

    if (mounted) {
      setState(() {
        _completedVideos = completedVideos;
        _completedExercises = completedCount;
      });
    }
  }

  Future<int> _getFirstIncompleteExerciseIndex() async {
    final completedVideos = await WorkoutProgressService.getCompletedVideos();
    final exercises = widget.workout.exercises;

    for (int i = 0; i < exercises.length; i++) {
      final videoId = '${widget.workout.title}_exercise_$i';
      if (!completedVideos.contains(videoId)) {
        return i;
      }
    }
    return 0;
  }

  Future<void> _openFirstIncompleteExercise() async {
    final exercises = widget.workout.exercises;
    final exerciseIndex = await _getFirstIncompleteExerciseIndex();
    final videoId = '${widget.workout.title}_exercise_$exerciseIndex';

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExercisePlayerScreen(
            ref: ref,
            workoutTitle: widget.workout.title,
            exerciseName: exercises[exerciseIndex],
            videoId: videoId,
            exerciseIndex: exerciseIndex,
            totalExercises: exercises.length,
            totalWorkoutPoints: widget.workout.points,
            onCompleted: () async {
              await _loadCompletionStatus();
            },
            workoutId: widget.workout.id,
            totalWorkoutExercises: exercises.length,
          ),
        ),
      ).then((_) {
        _loadCompletionStatus();
      });
    }
  }

  Future<void> _markWorkoutCompleteIfNeeded() async {
    final exercises = widget.workout.exercises;
    if (_completedExercises >= exercises.length && !_workoutMarkedComplete) {
      _workoutMarkedComplete = true;
      await WorkoutProgressService.markWorkoutComplete(widget.workout.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final exercises = widget.workout.exercises;
    final progressVal = exercises.isEmpty ? 0.0 : _completedExercises / exercises.length;
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha:0.72);

    if (progressVal >= 1.0) {
      Future.microtask(() => _markWorkoutCompleteIfNeeded());
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 16),
              ),
            ),
          ),
          title: Text(
            widget.workout.title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.share_outlined, color: colorScheme.onSurface, size: 18),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // ── Session info banner ──
                    Container(
                      padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _infoPill(
                                icon: Icons.calendar_today_outlined,
                                label: 'Semaine 1 · Séance 1',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _infoPill(
                                icon: Icons.timer_outlined,
                                label: widget.workout.duration,
                              ),
                              const SizedBox(width: 8),
                              _levelPill(widget.workout.level),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox.shrink(),
                          ),
                          Divider(height: 1, color: colorScheme.outlineVariant),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.fitness_center_outlined, size: 14, color: textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                'Matériel : ',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                              Text(
                                'Tapis de sol, Haltères',
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Points & Progress ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progression',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.workout.points} points possibles',
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.60),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_completedExercises / ${exercises.length} complétés',
                                style: TextStyle(
                                  color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Exercise list ──
                    ...List.generate(exercises.length, (index) {
                      final eName = exercises[index];
                      final videoId = '${widget.workout.title}_exercise_$index';
                      final isDone = _completedVideos.contains(videoId);
                      final isCurrent = !isDone && index == _completedExercises;

                      return GestureDetector(
                        onTap: () {
                          final videoId = '${widget.workout.title}_exercise_$index';
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExercisePlayerScreen(
                                ref: ref,
                                workoutTitle: widget.workout.title,
                                exerciseName: eName,
                                videoId: videoId,
                                exerciseIndex: index,
                                totalExercises: exercises.length,
                                totalWorkoutPoints: widget.workout.points,
                                onCompleted: () {
                                  if (!isDone) {
                                    setState(() {
                                      _completedExercises++;
                                      _completedVideos.add(videoId);
                                    });
                                  }
                                },
                                workoutId: widget.workout.id,
                                totalWorkoutExercises: exercises.length,
                              ),
                            ),
                          ).then((_) {
                            _loadCompletionStatus();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isCurrent
                                        ? colorScheme.primary.withValues(alpha:0.12)
                                        : colorScheme.shadow.withValues(alpha:0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                border: isCurrent
                                    ? null
                                    : null,
                          ),
                          child: Row(
                            children: [
                              // Index badge
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? colorScheme.primary
                                      : isCurrent
                                          ? colorScheme.secondaryContainer
                                          : colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isDone
                                      ? Icon(Icons.check_rounded, color: colorScheme.onPrimary, size: 16)
                                      : Text(
                                          (index + 1).toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: isCurrent
                                                ? colorScheme.primary
                                                : textSecondary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 64,
                                      child: Image.asset(
                                        widget.workout.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: colorScheme.surfaceContainerHighest,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      height: 64,
                                      color: colorScheme.shadow.withValues(alpha:0.2),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? colorScheme.primary
                                                : colorScheme.onSurface.withValues(alpha:0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isDone ? Icons.check_rounded : Icons.play_arrow_rounded,
                                            color: isDone ? colorScheme.onPrimary : colorScheme.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eName,
                                      style: TextStyle(
                                        color: isDone
                                            ? textSecondary
                                            : colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        decorationColor: textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '45 sec · 3 séries',
                                      style: TextStyle(color: textSecondary, fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Full Body',
                                        style: TextStyle(
                                          color: colorScheme.onSecondaryContainer,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Chevron
                              Icon(Icons.chevron_right_rounded, color: colorScheme.outlineVariant, size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom CTA ──
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha:0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: progressVal >= 1.0 ? null : () {
                    if (exercises.isNotEmpty) {
                      _openFirstIncompleteExercise();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: progressVal >= 1.0 ? colorScheme.primary.withValues(alpha: 0.50) : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        progressVal >= 1.0 ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        progressVal >= 1.0 ? 'Séance terminée ✓' : 'Commencer la séance',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill({required IconData icon, required String label}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colorScheme.onSurface.withValues(alpha:0.72)),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _levelPill(String level) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_outlined, size: 13, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            level,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}