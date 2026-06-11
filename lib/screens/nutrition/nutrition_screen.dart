import 'package:fiteva/core/nutrition/models.dart' as core;
import 'package:fiteva/core/nutrition/nutrition_provider.dart';
import 'package:fiteva/screens/nutrition/widgets/recommended_meals_section.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';
import 'widgets/home/home_widgets.dart';

import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'recette_detail_screen.dart';

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

  static const _recipes = [
    RecipeItem(
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
      'Salade bowl', 'Salade bowl', Color(0xFFD4E8D0),
      duration: '15 min', difficulty: 'Facile'),
    RecipeItem(
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&q=80',
      'Oeufs brouillés', 'Oeufs brouillés', Color(0xFFE8D4C8),
      duration: '10 min', difficulty: 'Très facile'),
    RecipeItem(
      'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400&q=80',
      'Toast avocat', 'Toast avocat', Color(0xFFD0D8E8),
      duration: '8 min', difficulty: 'Très facile'),
    RecipeItem(
      'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
      'Soupe légumes', 'Soupe légumes', Color(0xFFE8E0D0),
      duration: '25 min', difficulty: 'Facile'),
  ];

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

  @override
  Widget build(BuildContext context) {
    final totals  = ref.watch(todayTotalsProvider);
    final profile = ref.watch(userProfileProvider);
    final key     = todayKey;

    // Build live categories from provider
    final categories = core.MealType.values.map((type) {
      final entries = ref.watch(mealsForTypeProvider((dateKey: key, type: type)));
      final typeTotals = core.DailyTotals.from(entries);
      return MealCategoryData(
        _mealImageUrl(type),
        type.label,
        typeTotals.calories,
        type.budgetKcal,
        typeTotals.protein.toDouble(),
        typeTotals.carbs.toDouble(),
        time: _mealTime(type),
        recipeCount: entries.length,
      );
    }).toList();

    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ────────────────────────────────────────────────────────
          SharedAppHeader.sliver(
            eyebrow:     'Nutrition',
            title:       'Mon alimentation',
            accentColor: _kMint,
          ),

          // ── Hero: daily summary card ──────────────────────────────────────
         

          // ── Calorie ring ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _CalorieRingCard(
                anim:     _anim,
                consumed: totals.calories,
                goal:     profile.dailyKcal,
                protein:  totals.protein,
                carbs:    totals.carbs,
                fat:      totals.fat,
                proteinGoal: profile.dailyProtein,
                carbsGoal:   profile.dailyCarbs,
                fatGoal:     profile.dailyFat,
              ),
            ),
          ),

          // ── Meals list ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: MealsContainer(
                categories: categories,
                onMealTap:  _goToSuivi,
              ),
            ),
          ),

          // ── Recommended meals ─────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 32, 0, 0),
              child: RecommendedMealsSection(initialGoalId: 'loss'),
            ),
          ),

          // ── Recipes ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
              child: SectionHeader(
                eyebrow:  'RECETTES',
                title:    'Nouvelles recettes',
                onSeeAll: _goToRecipes))),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 162,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _recipes.length,
                  itemBuilder: (_, i) => RecipeCard(
                    recipe: _recipes[i],
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        RecipeDetailScreen(recipe: _recipes[i])))),
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

  const _CalorieRingCard({
    required this.anim,
    required this.consumed, required this.goal,
    required this.protein,  required this.carbs,  required this.fat,
    required this.proteinGoal, required this.carbsGoal, required this.fatGoal,
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
                  ? '+${(-remaining)} kcal dépassés'
                  : '$remaining kcal restantes',
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
