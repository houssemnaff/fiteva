// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fiteva/core/nutrition/food_database.dart';
import 'package:fiteva/core/nutrition/models.dart';
import 'package:fiteva/core/nutrition/nutrition_provider.dart' show generateMealId, userProfileProvider;
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/services/nutruition_ia.dart';
import 'package:fiteva/services/spoonacular_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../l10n/lang.dart';
import '../../l10n/app_localizations.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
Color _kGreen(BuildContext c) => Theme.of(c).colorScheme.primary;
const _kMint    = Color(0xFF7ABB98);
const _kMintBg  = Color(0xFFEAF3EC);
const _kCream   = Color(0xFFFAFAF8);
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF6B7280);
const _kSurface = Colors.white;

// ── Spoonacular CDN image mapping ─────────────────────────────────────────────
const _kSpoonBase = 'https://spoonacular.com/cdn/ingredients_250x250/';
const _foodImage = <String, String>{
  'chicken_breast': 'chicken-breasts.png',
  'chicken_thigh': 'chicken-thigh.jpg',
  'turkey_breast': 'turkey-breast.jpg',
  'beef_lean': 'fresh-ground-beef.jpg',
  'beef_steak': 'beef-steak.jpg',
  'pork_tenderloin': 'pork-tenderloin-raw.jpg',
  'lamb_leg': 'lamb-leg.jpg',
  'ham_cooked': 'ham-whole.jpg',
  'chorizo': 'chorizo.jpg',
  'salmon': 'salmon.png',
  'tuna_canned': 'canned-tuna.png',
  'cod': 'cod-fillet.jpg',
  'trout': 'trout.jpg',
  'sardines': 'sardines-canned.jpg',
  'shrimp': 'shrimp.png',
  'mussels': 'mussels.jpg',
  'mackerel': 'mackerel.jpg',
  'egg_whole': 'egg.png',
  'egg_white': 'egg-white.jpg',
  'greek_yogurt': 'greek-yogurt.jpg',
  'yogurt_nature': 'plain-yogurt.jpg',
  'cottage_cheese': 'cottage-cheese.jpg',
  'milk_skimmed': 'milk.png',
  'milk_whole': 'milk.png',
  'cheddar': 'cheddar-cheese.png',
  'mozzarella': 'mozzarella.png',
  'parmesan': 'parmesan.jpg',
  'feta': 'feta.png',
  'rice_white': 'uncooked-white-rice.png',
  'rice_brown': 'brown-rice.png',
  'quinoa': 'uncooked-quinoa.png',
  'pasta_cooked': 'pasta.jpg',
  'pasta_ww': 'whole-wheat-spaghetti.jpg',
  'oats': 'rolled-oats.jpg',
  'bread_whole': 'whole-wheat-bread.jpg',
  'bread_white': 'french-bread.jpg',
  'sweet_potato': 'sweet-potato.png',
  'potato': 'potatoes-yukon-background.png',
  'couscous': 'couscous.png',
  'corn': 'corn.png',
  'granola': 'granola.jpg',
  'lentils': 'lentils-brown.jpg',
  'chickpeas': 'chickpeas.png',
  'black_beans': 'black-beans.jpg',
  'white_beans': 'cannellini-beans.jpg',
  'edamame': 'edamame.png',
  'tofu': 'tofu.png',
  'hummus': 'hummus.png',
  'spinach': 'spinach.jpg',
  'broccoli': 'broccoli.jpg',
  'carrots': 'sliced-carrots.png',
  'tomato': 'tomato.png',
  'cucumber': 'cucumber.jpg',
  'bell_pepper': 'red-pepper.jpg',
  'zucchini': 'zucchini.jpg',
  'eggplant': 'eggplant.png',
  'onion': 'brown-onion.png',
  'garlic': 'garlic.png',
  'mushroom': 'mushrooms-white.jpg',
  'lettuce': 'iceberg-lettuce.jpg',
  'cauliflower': 'cauliflower.jpg',
  'green_beans': 'green-beans-background.jpg',
  'apple': 'apple.jpg',
  'banana': 'bananas.jpg',
  'orange': 'orange.png',
  'avocado': 'avocado.jpg',
  'strawberry': 'strawberries.png',
  'blueberry': 'blueberries.jpg',
  'mango': 'mango.jpg',
  'pineapple': 'pineapple.jpg',
  'grapes': 'red-grapes.jpg',
  'kiwi': 'kiwi.png',
  'watermelon': 'watermelon.jpg',
  'dates': 'dates.jpg',
  'almonds': 'almonds.jpg',
  'walnuts': 'walnuts.jpg',
  'cashews': 'cashews.jpg',
  'peanuts': 'peanuts.png',
  'peanut_butter': 'peanut-butter.png',
  'almond_butter': 'almond-butter.jpg',
  'chia_seeds': 'chia-seeds.jpg',
  'flaxseeds': 'flax-seeds.png',
  'pumpkin_seeds': 'pumpkin-seeds.jpg',
  'olive_oil': 'olive-oil.jpg',
  'butter': 'butter-sliced.jpg',
  'coconut_oil': 'coconut-oil.jpg',
  'avocado_oil': 'vegetable-oil.jpg',
  'caesar_salad': 'caesar-salad.png',
  'chicken_rice_bowl': 'chicken-breast.png',
  'protein_smoothie': 'berry-smoothie.jpg',
  'overnight_oats': 'rolled-oats.jpg',
  'veggie_wrap': 'flour-tortilla.jpg',
  'pasta_bolognese': 'pasta.jpg',
  'vegetable_soup': 'mixed-vegetables.png',
  'water': 'water.png',
  'coffee_black': 'brewed-coffee.jpg',
  'orange_juice': 'orange-juice.jpg',
  'almond_milk': 'almond-milk.png',
  'oat_milk': 'milk.png',
  'green_tea': 'green-tea-bags.jpg',
  'dark_chocolate': 'dark-chocolate-pieces.jpg',
  'honey': 'honey.png',
  'rice_cake': 'rice-cakes.jpg',
  'protein_bar': 'protein-bar.jpg',
  'whey_protein': 'protein-powder.jpg',
};

String _foodImageUrl(String foodId) =>
    '$_kSpoonBase${_foodImage[foodId] ?? 'mixed-vegetables.png'}';

Widget _foodFallbackIcon(FoodCategory cat) => Container(
  color: _catColor(cat).withOpacity(0.10),
  child: Icon(_catIcon(cat), size: 20, color: _catColor(cat)));

// ── Food units ────────────────────────────────────────────────────────────────
enum FoodUnit { g, kg, ml, cup, tbsp, tsp, piece }

extension FoodUnitExt on FoodUnit {
  String get label => labelFor(Lang.code);

  String labelFor(String lang) {
    final l10n = AppL10n(lang);
    return switch (this) {
      FoodUnit.g     => 'g',
      FoodUnit.kg    => 'kg',
      FoodUnit.ml    => 'ml',
      FoodUnit.cup   => 'cup',
      FoodUnit.tbsp  => l10n.unitTbsp,
      FoodUnit.tsp   => l10n.unitTsp,
      FoodUnit.piece => l10n.unitPiece,
    };
  }

  String get shortLabel => switch (this) {
    FoodUnit.g     => 'g',
    FoodUnit.kg    => 'kg',
    FoodUnit.ml    => 'ml',
    FoodUnit.cup   => 'cup',
    FoodUnit.tbsp  => 'tbsp',
    FoodUnit.tsp   => 'tsp',
    FoodUnit.piece => 'pce',
  };

  double toGrams(double amount, {double pieceGrams = 100}) => switch (this) {
    FoodUnit.g     => amount,
    FoodUnit.kg    => amount * 1000,
    FoodUnit.ml    => amount,
    FoodUnit.cup   => amount * 240,
    FoodUnit.tbsp  => amount * 15,
    FoodUnit.tsp   => amount * 5,
    FoodUnit.piece => amount * pieceGrams,
  };

  double defaultAmount(double grams, {double pieceGrams = 100}) => switch (this) {
    FoodUnit.g     => grams,
    FoodUnit.kg    => grams / 1000,
    FoodUnit.ml    => grams,
    FoodUnit.cup   => grams / 240,
    FoodUnit.tbsp  => grams / 15,
    FoodUnit.tsp   => grams / 5,
    FoodUnit.piece => (pieceGrams > 0 ? grams / pieceGrams : 1),
  };
}

