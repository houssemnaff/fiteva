import 'package:fiteva/screens/nutrition/health_nutrition_widgets.dart';
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'models/models.dart';
import 'widgets/shared/shared_widgets.dart';
import 'widgets/home/home_widgets.dart';

import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'nutruition_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────
// Enum onglet
// ─────────────────────────────────────────────────────────────────
enum _Tab { nutrition, sante }

// ─────────────────────────────────────────────────────────────────
// Screen principal
// ─────────────────────────────────────────────────────────────────
class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation (DailyTrackingCard) ─────────────────────────────
  late AnimationController _ctrl;
  late Animation<double> _anim;

  // ── Onglet actif ──────────────────────────────────────────────
  _Tab _activeTab = _Tab.nutrition;

  // ── Données repas ─────────────────────────────────────────────
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
      'Salade bowl', 'Salade bowl', Color(0xFFD4E8D0),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=400&q=80',
      'Oeufs brouillés', 'Oeufs brouillés', Color(0xFFE8D4C8),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1588137378633-dea1336ce1e2?w=400&q=80',
      'Toast avocat', 'Toast avocat', Color(0xFFD0D8E8),
    ),
    RecipeItem(
      'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
      'Soupe légumes', 'Soupe légumes', Color(0xFFE8E0D0),
    ),
  ];

  // ── Données santé ─────────────────────────────────────────────
  static const _alerts = [
    HealthAlert(
      type: AlertType.danger,
      icon: Icons.warning_amber_rounded,
      text: 'Tu n\'as mangé que 865 kcal aujourd\'hui — objectif 2 000 kcal.',
    ),
    HealthAlert(
      type: AlertType.warning,
      icon: Icons.water_drop_outlined,
      text: 'Hydratation insuffisante : 1,2 L / 2,5 L recommandés.',
    ),
    HealthAlert(
      type: AlertType.info,
      icon: Icons.eco_outlined,
      text: 'Besoin de plus de fer aujourd\'hui (phase menstruelle).',
    ),
  ];

  static const _experts = [
    ExpertAdvice(
      name: 'Dr. Sana Ben Ali',
      role: 'Nutritionniste clinique',
      initials: 'SB',
      color: Color(0xFF185FA5),
      bg: Color(0xFFE6F1FB),
      title: 'Protéines & cycle menstruel',
      body:
          'Les besoins en protéines augmentent de 15–20 % en phase lutéale. '
          'Prioriser les légumineuses et les œufs pour soutenir la synthèse hormonale.',
      tag: 'Hormones',
    ),
    ExpertAdvice(
      name: 'Dr. Leila Mrad',
      role: 'Médecin endocrinologue',
      initials: 'LM',
      color: Color(0xFF0F6E56),
      bg: Color(0xFFE1F5EE),
      title: 'Alimentation anti-fatigue',
      body:
          'La carence en fer est la première cause de fatigue féminine. '
          'Un bilan sanguin annuel et des aliments fortifiés permettent de maintenir l\'énergie durablement.',
      tag: 'Énergie',
    ),
  ];

  static const _currentPhase = CyclePhase.luteale;
  static const _foodTags = [
    '🍌 Banane', '🥜 Amandes', '🥦 Brocoli', '🐟 Saumon'
  ];

  // ── Lifecycle ─────────────────────────────────────────────────
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

  // ── Navigation ────────────────────────────────────────────────
  void _goToSuivi(String mealId) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SuiviNutritionScreen(initialMealId: mealId)));

  void _goToRecipes() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const RecipesListScreen()));

  void _goToAjout() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const AjoutRapideScreen()));

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: CustomScrollView(
        slivers: [
          // ── Header avec tabs ──────────────────────────────────
          _NutritionTabHeader(
            activeTab: _activeTab,
            onTab: (t) => setState(() => _activeTab = t),
          ),

          // ════════════════════════════════════════════════════
          // TAB NUTRITION
          // ════════════════════════════════════════════════════
          if (_activeTab == _Tab.nutrition) ...[
            // Carte suivi journalier
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: DailyTrackingCard(
                  anim: _anim,
                  onConsulter: () => _goToSuivi('lunch'),
                  onCamera: _goToAjout,
                  onBarcode: _goToAjout,
                  onRecipes: _goToRecipes,
                  onEdit: _goToAjout,
                  caloriesConsumed: 865,
                  caloriesGoal: 2000,
                ),
              ),
            ),

            // Liste repas
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MealCategoryCard(
                      data: _categories[i],
                      onTap: () => _goToSuivi(
                          ['breakfast', 'lunch', 'snack', 'dinner'][i]),
                    ),
                  ),
                  childCount: _categories.length,
                ),
              ),
            ),

            // Header recettes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: SectionHeader(
                    title: 'Nouvelles recettes', onSeeAll: _goToRecipes),
              ),
            ),

            // Liste horizontale recettes
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
                            builder: (_) =>
                                RecipeDetailScreen(recipe: _recipes[i])),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ════════════════════════════════════════════════════
          // TAB SANTÉ
          // ════════════════════════════════════════════════════
          if (_activeTab == _Tab.sante) ...[
            // Alertes
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: HealthAlertsSection(alerts: _alerts),
              ),
            ),

            // Suivi nutritionnel + macros
            

            // Water tracker
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: const WaterTrackerCard(initialMl: 1200, goalMl: 2500),
              ),
            ),

            // Recommandation du jour
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: DailyRecommendationCard(
                  phase: _currentPhase,
                  foodTags: _foodTags,
                ),
              ),
            ),

            // Cycle nutrition
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: CycleNutritionSection(initialPhase: _currentPhase),
              ),
            ),

            // Conseils d'experts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: ExpertAdviceSection(experts: _experts),
              ),
            ),
          ],

          // Espace bas commun aux deux tabs
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SliverAppBar avec header + tabs intégrés
// ─────────────────────────────────────────────────────────────────
class _NutritionTabHeader extends StatelessWidget {
  final _Tab activeTab;
  final ValueChanged<_Tab> onTab;

