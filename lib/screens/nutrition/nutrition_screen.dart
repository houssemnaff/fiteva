import 'package:fiteva/screens/nutrition/health_nutrition_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import 'widgets/home/home_widgets.dart';

import 'suivi_nutrition_screen.dart';
import 'recipes_list_screen.dart';
import 'ajout_rapide_screen.dart';
import 'recette_detail_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kGreen  = Color(0xFF1C4D30);
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFEFEFE);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF1A1A1A);
const _kText2  = Color(0xFF6B7280);

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class NutritionHomeScreen extends StatefulWidget {
  const NutritionHomeScreen({super.key});

  @override
  State<NutritionHomeScreen> createState() => _NutritionHomeScreenState();
}

class _NutritionHomeScreenState extends State<NutritionHomeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _anim;

  static const _categories = [
    MealCategoryData(
      'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
      'Petit déjeuner', 333, 500, 10.0, 30.0, time: '08 h 00', recipeCount: 3),
    MealCategoryData(
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      'Déjeuner', 198, 600, 8.0, 40.0, time: '12 h 30', recipeCount: 2),
    MealCategoryData(
      'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
      'Collation', 0, 200, 0.0, 15.0, time: '16 h 00', recipeCount: 0),
    MealCategoryData(
      'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      'Dîner', 0, 620, 0.0, 45.0, time: '19 h 30', recipeCount: 0),
  ];

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

  static const _experts = [
    ExpertAdvice(
      name: 'Dr. Sana Ben Ali', role: 'Nutritionniste clinique',
      initials: 'SB', color: Color(0xFF185FA5), bg: Color(0xFFE6F1FB),
      title: 'Protéines & cycle menstruel',
      body: 'Les besoins en protéines augmentent de 15–20 % en phase lutéale. '
          'Prioriser les légumineuses et les œufs pour soutenir la synthèse hormonale.',
      tag: 'Hormones'),
    ExpertAdvice(
      name: 'Dr. Leila Mrad', role: 'Médecin endocrinologue',
      initials: 'LM', color: Color(0xFF0F6E56), bg: Color(0xFFE1F5EE),
      title: 'Alimentation anti-fatigue',
      body: 'La carence en fer est la première cause de fatigue féminine. '
          'Un bilan sanguin annuel et des aliments fortifiés permettent de maintenir l\'énergie durablement.',
      tag: 'Énergie'),
  ];

  static const _currentPhase = CyclePhase.luteale;

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

  void _goToAjout() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => const AjoutRapideScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Sticky editorial header ───────────────────────────
          _NutritionHeader(),

          // ══════════════════════════════════════════════════════
          // NUTRITION SECTION
          // ══════════════════════════════════════════════════════

          // Daily tracking card
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

          // Meal categories
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MealCategoryCard(
                    data: _categories[i],
                    onTap: () => _goToSuivi(
                        ['breakfast', 'lunch', 'snack', 'dinner'][i]))),
                childCount: _categories.length)),
          ),

          // Recipes section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: SectionHeader(title: 'Nouvelles recettes', onSeeAll: _goToRecipes))),

          // Horizontal recipe scroll
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
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

          // ══════════════════════════════════════════════════════
          // SANTÉ & BIEN-ÊTRE SECTION
          // ══════════════════════════════════════════════════════

          const SliverToBoxAdapter(child: _SanteDivider()),

          // 1. Score Vitalité (new)
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _VitalityScoreCard())),

          // 2. Micronutriments clés (new)
          const SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _MicronutrientsCard())),

          // 3. Signal du moment (new)
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _BodySignalCard())),

          // 4. Water tracker (existing)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: const WaterTrackerCard(initialMl: 1200, goalMl: 2500))),

          // 5. Cycle nutrition (existing)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: CycleNutritionSection(initialPhase: _currentPhase))),

          // 6. Expert advice (existing)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ExpertAdviceSection(experts: _experts))),

          const SliverToBoxAdapter(child: SizedBox(height: 110)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HEADER — no tabs
// ══════════════════════════════════════════════════════════════════════════════
class _NutritionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return SliverAppBar(
      pinned: true,
      expandedHeight: top + 100.0,
      collapsedHeight: top + 56,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: LayoutBuilder(builder: (_, constraints) {
        final collapsed =
            1 - ((constraints.maxHeight - (top + 56)) / 44).clamp(0.0, 1.0);
        return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: (1 - collapsed * 2.2).clamp(0.0, 1.0),
                duration: Duration.zero,
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('NUTRITION', style: GoogleFonts.inter(
                      color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                      letterSpacing: 3.5)),
                    const SizedBox(height: 2),
                    Text('Mon alimentation', style: GoogleFonts.outfit(
                      color: _kGreen, fontSize: 24, fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
                  ]),
                  const Spacer(),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _kMintBg, shape: BoxShape.circle,
                      border: Border.all(color: _kMint, width: 1.5)),
                    child: Center(child: Text('Y', style: GoogleFonts.outfit(
                      color: _kGreen, fontSize: 15, fontWeight: FontWeight.w700)))),
                ]),
              ),
              const Spacer(),
              // Date row (stays visible when collapsed)
              Row(children: [
                const Icon(LucideIcons.calendarDays, size: 12, color: _kText2),
                const SizedBox(width: 5),
                Text(_todayLabel(), style: GoogleFonts.inter(
                  fontSize: 12, color: _kText2)),
                const Spacer(),
                Container(width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: _kMint, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('Sur la bonne voie', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
              ]),
            ],
          ),
        );
      }),
    );
  }

  static String _todayLabel() {
    final now = DateTime.now();
    const j = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    const m = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
    return '${j[now.weekday - 1]} ${now.day} ${m[now.month - 1]}';
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SANTÉ SECTION DIVIDER
// ══════════════════════════════════════════════════════════════════════════════
class _SanteDivider extends StatelessWidget {
  const _SanteDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 3, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [_kMint, _kGreen]),
              borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SANTÉ & BIEN-ÊTRE', style: GoogleFonts.inter(
              color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
              letterSpacing: 3.5)),
            const SizedBox(height: 2),
            Text('Mon bilan', style: GoogleFonts.outfit(
              color: _kGreen, fontSize: 24, fontWeight: FontWeight.w800,
              letterSpacing: -0.4)),
          ]),
        ]),
        const SizedBox(height: 14),
        Container(height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kMint, Colors.transparent]))),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 1. SCORE VITALITÉ
