// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/Phasecolors.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import 'recette_detail_screen.dart';
import 'recipe_video_screen.dart';
import 'all_video_recipes_screen.dart';
import 'all_image_recipes_screen.dart';
import '../../services/recipe_service.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
Color _kGreen(BuildContext c) => Theme.of(c).colorScheme.primary;
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFAFAF8);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF111110);
const _kText2  = Color(0xFF6B7280);
const _kChipBg = Color(0xFFF2F2F0);

// ── Data model ─────────────────────────────────────────────────────────────────
class RealRecipe {
  final String name, subtitle, imageUrl, duration, difficulty;
  final int kcal, proteins;
  final List<String> tags;
  final Color accent;
  final CyclePhase phase;

  const RealRecipe({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.duration,
    required this.kcal,
    required this.proteins,
    required this.difficulty,
    required this.tags,
    required this.accent,
    required this.phase,
  });
}

const allRecipes = [
  RealRecipe(
    name: 'Poke Bowl Saumon Avocat',
    subtitle: 'Riz, saumon mariné, avocat, edamame',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
    duration: '20 min', kcal: 487, proteins: 32, difficulty: 'Facile',
    tags: ['Protéiné', 'Sans Gluten', 'Omega-3'],
    accent: Color(0xFF4A8B6F), phase: CyclePhase.follicular,
  ),
  RealRecipe(
    name: 'One Pot Pasta Poulet Pesto',
    subtitle: 'Pâtes crémeuses, poulet grillé, pesto maison',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80',
    duration: '30 min', kcal: 562, proteins: 41, difficulty: 'Facile',
    tags: ['Protéiné', 'Savoureux'],
    accent: Color(0xFF2D5A45), phase: CyclePhase.luteal,
  ),
  RealRecipe(
    name: 'Avocado Toast Oeuf Poché',
    subtitle: 'Pain complet, avocat, oeuf poché, graines',
    imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=800&q=80',
    duration: '15 min', kcal: 324, proteins: 18, difficulty: 'Très facile',
    tags: ['Petit-dej', 'Végé'],
    accent: Color(0xFF5A7A35), phase: CyclePhase.follicular,
  ),
  RealRecipe(
    name: 'Bowl Méditerranéen Poulet',
    subtitle: 'Quinoa, poulet grillé, feta, olives, tomates',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
    duration: '25 min', kcal: 445, proteins: 38, difficulty: 'Facile',
    tags: ['Protéiné', 'Sans Gluten'],
    accent: Color(0xFF1A6B8A), phase: CyclePhase.ovulation,
  ),
  RealRecipe(
    name: 'Overnight Oats Protéinés',
    subtitle: 'Flocons avoine, whey, chia, fruits rouges',
    imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=800&q=80',
    duration: '5 min', kcal: 356, proteins: 28, difficulty: 'Très facile',
    tags: ['Petit-dej', 'Protéiné', 'Batch cooking'],
    accent: Color(0xFF8B3A6B), phase: CyclePhase.menstrual,
  ),
  RealRecipe(
    name: 'Smoothie Bowl Acai Cacao',
    subtitle: 'Acai, banane, cacao, granola croquant',
    imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=800&q=80',
    duration: '10 min', kcal: 298, proteins: 14, difficulty: 'Très facile',
    tags: ['Petit-dej', 'Vegan'],
    accent: Color(0xFF6B2D8B), phase: CyclePhase.menstrual,
  ),
];

// ── Supabase providers ─────────────────────────────────────────────────────────

final imageRecipesProvider = FutureProvider<List<RealRecipe>>((ref) async {
  try {
    final rows = await RecipeService.fetchImageRecipes();
    if (rows.isEmpty) return allRecipes;
    return rows.map(_realRecipeFromRow).toList();
  } catch (_) {
    return allRecipes;
  }
});

final videoRecipesProvider = FutureProvider<List<VideoRecipe>>((ref) async {
  try {
    final rows = await RecipeService.fetchVideoRecipes();
    if (rows.isEmpty) return videoRecipes;
    return rows.map(_videoRecipeFromRow).toList();
  } catch (_) {
    return videoRecipes;
  }
});

