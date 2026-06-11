// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kGreen   = Color(0xFF1C4D30);
const _kMint    = Color(0xFF7ABB98);
const _kSurface = Color(0xFFFEFEFE);
const _kBorder  = Color(0xFFECECEC);
const _kText1   = Color(0xFF1A1A1A);
const _kText2   = Color(0xFF6B7280);

// ─────────────────────────────────────────────────────────────────────────────
//  MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _Goal {
  final String id, label, sublabel;
  final IconData icon;
  final Color primary, light, text;
  const _Goal({
    required this.id, required this.label, required this.sublabel,
    required this.icon,
    required this.primary, required this.light, required this.text,
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
  _Goal(
    id: 'loss',
    label: 'Perte de poids',
    sublabel: 'Déficit calorique',
    icon: LucideIcons.trendingDown,
    primary: Color(0xFF5BAE8A),
    light:   Color(0xFFEEF8F3),
    text:    Color(0xFF2A6E52),
  ),
  _Goal(
    id: 'maintain',
    label: 'Maintien',
    sublabel: 'Équilibre calorique',
    icon: LucideIcons.minus,
    primary: Color(0xFF6B8FD4),
    light:   Color(0xFFF0F3FC),
    text:    Color(0xFF2E4A8A),
  ),
  _Goal(
    id: 'muscle',
    label: 'Prise de muscle',
    sublabel: 'Surplus protéiné',
    icon: LucideIcons.dumbbell,
    primary: Color(0xFFF4A940),
    light:   Color(0xFFFFF6E9),
    text:    Color(0xFF8A5800),
  ),
  _Goal(
    id: 'pregnancy',
    label: 'Grossesse',
    sublabel: 'Nutriments essentiels',
    icon: LucideIcons.heart,
    primary: Color(0xFFD94F6B),
    light:   Color(0xFFFDF0F2),
    text:    Color(0xFF8B2A3A),
  ),
  _Goal(
    id: 'postpartum',
    label: 'Post-partum',
    sublabel: 'Récupération & énergie',
    icon: LucideIcons.sparkles,
    primary: Color(0xFF9B6FD4),
    light:   Color(0xFFF4EEFF),
    text:    Color(0xFF5A2A8A),
  ),
];

const _meals = {
  'loss': [
    _RecoMeal(
      name: 'Bowl de quinoa & légumes rôtis',
      description: 'Riche en fibres, faible en calories — satiété durable.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Fibres · Végétarien',
      kcal: 320, protein: 14, carbs: 42, fat: 9,
    ),
    _RecoMeal(
      name: 'Poulet grillé & brocoli vapeur',
      description: 'Protéines maigres + légumes croquants pour rester rassasiée.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Protéiné · Léger',
      kcal: 280, protein: 38, carbs: 14, fat: 7,
    ),
    _RecoMeal(
      name: 'Soupe miso & tofu soyeux',
      description: 'Faible en calories, probiotiques naturels.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Détox · Chaud',
      kcal: 190, protein: 12, carbs: 18, fat: 5,
    ),
    _RecoMeal(
      name: 'Salade niçoise légère',
      description: 'Thon, œuf dur, haricots verts — équilibre parfait.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Complet · Frais',
      kcal: 350, protein: 28, carbs: 20, fat: 14,
    ),
  ],
  'maintain': [
    _RecoMeal(
      name: 'Poke bowl saumon avocat',
      description: 'Oméga-3, glucides complexes et bons lipides — le trio gagnant.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Équilibré · Gourmet',
      kcal: 480, protein: 28, carbs: 52, fat: 16,
    ),
    _RecoMeal(
      name: 'Pasta complète pesto basilic',
      description: 'Énergie durable, satiété et plaisir gustatif.',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      tag: 'Glucides complexes',
      kcal: 520, protein: 18, carbs: 68, fat: 18,
    ),
    _RecoMeal(
      name: 'Omelette champignons & fromage',
      description: 'Protéines complètes, lipides sains, rapide à préparer.',
      imageUrl: 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
      tag: 'Brunch · Rapide',
      kcal: 410, protein: 26, carbs: 8, fat: 22,
    ),
    _RecoMeal(
      name: 'Riz thaï au lait de coco',
      description: 'Saveurs d\'Asie, macros équilibrées.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Savoureux · Complet',
      kcal: 460, protein: 16, carbs: 60, fat: 14,
    ),
  ],
  'muscle': [
    _RecoMeal(
      name: 'Steak de bœuf & patate douce',
      description: 'Protéines complètes + glucides à index glycémique bas.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Haute protéine',
      kcal: 620, protein: 52, carbs: 46, fat: 18,
    ),
    _RecoMeal(
      name: 'Blanc de dinde & riz basmati',
      description: 'Le classique du bâtisseur de muscle — simple et efficace.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'Muscle · Léger',
      kcal: 550, protein: 56, carbs: 58, fat: 8,
    ),
    _RecoMeal(
      name: 'Greek bowl protéiné',
      description: 'Yaourt grec, pois chiches, concombre — récupération optimale.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Récupération',
      kcal: 490, protein: 42, carbs: 38, fat: 14,
    ),
    _RecoMeal(
      name: 'Saumon & lentilles beluga',
      description: 'Oméga-3 anti-inflammatoires + protéines végétales.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Oméga-3 · Force',
      kcal: 570, protein: 48, carbs: 32, fat: 20,
    ),
  ],
  'pregnancy': [
    _RecoMeal(
      name: 'Épinards & lentilles corail au curry',
      description: 'Fer, acide folique et protéines végétales pour bébé.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Fer · Acide folique',
      kcal: 380, protein: 18, carbs: 48, fat: 10,
    ),
    _RecoMeal(
      name: 'Sardines grillées & quinoa',
      description: 'Oméga-3 DHA essentiels au développement cérébral.',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
      tag: 'DHA · Cerveau bébé',
      kcal: 420, protein: 32, carbs: 36, fat: 14,
    ),
    _RecoMeal(
      name: 'Smoothie bowl avocat & banane',
      description: 'Potassium, magnésium, vitamine B6 — anti-nausées.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Anti-nausées · Doux',
      kcal: 340, protein: 8, carbs: 52, fat: 14,
    ),
    _RecoMeal(
      name: 'Soupe de potimarron & amandes',
      description: 'Zinc, calcium et bêta-carotène pour la croissance.',
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600&q=80',
      tag: 'Calcium · Zinc',
      kcal: 290, protein: 10, carbs: 38, fat: 12,
    ),
  ],
  'postpartum': [
    _RecoMeal(
      name: 'Porridge avoine & graines de lin',
      description: 'Galactogènes naturels, oméga-3 et énergie durable.',
      imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600&q=80',
      tag: 'Allaitement · Énergie',
      kcal: 360, protein: 12, carbs: 54, fat: 12,
    ),
    _RecoMeal(
      name: 'Bouillon de poulet maison & vermicelles',
      description: 'Collagène, minéraux et chaleur réconfortante pour la récupération.',
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=600&q=80',
      tag: 'Récupération · Chaud',
      kcal: 310, protein: 24, carbs: 28, fat: 8,
    ),
    _RecoMeal(
      name: 'Salade de betterave, noix & chèvre',
      description: 'Fer, magnésium et bons lipides pour reconstituer les réserves.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
      tag: 'Fer · Anti-fatigue',
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
class RecommendedMealsSection extends StatefulWidget {
  /// Objectif initial (id parmi loss / maintain / muscle / pregnancy / postpartum)
  final String initialGoalId;
  const RecommendedMealsSection({super.key, this.initialGoalId = 'loss'});

  @override
  State<RecommendedMealsSection> createState() =>
      _RecommendedMealsSectionState();
}

class _RecommendedMealsSectionState extends State<RecommendedMealsSection> {
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
    final goal = _goal;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Section header ────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Row(children: [
          Container(
            width: 3, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [goal.primary, goal.primary.withOpacity(0.4)]),
              borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('RECOMMANDATIONS', style: GoogleFonts.inter(
              color: goal.primary, fontSize: 9,
              fontWeight: FontWeight.w700, letterSpacing: 3)),
            Text('Repas du jour', style: GoogleFonts.outfit(
              color: _kText1, fontSize: 22,
              fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          ]),
        ]),
      ),

      const SizedBox(height: 14),

      // ── Goal selector ─────────────────────────────────────────────
      SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemCount: _goals.length,
          itemBuilder: (_, i) {
            final g        = _goals[i];
            final selected = g.id == _selectedId;
            return GestureDetector(
              onTap: () => setState(() => _selectedId = g.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? g.primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? g.primary
                        : _kBorder,
                    width: selected ? 0 : 1),
                  boxShadow: selected
                      ? [BoxShadow(
                          color: g.primary.withOpacity(0.25),
                          blurRadius: 12, offset: const Offset(0, 4))]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(g.icon,
                        size: 13,
                        color: selected
                            ? Colors.white
                            : g.primary),
                      const SizedBox(width: 6),
                      Text(g.label, style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : _kText1)),
                    ]),
                    const SizedBox(height: 3),
                    Text(g.sublabel, style: GoogleFonts.inter(
                      fontSize: 10,
                      color: selected
                          ? Colors.white.withOpacity(0.75)
                          : _kText2)),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      const SizedBox(height: 16),

      // ── Featured card (first meal) ─────────────────────────────────
      if (_currentMeals.isNotEmpty)
        LayoutBuilder(builder: (_, constraints) {
          final featH = (constraints.maxWidth * 0.52).clamp(180.0, 230.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FeaturedCard(
              meal: _currentMeals.first,
              goal: goal,
              height: featH),
          );
        }),

      const SizedBox(height: 12),

      // ── Horizontal compact cards (rest) ───────────────────────────
      if (_currentMeals.length > 1)
        LayoutBuilder(builder: (_, constraints) {
          final cardW = constraints.maxWidth * 0.42;
          final imgH  = cardW * 0.55;
          final listH = imgH + 78;
          return SizedBox(
            height: listH,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: _currentMeals.length - 1,
              itemBuilder: (_, i) => _CompactCard(
                meal: _currentMeals[i + 1],
                goal: goal,
                width: cardW,
                imageHeight: imgH,
              ),
            ),
          );
        }),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FEATURED CARD  (grande carte principale)
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final _RecoMeal meal;
  final _Goal goal;
  final double height;
  const _FeaturedCard({
      required this.meal, required this.goal, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 20, offset: const Offset(0, 6))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        // Image
        Image.network(meal.imageUrl, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: goal.light,
            child: Center(child: Icon(
                LucideIcons.salad, color: goal.primary, size: 40)))),

        // Gradient overlay
        DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.20),
              Colors.black.withOpacity(0.72),
            ],
            stops: const [0.1, 0.5, 1.0]))),

        // Goal badge top-left
        Positioned(top: 14, left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: goal.primary,
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(goal.icon, size: 11, color: Colors.white),
              const SizedBox(width: 5),
              Text(goal.label, style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: Colors.white)),
            ]),
          )),

        // Kcal badge top-right
        Positioned(top: 14, right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withOpacity(0.30))),
            child: Text('${meal.kcal} kcal', style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: Colors.white)),
          )),

        // Bottom info
        Positioned(bottom: 14, left: 14, right: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tag
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: goal.primary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(10)),
                child: Text(meal.tag, style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.3))),
              const SizedBox(height: 6),

              // Name
              Text(meal.name, style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.3)),
              const SizedBox(height: 4),

              // Description
              Text(meal.description,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75))),

              const SizedBox(height: 10),

              // Macro row
              Row(children: [
                _MacroPill('P · ${meal.protein}g',
                    Colors.white, Colors.white.withOpacity(0.18)),
                const SizedBox(width: 6),
                _MacroPill('G · ${meal.carbs}g',
                    Colors.white, Colors.white.withOpacity(0.18)),
                const SizedBox(width: 6),
                _MacroPill('L · ${meal.fat}g',
                    Colors.white, Colors.white.withOpacity(0.18)),
              ]),
            ],
          )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPACT CARD  (petites cartes horizontales)
