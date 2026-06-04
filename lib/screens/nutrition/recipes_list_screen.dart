import 'package:fiteva/screens/cycle/widgets-cycle/Phasecolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';
import 'recette_detail_screen.dart';
import 'recipe_video_screen.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const _kGreen  = Color(0xFF1C4D30);
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFEFEFE);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF1A1A1A);
const _kText2  = Color(0xFF6B7280);

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

const _allRecipes = [
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

const _filters = [
  'Tout', 'Petit-dej', 'Protéiné', 'Végé', 'Vegan', 'Sans Gluten', 'Batch cooking',
];

// ── Video recipe data ──────────────────────────────────────────────────────────
class _VideoRecipe {
  final String name, imageUrl, duration, difficulty;
  final int kcal;
  final CyclePhase phase;
  const _VideoRecipe({
    required this.name, required this.imageUrl, required this.duration,
    required this.difficulty, required this.kcal, required this.phase,
  });
}

const _videoRecipes = [
  _VideoRecipe(name: 'Soupe anti-crampes',
    imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400&q=80',
    duration: '20 min', difficulty: 'Facile', kcal: 180,
    phase: CyclePhase.menstrual),
  _VideoRecipe(name: 'Poke Bowl vitalité',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    duration: '15 min', difficulty: 'Facile', kcal: 420,
    phase: CyclePhase.follicular),
  _VideoRecipe(name: 'Smoothie énergie max',
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&q=80',
    duration: '5 min', difficulty: 'Très facile', kcal: 280,
    phase: CyclePhase.ovulation),
  _VideoRecipe(name: 'Pasta réconfort',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80',
    duration: '30 min', difficulty: 'Facile', kcal: 520,
    phase: CyclePhase.luteal),
];

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class RecipesListScreen extends StatefulWidget {
  const RecipesListScreen({super.key});

  @override
  State<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends State<RecipesListScreen> {
  String _activeFilter = 'Tout';
  CyclePhase? _activePhase;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RealRecipe> get _filtered {
    var list = _allRecipes.toList();
    if (_activeFilter != 'Tout') {
      list = list.where((r) => r.tags.contains(_activeFilter)).toList();
    }
    if (_activePhase != null) {
      list = list.where((r) => r.phase == _activePhase).toList();
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
    final filtered = _filtered;
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _kCream,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Sticky header ────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: top + 110,
              collapsedHeight: top + 62,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: LayoutBuilder(builder: (ctx, constraints) {
                final collapsed = 1 -
                    ((constraints.maxHeight - (top + 62)) / 48).clamp(0.0, 1.0);
                return Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, top + 14, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: _kMintBg, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(LucideIcons.chevronLeft,
                              color: _kGreen, size: 18)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: AnimatedOpacity(
                            opacity: (1 - collapsed * 2.5).clamp(0.0, 1.0),
                            duration: Duration.zero,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text('RECETTES', style: GoogleFonts.inter(
                                color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 3)),
                              Text('Toutes les Recettes', style: GoogleFonts.outfit(
                                color: _kGreen, fontSize: 20,
                                fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                            ]),
                          ),
                        ),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F4F4),
                            borderRadius: BorderRadius.circular(10)),
                          child: const Icon(LucideIcons.bookmark,
                            color: _kText2, size: 16)),
                      ]),
                    ],
                  ),
                );
              }),
            ),

            // ── Search ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(children: [
                    const Icon(LucideIcons.search, size: 16, color: _kText2),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.inter(fontSize: 13, color: _kText1),
                        decoration: InputDecoration(
                          hintText: 'Chercher une recette, un ingrédient…',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: _kText2),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
                        child: const Icon(LucideIcons.x, size: 14, color: _kText2)),
                    if (_searchQuery.isEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _kGreen, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.sliders, size: 12, color: Colors.white)),
                    ],
                  ]),
                ),
              ),
            ),

            // ── Phase cycle filter ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selon votre cycle', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _kText2, letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _PhaseChip(
                          label: 'Toutes',
                          active: _activePhase == null,
                          activeColor: _kGreen,
                          activeBg: _kMintBg,
                          activeBorder: _kMint,
                          onTap: () => setState(() => _activePhase = null)),
                        const SizedBox(width: 6),
                        ...PhaseColors.all.map((pc) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _PhaseChip(
                            label: pc.name,
                            active: _activePhase == pc.phase,
                            activeColor: pc.primary,
                            activeBg: pc.light,
                            activeBorder: pc.border,
                            onTap: () => setState(() =>
                              _activePhase = _activePhase == pc.phase ? null : pc.phase)))),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ]),
              ),
            ),

            // ── Featured hero ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _FeaturedCard(recipe: _allRecipes.first, onTap: () => _openRecipe(context, _allRecipes.first)),
              ),
            ),

            // ── Video recipes ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _kGreen, borderRadius: BorderRadius.circular(9)),
                        child: const Icon(LucideIcons.play, size: 13, color: Colors.white)),
                      const SizedBox(width: 10),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('VIDÉOS', style: GoogleFonts.inter(
                          color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                          letterSpacing: 2.5)),
                        Text('Recettes Vidéo', style: GoogleFonts.outfit(
                          color: _kText1, fontSize: 18, fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                      ]),
                    ]),
                    Text('Voir tout', style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen)),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 185,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _videoRecipes.length,
                  itemBuilder: (_, i) => _VideoCard(recipe: _videoRecipes[i])),
              ),
            ),

            // ── Tag filters ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Catégories', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: _kText2, letterSpacing: 0.3)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemCount: _filters.length,
                      itemBuilder: (_, i) => _TagChip(
                        label: _filters[i],
                        active: _activeFilter == _filters[i],
                        onTap: () => setState(() => _activeFilter = _filters[i]))),
                  ),
                ]),
              ),
            ),

            // ── Results header ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
                child: Row(children: [
                  Text(
                    _activeFilter == 'Tout' && _activePhase == null
                        ? 'Toutes les recettes'
                        : _activePhase != null
                            ? PhaseColors.forPhase(_activePhase!).name
                            : _activeFilter,
                    style: GoogleFonts.outfit(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: _kText1, letterSpacing: -0.3)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kMintBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${filtered.length} recette${filtered.length > 1 ? "s" : ""}',
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen))),
                ]),
              ),
            ),

            // ── Recipe list (full-width editorial cards) ──────────
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
                  child: Column(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        color: _kMintBg, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(LucideIcons.search, color: _kGreen, size: 28)),
                    const SizedBox(height: 16),
                    Text('Aucune recette trouvée', style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _kText1)),
                    const SizedBox(height: 6),
                    Text('Essaie une autre catégorie ou phase', style: GoogleFonts.inter(
                      fontSize: 13, color: _kText2)),
                  ]),
                ))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _RecipeCard(
                    recipe: filtered[i],
                    onTap: () => _openRecipe(context, filtered[i])))),
          ],
        ),
      ),
    );
  }

  void _openRecipe(BuildContext ctx, RealRecipe r) {
    Navigator.push(ctx, MaterialPageRoute(
      builder: (_) => RecipeDetailScreen(
        recipe: RecipeItem(r.imageUrl, r.name, r.name, r.accent))));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FEATURED CARD
// ══════════════════════════════════════════════════════════════════════════════

class _FeaturedCard extends StatelessWidget {
  final RealRecipe recipe;
  final VoidCallback onTap;
  const _FeaturedCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(recipe.imageUrl, fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child : Container(color: _kMintBg),
            errorBuilder: (_, __, ___) => Container(color: _kMintBg,
              child: const Center(child: Icon(
                LucideIcons.image, color: _kMint, size: 40)))),

          // Gradient
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x22000000), Color(0xDD000000)],
                stops: [0.2, 1.0]))),

          // En vedette badge
          Positioned(top: 14, left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
              child: Text('En vedette', style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700,
                letterSpacing: 0.5)))),

          // Phase badge
          Positioned(top: 14, right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pc.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20)),
              child: Text(pc.name, style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),

          // Recipe info
          Positioned(bottom: 16, left: 16, right: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.name, style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.4, height: 1.15)),
              const SizedBox(height: 8),
              Row(children: [
                _GlassPill(icon: LucideIcons.clock, label: recipe.duration),
                const SizedBox(width: 8),
                _GlassPill(icon: LucideIcons.flame, label: '${recipe.kcal} kcal'),
                const SizedBox(width: 8),
                _GlassPill(icon: LucideIcons.barChart2, label: recipe.difficulty),
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
  final _VideoRecipe recipe;
  const _VideoCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => RecipeVideoPlayerScreen(
          recipeName: recipe.name,
          imageUrl: recipe.imageUrl,
          duration: recipe.duration,
          difficulty: recipe.difficulty,
          kcal: recipe.kcal,
          phase: recipe.phase))),
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
          boxShadow: [BoxShadow(
            color: pc.primary.withValues(alpha: 0.1),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          SizedBox(
            height: 116,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: pc.light)),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x99000000)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),

              // Play button
              Center(
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)]),
                  child: Icon(LucideIcons.play, color: pc.primary, size: 16))),

              // Duration
              Positioned(bottom: 8, left: 8,
                child: Row(children: [
                  Icon(LucideIcons.clock, size: 9, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600))])),

              // Phase pill — top right
              Positioned(top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: pc.primary.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(pc.name, style: GoogleFonts.inter(
                    fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700)))),
            ]),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                Text(recipe.name,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5, fontWeight: FontWeight.w700,
                    color: _kText1, height: 1.3)),
                Text('${recipe.kcal} kcal · ${recipe.difficulty}',
                  style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
              ]),
            ),
          ),

          // Phase color line
          Container(height: 3, color: pc.primary),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE LIST CARD (full-width editorial)