RealRecipe _realRecipeFromRow(Map<String, dynamic> r) {
  final hex = (r['accent_hex'] as String? ?? '#4A8B6F').replaceFirst('#', '');
  final color = Color(int.tryParse('0xFF$hex') ?? 0xFF4A8B6F);
  final phaseStr = r['phase'] as String? ?? 'follicular';
  final phase = CyclePhase.values.firstWhere(
    (p) => p.name == phaseStr, orElse: () => CyclePhase.follicular);
  final rawTags = r['tags'];
  final tags = rawTags is List
      ? rawTags.cast<String>()
      : (rawTags as String? ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  return RealRecipe(
    name:       r['name']       as String? ?? '',
    subtitle:   r['subtitle']   as String? ?? '',
    imageUrl:   r['image_url']  as String? ?? '',
    duration:   r['duration']   as String? ?? '',
    difficulty: r['difficulty'] as String? ?? 'Facile',
    kcal:       (r['kcal']     as num? ?? 0).toInt(),
    proteins:   (r['proteins'] as num? ?? 0).toInt(),
    tags:       tags,
    accent:     color,
    phase:      phase,
  );
}

VideoRecipe _videoRecipeFromRow(Map<String, dynamic> r) {
  final phaseStr = r['phase'] as String? ?? 'follicular';
  final phase = CyclePhase.values.firstWhere(
    (p) => p.name == phaseStr, orElse: () => CyclePhase.follicular);
  final rawIngredients = r['ingredients'] as List? ?? [];
  final rawSteps       = r['steps']       as List? ?? [];
  return VideoRecipe(
    name:        r['name']        as String? ?? '',
    subtitle:    r['subtitle']    as String? ?? '',
    imageUrl:    r['image_url']   as String? ?? '',
    duration:    r['duration']    as String? ?? '',
    difficulty:  r['difficulty']  as String? ?? 'Facile',
    kcal:        (r['kcal']      as num? ?? 0).toInt(),
    proteins:    (r['proteins']  as num? ?? 0).toInt(),
    phase:       phase,
    videoAsset:  r['video_asset'] as String?,
    ingredients: rawIngredients.map((i) => VideoIngredient(
      name: i['name'] as String? ?? '',
      qty:  i['qty']  as String? ?? '',
      kcal: (i['kcal'] as num? ?? 0).toInt(),
    )).toList(),
    steps: rawSteps.map((s) => VideoStep(
      number:      (s['number']      as num? ?? 0).toInt(),
      title:       s['title']        as String? ?? '',
      description: s['description']  as String? ?? '',
    )).toList(),
  );
}

const _filterCategories = [
  (label: 'Tout',          icon: LucideIcons.layoutGrid),

  (label: 'Petit-dej',     icon: LucideIcons.sunrise),
  (label: 'Protéiné',      icon: LucideIcons.dumbbell),
  (label: 'Végé',          icon: LucideIcons.leaf),
  (label: 'Vegan',         icon: LucideIcons.sprout),
  (label: 'Sans Gluten',   icon: LucideIcons.wheatOff),
  (label: 'Batch cooking', icon: LucideIcons.cookingPot),
];

// ── Video data ─────────────────────────────────────────────────────────────────
class VideoIngredient {
  final String name, qty;
  final int kcal;
  const VideoIngredient({required this.name, required this.qty, required this.kcal});
}

class VideoStep {
  final int number;
  final String title, description;
  const VideoStep({required this.number, required this.title, required this.description});
}

class VideoRecipe {
  final String name, subtitle, imageUrl, duration, difficulty;
  final String? videoAsset;
  final int kcal, proteins;
  final CyclePhase phase;
  final List<VideoIngredient> ingredients;
  final List<VideoStep> steps;
  const VideoRecipe({
    required this.name, required this.subtitle, required this.imageUrl,
    required this.duration, required this.difficulty,
    required this.kcal, required this.proteins,
    required this.phase, required this.ingredients, required this.steps,
    this.videoAsset,
  });
}

const videoRecipes = [
  VideoRecipe(
    name: 'Pancakes Petit-déj Protéinés',
    subtitle: 'Flocons d\'avoine, œufs, banane, miel',
    imageUrl: 'https://images.unsplash.com/photo-1528207776546-365bb710ee93?w=400&q=80',
    videoAsset: 'assets/videos/ptitdej.mp4',
    duration: '15 min', difficulty: 'Très facile',
    kcal: 342, proteins: 22, phase: CyclePhase.follicular,
    ingredients: [
      VideoIngredient(name: 'Flocons d\'avoine',  qty: '60 g',   kcal: 230),
      VideoIngredient(name: 'Œufs entiers',        qty: '2 pièces', kcal: 140),
      VideoIngredient(name: 'Banane mûre',          qty: '1 pièce', kcal: 89),
      VideoIngredient(name: 'Lait végétal',         qty: '100 ml',  kcal: 35),
      VideoIngredient(name: 'Miel',                 qty: '1 c. à s.', kcal: 60),
      VideoIngredient(name: 'Levure chimique',      qty: '½ c. à c.', kcal: 3),
    ],
    steps: [
      VideoStep(number: 1, title: 'Mixer la base',
        description: 'Mixe les flocons d\'avoine en farine fine. Ajoute la banane et les œufs, puis mixe à nouveau jusqu\'à obtenir une pâte lisse.'),
      VideoStep(number: 2, title: 'Ajuster la consistance',
        description: 'Verse le lait végétal en filet en mélangeant. La pâte doit être fluide mais pas trop liquide. Ajoute la levure et mélange doucement.'),
      VideoStep(number: 3, title: 'Cuire les pancakes',
        description: 'Chauffe une poêle antiadhésive à feu moyen. Verse une louche de pâte et cuis 2 min jusqu\'à ce que des bulles se forment. Retourne et cuis encore 1 min.'),
      VideoStep(number: 4, title: 'Dresser et servir',
        description: 'Empile les pancakes, arrose de miel et ajoute des fruits frais. Sers immédiatement pour profiter du moelleux optimal.'),
    ],
  ),
  VideoRecipe(
    name: 'Soupe anti-crampes',
    subtitle: 'Lentilles, épinards, curcuma, gingembre',
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
    duration: '20 min', difficulty: 'Facile',
    kcal: 180, proteins: 9, phase: CyclePhase.menstrual,
    ingredients: [
      VideoIngredient(name: 'Lentilles rouges', qty: '80 g',  kcal: 90),
      VideoIngredient(name: 'Épinards frais',   qty: '100 g', kcal: 23),
      VideoIngredient(name: 'Curcuma',          qty: '1 c. à c.', kcal: 8),
      VideoIngredient(name: 'Gingembre frais',  qty: '1 cm',  kcal: 5),
      VideoIngredient(name: 'Bouillon légumes', qty: '500 ml', kcal: 20),
    ],
    steps: [
      VideoStep(number: 1, title: 'Faire revenir les épices',
        description: 'Dans une casserole, chauffe un filet d\'huile et fais revenir le curcuma et le gingembre râpé 1 minute pour libérer les arômes.'),
      VideoStep(number: 2, title: 'Ajouter les lentilles',
        description: 'Verse les lentilles rinsées et le bouillon chaud. Porte à ébullition puis baisse le feu. Cuis 12 min à couvert.'),
      VideoStep(number: 3, title: 'Incorporer les épinards',
        description: 'Ajoute les épinards frais en fin de cuisson. Mélange et laisse cuire encore 2 min. Ajuste sel et poivre.'),
      VideoStep(number: 4, title: 'Mixer et servir',
        description: 'Mixe la moitié de la soupe pour une texture mi-crémeuse mi-chunky. Sers chaud avec un filet de citron.'),
    ],
  ),
  VideoRecipe(
    name: 'Poke Bowl vitalité',
    subtitle: 'Riz, saumon, avocat, edamame',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    duration: '15 min', difficulty: 'Facile',
    kcal: 420, proteins: 28, phase: CyclePhase.follicular,
    ingredients: [
      VideoIngredient(name: 'Riz sushi cuit',  qty: '150 g', kcal: 195),
      VideoIngredient(name: 'Saumon frais',    qty: '120 g', kcal: 200),
      VideoIngredient(name: 'Avocat',          qty: '½ pièce', kcal: 80),
      VideoIngredient(name: 'Edamame',         qty: '50 g',  kcal: 55),
      VideoIngredient(name: 'Sauce soja',      qty: '2 c. à s.', kcal: 12),
    ],
    steps: [
      VideoStep(number: 1, title: 'Assaisonner le riz',
        description: 'Mélange le riz tiède avec un peu de vinaigre de riz et une pincée de sel. Étale dans le bol.'),
      VideoStep(number: 2, title: 'Préparer le saumon',
        description: 'Coupe le saumon en cubes. Marine-le 5 min avec sauce soja, sésame et un filet de citron.'),
      VideoStep(number: 3, title: 'Dresser le bowl',
        description: 'Dispose le saumon, l\'avocat tranché et les edamame sur le riz. Ajoute tes garnitures favorites et sers frais.'),
    ],
  ),
  VideoRecipe(
    name: 'Pasta réconfort',
    subtitle: 'Pâtes crémeuses, champignons, parmesan',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80',
    duration: '30 min', difficulty: 'Facile',
    kcal: 520, proteins: 18, phase: CyclePhase.luteal,
    ingredients: [
      VideoIngredient(name: 'Penne',           qty: '80 g',  kcal: 280),
      VideoIngredient(name: 'Champignons',      qty: '150 g', kcal: 33),
      VideoIngredient(name: 'Crème légère',     qty: '100 ml', kcal: 110),
      VideoIngredient(name: 'Parmesan râpé',    qty: '30 g',  kcal: 120),
      VideoIngredient(name: 'Ail',             qty: '2 gousses', kcal: 8),
    ],
    steps: [
      VideoStep(number: 1, title: 'Cuire les pâtes',
        description: 'Cuis les pâtes al dente selon les instructions. Réserve un peu d\'eau de cuisson.'),
      VideoStep(number: 2, title: 'Faire revenir les champignons',
        description: 'Saute les champignons à feu vif avec l\'ail dans un peu de beurre jusqu\'à dorure.'),
      VideoStep(number: 3, title: 'Créer la sauce',
        description: 'Ajoute la crème, le parmesan et un peu d\'eau de cuisson. Laisse réduire 2 min à feu doux.'),
      VideoStep(number: 4, title: 'Mélanger et servir',
        description: 'Incorpore les pâtes à la sauce. Mélange bien, ajuste l\'assaisonnement et sers avec du parmesan supplémentaire.'),
    ],
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class RecipesListScreen extends ConsumerStatefulWidget {
  const RecipesListScreen({super.key});

  @override
  ConsumerState<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  String _activeCategory = 'Tout';
  String _searchQuery    = '';
  final _searchCtrl      = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleFavorite(String name) {
    HapticFeedback.lightImpact();
    ref.read(favoritesProvider.notifier).toggle(name);
  }

  List<RealRecipe> _filtered(Set<String> favorites, List<RealRecipe> recipes) {
    var list = recipes.toList();

    if (_activeCategory == 'Favoris') {
      list = list.where((r) => favorites.contains(r.name)).toList();
    } else if (_activeCategory != 'Tout') {
      list = list.where((r) => r.tags.contains(_activeCategory)).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.subtitle.toLowerCase().contains(q) ||
        r.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final top       = MediaQuery.of(context).padding.top;
    final favorites = ref.watch(favoritesProvider);
    final recipes   = ref.watch(imageRecipesProvider).asData?.value ?? allRecipes;
    final dbVideos  = ref.watch(videoRecipesProvider).asData?.value ?? videoRecipes;
    final filtered  = _filtered(favorites, recipes);
    final nc        = NutritionColors.of(context);
    final l10n      = ref.watch(l10nProvider);
    final isFavMode = _activeCategory == 'Favoris';
    final videoFavs = isFavMode
        ? dbVideos.where((r) => favorites.contains(r.name)).toList()
        : <VideoRecipe>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: nc.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            _StickyHeader(
              top: top,
              onBack: () => Navigator.pop(context),
              favCount: favorites.length,
              l10n: l10n,
              onFavTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeCategory =
                  _activeCategory == 'Favoris' ? 'Tout' : 'Favoris');
              },
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _SearchBar(
                  controller: _searchCtrl,
                  query: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _filterCategories.length,
                    itemBuilder: (_, i) {
                      final c   = _filterCategories[i];
                      final sel = _activeCategory == c.label;
                      final isFavPill = c.label == 'Favoris';
                      return _CategoryPill(
                        label: c.label,
                        icon: c.icon,
                        selected: sel,
                        badge: isFavPill && favorites.isNotEmpty
                            ? favorites.length : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeCategory = c.label);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // Hero card (hidden in Favoris mode)
            if (!isFavMode) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HeroCard(
                    recipe: recipes.first,
                    isFavorite: favorites.contains(recipes.first.name),
                    onToggleFavorite: () => _toggleFavorite(recipes.first.name),
                    onTap: () => _openRecipe(context, recipes.first),
                    l10n: l10n,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: LucideIcons.play, eyebrow: 'VIDÉOS',
                  title: 'Recettes rapides',
                  action: l10n.sectionVoirTout,
                  onAction: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const AllVideoRecipesScreen())),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 178,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: dbVideos.length,
                    itemBuilder: (_, i) => _VideoCard(
                      recipe: dbVideos[i],
                      isFavorite: favorites.contains(dbVideos[i].name),
                      onToggleFavorite: () => _toggleFavorite(dbVideos[i].name),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RecipeVideoPlayerScreen(recipe: dbVideos[i]))),
                    ),
                  ),
                ),
              ),
            ],

            // Vidéos favorites (mode Favoris uniquement)
            if (isFavMode && videoFavs.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: LucideIcons.video, eyebrow: 'FAVORIS',
                  title: 'Recettes vidéos',
                  action: '${videoFavs.length} recette${videoFavs.length > 1 ? "s" : ""}',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                sliver: SliverList.separated(
                  itemCount: videoFavs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final r = videoFavs[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(
                        builder: (_) => RecipeVideoPlayerScreen(recipe: r))),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _kBorder)),
                        child: Row(children: [
                          Stack(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(r.imageUrl,
                                width: 62, height: 62, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 62, height: 62, color: _kMintBg))),
                            Positioned.fill(child: Center(
                              child: Container(
                                width: 26, height: 26,
                                decoration: BoxDecoration(
                                  color: _kGreen(context).withOpacity(0.88),
                                  shape: BoxShape.circle),
                                child: const Icon(LucideIcons.play,
                                  color: Colors.white, size: 11)))),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: GoogleFonts.outfit(
                              fontSize: 13.5, fontWeight: FontWeight.w700, color: _kText1)),
                            const SizedBox(height: 3),
                            Text('${r.kcal} kcal · ${r.duration}',
                              style: GoogleFonts.inter(fontSize: 11.5, color: _kText2)),
                          ])),
                          GestureDetector(
                            onTap: () => _toggleFavorite(r.name),
                            child: const Icon(LucideIcons.heart,
                              color: Color(0xFFE03050), size: 20)),
                        ]),
                      ),
                    );
                  },
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: _activeCategory == 'Favoris'
                    ? LucideIcons.heart : LucideIcons.image,
                eyebrow: _activeCategory == 'Favoris' ? 'MES FAVORIS' : 'RECETTES PHOTOS',
                title: _activeCategory == 'Favoris'
                    ? 'Mes favoris'
                    : _activeCategory == 'Tout' ? 'Photos & Étapes' : _activeCategory,
                action: _activeCategory == 'Tout' ? l10n.sectionVoirTout : '${filtered.length} résultat${filtered.length > 1 ? "s" : ""}',
                onAction: _activeCategory == 'Tout'
                    ? () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const AllImageRecipesScreen()))
                    : null,
              ),
            ),

            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 52),
                  child: Center(
                    child: Column(children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: _activeCategory == 'Favoris'
                              ? const Color(0xFFFFF0F3)
                              : _kMintBg,
                          borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          _activeCategory == 'Favoris'
                              ? LucideIcons.heartOff
                              : LucideIcons.search,
                          color: _activeCategory == 'Favoris'
                              ? const Color(0xFFE03050)
                              : _kGreen(context),
                          size: 26)),
                      const SizedBox(height: 16),
                      Text(
                        _activeCategory == 'Favoris'
                            ? 'Aucun favori pour l\'instant'
                            : 'Aucune recette',
                        style: GoogleFonts.outfit(
                          fontSize: 17, fontWeight: FontWeight.w700, color: _kText1)),
                      const SizedBox(height: 4),
                      Text(
                        _activeCategory == 'Favoris'
                            ? 'Appuie sur ♡ pour sauvegarder une recette'
                            : 'Essaie une autre catégorie',
                        style: GoogleFonts.inter(fontSize: 13, color: _kText2)),
                    ]),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RecipeCard(
                    recipe: filtered[i],
                    isFavorite: favorites.contains(filtered[i].name),
                    onToggleFavorite: () => _toggleFavorite(filtered[i].name),
                    onTap: () => _openRecipe(context, filtered[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openRecipe(BuildContext ctx, RealRecipe r) {
    Navigator.of(ctx, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => RecipeDetailScreen(
        recipe: RecipeItem(r.imageUrl, r.name, r.name, r.accent))));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STICKY HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  final double top;
  final VoidCallback onBack;
  final int favCount;
  final VoidCallback onFavTap;
  final AppL10n l10n;

  const _StickyHeader({
    required this.top,
    required this.onBack,
    required this.favCount,
    required this.onFavTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: top + 72,
      collapsedHeight: top + 60,
      backgroundColor: nc.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(builder: (_, __) {
        return Container(
          color: nc.bg,
          padding: EdgeInsets.fromLTRB(20, top + 16, 20, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: nc.mintBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.chevronLeft, color: _kGreen(context), size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l10n.recettesEyebrow, style: GoogleFonts.inter(
                  color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 3)),
                Text(l10n.recettesExplorer, style: GoogleFonts.outfit(
                  color: nc.text1, fontSize: 22, fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
              ]),
            ),
            // Favorites bookmark button with badge
            GestureDetector(
              onTap: onFavTap,
              child: Stack(clipBehavior: Clip.none, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: favCount > 0
                        ? const Color(0xFFE03050).withOpacity(nc.isDark ? 0.25 : 0.10)
                        : nc.chipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: favCount > 0
                          ? const Color(0xFFE03050).withOpacity(0.3)
                          : Colors.transparent)),
                  child: Icon(
                    LucideIcons.heart,
                    color: favCount > 0
                        ? const Color(0xFFE03050)
                        : nc.text2,
                    size: 16)),
                if (favCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE03050),
                        shape: BoxShape.circle),
                      child: Center(child: Text(
                        '$favCount',
                        style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: Colors.white))))),
              ]),
            ),
          ]),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchBar({
    required this.controller, required this.query,
    required this.onChanged, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: nc.border),
        boxShadow: nc.isDark ? [] : [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        Icon(LucideIcons.search, size: 16, color: nc.text2),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 13.5, color: nc.text1),
            decoration: InputDecoration(
              hintText: 'Rechercher une recette…',
              hintStyle: GoogleFonts.inter(fontSize: 13.5, color: nc.text2),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero),
          ),
        ),
        if (query.isNotEmpty)
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: nc.chipBg, shape: BoxShape.circle),
              child: Icon(LucideIcons.x, size: 11, color: nc.text2)),
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CATEGORY PILL
// ══════════════════════════════════════════════════════════════════════════════
class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label, required this.icon,
    required this.selected, required this.onTap,
    this.badge,
  });

  bool get _isFav => label == 'Favoris';

  @override
  Widget build(BuildContext context) {
    final _activeColor = _isFav ? const Color(0xFFE03050) : _kGreen(context);
    final _activeBg    = _isFav ? const Color(0xFFE03050) : _kGreen(context);
    final nc = NutritionColors.of(context);
    return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? _activeBg : nc.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? _activeBg
              : _isFav && badge != null
                  ? const Color(0xFFE03050).withOpacity(0.4)
                  : nc.border,
          width: 1.2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          selected && _isFav ? LucideIcons.heartHandshake : icon,
          size: 12,
          color: selected
              ? Colors.white
              : _isFav
                  ? const Color(0xFFE03050)
                  : nc.text2),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? Colors.white
              : _isFav
                  ? const Color(0xFFE03050)
                  : nc.text2)),
        if (badge != null && !selected) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFE03050),
              borderRadius: BorderRadius.circular(10)),
            child: Text('$badge', style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w800,
              color: Colors.white))),
        ],
      ]),
    ),
  );}
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.icon, required this.eyebrow, required this.title,
    this.action, this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: nc.mintBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(LucideIcons.salad, size: 14, color: _kGreen(context)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(eyebrow, style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: _kMint, letterSpacing: 2.5)),
            Text(title, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: nc.text1, letterSpacing: -0.3)),
          ]),
        ),
        if (action != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: onAction != null ? nc.mintBg : nc.chipBg,
              borderRadius: BorderRadius.circular(20)),
            child: GestureDetector(
              onTap: onAction,
              child: Text(action!, style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: onAction != null ? _kGreen(context) : nc.text2))),
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO CARD  +  favorite button
// ══════════════════════════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  final AppL10n l10n;
  const _HeroCard({
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(recipe.imageUrl, fit: BoxFit.cover,
            loadingBuilder: (_, child, p) =>
              p == null ? child : Container(color: NutritionColors.of(context).mintBg),
            errorBuilder: (_, __, ___) =>
              Container(color: NutritionColors.of(context).mintBg,
                child: const Center(child: Icon(
                  LucideIcons.image, color: _kMint, size: 36)))),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xE0000000)],
                stops: [0.25, 1.0]))),

          Positioned(top: 14, left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.star, size: 9, color: Colors.white),
                const SizedBox(width: 5),
                Text(l10n.recettesEnVedette, style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
              ]))),

          // Phase badge
          Positioned(top: 14, right: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pc.primary.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20)),
              child: Text(pc.name, style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),

          // ❤ Favorite button
          Positioned(top: 10, right: 10,
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? const Color(0xFFE03050)
                      : Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                  boxShadow: isFavorite ? [BoxShadow(
                    color: const Color(0xFFE03050).withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 3))] : []),
                child: Icon(
                  isFavorite ? LucideIcons.heart : LucideIcons.heart,
                  size: 16,
                  color: Colors.white)))),

          Positioned(bottom: 14, left: 16, right: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.name, style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.3, height: 1.2)),
              const SizedBox(height: 8),
              Row(children: [
                _GlassBadge(icon: LucideIcons.clock, label: recipe.duration),
                const SizedBox(width: 8),
                _GlassBadge(icon: LucideIcons.flame, label: '${recipe.kcal} kcal'),
                const SizedBox(width: 8),
                _GlassBadge(icon: LucideIcons.barChart2, label: recipe.difficulty),
              ]),
            ])),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VIDEO CARD
