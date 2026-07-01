import 'supabase_config.dart';

class RecipeService {
  static Future<List<Map<String, dynamic>>> fetchImageRecipes() async {
    final rows = await SupabaseConfig.table('nutrition_recipes')
        .select()
        .eq('type', 'image')
        .order('created_at', ascending: false) as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchVideoRecipes() async {
    final rows = await SupabaseConfig.table('nutrition_recipes')
        .select()
        .eq('type', 'video')
        .order('created_at', ascending: false) as List;
    return rows.cast<Map<String, dynamic>>();
  }
}
