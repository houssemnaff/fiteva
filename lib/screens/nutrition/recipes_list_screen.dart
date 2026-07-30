// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/recipe_author_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import 'recette_detail_screen.dart';
import 'recipe_video_screen.dart';
import '../../services/recipe_service.dart';
import '../../services/spoonacular_service.dart';

// ── Phase helper ──────────────────────────────────────────────────────────────
class PhaseInfo {
  final String label;
  final Color color;
  const PhaseInfo(this.label, this.color);

  static PhaseInfo from(String phase) => switch (phase) {
    'menstrual'  => const PhaseInfo('Règles',       Color(0xFFE03050)),
    'follicular' => const PhaseInfo('Folliculaire', Color(0xFF4CAF50)),
    'ovulation'  => const PhaseInfo('Ovulation',    Color(0xFFF59E0B)),
    'luteal'     => const PhaseInfo('Lutéale',      Color(0xFF8B5CF6)),
    _            => const PhaseInfo('Toutes phases', Color(0xFF78909C)),
  };
}

// ── Data model ────────────────────────────────────────────────────────────────
class RealRecipe {
  final String name, subtitle, imageUrl, duration, difficulty;
  final int kcal, proteins;
  final List<String> tags;
  final Color accent;
  final String phase;
  final String? authorName, authorId;
  final AppRecipe? source;

  const RealRecipe({
    required this.name, required this.subtitle, required this.imageUrl,
    required this.duration, required this.kcal, required this.proteins,
    required this.difficulty, required this.tags, required this.accent,
    this.phase = 'all', this.authorName, this.authorId, this.source,
  });
}

// ── Video models ──────────────────────────────────────────────────────────────
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
  final String phase;
  final String? authorName, authorId;
  final List<VideoIngredient> ingredients;
  final List<VideoStep> steps;
  const VideoRecipe({
    required this.name, required this.subtitle, required this.imageUrl,
    required this.duration, required this.difficulty,
    required this.kcal, required this.proteins,
    required this.ingredients, required this.steps,
    this.videoAsset, this.phase = 'all', this.authorName, this.authorId,
  });
}

// ── Converters ────────────────────────────────────────────────────────────────
RealRecipe _fromApp(AppRecipe r) => RealRecipe(
  name: r.title, subtitle: r.subtitle, imageUrl: r.imageUrl,
  duration: r.duration, difficulty: r.difficulty,
  kcal: r.kcal, proteins: r.proteins, tags: r.tags,
  accent: const Color(0xFF4A8B6F), phase: r.phase,
  authorName: r.author?.username, authorId: r.userId,
  source: r,
);

VideoRecipe _videoFromApp(AppRecipe r) => VideoRecipe(
  name: r.title, subtitle: r.subtitle, imageUrl: r.imageUrl,
  videoAsset: r.videoUrl, duration: r.duration, difficulty: r.difficulty,
  kcal: r.kcal, proteins: r.proteins, phase: r.phase,
  authorName: r.author?.username, authorId: r.userId,
  ingredients: r.ingredients.map((i) => VideoIngredient(
    name: i['name'] as String? ?? '', qty: i['qty'] as String? ?? '',
    kcal: (i['kcal'] as num? ?? 0).toInt())).toList(),
  steps: r.steps.map((s) => VideoStep(
    number: (s['number'] as num? ?? 0).toInt(),
    title: s['title'] as String? ?? '',
    description: s['description'] as String? ?? '')).toList(),
);

// ── Providers ─────────────────────────────────────────────────────────────────
final imageRecipesProvider = FutureProvider<List<RealRecipe>>((ref) async {
  final results = await Future.wait([
    RecipeService.fetchAppRecipes(),
    SpoonacularRecipeApi.getRandomRecipes(number: 20),
  ]);
  final supabase = results[0].map(_fromApp).toList();
  final spoon = results[1].map(_fromApp).toList();
  return [...supabase, ...spoon];
});

final videoRecipesProvider = FutureProvider<List<VideoRecipe>>((ref) async {
  final all = await RecipeService.fetchAppRecipes();
  return all.where((r) => r.videoUrl != null && r.videoUrl!.isNotEmpty)
      .map(_videoFromApp).toList();
});

// ── Filter tabs ───────────────────────────────────────────────────────────────
const _tabs = ['Tout', 'Petit-dej', 'Protéiné', 'Végé', 'Vegan', 'Sans Gluten'];