// ── Category icon & color ─────────────────────────────────────────────────────
IconData _catIcon(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => LucideIcons.drumstick,
  FoodCategory.poissons     => LucideIcons.fish,
  FoodCategory.oeufslaitiers=> LucideIcons.egg,
  FoodCategory.cereales     => LucideIcons.wheat,
  FoodCategory.legumineuses => LucideIcons.leaf,
  FoodCategory.legumes      => LucideIcons.salad,
  FoodCategory.fruits       => LucideIcons.apple,
  FoodCategory.oleagineux   => LucideIcons.nut,
  FoodCategory.corpsGras    => LucideIcons.droplets,
  FoodCategory.platCompose  => LucideIcons.utensils,
  FoodCategory.boissons     => LucideIcons.glassWater,
  FoodCategory.desserts     => LucideIcons.cookie,
};

// Palette harmonisée (tons rompus, même famille de saturation) — remplace
// l'ancienne palette arc-en-ciel (rouge vif, bleu vif, jaune vif…) qui
// jurait avec le reste de l'app.
Color _catColor(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => const Color(0xFFC0725A),
  FoodCategory.poissons     => const Color(0xFF4C8C93),
  FoodCategory.oeufslaitiers=> const Color(0xFFB8892F),
  FoodCategory.cereales     => const Color(0xFFA07A52),
  FoodCategory.legumineuses => const Color(0xFF7A8B4F),
  FoodCategory.legumes      => const Color(0xFF4F8060),
  FoodCategory.fruits       => const Color(0xFFC97B84),
  FoodCategory.oleagineux   => const Color(0xFFB08256),
  FoodCategory.corpsGras    => const Color(0xFFBFA35A),
  FoodCategory.platCompose  => const Color(0xFF5F9C7C),
  FoodCategory.boissons     => const Color(0xFF5A7A9E),
  FoodCategory.desserts     => const Color(0xFF8E7BA6),
};

String _catPhoto(FoodCategory c) => switch (c) {
  FoodCategory.viandes      => 'https://images.unsplash.com/photo-1551446591-142875a901a1?w=80&q=70&fit=crop',
  FoodCategory.poissons     => 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=80&q=70&fit=crop',
  FoodCategory.oeufslaitiers=> 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=80&q=70&fit=crop',
  FoodCategory.cereales     => 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=80&q=70&fit=crop',
  FoodCategory.legumineuses => 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=80&q=70&fit=crop',
  FoodCategory.legumes      => 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=80&q=70&fit=crop',
  FoodCategory.fruits       => 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=80&q=70&fit=crop',
  FoodCategory.oleagineux   => 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=80&q=70&fit=crop',
  FoodCategory.corpsGras    => 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=80&q=70&fit=crop',
  FoodCategory.platCompose  => 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=80&q=70&fit=crop',
  FoodCategory.boissons     => 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=80&q=70&fit=crop',
  FoodCategory.desserts     => 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=80&q=70&fit=crop',
};

// ── Scan state ────────────────────────────────────────────────────────────────
enum _ScanState { idle, loading, preview, scanning, result }

// ── Basket item ───────────────────────────────────────────────────────────────
class _BasketItem {
  final FoodItem food;
  final double grams;
  const _BasketItem(this.food, this.grams);
  int get calories => food.kcalFor(grams).round();
  int get protein  => food.proteinFor(grams).round();
  int get carbs    => food.carbsFor(grams).round();
  int get fat      => food.fatFor(grams).round();
}

// ════════════════════════════════════════════════════════════════════════════
//  SCREEN
// ════════════════════════════════════════════════════════════════════════════
class AjoutRapideScreen extends ConsumerStatefulWidget {
  final String? initialTypeId;
  // Jour auquel les repas ajoutés ici seront rattachés — par défaut
  // aujourd'hui. Sans ce paramètre, un ajout fait en consultant un jour
  // passé se retrouvait toujours enregistré sur la date du jour (bug).
  final DateTime? targetDate;
  const AjoutRapideScreen({super.key, this.initialTypeId, this.targetDate});

  @override
  ConsumerState<AjoutRapideScreen> createState() => _AjoutRapideScreenState();
}

class _AjoutRapideScreenState extends ConsumerState<AjoutRapideScreen> {
  // 0 = Recherche, 1 = Manuel, 2 = Scanner
  int _mode = 0;

  MealType? get _preselectedType =>
      widget.initialTypeId != null
          ? MealType.fromId(widget.initialTypeId!)
          : null;

  // ── Basket ───────────────────────────────────────────────────────────────
  final List<_BasketItem> _basket = [];
  int get _basketCalories => _basket.fold(0, (s, i) => s + i.calories);

  // ── Search mode ──────────────────────────────────────────────────────────
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  FoodItem? _selectedFood;
  double _selectedGrams = 100;
  FoodUnit _selectedUnit = FoodUnit.g;
  final _amountCtrl = TextEditingController(text: '100');
  FoodCategory? _activeCategory;