// ─────────────────────────────────────────────────────────────────────────────
class _CompactCard extends StatelessWidget {
  final _RecoMeal meal;
  final _Goal goal;
  final double width;
  final double imageHeight;

  const _CompactCard({
    required this.meal,
    required this.goal,
    required this.width,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image
          SizedBox(
            height: imageHeight,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(meal.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: goal.light,
                  child: Center(child: Icon(
                      LucideIcons.salad, color: goal.primary, size: 22)))),
              Positioned(bottom: 6, right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text('${meal.kcal} kcal',
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: Colors.white)))),
            ]),
          ),

          // Content — fixed height 78px, no overflow possible
          SizedBox(
            height: 78,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tag pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: goal.light,
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(meal.tag.split(' · ').first,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: goal.text))),

                  // Name
                  Text(meal.name,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: _kText1, height: 1.25)),

                  // Macro dots
                  Row(children: [
                    _DotMacro('P ${meal.protein}g', goal.primary),
                    const SizedBox(width: 5),
                    _DotMacro('G ${meal.carbs}g',
                        goal.primary.withOpacity(0.55)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────
class _MacroPill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _MacroPill(this.label, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: GoogleFonts.inter(
      fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _DotMacro extends StatelessWidget {
  final String label;
  final Color color;
  const _DotMacro(this.label, this.color);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 5, height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 9, fontWeight: FontWeight.w600,
        color: _kText2)),
    ],
  );
}
