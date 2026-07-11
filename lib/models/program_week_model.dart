import 'workout_model.dart';

/// Une semaine d'un programme : programs ──< program_weeks ──< workouts.
class ProgramWeekModel {
  final String id;
  final int weekNumber;
  final String title;
  final String description;
  final List<WorkoutModel> workouts;

  ProgramWeekModel({
    required this.id,
    required this.weekNumber,
    this.title = '',
    this.description = '',
    this.workouts = const [],
  });
}