  // Spoonacular API search
  List<SpoonIngredient> _spoonResults = [];
  final Map<String, FoodItem> _spoonFoodCache = {};
  bool _spoonLoading = false;
  bool _spoonError = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _activeCategory = null;
    });
    _debounce?.cancel();
    if (query.length >= 2) {
      _debounce = Timer(const Duration(milliseconds: 400), () => _searchSpoonacular(query));
    } else {
      setState(() { _spoonResults = []; _spoonLoading = false; _spoonError = false; });
    }
  }

  Future<void> _searchSpoonacular(String query) async {
    if (!mounted) return;
    setState(() { _spoonLoading = true; _spoonError = false; });
    try {
      final results = await SpoonacularService.searchIngredients(query);
      if (!mounted || _searchQuery != query) return;
      setState(() {
        _spoonResults = results;
        _spoonLoading = false;
        _spoonError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _spoonLoading = false; _spoonError = true; });
    }
  }

  List<FoodItem> _localResults() {
    final allFoods = ref.read(foodItemsProvider).asData?.value ?? FoodDatabase.all;
    return FoodDatabase.searchIn(allFoods, _searchQuery);
  }

  FoodItem _resolveSpoonFood(SpoonIngredient ingredient) {
    if (_spoonFoodCache.containsKey(ingredient.id)) {
      return _spoonFoodCache[ingredient.id]!;
    }
    final food = SpoonacularService.toFoodItem(ingredient);
    _spoonFoodCache[ingredient.id] = food;
    return food;
  }

  List<FoodItem> _searchResults(List<FoodItem> allFoods) {
    if (_selectedFood != null) return [];
    if (_searchQuery.isNotEmpty) return FoodDatabase.searchIn(allFoods, _searchQuery);
    if (_activeCategory != null) return FoodDatabase.byCategoryIn(allFoods, _activeCategory!);
    return FoodDatabase.popularIn(allFoods);
  }

  // ── Scanner mode ─────────────────────────────────────────────────────────
  _ScanState        _scanState = _ScanState.idle;
  // Un ou plusieurs aliments détectés sur la photo (ex. poulet + riz +
  // légumes) — l'IA ne se limite plus au seul plat dominant visuellement.
  List<FoodItem>    _scannedFoods = [];
  Uint8List?  _pickedImageBytes;
  String?     _scanError;
  final _imagePicker = ImagePicker();

  // Picks a photo (camera or gallery) and shows it in the scan zone —
  // analysis only starts once the user taps "Analyser".
  //
  // Sur iPhone, une photo choisie depuis la galerie peut être encodée en
  // HEIC (format par défaut de l'appareil photo iOS) — un format que le
  // modèle vision ne sait pas décoder. On convertit donc systématiquement
  // en JPEG juste après la sélection. On garde le résultat en mémoire
  // (Uint8List) plutôt que d'écrire un fichier temporaire : sur iOS, iOS
  // peut purger le dossier Caches/tmp entre la sélection de la photo et
  // le tap sur "Analyser", ce qui faisait échouer l'analyse avec une
  // PathNotFoundException — garder les bytes en mémoire élimine ce risque.
  //
  // La conversion peut prendre 1-2s sur un gros fichier HEIC iPhone — sans
  // indicateur, l'écran semblait figé/ne rien faire pendant ce délai. Idem
  // en cas d'échec : l'erreur passait par un SnackBar transitoire facile à
  // manquer, ce qui donnait l'impression que "rien ne se passe" alors qu'une
  // erreur s'était bien produite. On garde maintenant l'erreur affichée en
  // permanence (bandeau) tant que l'utilisatrice ne relance pas une sélection.
  Future<void> _pickImage(ImageSource source) async {
    XFile? picked;
    try {
      picked = await _imagePicker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1600);
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanError = 'Impossible d\'ouvrir la caméra/galerie : $e');
      return;
    }
    if (picked == null) return;

    HapticFeedback.selectionClick();
    setState(() {
      _scanState = _ScanState.loading;
      _scanError = null;
    });

    Uint8List jpegBytes;
    try {
      jpegBytes = await _ensureJpegBytes(picked);
    } catch (e) {
      debugPrint('[Scan] _ensureJpegBytes FAILED: $e');
      if (!mounted) return;
      setState(() {
        _scanState = _ScanState.idle;
        _scanError = e.toString().replaceFirst('Exception: ', '');
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _scanState         = _ScanState.preview;
      _pickedImageBytes  = jpegBytes;
      _scannedFoods      = [];
    });
  }

  /// Réencode n'importe quelle photo (HEIC, PNG, WebP…) en bytes JPEG,
  /// pour garantir un format toujours supporté par l'API vision — peu
  /// importe la plateforme ou le format d'origine.
  ///
  /// Une photo ancienne avec "Optimiser le stockage" iCloud peut encore être
  /// en train de télécharger son original au moment où l'utilisatrice la
  /// choisit (le picker déclenche déjà ce téléchargement en arrière-plan) —
  /// on retente donc une deuxième fois après un court délai avant d'abandonner,
  /// plutôt que d'échouer immédiatement sur ce qui n'est souvent qu'un
  /// problème de timing.
  Future<Uint8List> _ensureJpegBytes(XFile picked) async {
    final rawBytes = await picked.readAsBytes();

    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) await Future.delayed(const Duration(milliseconds: 1500));

      // compressWithList (variante "bytes") ne décode pas toujours le HEIC
      // correctement sur iOS et peut renvoyer un résultat vide/invalide sans
      // lever d'exception — ce qui produisait un data-URL cassé envoyé à
      // l'API vision ("Invalid image data-url", 400). On détecte ce cas et on
      // retombe sur la variante fichier (compressAndGetFile), qui décode le
      // HEIC de façon fiable côté natif ; le fichier temporaire est lu en
      // mémoire immédiatement puis jeté, donc le bug précédent (fichier
      // disparu entre l'aperçu et "Analyser") ne peut pas se reproduire ici.
      try {
        final result = await FlutterImageCompress.compressWithList(
          rawBytes, quality: 88, format: CompressFormat.jpeg,
        );
        if (_isJpeg(result)) return result;
        debugPrint('[Scan] compressWithList produced non-JPEG output (${result.length} bytes)');
      } catch (e) {
        debugPrint('[Scan] compressWithList FAILED: $e');
      }

      try {
        final tmpDir = await getTemporaryDirectory();
        final tmpIn  = File('${tmpDir.path}/scan_src_${DateTime.now().microsecondsSinceEpoch}');
        await tmpIn.writeAsBytes(rawBytes);
        final outPath = '${tmpDir.path}/scan_out_${DateTime.now().microsecondsSinceEpoch}.jpg';
        final xFile = await FlutterImageCompress.compressAndGetFile(
          tmpIn.path, outPath, quality: 88, format: CompressFormat.jpeg,
        );
        await tmpIn.delete().catchError((_) => tmpIn);
        if (xFile != null) {
          final bytes = await File(xFile.path).readAsBytes();
          await File(xFile.path).delete().catchError((_) => File(xFile.path));
          if (_isJpeg(bytes)) return bytes;
          debugPrint('[Scan] compressAndGetFile produced non-JPEG output (${bytes.length} bytes)');
        }
      } catch (e) {
        debugPrint('[Scan] compressAndGetFile FAILED: $e');
      }
    }

    // Les deux méthodes de conversion ont échoué à produire un vrai JPEG,
    // même après une seconde tentative —
    // renvoyer les bytes bruts (potentiellement HEIC) donnerait un aperçu
    // correct (Flutter/iOS sait décoder le HEIC nativement) mais ferait
    // échouer l'analyse IA sans qu'on comprenne pourquoi (le mimetype
    // déclaré "image/jpeg" ne correspondrait pas au contenu réel). On lève
    // donc une erreur explicite plutôt que de laisser ce mensonge silencieux
    // se propager jusqu'à l'appel API.
    //
    // Cause la plus fréquente sur iPhone : une photo ancienne dont
    // "Optimiser le stockage" (iCloud) n'a téléchargé qu'un aperçu basse
    // résolution en local — le décodeur natif refuse alors de la traiter,
    // alors qu'une photo tout juste prise (100% locale) fonctionne. On donne
    // donc une piste actionnable plutôt qu'un message technique opaque.
    throw Exception(
      'Cette photo semble ne pas être entièrement téléchargée sur ton téléphone '
      '(souvent le cas pour une ancienne photo avec "Optimiser le stockage" activé sur iCloud). '
      'Ouvre-la en plein écran dans l\'app Photos quelques secondes en Wi-Fi, puis réessaie ici.',
    );
  }

  static bool _isJpeg(Uint8List bytes) =>
      bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;

  Future<void> _analyzeImage() async {
    final bytes = _pickedImageBytes;
    if (bytes == null) return;

    HapticFeedback.mediumImpact();
    setState(() => _scanState = _ScanState.scanning);

    try {
      final foods = await NutritionIaService.analyzeFoodImageBytes(
        bytes, mimeType: 'image/jpeg');
      if (!mounted) return;
      setState(() {
        _scanState    = _ScanState.result;
        _scannedFoods = foods;
        if (foods.length == 1) {
          // Un seul aliment détecté : on garde le flux existant
          // (pré-remplissage de la fiche détail pour ajuster la quantité).
          final food = foods.first;
          _selectedFood  = food;
          _selectedGrams = food.defaultGrams;
          _selectedUnit  = FoodUnit.g;
          _amountCtrl.text = food.defaultGrams.round().toString();
        } else {
          // Plusieurs aliments détectés : pas de fiche détail unique,
          // l'écran affiche la liste complète à ajouter d'un coup.
          _selectedFood = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanState = _ScanState.preview);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analyse impossible : $e')));
    }
  }

  // Ajoute tous les aliments détectés (mode multi-plats) au panier en une
  // fois, chacun avec son grammage estimé par l'IA — même dédoublonnage par
  // nom que _addToBasket pour éviter des lignes en double.
  void _addAllScannedToBasket(List<FoodItem> foods) {
    HapticFeedback.mediumImpact();
    setState(() {
      for (final food in foods) {
        final idx = _basket.indexWhere((b) =>
            b.food.id == food.id ||
            b.food.name.trim().toLowerCase() == food.name.trim().toLowerCase());
        if (idx != -1) {
          _basket[idx] = _BasketItem(food, food.defaultGrams);
        } else {
          _basket.add(_BasketItem(food, food.defaultGrams));
        }
      }
    });
    _resetScan();
  }

  void _resetScan() => setState(() {
    _scanState         = _ScanState.idle;
    _scannedFoods       = [];
    _pickedImageBytes  = null;
    _selectedFood      = null;
    _scanError         = null;
  });

  // ── Manual mode ──────────────────────────────────────────────────────────
  final _nameCtrl  = TextEditingController();
  final _calCtrl   = TextEditingController();
  final _protCtrl  = TextEditingController();
  final _glucCtrl  = TextEditingController();
  final _lipCtrl   = TextEditingController();

  bool get _canAddToBasket {
    if (_mode == 0) return _selectedFood != null;
    if (_mode == 1) return _nameCtrl.text.isNotEmpty && _calCtrl.text.isNotEmpty;
    return false;
  }

  bool get _canSubmit => _basket.isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose(); _amountCtrl.dispose();
    _nameCtrl.dispose(); _calCtrl.dispose();
    _protCtrl.dispose(); _glucCtrl.dispose(); _lipCtrl.dispose();
    super.dispose();
  }

  void _setUnit(FoodUnit unit) {
    final pieceGrams = _selectedFood?.defaultGrams ?? 100;
    final newAmount = unit.defaultAmount(_selectedGrams, pieceGrams: pieceGrams);
    setState(() {
      _selectedUnit = unit;
      _amountCtrl.text = newAmount < 10
          ? newAmount.toStringAsFixed(1)
          : newAmount.round().toString();
    });
  }

  void _setAmount(double amount) {
    final pieceGrams = _selectedFood?.defaultGrams ?? 100;
    setState(() {
      _selectedGrams = _selectedUnit.toGrams(amount, pieceGrams: pieceGrams);
    });
  }

  // ── Add / update basket ───────────────────────────────────────────────────
  void _addToBasket() {
    FoodItem food;
    double grams;

    if ((_mode == 0 || _mode == 2) && _selectedFood != null) {
      food  = _selectedFood!;
      grams = _selectedGrams;
      if (grams <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La quantité doit être supérieure à 0.')));
        return;
      }
    } else {
      final name    = _nameCtrl.text.trim();
      final kcal    = double.tryParse(_calCtrl.text) ?? 0;
      final protein = double.tryParse(_protCtrl.text) ?? 0;
      final carbs   = double.tryParse(_glucCtrl.text) ?? 0;
      final fat     = double.tryParse(_lipCtrl.text) ?? 0;
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le nom de l\'aliment est requis.')));
        return;
      }
      if (kcal < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les calories ne peuvent pas être négatives.')));
        return;
      }
      food = FoodItem(
        id:       generateMealId(),
        name:     name,
        category: FoodCategory.platCompose,
        kcal: kcal, protein: protein, carbs: carbs, fat: fat,
        defaultGrams: 100,
      );
      grams = 100;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      // If already in basket (editing quantity), replace instead of appending.
      // On matche aussi par nom (pas seulement par id) : les aliments saisis
      // manuellement ou scannés reçoivent un id neuf à chaque ajout
      // (generateMealId()/"ai_<timestamp>"), donc un double-tap accidentel
      // sur "Ajouter" pour le même nom créait deux lignes distinctes au lieu
      // de mettre à jour la même — contrairement à la Recherche où l'id
      // stable de la base de données évitait déjà ce doublon.
      final idx = _basket.indexWhere((b) =>
          b.food.id == food.id ||
          b.food.name.trim().toLowerCase() == food.name.trim().toLowerCase());
      if (idx != -1) {
        _basket[idx] = _BasketItem(food, grams);
      } else {
        _basket.add(_BasketItem(food, grams));
      }
      _selectedFood   = null;
      _searchQuery    = '';
      _activeCategory = null;
      _selectedGrams  = 100;
      _selectedUnit   = FoodUnit.g;
      _amountCtrl.text = '100';
      _searchCtrl.clear();
      _nameCtrl.clear(); _calCtrl.clear();
      _protCtrl.clear(); _glucCtrl.clear(); _lipCtrl.clear();
    });
  }

  // ── Confirm basket → pop with entries list ────────────────────────────────
  Future<void> _submit() async {
    if (_basket.isEmpty) return;
    MealType? type = _preselectedType;
    if (type == null) {
      type = await showModalBottomSheet<MealType>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => _MealTypePickerSheet(),
      );
      if (type == null || !mounted) return;
    }

    final now = DateTime.now();
    // Jour ciblé (peut être un jour passé consulté depuis l'écran nutrition/
    // suivi), mais heure actuelle conservée pour un tri chronologique sensé.
    final day = widget.targetDate ?? now;
    final entryTime = DateTime(day.year, day.month, day.day, now.hour, now.minute, now.second);
    final entries = _basket.asMap().entries.map((e) => MealEntry(
      id:       generateMealId(),
      food:     e.value.food,
      grams:    e.value.grams,
      mealType: type!,
      dateTime: entryTime,
    )).toList();

    if (mounted) Navigator.pop(context, {'entries': entries});
  }

  @override
  Widget build(BuildContext context) {
    final top    = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final cs     = Theme.of(context).colorScheme;
    final l10n   = AppL10n(Lang.code);

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(children: [

        // ── Header — clean, no colored bg ─────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(LucideIcons.chevronLeft,
                  color: cs.onSurface, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.addMealTitle, style: GoogleFonts.inter(
                  color: cs.primary, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 2.5)),
                Text(
                  _preselectedType != null
                      ? _preselectedType!.labelFor(Lang.code)
                      : l10n.addMealSubtitle,
                  style: GoogleFonts.outfit(
                    color: cs.onSurface, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: -0.4)),
              ])),
              if (_basket.isNotEmpty)
                GestureDetector(
                  onTap: () => _showBasketSheet(),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text('${_basket.length}',
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w800,
                        color: Colors.white))),
                  ),
                ),
            ]),

            const SizedBox(height: 16),

            // ── Underline tabs ──────────────────────────────────────────
            Row(children: [
              _ModeTab(label: l10n.addMealSearch, active: _mode == 0,
                onTap: () => setState(() { _mode = 0; _selectedFood = null; })),
              const SizedBox(width: 24),
              _ModeTab(label: l10n.addMealManual, active: _mode == 1,
                onTap: () => setState(() => _mode = 1)),
              const SizedBox(width: 24),
              _ModeTab(label: l10n.addMealScanner, active: _mode == 2,
                onTap: () => setState(() => _mode = 2)),
            ]),
          ]),
        ),

        Divider(height: 1, color: cs.outline.withOpacity(0.15)),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _mode == 0
                      ? _buildSearch()
                      : _mode == 1
                          ? _buildManual()
                          : _buildScanner(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),

        // ── Bottom bar ───────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(
              color: cs.outline.withOpacity(0.1)))),
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            if (_canAddToBasket) ...[
              GestureDetector(
                onTap: _addToBasket,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(
                      _selectedFood != null &&
                          _basket.any((b) => b.food.id == _selectedFood!.id)
                        ? LucideIcons.check : LucideIcons.plus,
                      size: 16, color: cs.primary),
                    const SizedBox(width: 7),
                    Text(
                      _selectedFood != null &&
                          _basket.any((b) => b.food.id == _selectedFood!.id)
                        ? l10n.addMealUpdateQty : l10n.addMealAddToList,
                      style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: cs.primary)),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
            ],

            GestureDetector(
              onTap: _canSubmit ? () {
                HapticFeedback.mediumImpact();
                _submit();
              } : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _canSubmit ? cs.primary : cs.outline.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(LucideIcons.check, size: 17,
                    color: _canSubmit ? Colors.white : cs.onSurface.withOpacity(0.3)),
                  const SizedBox(width: 8),
                  Text(
                    _basket.isEmpty
                        ? l10n.addMealFirstAdd
                        : l10n.addMealConfirm(_basket.length, _basketCalories),
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: _canSubmit ? Colors.white : cs.onSurface.withOpacity(0.3))),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Basket bottom sheet ───────────────────────────────────────────────────
  Future<void> _showBasketSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => _BasketSheet(
          basket: _basket,
          onRemove: (i) => setState(() => _basket.removeAt(i)),
        )),
    );
    setState(() {}); // refresh after sheet closes
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SEARCH MODE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildSearch() {
    if (_selectedFood != null) return _buildFoodDetail(_selectedFood!);
    final cs = Theme.of(context).colorScheme;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Selected chips row ──────────────────────────────────────────────────
      if (_basket.isNotEmpty) ...[
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: _basket.length,
            itemBuilder: (_, i) {
              final item = _basket[i];
              return GestureDetector(
                onTap: () => setState(() => _basket.removeAt(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(item.food.name, style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: Colors.white)),
                    const SizedBox(width: 6),
                    const Icon(LucideIcons.x, size: 11, color: Colors.white70),
                  ])));
            })),
        const SizedBox(height: 14),
      ],

      // ── Search bar ──────────────────────────────────────────────────────────
      Container(
        height: 46,
        decoration: BoxDecoration(
          color: cs.outline.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(LucideIcons.search, size: 16,
            color: cs.onSurface.withOpacity(0.35)),
          const SizedBox(width: 10),
          Expanded(child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearchChanged,
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: AppL10n(Lang.code).addMealHint,
              hintStyle: GoogleFonts.inter(fontSize: 14,
                color: cs.onSurface.withOpacity(0.35)),
              border: InputBorder.none, isDense: true,
              contentPadding: EdgeInsets.zero),
          )),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchCtrl.clear();
                _debounce?.cancel();
                setState(() { _searchQuery = ''; _spoonResults = []; _spoonLoading = false; });
              },
              child: Icon(LucideIcons.x, size: 14,
                color: cs.onSurface.withOpacity(0.35))),
        ]),
      ),

      const SizedBox(height: 16),

      // ── Results ─────────────────────────────────────────────────────────────
      if (_searchQuery.length < 2)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(child: Column(children: [
            Icon(LucideIcons.search, size: 32,
              color: cs.onSurface.withOpacity(0.15)),
            const SizedBox(height: 12),
            Text(AppL10n(Lang.code).addMealHint,
              style: GoogleFonts.inter(fontSize: 14,
                color: cs.onSurface.withOpacity(0.35))),
          ])))
      else if (_spoonLoading)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Center(child: SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: cs.primary))))
      else ...[
        // Spoonacular API results
        if (_spoonResults.isNotEmpty) ...[
          Text(
            AppL10n(Lang.code).addMealResults(_spoonResults.length),
            style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.4),
              letterSpacing: 2.0)),
          const SizedBox(height: 8),
          ..._spoonResults.map((ingredient) => _SpoonTile(
            ingredient: ingredient,
            isSelected: _basket.any((b) => b.food.id == 'off_${ingredient.id}'),
            onTap: () {
              HapticFeedback.selectionClick();
              final existIdx = _basket.indexWhere((b) => b.food.id == 'off_${ingredient.id}');
              if (existIdx != -1) {
                setState(() => _basket.removeAt(existIdx));
                return;
              }
              final food = _resolveSpoonFood(ingredient);
              setState(() => _basket.add(_BasketItem(food, food.defaultGrams)));
            },
          )),
        ],

        // Fallback to local database when API fails or returns empty
        if (_spoonResults.isEmpty) ...[
          if (_spoonError)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(LucideIcons.wifiOff, size: 14, color: Color(0xFF856404)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Résultats hors-ligne',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                      color: const Color(0xFF856404)))),
                ]))),
          ..._buildLocalFallback(cs),
        ],
      ],
    ]);
  }

  List<Widget> _buildLocalFallback(ColorScheme cs) {
    final results = _localResults();
    if (results.isEmpty) return [_EmptySearch(query: _searchQuery)];
    return [
      Text(
        AppL10n(Lang.code).addMealResults(results.length),
        style: GoogleFonts.inter(
          fontSize: 9, fontWeight: FontWeight.w700,
          color: cs.onSurface.withOpacity(0.4),
          letterSpacing: 2.0)),
      const SizedBox(height: 8),
      ...results.map((food) {
        final basketIdx = _basket.indexWhere((b) => b.food.id == food.id);
        final isSelected = basketIdx != -1;
        final grams = isSelected ? _basket[basketIdx].grams : food.defaultGrams;
        final kcal = food.kcalFor(grams).round();
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (isSelected) {
              setState(() => _basket.removeAt(basketIdx));
            } else {
              setState(() => _basket.add(_BasketItem(food, food.defaultGrams)));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: cs.outline.withOpacity(0.08)))),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _catColor(food.category).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(_catIcon(food.category),
                  size: 20, color: _catColor(food.category))),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(food.name, style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
                const SizedBox(height: 4),
                Row(children: [
                  Text(food.portionLabel, style: GoogleFonts.inter(
                    fontSize: 12, color: cs.onSurface.withOpacity(0.45))),
                  const SizedBox(width: 10),
                  Text('$kcal kcal', style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface)),
                ]),
              ])),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.outline.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(
                  isSelected ? LucideIcons.check : LucideIcons.plus,
                  size: 15,
                  color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.35))),
            ])));
      }),
    ];
  }

  // ── Food detail ───────────────────────────────────────────────────────────
  Widget _buildFoodDetail(FoodItem food) {
    final nc      = NutritionColors.of(context);
    final grams   = _selectedGrams;
    final kcal    = food.kcalFor(grams).round();
    final protein = food.proteinFor(grams).round();
    final carbs   = food.carbsFor(grams).round();
    final fat     = food.fatFor(grams).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: () => setState(() { _selectedFood = null; _searchQuery = ''; _searchCtrl.clear(); }),
        child: Row(children: [
          const Icon(LucideIcons.chevronLeft, size: 14, color: _kMint),
          const SizedBox(width: 4),
          Text(AppL10n(Lang.code).addMealBack, style: GoogleFonts.inter(
            fontSize: 12, color: _kMint, fontWeight: FontWeight.w600)),
        ])),

      const SizedBox(height: 16),

      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 44, height: 44,
                child: Image.network(
                  _catPhoto(food.category),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _catColor(food.category).withOpacity(0.12),
                    child: Icon(_catIcon(food.category),
                      size: 22, color: _catColor(food.category)))))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
              Text(food.category.label, style: GoogleFonts.inter(
                fontSize: 11, color: nc.text2)),
            ])),
          ]),

          const SizedBox(height: 16),

          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$kcal', style: GoogleFonts.outfit(
              fontSize: 44, fontWeight: FontWeight.w800,
              color: _kGreen(context), height: 1)),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text('kcal', style: GoogleFonts.inter(
                fontSize: 15, color: _kText2))),
            const Spacer(),
            _MacroBadge('P ${protein}g', _kGreen(context), _kMintBg),
            const SizedBox(width: 6),
            _MacroBadge('G ${carbs}g', const Color(0xFF3B7FD4), const Color(0xFFEBF2FC)),
            const SizedBox(width: 6),
            _MacroBadge('L ${fat}g', const Color(0xFFC47A00), const Color(0xFFFFF3DC)),
          ]),

          const SizedBox(height: 16),
          _MacroBar(AppL10n(Lang.code).nutritionProtein, protein, food.proteinFor(100).round(), _kGreen(context)),
          const SizedBox(height: 10),
          _MacroBar(AppL10n(Lang.code).nutritionCarbs, carbs, food.carbsFor(100).round(), const Color(0xFF3B7FD4)),
          const SizedBox(height: 10),
          _MacroBar(AppL10n(Lang.code).nutritionFat, fat, food.fatFor(100).round(), const Color(0xFFC47A00)),
          if (food.fiber > 0) ...[
            const SizedBox(height: 10),
            _MacroBar(AppL10n(Lang.code).addMealFibers, food.fiberFor(grams).round(),
              food.fiberFor(100).round(), const Color(0xFF5BAE8A)),
          ],

          const SizedBox(height: 16),
          Divider(height: 1, color: nc.border),
          const SizedBox(height: 14),

          Text(AppL10n(Lang.code).addMealQuantity, style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          const SizedBox(height: 10),

          // Quick portion chips (always in grams)
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final g in <double>{50, 100, food.defaultGrams, 150, 200}
                .toList()..sort())
              _PortionChip(
                label: g == food.defaultGrams && food.portionLabel != '100 g'
                    ? '${g.round()}g · ${food.portionLabel}'
                    : '${g.round()}g',
                selected: _selectedGrams == g && _selectedUnit == FoodUnit.g,
                onTap: () => setState(() {
                  _selectedUnit  = FoodUnit.g;
                  _selectedGrams = g;
                  _amountCtrl.text = g.round().toString();
                })),
          ]),

          const SizedBox(height: 12),

          // Amount + unit row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final val = double.tryParse(v);
                  if (val != null && val > 0) _setAmount(val);
                },
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: nc.text1),
                decoration: InputDecoration(
                  filled: true, fillColor: nc.chipBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _kMint, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13)),
              ),
            ),
            const SizedBox(width: 10),
            _UnitSelector(
              selected: _selectedUnit,
              onChanged: _setUnit,
            ),
          ]),

          if (_selectedUnit != FoodUnit.g)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '≈ ${_selectedGrams.round()} g',
                style: GoogleFonts.inter(fontSize: 11, color: nc.text2))),
        ]),
      ),
    ]);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  MANUEL MODE — nom en tête, calories en gros ("hero"), macros en chips
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildManual() {
    final nc   = NutritionColors.of(context);
    final l10n = AppL10n(Lang.code);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Nom de l'aliment — champ autonome avec icône, plus de bandeau texte au-dessus
      Container(
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: nc.border)),
        child: TextField(
          controller: _nameCtrl,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: nc.text1),
          decoration: InputDecoration(
            hintText: l10n.addMealNameHint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: nc.text2),
            prefixIcon: Icon(LucideIcons.utensils, size: 17, color: nc.text2),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16))),
      ),

      const SizedBox(height: 14),

      // Calories — grand champ mis en avant, au centre de l'attention
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [_kGreen(context), const Color(0xFF0F2E1C)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(
            color: _kGreen(context).withOpacity(0.22),
            blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(children: [
          Text(l10n.addMealCalLabel.toUpperCase(), style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 2)),
          const SizedBox(height: 8),
          IntrinsicWidth(
            child: TextField(
              controller: _calCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white38),
                suffixText: ' kcal',
                suffixStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white70),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero)),
          ),
        ]),
      ),

      const SizedBox(height: 18),

      // Macros — facultatif, en chips compactes plutôt qu'en champs longs
      Row(children: [
        Text(l10n.addMealMacros, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w700, color: nc.text1)),
        const SizedBox(width: 6),
        Text('(${l10n.addMealOptional})', style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _MacroChipInput(
          icon: LucideIcons.beef, label: l10n.nutritionProtein,
          color: _kGreen(context), bg: nc.mintBg, controller: _protCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _MacroChipInput(
          icon: LucideIcons.wheat, label: l10n.nutritionCarbs,
          color: const Color(0xFF3B7FD4), bg: const Color(0xFFE8F1FC), controller: _glucCtrl)),
        const SizedBox(width: 8),
        Expanded(child: _MacroChipInput(
          icon: LucideIcons.droplet, label: l10n.nutritionFat,
          color: const Color(0xFFC47A00), bg: const Color(0xFFFBF0DC), controller: _lipCtrl)),
      ]),
  ]);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SCANNER MODE
  // ════════════════════════════════════════════════════════════════════════════
  Widget _buildScanner() {
    return switch (_scanState) {
      _ScanState.idle     => _buildScannerIdle(),
      _ScanState.loading  => _buildScannerLoading(),
      _ScanState.preview  => _buildScannerPreview(),
      _ScanState.scanning => _buildScannerScanning(),
      _ScanState.result   => _buildScannerResult(),
    };
  }

  // ── Scanner: loading (photo choisie, conversion HEIC→JPEG en cours) ──────
  Widget _buildScannerLoading() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 40),
    decoration: BoxDecoration(
      color: _kMintBg,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _kMint.withOpacity(0.3)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
        width: 28, height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.6, color: _kGreen(context))),
      const SizedBox(height: 14),
      Text('Préparation de la photo…', style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600, color: _kGreen(context))),
    ]),
  );

  // ── Scanner: idle ────────────────────────────────────────────────────────
  Widget _buildScannerIdle() => Column(children: [
    if (_scanError != null) ...[
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEAEA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8A0A0)),
        ),
        child: Row(children: [
          const Icon(LucideIcons.alertTriangle, size: 16, color: Color(0xFFB3261E)),
          const SizedBox(width: 10),
          Expanded(child: Text(_scanError!, style: GoogleFonts.inter(
            fontSize: 12.5, color: const Color(0xFFB3261E), height: 1.4))),
        ]),
      ),
      const SizedBox(height: 14),
    ],
    // Grande carte dégradée avec icône flottante — remplace l'ancien
    // "viewfinder" plat et sombre par un visuel plus doux et engageant.
    Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_kGreen(context), const Color(0xFF0F2E1C)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: _kGreen(context).withOpacity(0.24),
          blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2)),
          child: const Icon(LucideIcons.camera, size: 21, color: Colors.white)),
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(AppL10n(Lang.code).addMealScanner, style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.sparkles, size: 10, color: Colors.white),
              const SizedBox(width: 3),
              Text('IA', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ])),
        ]),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppL10n(Lang.code).addMealScanHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70, height: 1.5))),
      ]),
    ),

    const SizedBox(height: 16),

    // Buttons — même famille de couleur (vert plein / vert-menthe contouré)
    // au lieu du bleu marine incohérent de l'ancienne version.
    Row(children: [
      Expanded(child: GestureDetector(
        onTap: () => _pickImage(ImageSource.camera),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _kGreen(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
              color: _kGreen(context).withOpacity(0.25),
              blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(LucideIcons.camera, size: 17, color: Colors.white),
            const SizedBox(width: 8),
            Text(AppL10n(Lang.code).nutritionScanner, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          ])))),
      const SizedBox(width: 10),
      Expanded(child: GestureDetector(
        onTap: () => _pickImage(ImageSource.gallery),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: _kMintBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kMint.withOpacity(0.5))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.image, size: 17, color: _kGreen(context)),
            const SizedBox(width: 8),
            Text(AppL10n(Lang.code).nutritionPhoto, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: _kGreen(context))),
          ])))),
    ]),
  ]);

  // ── Scanner: preview (picked image, waiting for "Analyser") ──────────────
  // Boutons flottants directement sur la photo (dégradé bas) plutôt qu'une
  // rangée de boutons séparée sous un cadre sombre.
  Widget _buildScannerPreview() => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(fit: StackFit.expand, children: [
        if (_pickedImageBytes != null)
          Image.memory(_pickedImageBytes!, fit: BoxFit.cover),

        // Voile dégradé haut (bouton retour) + bas (actions)
        const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          stops: [0.0, 0.18], colors: [Color(0x99000000), Colors.transparent]))),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          stops: const [0.0, 0.4], colors: [Colors.black.withOpacity(0.75), Colors.transparent])))),

        Positioned(top: 14, left: 14, child: GestureDetector(
          onTap: _resetScan,
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
            child: const Icon(LucideIcons.x, size: 17, color: Colors.white)))),

        Positioned(top: 14, right: 14, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(50)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.check, size: 12, color: _kMint),
            const SizedBox(width: 5),
            Text('Photo prête', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          ]))),

        Positioned(left: 16, right: 16, bottom: 16, child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: _resetScan,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(LucideIcons.rotateCcw, size: 15, color: Colors.white),
                const SizedBox(width: 7),
                Text('Reprendre', style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ])))),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: GestureDetector(
            onTap: _analyzeImage,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGreen(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12, offset: const Offset(0, 4))]),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                const SizedBox(width: 7),
                Text('Analyser', style: GoogleFonts.inter(
                  fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ])))),
        ])),
      ]),
    ),
  );

  // ── Scanner: scanning (animated scan-line sweep) ─────────────────────────
  Widget _buildScannerScanning() => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
        if (_pickedImageBytes != null)
          Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.45)),
        const _ScanSweepLine(),
        Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: _kMint.withOpacity(0.5), width: 1.5)),
            child: const _ScanningDots()),
          const SizedBox(height: 18),
          Text(AppL10n(Lang.code).addMealAnalyzing, style: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 6),
          Text(AppL10n(Lang.code).addMealNutrients, style: GoogleFonts.inter(
            fontSize: 11.5, color: Colors.white60)),
        ]),
        Positioned(bottom: 16, left: 16, right: 16, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            SizedBox(width: 13, height: 13,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kMint)),
            const SizedBox(width: 10),
            Expanded(child: Text(AppL10n(Lang.code).addMealAiAnalysis,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white))),
          ]))),
      ]),
    ),
  );

  // ── Scanner: result (editable card, ou liste si plusieurs aliments) ──────
  Widget _buildScannerResult() {
    if (_scannedFoods.length > 1) return _buildScannerMultiResult();
    final nc      = NutritionColors.of(context);
    final food    = _scannedFoods.first;
    final kcal    = food.kcalFor(_selectedGrams).round();
    final protein = food.proteinFor(_selectedGrams).round();
    final carbs   = food.carbsFor(_selectedGrams).round();
    final fat     = food.fatFor(_selectedGrams).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // "Résultat" header
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _kMintBg, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.sparkles, size: 12, color: _kGreen(context)),
            const SizedBox(width: 4),
            Text(AppL10n(Lang.code).addMealScanResult, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen(context))),
          ])),
        const Spacer(),
        GestureDetector(
          onTap: _resetScan,
          child: Text(AppL10n(Lang.code).addMealNewPhoto, style: GoogleFonts.inter(
            fontSize: 12, color: nc.text2,
            decoration: TextDecoration.underline))),
      ]),
      const SizedBox(height: 12),

      // Food card
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Food name + category chip
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _pickedImageBytes != null
                ? Image.memory(_pickedImageBytes!, width: 52, height: 52, fit: BoxFit.cover)
                : Container(
                    width: 52, height: 52,
                    color: nc.mintBg,
                    child: Icon(LucideIcons.utensils, size: 20, color: _kGreen(context)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w800, color: nc.text1)),
              Text(food.category.label, style: GoogleFonts.inter(
                fontSize: 11, color: nc.text2)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _kMintBg, borderRadius: BorderRadius.circular(8)),
              child: Text('$kcal kcal', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700, color: _kGreen(context)))),
          ]),

          const SizedBox(height: 16),
          Divider(height: 1, color: nc.border),
          const SizedBox(height: 14),

          // Macro pills
          Row(children: [
            _ScanMacroPill(AppL10n(Lang.code).nutritionProtein, protein, 'g', _kGreen(context)),
            const SizedBox(width: 8),
            _ScanMacroPill(AppL10n(Lang.code).nutritionCarbs, carbs, 'g', const Color(0xFF3B7FD4)),
            const SizedBox(width: 8),
            _ScanMacroPill(AppL10n(Lang.code).nutritionFat, fat, 'g', const Color(0xFFC47A00)),
          ]),

          const SizedBox(height: 16),

          // Quantity selector
          Row(children: [
            Text(AppL10n(Lang.code).addMealQtyLabel, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: nc.text1)),
            const SizedBox(width: 12),
            SizedBox(width: 72,
              child: TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                onChanged: (v) {
                  final n = double.tryParse(v);
                  if (n != null && n > 0) _setAmount(n);
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kBorder)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kMint, width: 1.5))),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            _UnitSelector(
              selected: _selectedUnit,
              onChanged: _setUnit),
          ]),
        ])),

      const SizedBox(height: 16),

      // CTA: add to basket + scan another
      // CTA buttons
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: _resetScan,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kMintBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kMint.withOpacity(0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.camera, size: 16, color: _kGreen(context)),
              const SizedBox(width: 6),
              Text(AppL10n(Lang.code).addMealOtherPhoto, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kGreen(context))),
            ])))),
        const SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: _selectedFood == null ? null : () {
            _addToBasket();
            _resetScan();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kGreen(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: _kGreen(context).withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 3))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.check, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(AppL10n(Lang.code).addMealAdd, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ])))),
      ]),

      const SizedBox(height: 10),

      // Add more ingredients — switches to search tab keeping the basket
      GestureDetector(
        onTap: _selectedFood == null ? null : () {
          _addToBasket();
          _resetScan();
          setState(() => _mode = 0);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: nc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: nc.border)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(LucideIcons.search, size: 15, color: nc.text2),
            const SizedBox(width: 7),
            Text(AppL10n(Lang.code).addMealMoreIngr, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600, color: nc.text2)),
          ]))),
    ]);
  }

  // ── Scanner: résultat multi-aliments ─────────────────────────────────────
  // Affiché quand la photo contient plusieurs plats/aliments distincts
  // (ex. poulet + riz + légumes) — chacun est ajoutable/retirable avant un
  // ajout groupé au panier, au lieu de forcer un choix unique.
  Widget _buildScannerMultiResult() {
    final nc = NutritionColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _kMintBg, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.sparkles, size: 12, color: _kGreen(context)),
            const SizedBox(width: 4),
            Text('${_scannedFoods.length} aliments détectés', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen(context))),
          ])),
        const Spacer(),
        GestureDetector(
          onTap: _resetScan,
          child: Text(AppL10n(Lang.code).addMealNewPhoto, style: GoogleFonts.inter(
            fontSize: 12, color: nc.text2,
            decoration: TextDecoration.underline))),
      ]),
      const SizedBox(height: 12),

      if (_pickedImageBytes != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(_pickedImageBytes!, height: 140,
            width: double.infinity, fit: BoxFit.cover)),
      const SizedBox(height: 14),

      ..._scannedFoods.asMap().entries.map((entry) {
        final i    = entry.key;
        final food = entry.value;
        final kcal = food.kcalFor(food.defaultGrams).round();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: nc.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: nc.border)),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _catColor(food.category).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(_catIcon(food.category), size: 16, color: _catColor(food.category))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(food.name, style: GoogleFonts.inter(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: nc.text1)),
              Text('${food.defaultGrams.round()}g · $kcal kcal',
                style: GoogleFonts.inter(fontSize: 11.5, color: nc.text2)),
            ])),
            GestureDetector(
              onTap: () => setState(() => _scannedFoods.removeAt(i)),
              child: Icon(LucideIcons.x, size: 16, color: nc.text2)),
          ]),
        );
      }),

      if (_scannedFoods.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text('Tous les aliments ont été retirés.',
            style: GoogleFonts.inter(fontSize: 12, color: nc.text2))),

      const SizedBox(height: 8),

      Row(children: [
        Expanded(child: GestureDetector(
          onTap: _resetScan,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _kMintBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kMint.withOpacity(0.4))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.camera, size: 16, color: _kGreen(context)),
              const SizedBox(width: 6),
              Text(AppL10n(Lang.code).addMealOtherPhoto, style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kGreen(context))),
            ])))),
        const SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: _scannedFoods.isEmpty ? null : () => _addAllScannedToBasket(_scannedFoods),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _scannedFoods.isEmpty ? nc.border : _kGreen(context),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _scannedFoods.isEmpty ? [] : [BoxShadow(
                color: _kGreen(context).withOpacity(0.3),
                blurRadius: 10, offset: const Offset(0, 3))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(LucideIcons.check, size: 16,
                color: _scannedFoods.isEmpty ? nc.text2 : Colors.white),
              const SizedBox(width: 6),
              Text('Ajouter tout (${_scannedFoods.length})', style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: _scannedFoods.isEmpty ? nc.text2 : Colors.white)),
            ])))),
      ]),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  BASKET SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _BasketSheet extends StatefulWidget {
  final List<_BasketItem> basket;
  final ValueChanged<int> onRemove;
  const _BasketSheet({required this.basket, required this.onRemove});

  @override
  State<_BasketSheet> createState() => _BasketSheetState();
}

