import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiteva/core/nutrition/models.dart';
import 'recipe_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Spoonacular Recipe API + Open Food Facts ingredient search
//  All results cached locally — API is only called when cache is empty/expired.
// ══════════════════════════════════════════════════════════════════════════════

const _spoonApiKey = '05e7337ed1ee4d8a8a7e97ee48594678';
const _spoonBase = 'https://api.spoonacular.com';
const _cacheDuration = Duration(hours: 24);

final spoonRecipesProvider = FutureProvider.family<List<AppRecipe>, String>((ref, query) async {
  return SpoonacularRecipeApi.searchRecipes(query);
});

final spoonRandomRecipesProvider = FutureProvider<List<AppRecipe>>((ref) async {
  return SpoonacularRecipeApi.getRandomRecipes();
});

final spoonRecipesByDietProvider = FutureProvider.family<List<AppRecipe>, String>((ref, diet) async {
  return SpoonacularRecipeApi.searchRecipes('', diet: diet);
});

// ── Local cache helper ──────────────────────────────────────────────────────
class _SpoonCache {
  static Future<List<Map<String, dynamic>>?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('spoon_$key');
    final ts = prefs.getInt('spoon_ts_$key') ?? 0;
    if (raw == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    if (age > _cacheDuration.inMilliseconds) return null;
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  static Future<void> write(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spoon_$key', jsonEncode(data));
    await prefs.setInt('spoon_ts_$key', DateTime.now().millisecondsSinceEpoch);
  }
}

class SpoonacularRecipeApi {
  static Future<List<AppRecipe>> searchRecipes(
    String query, {
    int number = 10,
    String? diet,
    String? cuisine,
    int? maxCalories,
  }) async {
    final cacheKey = 'search_${query}_${diet ?? ''}_${cuisine ?? ''}_$maxCalories';
    final cached = await _SpoonCache.read(cacheKey);
    if (cached != null) {
      return cached.map((r) => _mapToAppRecipe(r)).toList();
    }

    final params = <String, String>{
      'apiKey': _spoonApiKey,
      'number': '$number',
      'addRecipeNutrition': 'true',
      'addRecipeInstructions': 'true',
      'fillIngredients': 'true',
      'instructionsRequired': 'true',
    };
    if (query.isNotEmpty) params['query'] = query;
    if (diet != null) params['diet'] = diet;
    if (cuisine != null) params['cuisine'] = cuisine;
    if (maxCalories != null) params['maxCalories'] = '$maxCalories';

    final uri = Uri.parse('$_spoonBase/recipes/complexSearch').replace(queryParameters: params);

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        debugPrint('Spoonacular search error: ${res.statusCode}');
        return [];
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List? ?? []).cast<Map<String, dynamic>>();
      await _SpoonCache.write(cacheKey, results);
      return results.map((r) => _mapToAppRecipe(r)).toList();
    } catch (e) {
      debugPrint('Spoonacular search error: $e');
      return [];
    }
  }

  static Future<List<AppRecipe>> getRandomRecipes({int number = 10, String? tags}) async {
    final cacheKey = 'random_${tags ?? 'all'}';
    final cached = await _SpoonCache.read(cacheKey);
    if (cached != null) {
      return cached.map((r) => _mapToAppRecipe(r)).toList();
    }

    final params = <String, String>{
      'apiKey': _spoonApiKey,
      'number': '$number',
    };
    if (tags != null) params['tags'] = tags;

    final uri = Uri.parse('$_spoonBase/recipes/random').replace(queryParameters: params);

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final recipes = (data['recipes'] as List? ?? []).cast<Map<String, dynamic>>();
      await _SpoonCache.write(cacheKey, recipes);
      return recipes.map((r) => _mapToAppRecipe(r)).toList();
    } catch (e) {
      debugPrint('Spoonacular random error: $e');
      return [];
    }
  }

  static Future<AppRecipe?> getRecipeById(int id) async {
    final cacheKey = 'recipe_$id';
    final cached = await _SpoonCache.read(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      return _mapToAppRecipe(cached.first);
    }

    final uri = Uri.parse('$_spoonBase/recipes/$id/information').replace(
      queryParameters: {
        'apiKey': _spoonApiKey,
        'includeNutrition': 'true',
      },
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _SpoonCache.write(cacheKey, [data]);
      return _mapToAppRecipe(data);
    } catch (e) {
      debugPrint('Spoonacular getById error: $e');
      return null;
    }
  }

  static String _resolveImage(Map<String, dynamic> json) {
    final img = json['image'] as String? ?? '';
    if (img.isEmpty) return '';
    if (img.startsWith('http')) return img;
    final id = json['id'];
    return 'https://spoonacular.com/recipeImages/$id-556x370.jpg';
  }

  static AppRecipe _mapToAppRecipe(Map<String, dynamic> json) {
    final nutrition = json['nutrition'] as Map<String, dynamic>? ?? {};
    final nutrients = nutrition['nutrients'] as List? ?? [];

    double findNutrient(String name) {
      for (final n in nutrients) {
        if ((n as Map<String, dynamic>)['name'] == name) {
          return (n['amount'] as num?)?.toDouble() ?? 0;
        }
      }
      return 0;
    }

    final extIngredients = json['extendedIngredients'] as List? ?? [];
    final ingredients = extIngredients.map<Map<String, dynamic>>((ing) {
      final i = ing as Map<String, dynamic>;
      return {
        'name': i['name'] ?? '',
        'qty': '${i['amount'] ?? ''} ${i['unit'] ?? ''}'.trim(),
        'kcal': 0,
      };
    }).toList();

    final instructions = json['analyzedInstructions'] as List? ?? [];
    final steps = <Map<String, dynamic>>[];
    if (instructions.isNotEmpty) {
      final stepsRaw = (instructions[0] as Map<String, dynamic>)['steps'] as List? ?? [];
      for (final s in stepsRaw) {
        final step = s as Map<String, dynamic>;
        steps.add({
          'number': step['number'] ?? (steps.length + 1),
          'title': 'Étape ${step['number']}',
          'description': step['step'] ?? '',
        });
      }
    }

    final tags = <String>[];
    if (json['vegetarian'] == true) tags.add('Végétarien');
    if (json['vegan'] == true) tags.add('Végan');
    if (json['glutenFree'] == true) tags.add('Sans gluten');
    if (json['dairyFree'] == true) tags.add('Sans lactose');
    if (json['veryHealthy'] == true) tags.add('Healthy');

    final readyMin = json['readyInMinutes'] as int? ?? 0;

    String difficulty;
    if (readyMin <= 15) {
      difficulty = 'Facile';
    } else if (readyMin <= 40) {
      difficulty = 'Moyen';
    } else {
      difficulty = 'Difficile';
    }

    return AppRecipe(
      id: 'spoon_${json['id']}',
      title: json['title'] as String? ?? '',
      subtitle: (json['sourceName'] as String?) ?? '',
      imageUrl: _resolveImage(json),
      duration: '$readyMin min',
      difficulty: difficulty,
      kcal: findNutrient('Calories').round(),
      proteins: findNutrient('Protein').round(),
      carbs: findNutrient('Carbohydrates').round(),
      fat: findNutrient('Fat').round(),
      servings: json['servings'] as int? ?? 1,
      category: _guessRecipeCategory(json),
      tags: tags,
      ingredients: ingredients,
      steps: steps,
      isFeatured: json['veryPopular'] == true,
      createdAt: DateTime.now(),
    );
  }

  static String _guessRecipeCategory(Map<String, dynamic> json) {
    final dishTypes = json['dishTypes'] as List? ?? [];
    for (final d in dishTypes) {
      final t = (d as String).toLowerCase();
      if (t.contains('breakfast') || t.contains('morning')) return 'breakfast';
      if (t.contains('lunch') || t.contains('main')) return 'lunch';
      if (t.contains('dinner') || t.contains('supper')) return 'dinner';
      if (t.contains('snack') || t.contains('appetizer')) return 'snack';
      if (t.contains('dessert') || t.contains('sweet')) return 'dessert';
      if (t.contains('salad')) return 'salad';
      if (t.contains('soup')) return 'soup';
      if (t.contains('drink') || t.contains('beverage') || t.contains('smoothie')) return 'smoothie';
    }
    return 'general';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  Open Food Facts API — free, unlimited, no API key (ingredient search)
// ══════════════════════════════════════════════════════════════════════════════

class SpoonacularService {
  static const _searchBase = 'https://world.openfoodfacts.org/cgi/search.pl';
  static const _barcodeBase = 'https://world.openfoodfacts.org/api/v2/product';

  static final Map<String, String> _imageCache = {};

  static Future<String?> getImageForName(String foodName) async {
    if (_imageCache.containsKey(foodName)) return _imageCache[foodName];
    final results = await searchIngredients(foodName, number: 1);
    if (results.isEmpty || results.first.image.isEmpty) return null;
    final url = results.first.image;
    _imageCache[foodName] = url;
    return url;
  }

  // ── Search ingredients ───────────────────────────────────────────────────

  static Future<List<SpoonIngredient>> searchIngredients(
    String query, {
    int number = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_searchBase).replace(
      queryParameters: {
        'search_terms': query,
        'search_simple': '1',
        'action': 'process',
        'json': 'true',
        'page_size': '$number',
        'fields': 'code,product_name,image_front_small_url,image_front_url,brands,categories_tags,nutriments',
      },
    );

    final res = await http.get(uri, headers: {
      'User-Agent': 'Fiteva/1.0 (balkischachia12@gmail.com)',
    });

    if (res.statusCode != 200) {
      throw Exception('API error: ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final products = data['products'] as List? ?? [];

    return products
        .map((p) => SpoonIngredient.fromOpenFoodFacts(p as Map<String, dynamic>))
        .where((i) => i.name.isNotEmpty)
        .toList();
  }

  // ── Barcode lookup ───────────────────────────────────────────────────────

  static Future<SpoonIngredient?> getByBarcode(String barcode) async {
    final uri = Uri.parse('$_barcodeBase/$barcode.json');

    final res = await http.get(uri, headers: {
      'User-Agent': 'Fiteva/1.0 (balkischachia12@gmail.com)',
    });

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] != 1) return null;

    final product = data['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    return SpoonIngredient.fromOpenFoodFacts(product);
  }

  // ── Convert to FoodItem ──────────────────────────────────────────────────

  static FoodItem toFoodItem(SpoonIngredient ingredient) {
    return FoodItem(
      id: 'off_${ingredient.id}',
      name: ingredient.name,
      category: _guessCategory(ingredient.aisle),
      kcal: ingredient.kcal,
      protein: ingredient.protein,
      carbs: ingredient.carbs,
      fat: ingredient.fat,
      fiber: ingredient.fiber,
      defaultGrams: 100,
      portionLabel: '100 g',
    );
  }

  static FoodCategory _guessCategory(String categories) {
    final c = categories.toLowerCase();
    if (c.contains('meat') || c.contains('viande') || c.contains('poulet') || c.contains('boeuf')) return FoodCategory.viandes;
    if (c.contains('fish') || c.contains('poisson') || c.contains('seafood')) return FoodCategory.poissons;
    if (c.contains('dairy') || c.contains('lait') || c.contains('fromage') || c.contains('yogurt') || c.contains('yaourt') || c.contains('egg') || c.contains('oeuf')) return FoodCategory.oeufslaitiers;
    if (c.contains('cereal') || c.contains('bread') || c.contains('pain') || c.contains('pasta') || c.contains('rice') || c.contains('riz')) return FoodCategory.cereales;
    if (c.contains('legume') || c.contains('bean') || c.contains('lentil') || c.contains('tofu')) return FoodCategory.legumineuses;
    if (c.contains('vegetable') || c.contains('légume')) return FoodCategory.legumes;
    if (c.contains('fruit')) return FoodCategory.fruits;
    if (c.contains('nut') || c.contains('seed') || c.contains('noix')) return FoodCategory.oleagineux;
    if (c.contains('oil') || c.contains('huile') || c.contains('butter') || c.contains('beurre')) return FoodCategory.corpsGras;
    if (c.contains('beverage') || c.contains('drink') || c.contains('boisson') || c.contains('juice') || c.contains('jus')) return FoodCategory.boissons;
    if (c.contains('dessert') || c.contains('chocolate') || c.contains('chocolat') || c.contains('sweet') || c.contains('sucr')) return FoodCategory.desserts;
    return FoodCategory.platCompose;
  }
}

// ── Ingredient model (works with Open Food Facts) ────────────────────────────
class SpoonIngredient {
  final String id;
  final String name;
  final String image;
  final String brand;
  final String aisle;
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  const SpoonIngredient({
    required this.id,
    required this.name,
    required this.image,
    this.brand = '',
    this.aisle = '',
    this.kcal = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
  });

  String get imageUrl => image;

  factory SpoonIngredient.fromOpenFoodFacts(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    return SpoonIngredient(
      id: json['code'] as String? ?? json['_id'] as String? ?? '',
      name: _cleanName(json['product_name'] as String? ?? ''),
      image: json['image_front_small_url'] as String? ??
             json['image_front_url'] as String? ?? '',
      brand: json['brands'] as String? ?? '',
      aisle: (json['categories_tags'] as List?)?.join(',') ?? '',
      kcal: _num(nutriments, 'energy-kcal_100g'),
      protein: _num(nutriments, 'proteins_100g'),
      carbs: _num(nutriments, 'carbohydrates_100g'),
      fat: _num(nutriments, 'fat_100g'),
      fiber: _num(nutriments, 'fiber_100g'),
    );
  }

  static double _num(Map<String, dynamic> m, String key) =>
      (m[key] as num?)?.toDouble() ?? 0.0;

  static String _cleanName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
