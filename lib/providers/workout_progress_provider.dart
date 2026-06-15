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

// Notifier for managing favorite items (programs, workouts)
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _loadFavorites();
    return {};
  }

  Future<void> _loadFavorites() async {
    final favorites = await WorkoutProgressService.getFavorites();
    state = favorites;
  }

  Future<void> toggleFavorite(String id) async {
    await WorkoutProgressService.toggleFavorite(id);
    final newSet = Set<String>.from(state);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    state = newSet;
  }

  Future<void> addFavorite(String id) async {
    await WorkoutProgressService.addFavorite(id);
    final newSet = Set<String>.from(state);
    newSet.add(id);
    state = newSet;
  }

  Future<void> removeFavorite(String id) async {
    await WorkoutProgressService.removeFavorite(id);
    final newSet = Set<String>.from(state);
    newSet.remove(id);
    state = newSet;
  }

  Future<void> setFavorites(Set<String> favorites) async {
    for (final id in favorites) {
      await WorkoutProgressService.addFavorite(id);
    }
    state = Set<String>.from(favorites);
  }
}

// Favorites from storage provider
final storedFavoritesProvider = FutureProvider<Set<String>>((ref) async {
  return await WorkoutProgressService.getFavorites();
});

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);
