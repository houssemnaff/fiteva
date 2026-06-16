import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/core/nutrition/models.dart' as core;
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/screens/nutrition/widgets/recommended_meals_section.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import 'widgets/home/home_widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/lang.dart';

import '../../providers/xp_provider.dart';
import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'recette_detail_screen.dart';
import 'recipe_video_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kMint  = Color(0xFF7ABB98);
const _kCream = Color(0xFFFEFEFE);

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class NutritionHomeScreen extends ConsumerStatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  ConsumerState<NutritionHomeScreen> createState() =>
      _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends ConsumerState<NutritionHomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  // Fix #4 — sync with allRecipes (take first 4)
  static List<RecipeItem> get _recipes => allRecipes.take(4).map((r) =>
    RecipeItem(r.imageUrl, r.name, r.name, r.accent,
      duration: r.duration, difficulty: r.difficulty)).toList();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _goToSuivi(String id) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => SuiviNutritionScreen(initialMealId: id)));

  void _goToRecipes() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const RecipesListScreen()));

  void _goToAjout() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AjoutRapideScreen()),
    );
    if (result == null || !mounted) return;
    final entries = result['entries'] as List<core.MealEntry>?;
    if (entries != null && entries.isNotEmpty) {
      for (final entry in entries) {
        ref.read(nutritionProvider.notifier).addMeal(entry);
      }
    }
  }

  static String _mealImageUrl(core.MealType type) {
    switch (type) {
      case core.MealType.breakfast: return 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&q=80';
      case core.MealType.lunch:     return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80';
      case core.MealType.snack:     return 'https://images.unsplash.com/photo-1555685812-4b943f1cb0eb?w=400&q=80';
      case core.MealType.dinner:    return 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80';
    }
  }

  static String _mealTime(core.MealType type) {
    switch (type) {
      case core.MealType.breakfast: return '7h – 9h';
      case core.MealType.lunch:     return '12h – 14h';
      case core.MealType.snack:     return '16h – 17h';
      case core.MealType.dinner:    return '19h – 21h';
    }
  }

  // Fix #3 — map NutritionGoal → goalId string
  String _goalId(core.NutritionGoal g) => switch (g) {
    core.NutritionGoal.loss     => 'loss',
    core.NutritionGoal.maintain => 'maintain',
    core.NutritionGoal.gain     => 'muscle',
  };

  @override
  Widget build(BuildContext context) {
    final totals  = ref.watch(todayTotalsProvider);
    final profile = ref.watch(userProfileProvider);
    final key     = todayKey;

    final categories = core.MealType.values.map((type) {
      final entries    = ref.watch(mealsForTypeProvider((dateKey: key, type: type)));
      final typeTotals = core.DailyTotals.from(entries);
      return MealCategoryData(
        _mealImageUrl(type), type.labelFor(Lang.code),
        typeTotals.calories, type.budgetKcal,
        typeTotals.protein.toDouble(), typeTotals.carbs.toDouble(),
        time: _mealTime(type), recipeCount: entries.length,
      );
    }).toList();

    final hasAnyMeal = totals.calories > 0;
    final recipes    = _recipes;
    final nc         = NutritionColors.of(context);

    return Scaffold(
      backgroundColor: nc.bg,
      // Fix #1 — FAB "Ajouter un aliment"
      floatingActionButton: Consumer(
        builder: (ctx, r, _) {
          final l10n = r.watch(l10nProvider);
          return FloatingActionButton.extended(
            onPressed: () { HapticFeedback.mediumImpact(); _goToAjout(); },
            backgroundColor: const Color(0xFF1C4D30),
            elevation: 4,
            icon: const Icon(LucideIcons.plus, color: Colors.white, size: 18),
            label: Text(l10n.nutritionAdd, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          );
        },
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          SharedAppHeader.sliver(
            eyebrow: 'Nutrition', title: ref.watch(l10nProvider).nutritionMyDiet, accentColor: _kMint,
            actions: [
              Consumer(builder: (ctx, r, _) {
                final favCount = r.watch(favoritesProvider).length;
                return GestureDetector(
                  onTap: () => Navigator.push(ctx, MaterialPageRoute(
                    builder: (_) => const _FavoritesScreen())),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: favCount > 0
                            ? const Color(0xFFFFEEF1)
                            : const Color(0xFFF4F4F4),
                        shape: BoxShape.circle),
                      child: Icon(LucideIcons.heart,
                        size: 18,
                        color: favCount > 0
                            ? const Color(0xFFE03050)
                            : const Color(0xFF9CA3AF))),
                    if (favCount > 0)
                      Positioned(
                        top: -3, right: -3,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE03050),
                            shape: BoxShape.circle),
                          child: Center(child: Text('$favCount',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 9,
                              fontWeight: FontWeight.w700))))),
                  ]),
                );
              }),
            ]),

          // Fix #2 — ring tappable → SuiviNutritionScreen
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SuiviNutritionScreen())),
                child: _CalorieRingCard(
                  anim: _anim,
                  consumed: totals.calories, goal: profile.dailyKcal,
                  protein: totals.protein, carbs: totals.carbs, fat: totals.fat,
                  proteinGoal: profile.dailyProtein,
                  carbsGoal:   profile.dailyCarbs,
                  fatGoal:     profile.dailyFat,
                  l10n: ref.watch(l10nProvider),
                ),
              ),
            ),
          ),

          // XP goal banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: _NutritionXpBanner(
                consumed: totals.calories,
                goal: profile.dailyKcal,
              ),
            ),
          ),

          // Fix #5 — empty state CTA
          if (!hasAnyMeal)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _EmptyDayBanner(onTap: _goToAjout),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: MealsContainer(categories: categories, onMealTap: _goToSuivi),
            ),
          ),

          // Fix #3 — goal from profile
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
              child: RecommendedMealsSection(initialGoalId: _goalId(profile.goal)),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: SectionHeader(
                eyebrow: ref.watch(l10nProvider).nutritionRecipesEyebrow, title: ref.watch(l10nProvider).nutritionNewRecipes,
                onSeeAll: _goToRecipes))),

          // Fix #4 — recipes from allRecipes
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 162,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: recipes.length,
                  itemBuilder: (_, i) => RecipeCard(
                    recipe: recipes[i],
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        RecipeDetailScreen(recipe: recipes[i])))),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CALORIE RING CARD
// ══════════════════════════════════════════════════════════════════════════════
class _CalorieRingCard extends StatelessWidget {
  final Animation<double> anim;
  final int consumed, goal;
  final int protein, carbs, fat;
  final int proteinGoal, carbsGoal, fatGoal;
  final AppL10n l10n;

