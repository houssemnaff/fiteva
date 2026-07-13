import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiteva/core/nutrition/models.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  Open Food Facts API — free, unlimited, no API key
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