class _BasketSheetState extends State<_BasketSheet> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final totalCal  = widget.basket.fold(0, (s, i) => s + i.calories);
    final totalProt = widget.basket.fold(0, (s, i) => s + i.protein);
    final totalCarb = widget.basket.fold(0, (s, i) => s + i.carbs);
    final totalFat  = widget.basket.fold(0, (s, i) => s + i.fat);

    final nc = NutritionColors.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // handle
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Container(width: 36, height: 4,
            decoration: BoxDecoration(
              color: nc.border,
              borderRadius: BorderRadius.circular(2)))),

        // title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
          child: Row(children: [
            Text(AppL10n(Lang.code).addMealBasketTitle, style: GoogleFonts.outfit(
              fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: nc.mintBg, borderRadius: BorderRadius.circular(20)),
              child: Text(AppL10n(Lang.code).addMealBasketCount(widget.basket.length),
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen(context)))),
          ])),

        // totals row
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: nc.mintBg,
            borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _TotalChip('$totalCal', 'kcal', _kGreen(context)),
              _TotalChip('${totalProt}g', AppL10n(Lang.code).addMealProt, _kGreen(context)),
              _TotalChip('${totalCarb}g', AppL10n(Lang.code).addMealGluc, const Color(0xFF3B7FD4)),
              _TotalChip('${totalFat}g', AppL10n(Lang.code).addMealLip, const Color(0xFFC47A00)),
            ],
          ),
        ),

        // list
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: widget.basket.length,
            itemBuilder: (_, i) {
              final item = widget.basket[i];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: nc.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: nc.border)),
                child: Row(children: [
                  Text(item.food.category.emoji,
                    style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.food.name, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: nc.text1)),
                    Text('${item.grams.round()}g · ${item.calories} kcal',
                      style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
                  ])),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onRemove(i);
                      setState(() {});
                      if (widget.basket.isEmpty) Navigator.pop(context);
                    },
                    child: Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEEEE),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(LucideIcons.trash2,
                        size: 13, color: Color(0xFFE03050)))),
                ]),
              );
            },
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _kGreen(context),
                borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(AppL10n(Lang.code).addMealClose, style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)))),
          )),
      ]),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String value, label;
  final Color color;
  const _TotalChip(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(value, style: GoogleFonts.outfit(
      fontSize: 16, fontWeight: FontWeight.w800, color: color)),
    Text(label, style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
//  UNIT SELECTOR
// ══════════════════════════════════════════════════════════════════════════════
class _UnitSelector extends StatelessWidget {
  final FoodUnit selected;
  final ValueChanged<FoodUnit> onChanged;
  const _UnitSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final unit = await showModalBottomSheet<FoodUnit>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _UnitPickerSheet(selected: selected),
        );
        if (unit != null) onChanged(unit);
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _kMintBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kMint.withOpacity(0.4))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(selected.shortLabel, style: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w700, color: _kGreen(context))),
          const SizedBox(width: 6),
          Icon(LucideIcons.chevronsUpDown, size: 14, color: _kGreen(context)),
        ]),
      ),
    );
  }
}

