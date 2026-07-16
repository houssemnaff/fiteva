// ignore_for_file: deprecated_member_use
import 'package:fiteva/screens/nutrition/models/models.dart';
import 'package:fiteva/screens/nutrition/recette_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _Goal {
  final String id, label;
  final IconData icon;
  final Color color;
  const _Goal({
    required this.id, required this.label,
    required this.icon, required this.color,
  });
}

class _RecoMeal {
  final String name, description, imageUrl, tag;
  final int kcal, protein, carbs, fat;
  const _RecoMeal({
    required this.name, required this.description,
    required this.imageUrl, required this.tag,
    required this.kcal, required this.protein,
    required this.carbs, required this.fat,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  DATA
// ─────────────────────────────────────────────────────────────────────────────
const _goals = [
  _Goal(id: 'loss',      label: 'Perte',     icon: LucideIcons.trendingDown, color: Color(0xFF5BAE8A)),
  _Goal(id: 'maintain',  label: 'Maintien',  icon: LucideIcons.minus,        color: Color(0xFF6B8FD4)),
  _Goal(id: 'muscle',    label: 'Muscle',    icon: LucideIcons.dumbbell,     color: Color(0xFFF4A940)),
  _Goal(id: 'pregnancy', label: 'Grossesse', icon: LucideIcons.heart,        color: Color(0xFFD94F6B)),
  _Goal(id: 'postpartum',label: 'Post-partum',icon: LucideIcons.sparkles,   color: Color(0xFF9B6FD4)),
];

const _meals = {
  'loss': [
    _RecoMeal(
      name: 'Bowl de quinoa & légumes rôtis',
      description: 'Riche en fibres, faible en calories — satiété durable.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Fibres',
      kcal: 320, protein: 14, carbs: 42, fat: 9,
    ),
    _RecoMeal(
      name: 'Poulet grillé & brocoli vapeur',
      description: 'Protéines maigres + légumes croquants pour rester rassasiée.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Protéiné',
      kcal: 280, protein: 38, carbs: 14, fat: 7,
    ),
    _RecoMeal(
      name: 'Soupe miso & tofu soyeux',
      description: 'Faible en calories, probiotiques naturels.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Détox',
      kcal: 190, protein: 12, carbs: 18, fat: 5,
    ),
    _RecoMeal(
      name: 'Salade niçoise légère',
      description: 'Thon, œuf dur, haricots verts — équilibre parfait.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Complet',
      kcal: 350, protein: 28, carbs: 20, fat: 14,
    ),
  ],
  'maintain': [
    _RecoMeal(
      name: 'Poke bowl saumon avocat',
      description: 'Oméga-3, glucides complexes et bons lipides.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Équilibré',
      kcal: 480, protein: 28, carbs: 52, fat: 16,
    ),
    _RecoMeal(
      name: 'Pasta complète pesto basilic',
      description: 'Énergie durable, satiété et plaisir gustatif.',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      tag: 'Glucides',
      kcal: 520, protein: 18, carbs: 68, fat: 18,
    ),
    _RecoMeal(
      name: 'Omelette champignons & fromage',
      description: 'Protéines complètes, lipides sains, rapide à préparer.',
      imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
      tag: 'Rapide',
      kcal: 410, protein: 26, carbs: 8, fat: 22,
    ),
    _RecoMeal(
      name: 'Riz thaï au lait de coco',
      description: 'Saveurs d\'Asie, macros équilibrées.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Savoureux',
      kcal: 460, protein: 16, carbs: 60, fat: 14,
    ),
  ],
  'muscle': [
    _RecoMeal(
      name: 'Steak de bœuf & patate douce',
      description: 'Protéines complètes + glucides à index glycémique bas.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Haute prot.',
      kcal: 620, protein: 52, carbs: 46, fat: 18,
    ),
    _RecoMeal(
      name: 'Blanc de dinde & riz basmati',
      description: 'Le classique — simple et efficace.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Classique',
      kcal: 550, protein: 56, carbs: 58, fat: 8,
    ),
    _RecoMeal(
      name: 'Greek bowl protéiné',
      description: 'Yaourt grec, pois chiches, concombre — récupération.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Récup.',
      kcal: 490, protein: 42, carbs: 38, fat: 14,
    ),
    _RecoMeal(
      name: 'Saumon & lentilles beluga',
      description: 'Oméga-3 anti-inflammatoires + protéines végétales.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Oméga-3',
      kcal: 570, protein: 48, carbs: 32, fat: 20,
    ),
  ],
  'pregnancy': [
    _RecoMeal(
      name: 'Épinards & lentilles corail au curry',
      description: 'Fer, acide folique et protéines végétales.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Fer',
      kcal: 380, protein: 18, carbs: 48, fat: 10,
    ),
    _RecoMeal(
      name: 'Sardines grillées & quinoa',
      description: 'Oméga-3 DHA essentiels au développement cérébral.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'DHA',
      kcal: 420, protein: 32, carbs: 36, fat: 14,
    ),
    _RecoMeal(
      name: 'Smoothie bowl avocat & banane',
      description: 'Potassium, magnésium, vitamine B6.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Anti-nausées',
      kcal: 340, protein: 8, carbs: 52, fat: 14,
    ),
    _RecoMeal(
      name: 'Soupe de potimarron & amandes',
      description: 'Zinc, calcium et bêta-carotène.',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      tag: 'Calcium',
      kcal: 290, protein: 10, carbs: 38, fat: 12,
    ),
  ],
  'postpartum': [
    _RecoMeal(
      name: 'Porridge avoine & graines de lin',
      description: 'Galactogènes naturels, oméga-3 et énergie durable.',
      imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
      tag: 'Allaitement',
      kcal: 360, protein: 12, carbs: 54, fat: 12,
    ),
    _RecoMeal(
      name: 'Bouillon de poulet maison',
      description: 'Collagène, minéraux et chaleur réconfortante.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Récupération',
      kcal: 310, protein: 24, carbs: 28, fat: 8,
    ),
    _RecoMeal(
      name: 'Salade betterave, noix & chèvre',
      description: 'Fer, magnésium et bons lipides.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Anti-fatigue',
      kcal: 390, protein: 14, carbs: 30, fat: 22,
    ),
    _RecoMeal(
      name: 'Œufs brouillés & légumes verts',
      description: 'Rapide à préparer, riche en vitamine D et B12.',
      imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
      tag: 'Vit. D · B12',
      kcal: 330, protein: 22, carbs: 16, fat: 18,
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
//  PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class RecommendedMealsSection extends ConsumerStatefulWidget {
  final String initialGoalId;
  const RecommendedMealsSection({super.key, this.initialGoalId = 'loss'});

  @override
  ConsumerState<RecommendedMealsSection> createState() =>
      _RecommendedMealsSectionState();
}

class _RecommendedMealsSectionState extends ConsumerState<RecommendedMealsSection> {
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialGoalId;
  }

  _Goal get _goal =>
      _goals.firstWhere((g) => g.id == _selectedId, orElse: () => _goals.first);

  List<_RecoMeal> get _currentMeals => _meals[_selectedId] ?? [];

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final goal = _goal;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Header ─────────────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(children: [
          Icon(LucideIcons.sparkles, size: 15, color: goal.color),
          const SizedBox(width: 8),
          Text('Recommandations', style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface)),
        ]),
      ),

      const SizedBox(height: 12),

      // ── Goal pills ─────────────────────────────────────────────────
      SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemCount: _goals.length,
          itemBuilder: (_, i) {
            final g = _goals[i];
            final sel = g.id == _selectedId;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedId = g.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? g.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: sel ? g.color : cs.outline.withOpacity(0.12))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(g.icon, size: 12,
                    color: sel ? Colors.white : cs.onSurface.withOpacity(0.35)),
                  const SizedBox(width: 5),
                  Text(g.label, style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? Colors.white : cs.onSurface.withOpacity(0.45))),
                ])));
          },
        ),
      ),

      const SizedBox(height: 14),

      // ── Featured card ──────────────────────────────────────────────
      if (_currentMeals.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              final meal = _currentMeals.first;
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (_) => RecipeDetailScreen(
                  recipe: RecipeItem(meal.imageUrl, meal.name, meal.name, goal.color))));
            },
            child: _FeaturedCard(meal: _currentMeals.first, goal: goal),
          ),
        ),

      const SizedBox(height: 10),

      // ── Horizontal cards ───────────────────────────────────────────
      if (_currentMeals.length > 1)
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: _currentMeals.length - 1,
            itemBuilder: (ctx, i) {
              final meal = _currentMeals[i + 1];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(ctx, rootNavigator: true).push(MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(
                      recipe: RecipeItem(meal.imageUrl, meal.name, meal.name, goal.color))));
                },
                child: _CompactCard(meal: meal, goal: goal),
              );
            },
          ),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FEATURED CARD
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final _RecoMeal meal;
  final _Goal goal;
  const _FeaturedCard({required this.meal, required this.goal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withOpacity(0.08))),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(meal.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: goal.color.withOpacity(0.08),
            child: Center(child: Icon(
              LucideIcons.salad, color: goal.color, size: 32)))),

        // Gradient
        DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.65),
            ],
            stops: const [0.3, 1.0]))),

        // Kcal top-right
        Positioned(top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(8)),
            child: Text('${meal.kcal} kcal', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)))),

        // Bottom info
        Positioned(bottom: 14, left: 14, right: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(meal.tag, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: Colors.white))),
              const SizedBox(height: 6),

              Text(meal.name, style: GoogleFonts.outfit(
                fontSize: 17, fontWeight: FontWeight.w800,
                color: Colors.white, height: 1.2)),
              const SizedBox(height: 4),

              Text(meal.description,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 11,
                  color: Colors.white.withOpacity(0.7))),

              const SizedBox(height: 8),

              // Macros
              Row(children: [
                _MacroDot('P ${meal.protein}g', Colors.white),
                const SizedBox(width: 10),
                _MacroDot('G ${meal.carbs}g', Colors.white.withOpacity(0.7)),
                const SizedBox(width: 10),
                _MacroDot('L ${meal.fat}g', Colors.white.withOpacity(0.7)),
              ]),
            ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPACT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _CompactCard extends StatelessWidget {
  final _RecoMeal meal;
  final _Goal goal;
  const _CompactCard({required this.meal, required this.goal});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.08))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 85,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(meal.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: goal.color.withOpacity(0.06))),
              Positioned(bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(5)),
                  child: Text('${meal.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: Colors.white)))),
            ]),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5)),
                  child: Text(meal.tag, style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: goal.color))),
                const SizedBox(height: 4),
                Text(meal.name,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5, fontWeight: FontWeight.w700,
                    color: cs.onSurface, height: 1.2)),
                const SizedBox(height: 4),
                Row(children: [
                  _MacroDot('P ${meal.protein}g', goal.color),
                  const SizedBox(width: 6),
                  _MacroDot('G ${meal.carbs}g', cs.onSurface.withOpacity(0.3)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper ───────────────────────────────────────────────────────────────────
class _MacroDot extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroDot(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 4, height: 4,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 3),
      Text(label, style: GoogleFonts.inter(
        fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    ],
  );
}