// ══════════════════════════════════════════════════════════════════════════════
class _VitalityScoreCard extends StatelessWidget {
  const _VitalityScoreCard();

  static const _items = [
    ('Calories',    0.86, Color(0xFF7BA7FF)),
    ('Macros',      0.72, _kMint),
    ('Hydratation', 0.48, Color(0xFF7BD4FF)),
    ('Cycle',       0.90, Color(0xFFFFB347)),
  ];

  @override
  Widget build(BuildContext context) {
    const score = 74;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
          color: _kGreen.withValues(alpha: 0.28),
          blurRadius: 20, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('SCORE VITALITÉ', style: GoogleFonts.inter(
            color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
            letterSpacing: 2.5)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20)),
            child: Text('Aujourd\'hui', style: GoogleFonts.inter(
              fontSize: 10, color: Colors.white60))),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Score ring
          SizedBox(
            width: 90, height: 90,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 90, height: 90,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation(_kMint),
                  strokeCap: StrokeCap.round)),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$score', style: GoogleFonts.outfit(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white, height: 1)),
                Text('/100', style: GoogleFonts.inter(
                  fontSize: 10, color: _kMint)),
              ]),
            ])),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: _items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(width: 70,
                    child: Text(item.$1, style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.white60))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: item.$2, minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(item.$3)))),
                  const SizedBox(width: 8),
                  Text('${(item.$2 * 100).round()}%', style: GoogleFonts.inter(
                    fontSize: 10, color: item.$3, fontWeight: FontWeight.w700)),
                ])))
              .toList(),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            const Icon(LucideIcons.trendingUp, size: 13, color: _kMint),
            const SizedBox(width: 8),
            Flexible(child: Text(
              'Hydratation à améliorer pour booster ton score',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white70))),
          ])),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. MICRONUTRIMENTS CLÉS
// ══════════════════════════════════════════════════════════════════════════════
class _MicronutrientsCard extends StatelessWidget {
  const _MicronutrientsCard();

