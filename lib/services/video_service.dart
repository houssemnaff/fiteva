import '../models/coach_model.dart';
import '../models/video_model.dart';
import 'supabase_config.dart';

/// Vidéos autonomes (workout_id NULL) — cartes Dance/Cardio/Récupération qui
/// s'ouvrent directement dans ExercisePlayerScreen sans passer par un programme.
class VideoService {
  static Future<List<VideoModel>> fetchStandalone() async {
    final rows = await SupabaseConfig.table('videos')
        .select()
        .isFilter('workout_id', null)
        .order('sort_order', ascending: true);

    final list = rows as List;

    // Collect unique coach IDs to fetch separately
    final coachIds = <String>{};
    for (final r in list) {
      final cid = (r as Map<String, dynamic>)['coach_id'] as String?;
      if (cid != null && cid.isNotEmpty) coachIds.add(cid);
    }

    // Fetch coaches in one query
    final coaches = <String, CoachModel>{};
    if (coachIds.isNotEmpty) {
      final coachRows = await SupabaseConfig.table('coaches')
          .select()
          .inFilter('id', coachIds.toList());
      for (final cr in coachRows as List) {
        final m = cr as Map<String, dynamic>;
        coaches[m['id'] as String] = CoachModel.fromRow(m);
      }
    }

    return list.map((r) {
      final m = r as Map<String, dynamic>;
      return _fromRow(m, coaches[m['coach_id'] as String?]);
    }).toList();
  }

  static VideoModel _fromRow(Map<String, dynamic> r, CoachModel? coach) => VideoModel(
        id: r['id'] as String,
        title: r['title'] as String,
        duration: r['duration'] as String? ?? '',
        points: r['points'] as int? ?? 0,
        thumbnailUrl: r['thumbnail_url'] as String? ?? '',
        url: r['url'] as String? ?? '',
        category: r['category'] as String? ?? 'dance',
        phases: r['phases'] as String? ?? '',
        coachId: r['coach_id'] as String?,
        coach: coach,
        techniqueDescription: r['technique_description'] as String? ?? '',
        techniqueSteps: List<String>.from(r['technique_steps'] as List? ?? []),
        musclesPrimary: (r['muscles_primary'] as List? ?? [])
            .map((m) => (
                  name: m['name'] as String? ?? '',
                  level: (m['level'] as num?)?.toDouble() ?? 0.0,
                ))
            .toList(),
        musclesSecondary: List<String>.from(r['muscles_secondary'] as List? ?? []),
        tips: (r['tips'] as List? ?? [])
            .map((t) => (
                  title: t['title'] as String? ?? '',
                  tip: t['tip'] as String? ?? '',
                ))
            .toList(),
        sets: r['sets'] as int? ?? 3,
        workSeconds: r['work_seconds'] as int? ?? 45,
        restSeconds: r['rest_seconds'] as int? ?? 15,
      );
}
