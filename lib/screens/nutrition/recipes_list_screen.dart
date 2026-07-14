// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/screens/nutrition/recipe_author_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/core/nutrition/models.dart' as core;
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'models/models.dart';
import 'recette_detail_screen.dart';
import 'widgets/recommended_meals_section.dart';
import 'recipe_video_screen.dart';
import '../../services/recipe_service.dart';

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
  final all = await RecipeService.fetchAppRecipes();
  return all.map(_fromApp).toList();
});

final videoRecipesProvider = FutureProvider<List<VideoRecipe>>((ref) async {
  final all = await RecipeService.fetchAppRecipes();
  return all.where((r) => r.videoUrl != null && r.videoUrl!.isNotEmpty)
      .map(_videoFromApp).toList();
});

// ── Filter tabs ───────────────────────────────────────────────────────────────
const _tabs = ['Tout', 'Petit-dej', 'Protéiné', 'Végé', 'Vegan', 'Sans Gluten'];

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
  String _q = '';
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  List<RealRecipe> _filter(List<RealRecipe> all) {
    var list = all.toList();
    if (_tab > 0) {
      final cat = _tabs[_tab];
      list = list.where((r) => r.tags.any((t) =>
        t.toLowerCase() == cat.toLowerCase())).toList();
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
    final filtered = _filter(recipes);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ────────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(20, top + 14, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.chevronLeft,
                        color: cs.onSurface, size: 20))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => HapticFeedback.selectionClick(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: favs.isNotEmpty
                            ? const Color(0xFFE03050).withOpacity(0.08)
                            : cs.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12)),
                      child: Stack(clipBehavior: Clip.none, children: [
                        Center(child: Icon(LucideIcons.heart, size: 18,
                          color: favs.isNotEmpty
                              ? const Color(0xFFE03050)
                              : cs.onSurface.withOpacity(0.4))),
                        if (favs.isNotEmpty) Positioned(
                          top: 4, right: 4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE03050), shape: BoxShape.circle),
                            child: Center(child: Text('${favs.length}',
                              style: GoogleFonts.inter(fontSize: 8,
                                fontWeight: FontWeight.w800, color: Colors.white))))),
                      ]))),
                ]),
                const SizedBox(height: 20),
                Text('RECETTES', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: cs.primary, letterSpacing: 2.5)),
                const SizedBox(height: 2),
                Text('Explorer', style: GoogleFonts.outfit(
                  fontSize: 28, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.5)),
              ]),
            )),

            // ── Search ────────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  Icon(LucideIcons.search, size: 16,
                    color: cs.onSurface.withOpacity(0.35)),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(
                    controller: _ctrl,
                    onChanged: (v) => setState(() => _q = v),
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une recette…',
                      hintStyle: GoogleFonts.inter(fontSize: 14,
                        color: cs.onSurface.withOpacity(0.3)),
                      border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.zero))),
                  if (_q.isNotEmpty) GestureDetector(
                    onTap: () { _ctrl.clear(); setState(() => _q = ''); },
                    child: Icon(LucideIcons.x, size: 16,
                      color: cs.onSurface.withOpacity(0.35))),
                ])),
            )),

            // ── Tabs ──────────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? cs.primary : cs.outline.withOpacity(0.15))),
                        child: Text(_tabs[i], style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? Colors.white : cs.onSurface.withOpacity(0.5)))));
                  }),
              ),
            )),

            // ── Recommended meals ────────────────────────────────────
            if (_tab == 0 && _q.isEmpty)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Builder(builder: (ctx) {
                  final profile = ref.watch(userProfileProvider);
                  final goalId = switch (profile.goal) {
                    core.NutritionGoal.loss     => 'loss',
                    core.NutritionGoal.maintain => 'maintain',
                    core.NutritionGoal.gain     => 'muscle',
                  };
                  return RecommendedMealsSection(initialGoalId: goalId);
                }))),

            // ── Video section ─────────────────────────────────────────
            if (videos.isNotEmpty && _tab == 0 && _q.isEmpty) ...[
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(LucideIcons.play, size: 12, color: cs.primary)),
                  const SizedBox(width: 10),
                  Text('Vidéos', style: GoogleFonts.outfit(
                    fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
                  const Spacer(),
                  Text('${videos.length} recette${videos.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(fontSize: 11,
                      color: cs.onSurface.withOpacity(0.35))),
                ]))),
              SliverToBoxAdapter(child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: videos.length,
                  itemBuilder: (_, i) => _VideoTile(
                    recipe: videos[i],
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: videos[i])))),
                ),
              )),
            ],

            // ── Recipe grid header ────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8)),
                  child: Icon(LucideIcons.chefHat, size: 12, color: cs.primary)),
                const SizedBox(width: 10),
                Text('Toutes les recettes', style: GoogleFonts.outfit(
                  fontSize: 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
                const Spacer(),
                Text('${filtered.length} résultat${filtered.length != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(fontSize: 11,
                    color: cs.onSurface.withOpacity(0.35))),
              ]))),

            // ── Loading ───────────────────────────────────────────────
            if (recipesAsync.isLoading)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(
                  strokeWidth: 2, color: cs.primary)))),

            // ── Empty ─────────────────────────────────────────────────
            if (!recipesAsync.isLoading && filtered.isEmpty)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Column(children: [
                  Icon(LucideIcons.searchX, size: 32,
                    color: cs.onSurface.withOpacity(0.12)),
                  const SizedBox(height: 14),
                  Text('Aucune recette trouvée', style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.4))),
                ])))),

            // ── Recipe grid (2 columns) ───────────────────────────────
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
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12))),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// VIDEO TILE (horizontal scroll)
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
        width: 160,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.1)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Expanded(
            flex: 3,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primary.withOpacity(0.06))),
              Container(decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)]))),
              Center(child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: Icon(LucideIcons.play, color: cs.primary, size: 14))),
              Positioned(bottom: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)))),
              // Phase badge
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pi.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 5, height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(pi.label, style: GoogleFonts.inter(
                      fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]))),
            ])),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.3)),
                  // Author
                  if (recipe.authorName != null) ...[
                    GestureDetector(
                      onTap: recipe.authorId != null ? () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => RecipeAuthorScreen(
                            userId: recipe.authorId!, username: recipe.authorName!)));
                      } : null,
                      child: Row(children: [
                        Container(width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Center(child: Text(recipe.authorName![0].toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 7,
                              fontWeight: FontWeight.w800, color: cs.primary)))),
                        const SizedBox(width: 4),
                        Text(recipe.authorName!, style: GoogleFonts.inter(
                          fontSize: 9.5, fontWeight: FontWeight.w600, color: cs.primary)),
                      ])),
                  ],
                  Row(children: [
                    Icon(LucideIcons.flame, size: 10, color: cs.primary),
                    const SizedBox(width: 3),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.w600, color: cs.primary)),
                  ]),
                ])),
          ),
          Container(height: 3, color: pi.color),
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
          border: Border.all(color: cs.outline.withOpacity(0.1)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null ? child
                    : Container(color: cs.primary.withOpacity(0.05)),
                errorBuilder: (_, __, ___) => Container(
                  color: cs.primary.withOpacity(0.06),
                  child: Icon(LucideIcons.chefHat, size: 28,
                    color: cs.primary.withOpacity(0.2)))),

              // Fav button
              Positioned(top: 8, right: 8,
                child: GestureDetector(
                  onTap: onFav,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: isFav
                          ? const Color(0xFFE03050)
                          : Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle),
                    child: Icon(LucideIcons.heart, size: 13,
                      color: Colors.white)))),

              // Phase badge
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pi.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 5, height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(pi.label, style: GoogleFonts.inter(
                      fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]))),

              // Duration badge
              Positioned(bottom: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.clock, size: 9, color: Colors.white),
                    const SizedBox(width: 3),
                    Text(recipe.duration, style: GoogleFonts.inter(
                      fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)),
                  ]))),
            ])),

          // Info
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.25)),

                  const Spacer(),

                  // Author row
                  if (recipe.authorName != null) ...[
                    GestureDetector(
                      onTap: recipe.authorId != null ? () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => RecipeAuthorScreen(
                            userId: recipe.authorId!, username: recipe.authorName!)));
                      } : null,
                      child: Row(children: [
                        Container(width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1), shape: BoxShape.circle),
                          child: Center(child: Text(recipe.authorName![0].toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 8,
                              fontWeight: FontWeight.w800, color: cs.primary)))),
                        const SizedBox(width: 5),
                        Expanded(child: Text(recipe.authorName!, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 10.5,
                            fontWeight: FontWeight.w600, color: cs.primary))),
                      ])),
                    const SizedBox(height: 6),
                  ],

                  // Kcal + difficulty
                  Row(children: [
                    Icon(LucideIcons.flame, size: 10, color: cs.primary),
                    const SizedBox(width: 3),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.w600, color: cs.primary)),
                    const Spacer(),
                    Text(recipe.difficulty, style: GoogleFonts.inter(
                      fontSize: 9.5, color: cs.onSurface.withOpacity(0.35))),
                  ]),
                ])),
          ),
          Container(height: 3, color: pi.color),
        ]),
      ),
    );
  }
}
