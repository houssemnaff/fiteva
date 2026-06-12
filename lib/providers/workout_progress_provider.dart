import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/workout_progress_service.dart';

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

// Notifier for marking videos complete
class VideoCompletionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> completeVideo(String videoId) async {
    await WorkoutProgressService.markVideoComplete(videoId);
    // Invalidate the providers to refresh UI
    ref.invalidate(completedVideosProvider);
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
  }
}

final programCompletionProvider = NotifierProvider<ProgramCompletionNotifier, void>(
  ProgramCompletionNotifier.new,
);
