import 'package:flutter/material.dart';
import '../models/home_program_model.dart';
import '../models/program_week_model.dart';
import '../models/workout_model.dart';
import '../models/video_model.dart';
import 'supabase_config.dart';

class ProgramService {
  /// Hiérarchie complète : programme → semaines → workouts → vidéos.
  /// L'embed `workouts` direct (via program_id) sert de fallback pour les
  /// programmes dont les workouts ne sont pas encore rattachés à une semaine.
  static const _select =
      '*, program_weeks(*, workouts(*, videos(*))), workouts(*, videos(*))';

  /// Charge tous les programmes depuis Supabase avec leurs semaines,
  /// workouts et vidéos.
  static Future<List<HomeProgramModel>> fetchAll() async {
    final rows = await SupabaseConfig.table('programs').select(_select);

    final list = rows as List;
    print('[ProgramService] ${list.length} programmes chargés depuis Supabase');
    for (final r in list) {
      final m = r as Map<String, dynamic>;
      print('  → ${m['id']} (${m['category']}) — '
          '${(m['program_weeks'] as List?)?.length ?? 0} semaines, '
          '${(m['workouts'] as List?)?.length ?? 0} workouts');
    }

    return list.map((r) => _programFromRow(r as Map<String, dynamic>)).toList();
  }

  /// Charge uniquement les programmes d'une catégorie donnée.
  static Future<List<HomeProgramModel>> fetchByCategory(String category) async {
    final rows = await SupabaseConfig.table('programs')
        .select(_select)
        .eq('category', category);

    return (rows as List)
        .map((r) => _programFromRow(r as Map<String, dynamic>))
        .toList();
  }

  static Future<HomeProgramModel?> fetchProgramById(String id) async {
    final row = await SupabaseConfig.table('programs')
        .select(_select)
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;
    return _programFromRow(row);
  }

  // ── Mappers ────────────────────────────────────────────────────────────────

  static HomeProgramModel _programFromRow(Map<String, dynamic> r) {
    final weekRows = (r['program_weeks'] as List? ?? [])
        .cast<Map<String, dynamic>>()
      ..sort((a, b) => ((a['week_number'] as int?) ?? 0)
          .compareTo((b['week_number'] as int?) ?? 0));
    final weeks = weekRows.map(_weekFromRow).toList();

    // Workouts à plat : depuis les semaines si elles existent, sinon
    // fallback sur les workouts rattachés directement au programme (legacy).
    final directWorkoutRows = (r['workouts'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    final workouts = weeks.isNotEmpty
        ? [for (final wk in weeks) ...wk.workouts]
        : directWorkoutRows.map(_workoutFromRow).toList();

    return HomeProgramModel(
      id:               r['id']             as String,
      name:             r['name']           as String,
      // La durée n'est plus stockée en base : elle est dérivée du nombre
      // de semaines réelles (program_weeks).
      duration:         _durationLabel(weeks),
      phases:           r['phases']         as String? ?? '',
      color:            Color(r['color']    as int? ?? 0xFF2D4A2D),
      imageUrl:         r['image_url']      as String? ?? '',
      compatibleCycles: List<String>.from(r['compatible_cycles'] as List? ?? []),
      totalPoints:      r['total_points']   as int? ?? 100,
      level:            r['level']          as String?,
      equipment:        List<String>.from(r['equipment'] as List? ?? []),
      category:         r['category']       as String? ?? 'home',
      weeks:            weeks,
      workouts:         workouts,
    );
  }

  /// Libellé affiché ("3 semaines") calculé depuis les semaines réelles.
  static String _durationLabel(List<ProgramWeekModel> weeks) {
    if (weeks.isEmpty) return '';
    return weeks.length == 1 ? '1 semaine' : '${weeks.length} semaines';
  }

  static ProgramWeekModel _weekFromRow(Map<String, dynamic> r) {
    final workoutRows = (r['workouts'] as List? ?? [])
        .cast<Map<String, dynamic>>()
      ..sort((a, b) => ((a['sort_order'] as int?) ?? 0)
          .compareTo((b['sort_order'] as int?) ?? 0));

    return ProgramWeekModel(
      id:          r['id']          as String,
      weekNumber:  r['week_number'] as int? ?? 1,
      title:       r['title']       as String? ?? '',
      description: r['description'] as String? ?? '',
      workouts:    workoutRows.map(_workoutFromRow).toList(),
    );
  }

  static WorkoutModel _workoutFromRow(Map<String, dynamic> r) {
    final videoRows = (r['videos'] as List? ?? [])
        .cast<Map<String, dynamic>>()
      ..sort((a, b) =>
          ((a['sort_order'] as int?) ?? 0)
              .compareTo((b['sort_order'] as int?) ?? 0));

    return WorkoutModel(
      id:        r['id']        as String,
      title:     r['title']     as String,
      category:  r['category']  as String? ?? '',
      duration:  r['duration']  as String? ?? '',
      level:     r['level']     as String? ?? '',
      imageUrl:  r['image_url'] as String? ?? '',
      calories:  r['calories']  as String? ?? '0',
      exercises: List<String>.from(r['exercises'] as List? ?? []),
      phases:    r['phases']    as String? ?? '',
      points:    r['points']    as int? ?? 0,
      videos:    videoRows.map(_videoFromRow).toList(),
    );
  }

  static VideoModel _videoFromRow(Map<String, dynamic> r) {
    return VideoModel(
      id:           r['id']            as String,
      title:        r['title']         as String,
      duration:     r['duration']      as String? ?? '',
      points:       r['points']        as int? ?? 0,
      thumbnailUrl: r['thumbnail_url'] as String? ?? '',
      url:          r['url']           as String? ?? '',
    );
  }
}
