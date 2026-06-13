import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/workout_progress_service.dart';
import '../models/workout_model.dart';
import '../models/home_program_model.dart';

// Completed videos provider
final completedVideosProvider = FutureProvider<Set<String>>((ref) async {
  return await WorkoutProgressService.getCompletedVideos();
});

// Completed workouts provider
final completedWorkoutsProvider = FutureProvider<Set<String>>((ref) async {
  return await WorkoutProgressService.getCompletedWorkouts();
});

// Completed programs provider
final completedProgramsProvider = FutureProvider<Set<String>>((ref) async {
  return await WorkoutProgressService.getCompletedPrograms();
});

// Video progress provider
final videoProgressProvider = FutureProvider.family<double, String>((ref, videoId) async {
  return await WorkoutProgressService.getVideoProgress(videoId);
});

// Workout completion status provider
final isWorkoutCompletedProvider = FutureProvider.family<bool, String>((ref, workoutId) async {
  return await WorkoutProgressService.isWorkoutCompleted(workoutId);
});

// Program completion status provider
final isProgramCompletedProvider = FutureProvider.family<bool, String>((ref, programId) async {
  return await WorkoutProgressService.isProgramCompleted(programId);
});

// Workout completion percentage provider
final workoutCompletionPercentageProvider = FutureProvider.family<double, WorkoutModel>((ref, workout) async {
  return await WorkoutProgressService.getWorkoutCompletionPercentage(workout);
});

// Program completion percentage provider
final programCompletionPercentageProvider = FutureProvider.family<double, HomeProgramModel>((ref, program) async {
  return await WorkoutProgressService.getProgramCompletionPercentage(program);
});

// Program status provider (completion status + percentage)
final programStatusProvider = FutureProvider.family<ProgramProgressStatus, HomeProgramModel>((ref, program) async {
  return await WorkoutProgressService.getProgramStatus(program);
});

// Notifier for marking videos complete
class VideoCompletionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> completeVideo(String videoId) async {
    await WorkoutProgressService.markVideoComplete(videoId);
    ref.invalidate(completedVideosProvider);
    ref.invalidate(completedWorkoutsProvider);
    ref.invalidate(completedProgramsProvider);
    ref.invalidate(workoutCompletionPercentageProvider);
    ref.invalidate(programCompletionPercentageProvider);
    ref.invalidate(programStatusProvider);
  }
}

final videoCompletionProvider = NotifierProvider<VideoCompletionNotifier, void>(
  VideoCompletionNotifier.new,
);

// Notifier for marking workouts complete
class WorkoutCompletionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> completeWorkout(String workoutId) async {
    await WorkoutProgressService.markWorkoutComplete(workoutId);
    ref.invalidate(completedWorkoutsProvider);
    ref.invalidate(completedProgramsProvider);
    ref.invalidate(isWorkoutCompletedProvider);
    ref.invalidate(programCompletionPercentageProvider);
    ref.invalidate(programStatusProvider);
  }
}

final workoutCompletionProvider = NotifierProvider<WorkoutCompletionNotifier, void>(
  WorkoutCompletionNotifier.new,
);

// Notifier for marking programs complete
class ProgramCompletionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> completeProgram(String programId) async {
    await WorkoutProgressService.markProgramComplete(programId);
    ref.invalidate(completedProgramsProvider);
    ref.invalidate(isProgramCompletedProvider);
  }
}

final programCompletionProvider = NotifierProvider<ProgramCompletionNotifier, void>(
  ProgramCompletionNotifier.new,
);
