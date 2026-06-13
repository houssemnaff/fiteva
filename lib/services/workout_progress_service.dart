import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import '../models/home_program_model.dart';

class ProgramProgressStatus {
  final String programId;
  final double completionPercentage;
  final bool isCompleted;
  final int completedWorkouts;
  final int totalWorkouts;

  ProgramProgressStatus({
    required this.programId,
    required this.completionPercentage,
    required this.isCompleted,
    required this.completedWorkouts,
    required this.totalWorkouts,
  });

  bool get isStarted => completedWorkouts > 0 && !isCompleted;
}

class WorkoutProgressService {
  static const _completedVideosKey = 'completed_videos';
  static const _completedWorkoutsKey = 'completed_workouts';
  static const _completedProgramsKey = 'completed_programs';
  static const _videoProgressKey = 'video_progress_';

  // Video Completion (80% watched)
  static Future<Set<String>> getCompletedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedVideosKey) ?? []).toSet();
  }

  static Future<void> markVideoComplete(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedVideosKey) ?? [];
    if (!completed.contains(videoId)) {
      completed.add(videoId);
      await prefs.setStringList(_completedVideosKey, completed);
    }
  }

  static Future<bool> isVideoCompleted(String videoId) async {
    final completed = await getCompletedVideos();
    return completed.contains(videoId);
  }

  // Workout Completion
  static Future<Set<String>> getCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedWorkoutsKey) ?? []).toSet();
  }

  static Future<void> markWorkoutComplete(String workoutId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedWorkoutsKey) ?? [];
    if (!completed.contains(workoutId)) {
      completed.add(workoutId);
      await prefs.setStringList(_completedWorkoutsKey, completed);
    }
  }

  static Future<bool> isWorkoutCompleted(String workoutId) async {
    final completed = await getCompletedWorkouts();
    return completed.contains(workoutId);
  }

  // Program Completion
  static Future<Set<String>> getCompletedPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_completedProgramsKey) ?? []).toSet();
  }

  static Future<void> markProgramComplete(String programId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedProgramsKey) ?? [];
    if (!completed.contains(programId)) {
      completed.add(programId);
      await prefs.setStringList(_completedProgramsKey, completed);
    }
  }

  static Future<bool> isProgramCompleted(String programId) async {
    final completed = await getCompletedPrograms();
    return completed.contains(programId);
  }

  // Video Progress Tracking
  static Future<double> getVideoProgress(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_videoProgressKey$videoId') ?? 0.0;
  }

  static Future<void> updateVideoProgress(String videoId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_videoProgressKey$videoId', progress);

    // Auto-complete at 80%
    if (progress >= 0.8) {
      await markVideoComplete(videoId);
    }
  }

  // Check and mark workout as completed if all videos are completed
  static Future<bool> checkAndMarkWorkoutComplete(WorkoutModel workout) async {
    final completedVideos = await getCompletedVideos();

    // Check if all exercises (videos) of this workout are completed
    bool allExercisesCompleted = true;
    for (int i = 0; i < workout.exercises.length; i++) {
      final videoId = '${workout.title}_exercise_$i';
      if (!completedVideos.contains(videoId)) {
        allExercisesCompleted = false;
        break;
      }
    }

    if (allExercisesCompleted && workout.exercises.isNotEmpty) {
      await markWorkoutComplete(workout.id);
      return true;
    }
    return false;
  }

  // Check all programs and mark as completed if all their workouts are completed
  static Future<void> checkAndMarkAllProgramsComplete(List<HomeProgramModel> programs) async {
    for (final program in programs) {
      await checkAndMarkProgramComplete(program);
    }
  }

  // Check and mark program as completed if all workouts are completed
  static Future<bool> checkAndMarkProgramComplete(HomeProgramModel program) async {
    final completedWorkouts = await getCompletedWorkouts();

    // Check if all workouts of this program are completed
    bool allWorkoutsCompleted = true;
    for (final workout in program.workouts) {
      if (!completedWorkouts.contains(workout.id)) {
        allWorkoutsCompleted = false;
        break;
      }
    }

    if (allWorkoutsCompleted && program.workouts.isNotEmpty) {
      await markProgramComplete(program.id);
      return true;
    }
    return false;
  }

  // Get completion percentage of a workout (0.0 to 1.0)
  static Future<double> getWorkoutCompletionPercentage(WorkoutModel workout) async {
    if (workout.exercises.isEmpty) return 0.0;

    final completedVideos = await getCompletedVideos();
    int completedCount = 0;

    for (int i = 0; i < workout.exercises.length; i++) {
      final videoId = '${workout.title}_exercise_$i';
      if (completedVideos.contains(videoId)) {
        completedCount++;
      }
    }

    return completedCount / workout.exercises.length;
  }

  // Get completion percentage of a program (0.0 to 1.0)
  static Future<double> getProgramCompletionPercentage(HomeProgramModel program) async {
    if (program.workouts.isEmpty) return 0.0;

    final completedWorkouts = await getCompletedWorkouts();
    int completedCount = 0;

    for (final workout in program.workouts) {
      if (completedWorkouts.contains(workout.id)) {
        completedCount++;
      }
    }

    return completedCount / program.workouts.length;
  }

  // Get complete program status
  static Future<ProgramProgressStatus> getProgramStatus(HomeProgramModel program) async {
    final percentage = await getProgramCompletionPercentage(program);
    final isCompleted = await isProgramCompleted(program.id);
    final completedWorkouts = await getCompletedWorkouts();

    int completedCount = 0;
    for (final workout in program.workouts) {
      if (completedWorkouts.contains(workout.id)) {
        completedCount++;
      }
    }

    return ProgramProgressStatus(
      programId: program.id,
      completionPercentage: percentage,
      isCompleted: isCompleted,
      completedWorkouts: completedCount,
      totalWorkouts: program.workouts.length,
    );
  }

  // Get list of programs that are started (not completed, but have progress)
  static Future<List<HomeProgramModel>> getStartedPrograms(List<HomeProgramModel> allPrograms) async {
    final started = <HomeProgramModel>[];
    for (final program in allPrograms) {
      final status = await getProgramStatus(program);
      if (status.isStarted) {
        started.add(program);
      }
    }
    return started;
  }

  // Clear all progress (for testing)
  static Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedVideosKey);
    await prefs.remove(_completedWorkoutsKey);
    await prefs.remove(_completedProgramsKey);
  }
}