class _UnitPickerSheet extends StatelessWidget {
  final FoodUnit selected;
  const _UnitPickerSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final nc     = NutritionColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(
            color: nc.border,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 14),
        Text(AppL10n(Lang.code).addMealUnitTitle, style: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w800, color: nc.text1)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: FoodUnit.values.map((unit) {
            final isSelected = unit == selected;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context, unit);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _kGreen(context) : nc.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? _kGreen(context) : nc.border)),
                child: Text(unit.label, style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : nc.text1)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MEAL TYPE PICKER SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _MealTypePickerSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nc     = NutritionColors.of(context);
    final bottom = MediaQuery.of(context).padding.bottom;
    final dailyKcal = ref.watch(userProfileProvider).dailyKcal;
    return Container(
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(
            color: nc.border,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        Text(AppL10n(Lang.code).addMealWhichMeal, style: GoogleFonts.outfit(
          fontSize: 20, fontWeight: FontWeight.w800,
          color: nc.text1)),
        const SizedBox(height: 16),
        ...MealType.values.map((type) => GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context, type);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: nc.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: nc.border)),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: nc.mintBg,
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(_typeIcon(type), size: 16,
                  color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 12),
              Text(type.labelFor(Lang.code), style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600,
                color: nc.text1)),
              const Spacer(),
              Text('${type.budgetKcalFor(dailyKcal)} kcal', style: GoogleFonts.inter(
                fontSize: 12, color: nc.text2)),
            ])))),
      ]));
  }

  IconData _typeIcon(MealType t) => switch (t) {
    MealType.breakfast => LucideIcons.coffee,
    MealType.lunch     => LucideIcons.utensils,
    MealType.snack     => LucideIcons.apple,
    MealType.dinner    => LucideIcons.moon,
  };
}

