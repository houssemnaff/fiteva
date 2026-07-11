import 'package:flutter/foundation.dart';
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

  /// Progrès brut (0.0-1.0) de toutes les vidéos vues par l'utilisateur,
  /// y compris celles regardées partiellement (progress < 0.8, donc pas
  /// encore marquées `completed`) — utile pour détecter "vidéo commencée
  /// mais pas terminée" plutôt que seulement "vidéo terminée".
  static Future<Map<String, double>> getAllVideoProgress() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_video_completions')
          .select('video_id, progress')
          .eq('user_id', _uid!);
      debugPrint('[WorkoutProgress] getAllVideoProgress: ${rows.length} row(s) for uid=$_uid');
      return {
        for (final r in rows as List)
          r['video_id'] as String: (r['progress'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      debugPrint('[WorkoutProgress] getAllVideoProgress FAILED: $e');
      return {};
    }
  }

  static Future<void> markVideoComplete(String videoId) async {
    if (_uid == null || videoId.isEmpty) return;
    try {
      await SupabaseConfig.table('user_video_completions').upsert({
        'user_id':      _uid,
        'video_id':     videoId,
        'progress':     1.0,
        'completed':    true,
        'completed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,video_id');
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
    if (_uid == null || videoId.isEmpty) {
      debugPrint('[WorkoutProgress] updateVideoProgress SKIPPED — uid=$_uid videoId="$videoId"');
      return;
    }
    try {
      final completed = progress >= 0.8;
      await SupabaseConfig.table('user_video_completions').upsert({
        'user_id':      _uid,
        'video_id':     videoId,
        'progress':     progress.clamp(0.0, 1.0),
        'completed':    completed,
        'completed_at': completed ? DateTime.now().toIso8601String() : null,
      }, onConflict: 'user_id,video_id');
      debugPrint('[WorkoutProgress] updateVideoProgress OK — videoId=$videoId progress=$progress');
    } catch (e) {
      debugPrint('[WorkoutProgress] updateVideoProgress FAILED: $e');
    }
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
      }, onConflict: 'user_id,workout_id');
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
      final videoId = workout.videoIdAt(i);
      if (videoId == null || !completedVideos.contains(videoId)) {
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
      final videoId = workout.videoIdAt(i);
      if (videoId != null && completedVideos.contains(videoId)) done++;
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
      }, onConflict: 'user_id,program_id');
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

  // ── Programmes rejoints ───────────────────────────────────────────────────

  static Future<Set<String>> getJoinedPrograms() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_joined_programs')
          .select('program_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['program_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<void> joinProgram(String programId) async {
    if (_uid == null) return;
    try {
      // ignoreDuplicates : ne PAS écraser joined_at si déjà rejoint —
      // cette date sert de point de départ au déblocage des semaines.
      await SupabaseConfig.table('user_joined_programs').upsert({
        'user_id':    _uid,
        'program_id': programId,
        'joined_at':  DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,program_id', ignoreDuplicates: true);
    } catch (_) {}
  }

  /// Date à laquelle l'utilisateur a commencé le programme (semaine 1).
  static Future<DateTime?> getProgramJoinedDate(String programId) async {
    if (_uid == null) return null;
    try {
      final row = await SupabaseConfig.table('user_joined_programs')
          .select('joined_at')
          .eq('user_id', _uid!)
          .eq('program_id', programId)
          .maybeSingle();
      final s = row?['joined_at'] as String?;
      return s == null ? null : DateTime.tryParse(s);
    } catch (_) {
      return null;
    }
  }

  /// Nombre de semaines débloquées d'un programme.
  /// Règles :
  ///  - la semaine 1 est toujours ouverte ;
  ///  - la semaine N+1 s'ouvre seulement si TOUS les workouts de la
  ///    semaine N sont terminés ET que 7×N jours sont passés depuis le
  ///    début du programme (joined_at de la semaine 1).
  static Future<int> getUnlockedWeeksCount(HomeProgramModel program) async {
    final weeks = program.weeks;
    if (weeks.length <= 1) return weeks.length;

    final done     = await getCompletedWorkouts();
    final joinedAt = await getProgramJoinedDate(program.id);

    int unlocked = 1;
    for (int i = 1; i < weeks.length; i++) {
      final prevWeekDone =
          weeks[i - 1].workouts.every((w) => done.contains(w.id));
      final dateOk = joinedAt != null &&
          !DateTime.now().isBefore(joinedAt.add(Duration(days: 7 * i)));
      if (prevWeekDone && dateOk) {
        unlocked = i + 1;
      } else {
        break;
      }
    }
    return unlocked;
  }

  static Future<bool> isProgramJoined(String programId) async {
    final joined = await getJoinedPrograms();
    return joined.contains(programId);
  }

  /// Filtre [all] pour ne garder que les programmes que l'utilisateur a rejoints.
  static Future<List<HomeProgramModel>> getJoinedProgramsList(List<HomeProgramModel> all) async {
    final joined = await getJoinedPrograms();
    return all.where((p) => joined.contains(p.id)).toList();
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

  static Future<Set<String>> getVideoFavorites() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('user_video_favorites')
          .select('video_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['video_id'] as String};
    } catch (_) {
      return {};
    }
  }

  /// Retourne l'union des favoris — programmes préfixés "prog:", vidéos autonomes
  /// préfixées "video:" pour les distinguer des workouts (sans préfixe)
  static Future<Set<String>> getFavorites() async {
    final wf = await getWorkoutFavorites();
    final pf = await getProgramFavorites();
    final vf = await getVideoFavorites();
    return {...wf, ...pf.map((id) => 'prog:$id'), ...vf.map((id) => 'video:$id')};
  }

  static Future<void> addWorkoutFavorite(String workoutId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_workout_favorites')
          .upsert({'user_id': _uid, 'workout_id': workoutId},
              onConflict: 'user_id,workout_id');
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
          .upsert({'user_id': _uid, 'program_id': programId},
              onConflict: 'user_id,program_id');
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

  static Future<void> addVideoFavorite(String videoId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_video_favorites')
          .upsert({'user_id': _uid, 'video_id': videoId},
              onConflict: 'user_id,video_id');
    } catch (_) {}
  }

  static Future<void> removeVideoFavorite(String videoId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('user_video_favorites')
          .delete()
          .eq('user_id', _uid!)
          .eq('video_id', videoId);
    } catch (_) {}
  }

  /// Détecte le type par le préfixe "prog:" (programmes), "video:" (vidéos
  /// autonomes) ou aucun préfixe (workouts)
  static Future<void> addFavorite(String id) async {
    if (id.startsWith('prog:')) {
      await addProgramFavorite(id.substring(5));
    } else if (id.startsWith('video:')) {
      await addVideoFavorite(id.substring(6));
    } else {
      await addWorkoutFavorite(id);
    }
  }

  static Future<void> removeFavorite(String id) async {
    if (id.startsWith('prog:')) {
      await removeProgramFavorite(id.substring(5));
    } else if (id.startsWith('video:')) {
      await removeVideoFavorite(id.substring(6));
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
      await SupabaseConfig.table('user_video_favorites').delete().eq('user_id', _uid!);
    } catch (_) {}
  }

  // ── Historique par date ──────────────────────────────────────────────────

  static Future<Map<DateTime, int>> getWorkoutCountsByMonth(int year, int month) async {
    if (_uid == null) return {};
    try {
      final start = DateTime(year, month, 1).toIso8601String();
      final end = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
      final rows = await SupabaseConfig.table('user_workout_completions')
          .select('completed_at')
          .eq('user_id', _uid!)
          .gte('completed_at', start)
          .lte('completed_at', end) as List;

      final counts = <DateTime, int>{};
      for (final r in rows) {
        final dt = DateTime.parse(r['completed_at'] as String);
        final day = DateTime(dt.year, dt.month, dt.day);
        counts[day] = (counts[day] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      debugPrint('[WorkoutProgress] getWorkoutCountsByMonth error: $e');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentCompletions(int limit) async {
    if (_uid == null) return [];
    try {
      final rows = await SupabaseConfig.table('user_workout_completions')
          .select('workout_id, completed_at')
          .eq('user_id', _uid!)
          .order('completed_at', ascending: false)
          .limit(limit) as List;
      return rows.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[WorkoutProgress] getRecentCompletions error: $e');
      return [];
    }
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
