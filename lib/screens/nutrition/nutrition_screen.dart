import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'models/models.dart';
import 'widgets/shared/shared_widgets.dart';
import 'widgets/home/home_widgets.dart';
import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'recipe_detail_screen.dart';

class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  static const _categories = [
    MealCategoryData(
      'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
      'Petit déjeuner', 333, 500, 10.0, 30.0,
      time: '08 h 00', recipeCount: 3,
    ),
    MealCategoryData(
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      'Déjeuner', 198, 600, 8.0, 40.0,
      time: '12 h 30', recipeCount: 2,
    ),
    MealCategoryData(
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
      'Collation', 0, 200, 0.0, 15.0,
      time: '16 h 00', recipeCount: 0,
    ),
    MealCategoryData(
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      'Dîner', 0, 620, 0.0, 45.0,
      time: '19 h 30', recipeCount: 0,
    ),
  ];

  static const _recipes = [
    RecipeItem(
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80',
      'Salade bowl',
      'Salade bowl',
      Color(0xFFD4E8D0),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&q=80',
      'Oeufs brouillés',
      'Oeufs brouillés',
      Color(0xFFE8D4C8),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400&q=80',
      'Toast avocat',
      'Toast avocat',
      Color(0xFFD0D8E8),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
      'Soupe légumes',
      'Soupe légumes',
      Color(0xFFE8E0D0),
    ),
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToSuivi() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const SuiviNutritionScreen()));

  void _goToRecipes() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const RecipesListScreen()));

  void _goToAjout() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const AjoutRapideScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────
          const NutritionHeader(),

          // ── Carte suivi journalier ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: DailyTrackingCard(
                anim: _anim,
                onConsulter: _goToSuivi,
                onCamera: _goToAjout,
                onBarcode: _goToAjout,
                onRecipes: _goToRecipes,
                onEdit: _goToAjout,
                caloriesConsumed: 865,
                caloriesGoal: 2000,
              ),
            ),
          ),

          // ── Grille repas ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => MealCategoryCard(
                  data: _categories[i],
                  onTap: _goToSuivi,
                ),
                childCount: _categories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
            ),
          ),

          // ── Section header recettes ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SectionHeader(
                title: 'Nouvelles recettes',
                onSeeAll: _goToRecipes,
              ),
            ),
          ),

          // ── Liste horizontale recettes ───────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 152,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: _recipes.length,
                  itemBuilder: (_, i) => RecipeCard(
                    recipe: _recipes[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(recipe: _recipes[i]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Espace bas de page ───────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}