import 'package:shared_preferences/shared_preferences.dart';

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

  // Clear all progress (for testing)
  static Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedVideosKey);
    await prefs.remove(_completedWorkoutsKey);
    await prefs.remove(_completedProgramsKey);
  }
}
