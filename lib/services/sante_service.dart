import 'supabase_config.dart';

class SanteService {
  static Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final rows = await SupabaseConfig.table('doctors')
        .select()
        .order('name') as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchArticles() async {
    final rows = await SupabaseConfig.table('health_articles')
        .select()
        .eq('status', 'accepted')
        .order('created_at', ascending: false) as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final rows = await SupabaseConfig.table('health_questions')
        .select()
        .order('votes', ascending: false) as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<void> submitQuestion(String questionText) async {
    final uid = SupabaseConfig.userId;
    await SupabaseConfig.table('health_questions').insert({
      if (uid != null) 'user_id': uid,
      'question': questionText,
      'votes': 0,
      'posted_ago': 'À l\'instant',
    });
  }
}
