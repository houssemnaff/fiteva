import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/workout_model.dart';
import '../../theme/app_theme.dart';
import 'exercise_player_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  int _completedExercises = 0;

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises;
    final progressVal = exercises.isEmpty ? 0.0 : _completedExercises / exercises.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:  Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E5EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1C1C1E), size: 16),
              ),
            ),
          ),
          title: Text(
            widget.workout.title,
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E5EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: Color(0xFF1C1C1E), size: 18),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                            child: Divider(height: 1, color: Color(0xFFE5E5EA)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.fitness_center_outlined, size: 14, color: Color(0xFF8E8E93)),
                              const SizedBox(width: 6),
                              const Text(
                                'Matériel : ',
                                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
                              ),
                              const Text(
                                'Tapis de sol, Haltères',
                                style: TextStyle(
                                  color: Color(0xFF1C1C1E),
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

                    // ── Progress ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progression',
                          style: TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_completedExercises / ${exercises.length} complétés',
                            style: const TextStyle(
                              color: Color(0xFF1B5E3B),
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
                        backgroundColor: const Color(0xFFE5E5EA),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B5E3B)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Exercise list ──
                    ...List.generate(exercises.length, (index) {
                      final eName = exercises[index];
                      final isDone = index < _completedExercises;
                      final isCurrent = index == _completedExercises;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ExercisePlayerScreen(
                                workoutTitle: widget.workout.title,
                                exerciseName: eName,
                                exerciseIndex: index,
                                totalExercises: exercises.length,
                                onCompleted: () {
                                  if (!isDone) setState(() => _completedExercises++);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isCurrent
                                ? Border.all(color: const Color(0xFF1B5E3B), width: 1.5)
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
                                      ? const Color(0xFF1B5E3B)
                                      : isCurrent
                                          ? const Color(0xFFE8F5EE)
                                          : const Color(0xFFF2F2F7),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                      : Text(
                                          (index + 1).toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            color: isCurrent
                                                ? const Color(0xFF1B5E3B)
                                                : const Color(0xFF8E8E93),
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
                                      child: Image.network(
                                        widget.workout.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFE5E5EA),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 90,
                                      height: 64,
                                      color: Colors.black.withOpacity(0.2),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isDone
                                                ? const Color(0xFF1B5E3B)
                                                : Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isDone ? Icons.check_rounded : Icons.play_arrow_rounded,
                                            color: isDone ? Colors.white : const Color(0xFF1B5E3B),
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
                                            ? const Color(0xFF8E8E93)
                                            : const Color(0xFF1C1C1E),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        decoration: isDone ? TextDecoration.lineThrough : null,
                                        decorationColor: const Color(0xFF8E8E93),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '45 sec · 3 séries',
                                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5EE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Full Body',
                                        style: TextStyle(
                                          color: Color(0xFF1B5E3B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Chevron
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC7C7CC), size: 20),
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
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F7),
                border: Border(top: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (exercises.isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExercisePlayerScreen(
                            workoutTitle: widget.workout.title,
                            exerciseName: exercises[0],
                            exerciseIndex: 0,
                            totalExercises: exercises.length,
                            onCompleted: () {
                              if (_completedExercises == 0) setState(() => _completedExercises = 1);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E3B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Commencer la séance',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF8E8E93)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _levelPill(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_outlined, size: 13, color: Color(0xFF1B5E3B)),
          const SizedBox(width: 4),
          Text(
            level,
            style: const TextStyle(
              color: Color(0xFF1B5E3B),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}