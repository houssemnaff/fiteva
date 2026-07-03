import 'supabase_config.dart';

class RecipeService {
  static String resolveFavoriteIdentifier(Map<String, dynamic> row) {
    final values = [
      row['recipe_id'],
      row['id'],
      row['recipe_name'],
      row['name'],
    ];

    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null) {
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }

    return '';
  }

  static Future<List<Map<String, dynamic>>> fetchAllRecipes() async {
    final rows = await SupabaseConfig.table('nutrition_recipes').select() as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchImageRecipes() async {
    final rows = await SupabaseConfig.table('nutrition_recipes')
        .select()
        .eq('type', 'image') as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> fetchVideoRecipes() async {
    final rows = await SupabaseConfig.table('nutrition_recipes')
        .select()
        .eq('type', 'video') as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>?> fetchRecipeByIdentifier(String identifier) async {
    final normalized = identifier.trim();
    if (normalized.isEmpty) return null;

    final recipes = await fetchAllRecipes();
    for (final recipe in recipes) {
      final recipeId = (recipe['id'] ?? recipe['recipe_id'] ?? '').toString().trim();
      final recipeName = (recipe['name'] ?? recipe['recipe_name'] ?? '').toString().trim();
      if (recipeId == normalized || recipeName == normalized) {
        return recipe;
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> fetchFavoriteRecipeDetails(List<String> favoriteIdentifiers) async {
    if (favoriteIdentifiers.isEmpty) return [];

    final resolved = await Future.wait(
      favoriteIdentifiers.map(fetchRecipeByIdentifier),
    );

    return resolved.whereType<Map<String, dynamic>>().toList();
  }

  static Future<List<Map<String, dynamic>>> fetchFavoriteRecipes() async {
    if (SupabaseConfig.userId == null) return [];

    final rows = await SupabaseConfig.table('nutrition_recipe_favorites')
        .select()
        .eq('user_id', SupabaseConfig.userId!) as List;
    return rows.cast<Map<String, dynamic>>();
  }

  static Future<void> addFavorite(String identifier) async {
    if (SupabaseConfig.userId == null || identifier.trim().isEmpty) return;

    try {
      await SupabaseConfig.table('nutrition_recipe_favorites').upsert({
        'user_id': SupabaseConfig.userId,
        'recipe_name': identifier.trim(),
      });
    } catch (_) {}
  }

  static Future<void> removeFavorite(String identifier) async {
    if (SupabaseConfig.userId == null || identifier.trim().isEmpty) return;

    try {
      await SupabaseConfig.table('nutrition_recipe_favorites')
          .delete()
          .eq('user_id', SupabaseConfig.userId!)
          .eq('recipe_name', identifier.trim());
    } catch (_) {}
  }
}