  const _CalorieRingCard({
    required this.anim,
    required this.consumed, required this.goal,
    required this.protein,  required this.carbs,  required this.fat,
    required this.proteinGoal, required this.carbsGoal, required this.fatGoal,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final pct       = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = goal - consumed;
    final over      = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C4D30),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: const Color(0xFF1C4D30).withOpacity(0.25),
          blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Row(children: [

        // ── Ring ────────────────────────────────────────────────────────────
        AnimatedBuilder(
          animation: anim,
          builder: (_, __) => SizedBox(
            width: 110, height: 110,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 110, height: 110,
                child: CircularProgressIndicator(
                  value: pct * anim.value,
                  strokeWidth: 9,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(
                    over ? const Color(0xFFFF6B6B) : const Color(0xFF7ABB98)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$consumed', style: GoogleFonts.outfit(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1)),
                Text('kcal', style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF7ABB98))),
              ]),
            ]),
          ),
        ),

        const SizedBox(width: 20),

        // ── Right side ──────────────────────────────────────────────────────
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Goal + remaining
          Text('/ $goal kcal', style: GoogleFonts.inter(
            fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: over
                  ? const Color(0xFFFF6B6B).withOpacity(0.18)
                  : Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20)),
            child: Text(
              over
                  ? '+${(-remaining)} ${l10n.nutritionKcalOver}'
                  : '$remaining ${l10n.nutritionKcalLeft}',
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: over ? const Color(0xFFFF6B6B) : const Color(0xFF7ABB98)))),

          const SizedBox(height: 14),

          // Macro mini-bars
          _MiniMacroBar('P', protein, proteinGoal, const Color(0xFF7ABB98)),
          const SizedBox(height: 6),
          _MiniMacroBar('G', carbs,   carbsGoal,   const Color(0xFF7BD4FF)),
          const SizedBox(height: 6),
          _MiniMacroBar('L', fat,     fatGoal,     const Color(0xFFFFB347)),
        ])),
      ]),
    );
  }
}