// ══════════════════════════════════════════════════════════════════════════════
class _VideoCard extends StatelessWidget {
  final VideoRecipe recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  const _VideoCard({
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          SizedBox(
            height: 108,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: pc.light)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x88000000)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),
              Center(
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90), shape: BoxShape.circle),
                  child: Icon(LucideIcons.play, color: pc.primary, size: 13))),
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? const Color(0xFFE03050)
                          : Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle),
                    child: const Icon(LucideIcons.heart,
                      color: Colors.white, size: 11)))),
              Positioned(bottom: 7, right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)))),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: nc.text1, height: 1.3)),
                  Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
                ],
              ),
            ),
          ),
          Container(height: 2.5, color: pc.primary),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE CARD (list item)  +  favorite button
// ══════════════════════════════════════════════════════════════════════════════
class _RecipeCard extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  const _RecipeCard({
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFavorite
                ? const Color(0xFFE03050).withOpacity(0.25)
                : nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: isFavorite
                ? const Color(0xFFE03050).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          SizedBox(
            width: 96,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(recipe.imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) =>
                    p == null ? child : Container(color: nc.mintBg),
                  errorBuilder: (_, __, ___) =>
                    Container(color: nc.mintBg,
                      child: const Center(child: Icon(
                        LucideIcons.image, color: _kMint, size: 22)))),
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(height: 3, color: pc.primary)),
              ]),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: pc.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(pc.name, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
                  ]),
                  const SizedBox(height: 3),
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: nc.text1, height: 1.3)),
                  const SizedBox(height: 7),
                  Row(children: [
                    _MiniStat(LucideIcons.clock, recipe.duration, nc.text2),
                    const SizedBox(width: 10),
                    _MiniStat(LucideIcons.flame, '${recipe.kcal} kcal', nc.text2),
                  ]),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5, runSpacing: 4,
                    children: recipe.tags.take(2).map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: nc.chipBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: GoogleFonts.inter(
                        fontSize: 10, color: nc.text2, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? const Color(0xFFE03050).withOpacity(nc.isDark ? 0.25 : 0.10)
                          : nc.chipBg,
                      shape: BoxShape.circle),
                    child: Icon(LucideIcons.heart, size: 14,
                      color: isFavorite
                          ? const Color(0xFFE03050)
                          : nc.text2))),
                const SizedBox(height: 6),
                Icon(LucideIcons.chevronRight, size: 14, color: nc.text2),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.30))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: Colors.white),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MiniStat(this.icon, this.label, [this.color]);

  @override
  Widget build(BuildContext context) {
    final c = color ?? NutritionColors.of(context).text2;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: c),
      const SizedBox(width: 3),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, color: c, fontWeight: FontWeight.w500)),
    ]);
  }
}