// ══════════════════════════════════════════════════════════════════════════════
//  SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
class _FoodSelectTile extends StatelessWidget {
  final FoodItem food;
  final bool isSelected;
  final double? selectedGrams;
  final VoidCallback onToggle;
  final VoidCallback onEditQuantity;
  const _FoodSelectTile({
    required this.food,
    required this.isSelected,
    required this.onToggle,
    required this.onEditQuantity,
    this.selectedGrams,
  });

  @override
  Widget build(BuildContext context) {
    final grams = selectedGrams ?? food.defaultGrams;
    final kcal  = food.kcalFor(grams).round();
    final cs = Theme.of(context).colorScheme;
    final prot = food.proteinFor(grams).round();
    final carb = food.carbsFor(grams).round();
    final fat  = food.fatFor(grams).round();

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: cs.outline.withOpacity(0.08)))),
        child: Row(children: [

          // Food photo from Spoonacular CDN
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44, height: 44,
              child: _foodImage.containsKey(food.id)
                  ? Image.network(
                      _foodImageUrl(food.id),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _foodFallbackIcon(food.category))
                  : FutureBuilder<String?>(
                      future: SpoonacularService.getImageForName(food.name),
                      builder: (context, snap) {
                        if (snap.hasData && snap.data != null) {
                          return Image.network(
                            snap.data!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _foodFallbackIcon(food.category));
                        }
                        return _foodFallbackIcon(food.category);
                      }))),

          const SizedBox(width: 12),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(food.name, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: cs.onSurface)),
            const SizedBox(height: 4),
            Row(children: [
              GestureDetector(
                onTap: isSelected ? onEditQuantity : null,
                child: Text(
                  isSelected ? '${grams.round()} g' : food.portionLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: cs.onSurface.withOpacity(0.45)))),
              const SizedBox(width: 10),
              Text('$kcal kcal', style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
              const SizedBox(width: 8),
              Text('P $prot', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6))),
              const SizedBox(width: 4),
              Text('G $carb', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: const Color(0xFFF59E0B))),
              const SizedBox(width: 4),
              Text('L $fat', style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444))),
            ]),
          ])),

          const SizedBox(width: 8),

          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.outline.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(
              isSelected ? LucideIcons.check : LucideIcons.plus,
              size: 15,
              color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.35))),
        ])));
  }
}