class _MiniMacroBar extends StatelessWidget {
  final String label;
  final int consumed, goal;
  final Color color;
  const _MiniMacroBar(this.label, this.consumed, this.goal, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Row(children: [
      SizedBox(width: 14, child: Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700, color: color))),
      const SizedBox(width: 6),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct, minHeight: 5,
          backgroundColor: Colors.white.withOpacity(0.12),
          valueColor: AlwaysStoppedAnimation(color)))),
      const SizedBox(width: 8),
      Text('${consumed}g', style: GoogleFonts.inter(
        fontSize: 9, color: Colors.white38)),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  EMPTY DAY BANNER  (Fix #5)
// ══════════════════════════════════════════════════════════════════════════════
class _NutritionXpBanner extends StatelessWidget {
  final int consumed;
  final int goal;
  const _NutritionXpBanner({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final reached = goal > 0 && consumed >= goal;
    final pct     = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: reached
            ? const Color(0xFF4CAF50).withOpacity(0.12)
            : const Color(0xFF1A2E20).withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: reached
              ? const Color(0xFF4CAF50).withOpacity(0.45)
              : const Color(0xFF4CAF50).withOpacity(0.20),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(reached ? '🏆' : '⭐', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                reached
                    ? 'Objectif atteint ! Tu as gagné +20 XP 🎉'
                    : 'Log tes repas du jour pour gagner +20 XP',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: reached
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF1A2E20),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: reached
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4CAF50).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('+20 XP',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: reached ? Colors.white : const Color(0xFF2E7D32),
                )),
            ),
          ]),
          if (!reached && goal > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 5,
                backgroundColor: const Color(0xFF4CAF50).withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${consumed} / $goal kcal — encore ${goal - consumed} kcal à logger',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF4CAF50).withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyDayBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyDayBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF7ABB98).withOpacity(0.4)),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1C4D30),
              borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.utensils, color: Colors.white, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.nutritionNoMealsToday, style: GoogleFonts.outfit(
              fontSize: 14, fontWeight: FontWeight.w700,
              color: const Color(0xFF1C4D30))),
            const SizedBox(height: 2),
            Text(l10n.nutritionStartTracking, style: GoogleFonts.inter(
              fontSize: 12, color: const Color(0xFF6B7280))),
          ])),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  FAVORITES SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class _FavoritesScreen extends ConsumerWidget {
  const _FavoritesScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n     = ref.watch(l10nProvider);
    final top      = MediaQuery.of(context).padding.top;
    final favNames = ref.watch(favoritesProvider);

    // Merge image + video recipes, keep only favorites
    final imageFavs = allRecipes
        .where((r) => favNames.contains(r.name))
        .toList();
    final videoFavs = videoRecipes
        .where((r) => favNames.contains(r.name))
        .toList();
    final isEmpty = imageFavs.isEmpty && videoFavs.isEmpty;

    final nc = NutritionColors.of(context);
    const kRed = Color(0xFFE03050);

    return Scaffold(
      backgroundColor: nc.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // Header
          SliverToBoxAdapter(
            child: Container(
              color: nc.surface,
              padding: EdgeInsets.fromLTRB(20, top + 16, 20, 16),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: kRed.withOpacity(nc.isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12)),
                    child: const Icon(LucideIcons.chevronLeft,
                      color: kRed, size: 18))),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.nutritionMyRecipes, style: GoogleFonts.inter(
                    color: kRed, fontSize: 9,
                    fontWeight: FontWeight.w700, letterSpacing: 3)),
                  Text(l10n.nutritionFavorites, style: GoogleFonts.outfit(
                    color: nc.text1, fontSize: 22,
                    fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                ]),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(nc.isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text('${favNames.length}', style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: kRed))),
              ]),
            ),
          ),

          // Empty state
          if (isEmpty)
            SliverFillRemaining(
              child: Center(child: Column(
                mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: kRed.withOpacity(nc.isDark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Icon(LucideIcons.heart,
                    color: kRed, size: 28)),
                const SizedBox(height: 16),
                Text(l10n.nutritionNoFavorites, style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: nc.text1)),
                const SizedBox(height: 6),
                Text(l10n.nutritionFavoriteHint,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13, color: nc.text2)),
              ])),
            ),

          // Image recipes section
          if (imageFavs.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(l10n.nutritionPhotoRecipes,
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: nc.text1)))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: imageFavs.length,
                itemBuilder: (ctx, i) {
                  final r = imageFavs[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(
                        recipe: RecipeItem(r.imageUrl, r.name, r.name, r.accent)))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: nc.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: nc.border)),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(r.imageUrl,
                            width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                              Container(width: 60, height: 60, color: r.accent.withOpacity(0.15)))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, style: GoogleFonts.outfit(
                            fontSize: 13.5, fontWeight: FontWeight.w700,
                            color: nc.text1)),
                          const SizedBox(height: 3),
                          Text('${r.kcal} kcal · ${r.duration}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5, color: nc.text2)),
                        ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: const Icon(LucideIcons.heart,
                            color: kRed, size: 20)),
                      ])),
                  );
                },
              ),
            ),
          ],

          // Video recipes section
          if (videoFavs.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Text(l10n.nutritionVideoRecipes,
                  style: GoogleFonts.outfit(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: nc.text1)))),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: videoFavs.length,
                itemBuilder: (ctx, i) {
                  final r = videoFavs[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: r))),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: nc.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: nc.border)),
                      child: Row(children: [
                        Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(r.imageUrl,
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                Container(width: 60, height: 60,
                                  color: const Color(0xFF1C4D30).withOpacity(0.10)))),
                          Positioned.fill(child: Center(
                            child: Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C4D30).withOpacity(0.85),
                                shape: BoxShape.circle),
                              child: const Icon(LucideIcons.play,
                                color: Colors.white, size: 10)))),
                        ]),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name, style: GoogleFonts.outfit(
                            fontSize: 13.5, fontWeight: FontWeight.w700,
                            color: nc.text1)),
                          const SizedBox(height: 3),
                          Text('${r.kcal} kcal · ${r.duration}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5, color: nc.text2)),
                        ])),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ref.read(favoritesProvider.notifier).toggle(r.name);
                          },
                          child: const Icon(LucideIcons.heart,
                            color: Color(0xFFE03050), size: 20)),
                      ])),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
