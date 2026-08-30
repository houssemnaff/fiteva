import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/nutrition/models.dart';
import 'supabase_config.dart';

/// Erreur levée quand l'analyse IA d'une photo de nourriture échoue
/// (réseau, authentification absente, réponse invalide, etc.).
class NutritionIaException implements Exception {
  final String message;
  NutritionIaException(this.message);

  @override
  String toString() => message;
}

/// Envoie une photo de nourriture à l'edge function Supabase
/// `analyze-food-image` (qui appelle un modèle vision via OpenRouter côté
/// serveur — la clé API n'est jamais exposée au client) et retourne un
/// [FoodItem] structuré de la même façon que les aliments de [FoodDatabase]
/// — utilisable directement dans le panier de AjoutRapideScreen (recherche,
/// manuel, scanner).
class NutritionIaService {
  NutritionIaService._();

  static const String _functionName = 'analyze-food-image';

  /// Analyse une photo de nourriture depuis un fichier local
  /// (typiquement issu de `image_picker`). Retourne un aliment par plat
  /// distinct détecté sur la photo (ex. poulet + riz + légumes → 3 entrées).
  static Future<List<FoodItem>> analyzeFoodImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final mimeType = _mimeTypeFor(imageFile.path);
    return analyzeFoodImageBytes(bytes, mimeType: mimeType);
  }

  /// Analyse une photo de nourriture à partir de ses bytes bruts. Retourne
  /// un [FoodItem] par plat/aliment distinct détecté — une photo avec
  /// plusieurs aliments (ex. poulet + riz) renvoie plusieurs entrées au lieu
  /// de n'en choisir qu'une seule arbitrairement.
  static Future<List<FoodItem>> analyzeFoodImageBytes(
    Uint8List bytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (SupabaseConfig.currentUser == null) {
      throw NutritionIaException(
          'Utilisateur non authentifié — connecte-toi avant d\'analyser une photo.');
    }

    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

    FunctionResponse response;
    try {
      response = await SupabaseConfig.client.functions
          .invoke(_functionName, body: {'image': dataUrl})
          .timeout(const Duration(seconds: 30));
    } on FunctionException catch (e) {
      final message = (e.details is Map)
          ? (e.details as Map)['error']?.toString()
          : e.details?.toString();
      throw NutritionIaException(
          'Échec de l\'analyse IA (${e.status}) : ${message ?? e.reasonPhrase}');
    } catch (e) {
      throw NutritionIaException('Erreur réseau pendant l\'analyse : $e');
    }

    final data = response.data;
    if (data is! Map) {
      throw NutritionIaException('Réponse IA illisible.');
    }

    final items = data['items'] as List?;
    if (items == null || items.isEmpty) {
      throw NutritionIaException('Aucun aliment détecté sur cette photo.');
    }
    // L'index est ajouté à l'id : plusieurs aliments d'un même scan peuvent
    // être traités dans la même microseconde, ce qui produirait sinon des
    // ids identiques (et un dédoublonnage par id dans le panier écraserait
    // silencieusement un des aliments détectés).
    return items
        .asMap()
        .entries
        .map((e) => _foodItemFromAi(e.value as Map<String, dynamic>, e.key))
        .toList();
  }

  static FoodItem _foodItemFromAi(Map<String, dynamic> data, [int index = 0]) {
    final category = FoodCategory.values.firstWhere(
      (c) => c.name == (data['category'] as String? ?? ''),
      orElse: () => FoodCategory.platCompose,
    );
    final grams = (data['grams'] as num?)?.toDouble() ?? 100;

    return FoodItem(
      id:           'ai_${DateTime.now().microsecondsSinceEpoch}_$index',
      name:         data['name'] as String? ?? 'Aliment scanné',
      category:     category,
      kcal:         (data['kcal'] as num?)?.toDouble() ?? 0,
      protein:      (data['protein'] as num?)?.toDouble() ?? 0,
      carbs:        (data['carbs'] as num?)?.toDouble() ?? 0,
      fat:          (data['fat'] as num?)?.toDouble() ?? 0,
      fiber:        (data['fiber'] as num?)?.toDouble() ?? 0,
      defaultGrams: grams > 0 ? grams : 100,
      portionLabel: (data['portion_label'] as String?)?.isNotEmpty == true
          ? data['portion_label'] as String
          : '${grams.round()} g',
    );
  }

  static String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}