class _SpoonTile extends StatelessWidget {
  final SpoonIngredient ingredient;
  final bool isSelected;
  final VoidCallback onTap;
  const _SpoonTile({
    required this.ingredient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: cs.outline.withOpacity(0.08)))),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 44, height: 44,
              child: Image.network(
                ingredient.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primary.withOpacity(0.08),
                  child: Icon(LucideIcons.utensils, size: 18, color: cs.primary))))),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ingredient.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: cs.onSurface)),
            const SizedBox(height: 4),
            Row(children: [
              if (ingredient.brand.isNotEmpty) ...[
                Text(ingredient.brand,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
                const SizedBox(width: 8),
              ],
              if (ingredient.kcal > 0) ...[
                Text('${ingredient.kcal.round()} kcal', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
                const SizedBox(width: 6),
                Text('P ${ingredient.protein.round()}', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B82F6))),
                const SizedBox(width: 4),
                Text('G ${ingredient.carbs.round()}', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: const Color(0xFFF59E0B))),
                const SizedBox(width: 4),
                Text('L ${ingredient.fat.round()}', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444))),
              ],
            ]),
          ])),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.outline.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8)),
            child: Icon(
              isSelected ? LucideIcons.check : LucideIcons.plus,
              size: 15,
              color: isSelected ? Colors.white : cs.onSurface.withOpacity(0.35))),
        ])));
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: nc.surface, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: nc.border)),
    child: Column(children: [
      Icon(LucideIcons.searchX, size: 32, color: nc.text2),
      const SizedBox(height: 10),
      Text(AppL10n(Lang.code).addMealNoResults(query),
        style: GoogleFonts.inter(fontSize: 13, color: nc.text2)),
      const SizedBox(height: 4),
      Text(AppL10n(Lang.code).addMealTryManual,
        style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
    ]));
  }
}

