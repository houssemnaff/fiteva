import '../models/workout_model.dart';
import '../models/home_program_model.dart';
import 'supabase_config.dart';

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

/// Progression workouts, vidéos, programmes et favoris — stocké dans Supabase
class WorkoutProgressService {
  static String? get _uid => SupabaseConfig.userId;

  // ── Vidéos ────────────────────────────────────────────────────────────────

  static Future<Set<String>> getCompletedVideos() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_video_completions')
          .select('video_id')
          .eq('user_id', _uid!)
          .eq('completed', true);
      return {for (final r in rows as List) r['video_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<void> markVideoComplete(String videoId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_video_completions').upsert({
        'user_id':      _uid,
        'video_id':     videoId,
        'progress':     1.0,
        'completed':    true,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<bool> isVideoCompleted(String videoId) async {
    if (_uid == null) return false;
    try {
      final row = await SupabaseConfig.table('user_video_completions')
          .select('completed')
          .eq('user_id', _uid!)
          .eq('video_id', videoId)
          .maybeSingle();
      return row?['completed'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<double> getVideoProgress(String videoId) async {
    if (_uid == null) return 0.0;
    try {
      final row = await SupabaseConfig.table('user_video_completions')
          .select('progress')
          .eq('user_id', _uid!)
          .eq('video_id', videoId)
          .maybeSingle();
      return (row?['progress'] as num?)?.toDouble() ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  static Future<void> updateVideoProgress(String videoId, double progress) async {
    if (_uid == null) return;
    try {
      final completed = progress >= 0.8;
      await SupabaseConfig.table('user_video_completions').upsert({
        'user_id':      _uid,
        'video_id':     videoId,
        'progress':     progress.clamp(0.0, 1.0),
        'completed':    completed,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      });
    } catch (_) {}
  }

  // ── Workouts ──────────────────────────────────────────────────────────────

  static Future<Set<String>> getCompletedWorkouts() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_workout_completions')
          .select('workout_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['workout_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<void> markWorkoutComplete(String workoutId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_workout_completions').upsert({
        'user_id':      _uid,
        'workout_id':   workoutId,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<bool> isWorkoutCompleted(String workoutId) async {
    if (_uid == null) return false;
    final completed = await getCompletedWorkouts();
    return completed.contains(workoutId);
  }

  static Future<bool> checkAndMarkWorkoutComplete(WorkoutModel workout) async {
    final completedVideos = await getCompletedVideos();
    bool allDone = true;
    for (int i = 0; i < workout.exercises.length; i++) {
      if (!completedVideos.contains('${workout.title}_exercise_$i')) {
        allDone = false;
        break;
      }
    }
    if (allDone && workout.exercises.isNotEmpty) {
      await markWorkoutComplete(workout.id);
      return true;
    }
    return false;
  }

  static Future<double> getWorkoutCompletionPercentage(WorkoutModel workout) async {
    if (workout.exercises.isEmpty) return 0.0;
    final completedVideos = await getCompletedVideos();
    int done = 0;
    for (int i = 0; i < workout.exercises.length; i++) {
      if (completedVideos.contains('${workout.title}_exercise_$i')) done++;
    }
    return done / workout.exercises.length;
  }

  // ── Programmes ────────────────────────────────────────────────────────────

  static Future<Set<String>> getCompletedPrograms() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_program_completions')
          .select('program_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['program_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<void> markProgramComplete(String programId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_program_completions').upsert({
        'user_id':      _uid,
        'program_id':   programId,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  static Future<bool> isProgramCompleted(String programId) async {
    final completed = await getCompletedPrograms();
    return completed.contains(programId);
  }

  static Future<bool> checkAndMarkProgramComplete(HomeProgramModel program) async {
    final completedWorkouts = await getCompletedWorkouts();
    bool allDone = program.workouts.isNotEmpty &&
        program.workouts.every((w) => completedWorkouts.contains(w.id));
    if (allDone) {
      await markProgramComplete(program.id);
      return true;
    }
    return false;
  }

  static Future<void> checkAndMarkAllProgramsComplete(List<HomeProgramModel> programs) async {
    for (final p in programs) {
      await checkAndMarkProgramComplete(p);
    }
  }

  static Future<double> getProgramCompletionPercentage(HomeProgramModel program) async {
    if (program.workouts.isEmpty) return 0.0;
    final completedWorkouts = await getCompletedWorkouts();
    final done = program.workouts.where((w) => completedWorkouts.contains(w.id)).length;
    return done / program.workouts.length;
  }

  static Future<ProgramProgressStatus> getProgramStatus(HomeProgramModel program) async {
    final percentage       = await getProgramCompletionPercentage(program);
    final isCompleted      = await isProgramCompleted(program.id);
    final completedWorkouts = await getCompletedWorkouts();
    final done = program.workouts.where((w) => completedWorkouts.contains(w.id)).length;
    return ProgramProgressStatus(
      programId:             program.id,
      completionPercentage:  percentage,
      isCompleted:           isCompleted,
      completedWorkouts:     done,
      totalWorkouts:         program.workouts.length,
    );
  }

  static Future<List<HomeProgramModel>> getStartedPrograms(List<HomeProgramModel> all) async {
    final started = <HomeProgramModel>[];
    for (final p in all) {
      final status = await getProgramStatus(p);
      if (status.isStarted) started.add(p);
    }
    return started;
  }

  // ── Favoris workouts ──────────────────────────────────────────────────────

  static Future<Set<String>> getWorkoutFavorites() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_workout_favorites')
          .select('workout_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['workout_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<Set<String>> getProgramFavorites() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_program_favorites')
          .select('program_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['program_id'] as String};
    } catch (_) {
      return {};
    }
  }

  /// Retourne l'union des favoris workouts + programmes
  static Future<Set<String>> getFavorites() async {
    final wf = await getWorkoutFavorites();
    final pf = await getProgramFavorites();
    return {...wf, ...pf};
  }

  static Future<void> addWorkoutFavorite(String workoutId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_workout_favorites')
          .upsert({'user_id': _uid, 'workout_id': workoutId});
    } catch (_) {}
  }

  static Future<void> removeWorkoutFavorite(String workoutId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_workout_favorites')
          .delete()
          .eq('user_id', _uid!)
          .eq('workout_id', workoutId);
    } catch (_) {}
  }

  static Future<void> addProgramFavorite(String programId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_program_favorites')
          .upsert({'user_id': _uid, 'program_id': programId});
    } catch (_) {}
  }

  static Future<void> removeProgramFavorite(String programId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_program_favorites')
          .delete()
          .eq('user_id', _uid!)
          .eq('program_id', programId);
    } catch (_) {}
  }

  /// Compatibilité : detecte le type par le préfixe "prog_"
  static Future<void> addFavorite(String id) async {
    if (id.startsWith('prog_')) {
      await addProgramFavorite(id);
    } else {
      await addWorkoutFavorite(id);
    }
  }

  static Future<void> removeFavorite(String id) async {
    if (id.startsWith('prog_')) {
      await removeProgramFavorite(id);
    } else {
      await removeWorkoutFavorite(id);
    }
  }

  static Future<void> toggleFavorite(String id) async {
    final favs = await getFavorites();
    if (favs.contains(id)) {
      await removeFavorite(id);
    } else {
      await addFavorite(id);
    }
  }

  static Future<bool> isFavorite(String id) async {
    final favs = await getFavorites();
    return favs.contains(id);
  }

  static Future<void> clearFavorites() async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_workout_favorites').delete().eq('user_id', _uid!);
      await SupabaseConfig.table('user_program_favorites').delete().eq('user_id', _uid!);
    } catch (_) {}
  }

  static Future<void> clearAllProgress() async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_video_completions').delete().eq('user_id', _uid!);
      await SupabaseConfig.table('user_workout_completions').delete().eq('user_id', _uid!);
      await SupabaseConfig.table('user_program_completions').delete().eq('user_id', _uid!);
    } catch (_) {}
  }
}
