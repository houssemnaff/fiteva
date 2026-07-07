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

    return (rows as List)
        .map((r) => _fromRow(r as Map<String, dynamic>))
        .toList();
  }

  static VideoModel _fromRow(Map<String, dynamic> r) => VideoModel(
        id: r['id'] as String,
        title: r['title'] as String,
        duration: r['duration'] as String? ?? '',
        points: r['points'] as int? ?? 0,
        thumbnailUrl: r['thumbnail_url'] as String? ?? '',
        url: r['url'] as String? ?? '',
        category: r['category'] as String? ?? 'dance',
        phases: r['phases'] as String? ?? '',
      );
}