class _PortionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PortionChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? _kGreen(context) : nc.chipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? _kGreen(context) : nc.border)),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: selected ? Colors.white : nc.text1))));
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab({required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(
            color: active ? cs.primary : Colors.transparent,
            width: 2))),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? cs.primary : cs.onSurface.withOpacity(0.45)))));
  }
}

class _MacroChipInput extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  final TextEditingController controller;
  const _MacroChipInput({
    required this.icon, required this.label,
    required this.color, required this.bg, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: color),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: color.withOpacity(0.35)),
            filled: false,
            fillColor: Colors.transparent,
            isDense: true,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 2),
        Text('$label (g)', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(fontSize: 9.5, color: color.withOpacity(0.75), fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _MacroBadge extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MacroBadge(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w700, color: color)));
}

class _MacroBar extends StatelessWidget {
  final String label;
  final int value, maxPer100;
  final Color color;
  const _MacroBar(this.label, this.value, this.maxPer100, this.color);

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600, color: nc.text1)),
      Text('${value}g', style: GoogleFonts.inter(fontSize: 11, color: nc.text2)),
    ]),
    const SizedBox(height: 6),
    ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: LinearProgressIndicator(
        value: maxPer100 > 0 ? (value / maxPer100).clamp(0.0, 1.0) : 0,
        minHeight: 5,
        backgroundColor: color.withOpacity(0.12),
        valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }
}

// ── Scan-line sweep (up/down glow bar over the analyzing photo) ────────────
class _ScanSweepLine extends StatefulWidget {
  const _ScanSweepLine();
  @override
  State<_ScanSweepLine> createState() => _ScanSweepLineState();
}

class _ScanSweepLineState extends State<_ScanSweepLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Align(
        alignment: Alignment(0, _ctrl.value * 2 - 1),
        child: Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kMint.withOpacity(0),
                _kMint.withOpacity(0.9),
                _kMint.withOpacity(0),
              ]),
            boxShadow: [BoxShadow(
              color: _kMint.withOpacity(0.6),
              blurRadius: 10)])))));
  }
}

// ── Scanning animated dots ─────────────────────────────────────────────────
class _ScanningDots extends StatefulWidget {
  const _ScanningDots();
  @override
  State<_ScanningDots> createState() => _ScanningDotsState();
}

class _ScanningDotsState extends State<_ScanningDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
          final scale = (1 + 0.5 * ((t * 3 - i).clamp(0, 1) *
            (1 - (t * 3 - i).clamp(0, 1)) * 4)).clamp(0.7, 1.5);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: _kMint,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: _kMint.withOpacity(0.5 * (scale - 0.7)),
                    blurRadius: 8)]))));
        }));
      });
  }
}

// ── Scan macro pill ────────────────────────────────────────────────────────
class _ScanMacroPill extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;
  const _ScanMacroPill(this.label, this.value, this.unit, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text('$value$unit', style: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
          fontSize: 10, color: _kText2)),
      ])));
}