  static const _nutrients = [
    _Nutrient('Fer',       12.0, 18.0, 'mg', Color(0xFFD94F6B), Color(0xFFFDF0F2)),
    _Nutrient('Calcium',  680.0, 1000.0, 'mg', Color(0xFF5BAE8A), Color(0xFFEEF8F3)),
    _Nutrient('Magnésium', 180.0, 310.0, 'mg', Color(0xFF6B8FD4), Color(0xFFF0F3FC)),
    _Nutrient('Oméga-3',    0.8, 1.6,  'g',  Color(0xFFF4A940), Color(0xFFFFF6E9)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('MICRONUTRIMENTS', style: GoogleFonts.inter(
          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.5)),
        const SizedBox(height: 3),
        Text('Nutriments essentiels', style: GoogleFonts.outfit(
          color: _kText1, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _nutrients.map((n) => _NutrientTile(n: n)).toList()),
      ]),
    );
  }
}

class _Nutrient {
  final String name, unit;
  final double current, goal;
  final Color color, bg;
  const _Nutrient(this.name, this.current, this.goal, this.unit, this.color, this.bg);
  double get pct => (current / goal).clamp(0.0, 1.0);
}

class _NutrientTile extends StatelessWidget {
  final _Nutrient n;
  const _NutrientTile({required this.n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: n.bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(width: 6, height: 6,
              decoration: BoxDecoration(color: n.color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(n.name, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: _kText1)),
            const Spacer(),
            Text('${(n.pct * 100).round()}%', style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700, color: n.color)),
          ]),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: n.pct, minHeight: 4,
              backgroundColor: n.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(n.color))),
          Text(
            '${n.current.toStringAsFixed(n.current < 10 ? 1 : 0)} / ${n.goal.toStringAsFixed(0)} ${n.unit}',
            style: GoogleFonts.inter(fontSize: 10, color: _kText2)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. SIGNAL DU MOMENT
// ══════════════════════════════════════════════════════════════════════════════
class _BodySignalCard extends StatefulWidget {
  @override
  State<_BodySignalCard> createState() => _BodySignalCardState();
}

class _BodySignalCardState extends State<_BodySignalCard> {
  int _energy    = -1;
  int _digestion = -1;
  int _humeur    = -1;

  @override
  Widget build(BuildContext context) {
    final allSet = _energy >= 0 && _digestion >= 0 && _humeur >= 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('SIGNAL DU MOMENT', style: GoogleFonts.inter(
          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2.5)),
        const SizedBox(height: 3),
        Text('Comment tu te sens ?', style: GoogleFonts.outfit(
          color: _kText1, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
        const SizedBox(height: 16),
        _SignalRow(
          icon: LucideIcons.zap,
          label: 'Énergie',
          options: ['Faible', 'Normale', 'Élevée'],
          color: const Color(0xFFF4A940),
          selected: _energy,
          onSelect: (i) => setState(() => _energy = i)),
        const SizedBox(height: 10),
        _SignalRow(
          icon: LucideIcons.activity,
          label: 'Digestion',
          options: ['Difficile', 'Correcte', 'Bonne'],
          color: const Color(0xFF5BAE8A),
          selected: _digestion,
          onSelect: (i) => setState(() => _digestion = i)),
        const SizedBox(height: 10),
        _SignalRow(
          icon: LucideIcons.sun,
          label: 'Humeur',
          options: ['Basse', 'Neutre', 'Bonne'],
          color: const Color(0xFF6B8FD4),
          selected: _humeur,
          onSelect: (i) => setState(() => _humeur = i)),
        if (allSet) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _kGreen, borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(
                color: _kGreen.withValues(alpha: 0.2),
                blurRadius: 12, offset: const Offset(0, 4))]),
            child: Center(child: Text('Enregistrer mon signal', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)))),
        ],
      ]),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> options;
  final Color color;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SignalRow({
    required this.icon, required this.label, required this.options,
    required this.color, required this.selected, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9)),
        child: Icon(icon, size: 13, color: color)),
      const SizedBox(width: 10),
      SizedBox(width: 70,
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: _kText1))),
      const Spacer(),
      ...List.generate(3, (i) => GestureDetector(
        onTap: () => onSelect(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(left: 5),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected == i ? color : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(20)),
          child: Text(options[i], style: GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w600,
            color: selected == i ? Colors.white : _kText2))))),
    ]);
  }
}