// ══════════════════════════════════════════════════════════════════════════════

class _RecipeCard extends StatelessWidget {
  final RealRecipe recipe;
  final VoidCallback onTap;
  const _RecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kBorder),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14, offset: const Offset(0, 4))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Image 200px ────────────────────────────────────────
          SizedBox(
            height: 200,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child : Container(color: _kMintBg),
                errorBuilder: (_, __, ___) => Container(color: _kMintBg,
                  child: const Center(child: Icon(
                    LucideIcons.image, color: _kMint, size: 40)))),

              // Gradient
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0x11000000), Color(0xCC000000)],
                    stops: [0.3, 1.0]))),

              // Duration badge
              Positioned(top: 14, left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(LucideIcons.clock, size: 10, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(recipe.duration, style: GoogleFonts.inter(
                      fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600))]))),

              // Difficulty badge
              Positioned(top: 14, right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10)),
                  child: Text(recipe.difficulty, style: GoogleFonts.inter(
                    fontSize: 10, color: _kText1, fontWeight: FontWeight.w700)))),

              // Recipe name
              Positioned(bottom: 14, left: 14, right: 14,
                child: Text(recipe.name, style: GoogleFonts.outfit(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: -0.3, height: 1.2))),
            ]),
          ),

          // ── Info row ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(children: [
              Expanded(child: Text(recipe.subtitle,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 12, color: _kText2))),
              const SizedBox(width: 10),
              _StatPill('${recipe.kcal} kcal', LucideIcons.flame, _kGreen, _kMintBg),
              const SizedBox(width: 6),
              _StatPill('${recipe.proteins}g prot.', LucideIcons.dumbbell, _kText2, const Color(0xFFF4F4F4)),
            ]),
          ),

          // ── Phase accent bar ───────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(children: [
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(
                  color: pc.primary, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Phase ${pc.name}', style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w600, color: pc.primary)),
              const Spacer(),
              ...recipe.tags.take(2).map((tag) => Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(tag, style: GoogleFonts.inter(
                    fontSize: 10, color: _kText2, fontWeight: FontWeight.w600))))),
            ]),
          ),

          // Phase color line at very bottom
          Container(height: 2, color: pc.primary),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _PhaseChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor, activeBg, activeBorder;
  final VoidCallback onTap;
  const _PhaseChip({
    required this.label, required this.active,
    required this.activeColor, required this.activeBg,
    required this.activeBorder, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? activeBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? activeBorder : _kBorder,
          width: active ? 1.5 : 1)),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: active ? activeColor : _kText2)),
    ),
  );
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TagChip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: active ? _kGreen : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _kGreen : _kBorder)),
      child: Text(label, style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        color: active ? Colors.white : _kText2)),
    ),
  );
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: Colors.white),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StatPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, bg;
  const _StatPill(this.label, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: color),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    ]),
  );
}
