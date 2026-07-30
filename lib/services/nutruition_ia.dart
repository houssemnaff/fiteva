import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/nutrition/models.dart';

/// Erreur levée quand l'analyse IA d'une photo de nourriture échoue
/// (réseau, clé API absente, réponse invalide, etc.).
class NutritionIaException implements Exception {
  final String message;
  NutritionIaException(this.message);

  @override
  String toString() => message;
}

/// Envoie une photo de nourriture à un modèle vision via OpenRouter et
/// retourne un [FoodItem] structuré de la même façon que les aliments de
/// [FoodDatabase] — utilisable directement dans le panier de
/// AjoutRapideScreen (recherche, manuel, scanner).
class NutritionIaService {
  NutritionIaService._();

  // ───────────────────────────────────────────────────────────────────────
  // TODO: remplir avec une vraie clé API OpenRouter avant de mettre en prod.
  // Génère une clé sur https://openrouter.ai/keys
  // ───────────────────────────────────────────────────────────────────────
  static const String _apiKey = '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';

  // Modèle vision capable de sortie JSON structurée (pas un modèle de rerank —
  // nvidia/llama-nemotron-rerank-vl-1b-v2 ne fonctionne pas sur /chat/completions).
  // gemini-2.0-flash-001 a été retiré du routage OpenRouter (404 "No endpoints
  // found") — gemini-2.5-flash est le modèle vision actif équivalent.
  static const String _model = 'google/gemini-2.5-flash';

  static final Uri _endpoint =
      Uri.parse('https://openrouter.ai/api/v1/chat/completions');

  static const String _prompt = '''
Tu es un nutritionniste expert. Analyse cette photo de nourriture et identifie
TOUS les aliments/plats distincts visibles — pas seulement celui qui domine
visuellement. Par exemple, une assiette avec un poulet ET du riz ET des
légumes doit produire TROIS entrées séparées dans "items", pas une seule.
Si un seul aliment est visible, renvoie un tableau "items" avec une seule entrée.

Pour chaque aliment détecté, réponds avec les champs demandés par le schéma :
- name : nom court et clair de l'aliment/plat, en français.
- category : catégorie la plus proche parmi la liste fournie.
- kcal, protein, carbs, fat, fiber : valeurs nutritionnelles estimées
  POUR 100 GRAMMES de cet aliment (pas pour la portion visible).
- grams : poids estimé de la portion visible sur la photo, en grammes.
- portion_label : courte description de la portion (ex. "1 assiette", "1 bol").

Base tes estimations sur des valeurs nutritionnelles réalistes.
''';

  static const List<String> _categoryValues = [
    'viandes', 'poissons', 'oeufslaitiers', 'cereales', 'legumineuses',
    'legumes', 'fruits', 'oleagineux', 'corpsGras', 'platCompose',
    'boissons', 'desserts',
  ];

  static final Map<String, dynamic> _foodItemSchema = {
    'type': 'object',
    'properties': {
      'name':          {'type': 'string'},
      'category':      {'type': 'string', 'enum': _categoryValues},
      'kcal':          {'type': 'number'},
      'protein':       {'type': 'number'},
      'carbs':         {'type': 'number'},
      'fat':           {'type': 'number'},
      'fiber':         {'type': 'number'},
      'grams':         {'type': 'number'},
      'portion_label': {'type': 'string'},
    },
    'required': [
      'name', 'category', 'kcal', 'protein', 'carbs', 'fat',
      'fiber', 'grams', 'portion_label',
    ],
    'additionalProperties': false,
  };

  static final Map<String, dynamic> _jsonSchema = {
    'name': 'food_items',
    'strict': true,
    'schema': {
      'type': 'object',
      'properties': {
        'items': {
          'type': 'array',
          'items': _foodItemSchema,
        },
      },
      'required': ['items'],
      'additionalProperties': false,
    },
  };

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
    if (_apiKey.isEmpty || _apiKey == 'YOUR_OPENROUTER_API_KEY') {
      throw NutritionIaException(
          'Clé API OpenRouter manquante — configure NutritionIaService._apiKey.');
    }

    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';

    final body = jsonEncode({
      'model': _model,
      // Cap la sortie — le JSON attendu est court, et sans cette limite
      // le modèle réserve jusqu'à 65k tokens de budget (402 "insufficient credits").
      'max_tokens': 200,
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': _prompt},
            {
              'type': 'image_url',
              'image_url': {'url': dataUrl},
            },
          ],
        },
      ],
      'response_format': {
        'type': 'json_schema',
        'json_schema': _jsonSchema,
      },
    });

    http.Response response;
    try {
      response = await http
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://fiteva.app',
              'X-Title': 'FitEva',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw NutritionIaException('Erreur réseau pendant l\'analyse : $e');
    }

    if (response.statusCode != 200) {
      throw NutritionIaException(
          'Échec de l\'analyse IA (${response.statusCode}) : ${response.body}');
    }

    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw NutritionIaException('Réponse IA illisible : $e');
    }

    final text = _extractContent(decoded);
    if (text == null || text.isEmpty) {
      throw NutritionIaException('Aucun résultat renvoyé par l\'IA.');
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      throw NutritionIaException('Format de résultat IA invalide : $e');
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

  static String? _extractContent(Map<String, dynamic> decoded) {
    final choices = decoded['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;
    final message = choices.first['message'] as Map<String, dynamic>?;
    return message?['content'] as String?;
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