  const _NutritionTabHeader({
    required this.activeTab,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    // hauteur expandée = padding status bar + titre + tabs + marges
    final expandedH = topPad + 130.0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedH,
      collapsedHeight: topPad + 56, // tabs toujours visibles
      backgroundColor: const Color(0xFFF5F3EE),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // fraction de collapse (0 = expanded, 1 = collapsed)
          final collapsed =
              1 - ((constraints.maxHeight - (topPad + 56)) / 74).clamp(0.0, 1.0);

          return Container(
            color: const Color(0xFFF5F3EE),
            padding: EdgeInsets.only(
              top: topPad + 12,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre + avatar (disparaît en scrollant)
                AnimatedOpacity(
                  opacity: (1 - collapsed * 2).clamp(0.0, 1.0),
                  duration: Duration.zero,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Bonjour, Yasmine 👋',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888780),
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mon espace santé',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2C2A),
                                  letterSpacing: -0.3),
                            ),
                          ],
                        ),
                      ),
                      // Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE1F5EE),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1D9E75).withOpacity(0.3),
                              width: 1.5),
                        ),
                        child: const Center(
                          child: Text('Y',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F6E56))),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Tabs — toujours visibles
                _TabBar(activeTab: activeTab, onTab: onTab),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Tab bar pill — Nutrition / Santé
// ─────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final _Tab activeTab;
  final ValueChanged<_Tab> onTab;

  const _TabBar({required this.activeTab, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E1DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabPill(
            label: '🥗  Nutrition',
            selected: activeTab == _Tab.nutrition,
            onTap: () => onTab(_Tab.nutrition),
            activeTextColor: const Color(0xFF2C2C2A),
          ),
          const SizedBox(width: 3),
          _TabPill(
            label: '🩺  Santé',
            selected: activeTab == _Tab.sante,
            onTap: () => onTab(_Tab.sante),
            activeTextColor: const Color(0xFF185FA5),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeTextColor;

  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? activeTextColor : const Color(0xFF888780),
            ),
          ),
        ),
      ),
    );
  }
}