const _phases = [
  ('all',        'Tout',         Color(0xFF78909C)),
  ('menstrual',  'Règles',       Color(0xFFE03050)),
  ('follicular', 'Folliculaire', Color(0xFF4CAF50)),
  ('ovulation',  'Ovulation',    Color(0xFFF59E0B)),
  ('luteal',     'Lutéale',      Color(0xFF8B5CF6)),
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
  int _tab = 0;
  int _phase = 0;
  String _q = '';
  final _ctrl = TextEditingController();
  List<RealRecipe> _apiResults = [];
  bool _apiSearching = false;
  Timer? _debounce;

  void _onSearchChanged(String v) {
    setState(() => _q = v);
    _debounce?.cancel();
    if (v.length >= 3) {
      _debounce = Timer(const Duration(milliseconds: 600), () => _searchApi(v));
    } else {
      setState(() { _apiResults = []; _apiSearching = false; });
    }
  }

  Future<void> _searchApi(String query) async {
    setState(() => _apiSearching = true);
    final results = await SpoonacularRecipeApi.searchRecipes(query, number: 10);
    if (mounted && _q == query) {
      setState(() {
        _apiResults = results.map(_fromApp).toList();
        _apiSearching = false;
      });
    }
  }

  @override
  void dispose() { _debounce?.cancel(); _ctrl.dispose(); super.dispose(); }

  List<RealRecipe> _filter(List<RealRecipe> all) {
    var list = all.toList();
    if (_tab > 0) {
      final cat = _tabs[_tab];
      list = list.where((r) => r.tags.any((t) =>
        t.toLowerCase() == cat.toLowerCase())).toList();
    }
    if (_phase > 0) {
      final phaseId = _phases[_phase].$1;
      list = list.where((r) => r.phase == phaseId).toList();
    }
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      list = list.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.subtitle.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  void _open(RealRecipe r) {
    HapticFeedback.lightImpact();
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (_) => RecipeDetailScreen(
        recipe: r.source ?? RecipeItem(r.imageUrl, r.name, r.name, r.accent))));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final favs = ref.watch(favoritesProvider);
    final recipesAsync = ref.watch(imageRecipesProvider);
    final videosAsync = ref.watch(videoRecipesProvider);
    final recipes = recipesAsync.asData?.value ?? [];
    final videos = videosAsync.asData?.value ?? [];
    final filtered = [..._filter(recipes), ..._apiResults];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────
            SliverToBoxAdapter(child: Container(
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 14),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [BoxShadow(
                  color: cs.onSurface.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10)),
                      child: Icon(LucideIcons.chevronLeft,
                        color: cs.onSurface, size: 18))),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Recettes', style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: cs.onSurface, letterSpacing: -0.3))),
                  if (favs.isNotEmpty)
                    GestureDetector(
                      onTap: () => HapticFeedback.selectionClick(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.heart, size: 13, color: cs.primary),
                          const SizedBox(width: 5),
                          Text('${favs.length}', style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: cs.primary)),
                        ]))),
                ]),
                const SizedBox(height: 12),
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(LucideIcons.search, size: 15,
                      color: cs.onSurface.withOpacity(0.3)),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(
                      controller: _ctrl,
                      onChanged: _onSearchChanged,
                      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Rechercher…',
                        hintStyle: GoogleFonts.inter(fontSize: 14,
                          color: cs.onSurface.withOpacity(0.3)),
                        border: InputBorder.none, isDense: true,
                        contentPadding: EdgeInsets.zero))),
                    if (_q.isNotEmpty) GestureDetector(
                      onTap: () { _ctrl.clear(); setState(() => _q = ''); },
                      child: Icon(LucideIcons.x, size: 15,
                        color: cs.onSurface.withOpacity(0.3))),
                  ])),
              ]),
            )),

            // ── Category tabs ─────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemCount: _tabs.length,
                  itemBuilder: (_, i) {
                    final sel = _tab == i;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _tab = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: sel ? cs.primary : cs.outline.withOpacity(0.12))),
                        child: Text(_tabs[i], style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? Colors.white : cs.onSurface.withOpacity(0.45)))));
                  }),
              ),
            )),

            // ── Cycle phase pills ────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: 30,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemCount: _phases.length,
                  itemBuilder: (_, i) {
                    final sel = _phase == i;
                    final color = _phases[i].$3;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _phase = i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? color.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sel ? color : cs.outline.withOpacity(0.08))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 5),
                          Text(_phases[i].$2, style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: sel ? color : cs.onSurface.withOpacity(0.4))),
                        ])));
                  }),
              ),
            )),

            // ── Videos strip (Tout tab, no search) ───────────────────
            if (videos.isNotEmpty && _tab == 0 && _q.isEmpty && _phase == 0)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SizedBox(
                  height: 175,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: videos.length,
                    itemBuilder: (_, i) => _VideoTile(
                      recipe: videos[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RecipeVideoPlayerScreen(recipe: videos[i])))),
                  ),
                ),
              )),

            // ── Count ─────────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Text(
                '${filtered.length} recette${filtered.length != 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.3))))),

            // ── Loading ───────────────────────────────────────────────
            if (recipesAsync.isLoading || _apiSearching)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(
                  strokeWidth: 2, color: cs.primary)))),

            // ── Empty ────────────────────────────────────────────────
            if (!recipesAsync.isLoading && filtered.isEmpty)
              SliverToBoxAdapter(child: _buildEmpty(cs)),

            // ── Recipe grid ──────────────────────────────────────────
            if (!recipesAsync.isLoading && filtered.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _RecipeTile(
                      recipe: filtered[i],
                      isFav: favs.contains(filtered[i].name),
                      onFav: () {
                        HapticFeedback.lightImpact();
                        ref.read(favoritesProvider.notifier).toggle(filtered[i].name);
                      },
                      onTap: () => _open(filtered[i])),
                    childCount: filtered.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10))),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60),
    child: Center(child: Column(children: [
      Icon(LucideIcons.searchX, size: 28,
        color: cs.onSurface.withOpacity(0.12)),
      const SizedBox(height: 12),
      Text('Aucun résultat', style: GoogleFonts.outfit(
        fontSize: 15, fontWeight: FontWeight.w700,
        color: cs.onSurface.withOpacity(0.35))),
    ])));
}

