import '../services/supabase_config.dart';

/// Gère la persistence des repas journaliers dans Supabase.
/// Table : user_nutrition_logs
/// Colonnes : id (uuid), user_id, date (date), meal_category, meal_name,
///            calories (int), protein (float8), carbs (float8), fat (float8),
///            created_at (timestamptz)
class NutritionService {
  static String _today() =>
      DateTime.now().toIso8601String().substring(0, 10); // "YYYY-MM-DD"

  /// Charge les repas du jour courant pour l'utilisateur connecté.
  static Future<List<Map<String, dynamic>>> fetchTodayLogs() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return [];

    final rows = await SupabaseConfig.table('user_nutrition_logs')
        .select()
        .eq('user_id', uid)
        .eq('date', _today())
        .order('created_at');

    return List<Map<String, dynamic>>.from(rows as List);
  }

  /// Ajoute un repas pour aujourd'hui.
  static Future<String?> addLog({
    required String category,
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return null;

    final row = await SupabaseConfig.table('user_nutrition_logs').insert({
      'user_id':       uid,
      'date':          _today(),
      'meal_category': category,
      'meal_name':     name,
      'calories':      calories,
      'protein':       protein,
      'carbs':         carbs,
      'fat':           fat,
    }).select().single();

    return (row)['id'] as String?;
  }

  /// Supprime un repas par son id.
  static Future<void> deleteLog(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await SupabaseConfig.table('user_nutrition_logs')
        .delete()
        .eq('id', id)
        .eq('user_id', uid);
  }
}
