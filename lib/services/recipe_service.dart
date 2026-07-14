import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_config.dart';

// ── Recipe author model ─────────────────────────────────────────────────────
class RecipeAuthor {
  final String id;
  final String username;
  final String avatarSeed;
  final String avatarStyle;
  final String avatarBgColor;

  const RecipeAuthor({
    required this.id,
    required this.username,
    this.avatarSeed = '',
    this.avatarStyle = 'lorelei',
    this.avatarBgColor = '#E0F2F1',
  });

  factory RecipeAuthor.fromJson(Map<String, dynamic> json) {
    return RecipeAuthor(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatarSeed: json['avatar_seed'] as String? ?? '',
      avatarStyle: json['avatar_style'] as String? ?? 'lorelei',
      avatarBgColor: json['avatar_bg_color'] as String? ?? '#E0F2F1',
    );
  }
}

// ── Full recipe model from Supabase ─────────────────────────────────────────
class AppRecipe {
  final String id;
  final String? userId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? videoUrl;
  final String duration;
  final String difficulty;
  final int kcal, proteins, carbs, fat, servings;
  final String category;
  final List<String> tags;
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> steps;
  final String phase;
  final bool isFeatured;
  final DateTime createdAt;
  final RecipeAuthor? author;

  const AppRecipe({
    required this.id,
    this.userId,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.videoUrl,
    this.duration = '',
    this.difficulty = 'Facile',
    this.kcal = 0,
    this.proteins = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servings = 1,
    this.category = 'general',
    this.phase = 'all',
    this.tags = const [],
    this.ingredients = const [],
    this.steps = const [],
    this.isFeatured = false,
    required this.createdAt,
    this.author,
  });

  factory AppRecipe.fromJson(Map<String, dynamic> json) {
    final authorData = json['user_profiles'] as Map<String, dynamic>?;

    return AppRecipe(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      videoUrl: json['video_url'] as String?,
      duration: json['duration'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Facile',
      kcal: json['kcal'] as int? ?? 0,
      proteins: json['proteins'] as int? ?? 0,
      carbs: json['carbs'] as int? ?? 0,
      fat: json['fat'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      category: json['category'] as String? ?? 'general',
      phase: json['phase'] as String? ?? 'all',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      ingredients: (json['ingredients'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      steps: (json['steps'] as List?)?.cast<Map<String, dynamic>>() ?? [],
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      author: authorData != null ? RecipeAuthor.fromJson(authorData) : null,
    );
  }
}

// ── Riverpod providers ──────────────────────────────────────────────────────
final appRecipesProvider = FutureProvider<List<AppRecipe>>((ref) async {
  return RecipeService.fetchAppRecipes();
});

final authorRecipesProvider = FutureProvider.family<List<AppRecipe>, String>((ref, userId) async {
  return RecipeService.fetchRecipesByUser(userId);
});

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

  // ── New recipes table methods ─────────────────────────────────────────────

  static Future<List<AppRecipe>> fetchAppRecipes() async {
    try {
      final rows = await SupabaseConfig.table('recipes')
          .select('*')
          .order('created_at', ascending: false) as List;
      return rows
          .cast<Map<String, dynamic>>()
          .map((r) => AppRecipe.fromJson(r))
          .toList();
    } catch (e) {
      debugPrint('fetchAppRecipes error: $e');
      return [];
    }
  }

  static Future<List<AppRecipe>> fetchRecipesByUser(String userId) async {
    try {
      final rows = await SupabaseConfig.table('recipes')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false) as List;
      return rows
          .cast<Map<String, dynamic>>()
          .map((r) => AppRecipe.fromJson(r))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<AppRecipe>> fetchRecipesByPhase(String phase) async {
    try {
      final rows = await SupabaseConfig.table('recipes')
          .select('*')
          .or('phase.eq.$phase,phase.eq.all')
          .order('created_at', ascending: false) as List;
      return rows
          .cast<Map<String, dynamic>>()
          .map((r) => AppRecipe.fromJson(r))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<AppRecipe>> fetchFeaturedRecipes() async {
    try {
      final rows = await SupabaseConfig.table('recipes')
          .select('*')
          .eq('is_featured', true)
          .order('created_at', ascending: false) as List;
      return rows
          .cast<Map<String, dynamic>>()
          .map((r) => AppRecipe.fromJson(r))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<AppRecipe?> fetchAppRecipeById(String id) async {
    try {
      final row = await SupabaseConfig.table('recipes')
          .select('*')
          .eq('id', id)
          .maybeSingle();
      if (row == null) return null;
      return AppRecipe.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  static Future<RecipeAuthor?> fetchAuthor(String userId) async {
    try {
      final row = await SupabaseConfig.table('user_profiles')
          .select('id, username, avatar_seed, avatar_style, avatar_bg_color')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return RecipeAuthor.fromJson(row);
    } catch (_) {
      return null;
    }
  }
}