// ══════════════════════════════════════════════════════════════════════════════
// VIDEO TILE (compact horizontal scroll card)
// ══════════════════════════════════════════════════════════════════════════════
class _VideoTile extends StatelessWidget {
  final VideoRecipe recipe;
  final VoidCallback onTap;
  const _VideoTile({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.08))),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primary.withOpacity(0.04))),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.35)])))),
              Center(child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]),
                child: Icon(LucideIcons.play, color: cs.primary, size: 13))),
              Positioned(bottom: 7, left: 7, right: 7,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.clock, size: 9, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text(recipe.duration, style: GoogleFonts.inter(
                        fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                    ])),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: pi.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(pi.label, style: GoogleFonts.inter(
                      fontSize: 8, fontWeight: FontWeight.w700,
                      color: Colors.white))),
                ])),
            ])),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700,
                    color: cs.onSurface, height: 1.2)),
                const SizedBox(height: 6),
                Row(children: [
                  Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10.5, fontWeight: FontWeight.w700,
                    color: cs.primary)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 3, height: 3,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.15),
                      shape: BoxShape.circle)),
                  Text(recipe.difficulty, style: GoogleFonts.inter(
                    fontSize: 10, color: cs.onSurface.withOpacity(0.35))),
                ]),
              ])),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE TILE (grid card)
// ══════════════════════════════════════════════════════════════════════════════
class _RecipeTile extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFav;
  final VoidCallback onFav, onTap;
  const _RecipeTile({
    required this.recipe, required this.isFav,
    required this.onFav, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.08))),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(
            flex: 5,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null ? child
                    : Container(color: cs.primary.withOpacity(0.04)),
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primary.withOpacity(0.04),
                  child: Icon(LucideIcons.chefHat, size: 24,
                    color: cs.primary.withOpacity(0.15)))),

              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.35)])))),

              Positioned(top: 8, right: 8,
                child: GestureDetector(
                  onTap: onFav,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: isFav
                          ? cs.primary
                          : Colors.black.withOpacity(0.25),
                      shape: BoxShape.circle),
                    child: Icon(LucideIcons.heart, size: 12,
                      color: Colors.white)))),

              Positioned(bottom: 7, left: 7, right: 7,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.clock, size: 9, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text(recipe.duration, style: GoogleFonts.inter(
                        fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                    ])),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: pi.color.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(5)),
                    child: Text(pi.label, style: GoogleFonts.inter(
                      fontSize: 8, fontWeight: FontWeight.w700,
                      color: Colors.white))),
                ])),
            ])),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700,
                    color: cs.onSurface, height: 1.2)),
                const SizedBox(height: 6),

                Row(children: [
                  Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10.5, fontWeight: FontWeight.w700,
                    color: cs.primary)),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 3, height: 3,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.15),
                      shape: BoxShape.circle)),
                  Text(recipe.difficulty, style: GoogleFonts.inter(
                    fontSize: 10, color: cs.onSurface.withOpacity(0.35))),
                ]),

                if (recipe.authorName != null) ...[
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: recipe.authorId != null ? () {
                      HapticFeedback.lightImpact();
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RecipeAuthorScreen(
                          userId: recipe.authorId!, username: recipe.authorName!)));
                    } : null,
                    child: Text('par ${recipe.authorName}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10,
                        color: cs.onSurface.withOpacity(0.3)))),
                ],
              ])),
        ]),
      ),
    );
  }
}
