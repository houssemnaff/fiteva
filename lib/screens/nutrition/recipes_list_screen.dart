// ignore_for_file: deprecated_member_use
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
const _kCream  = Color(0xFFFAFAF8);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF111110);
const _kText2  = Color(0xFF6B7280);
const _kChipBg = Color(0xFFF2F2F0);

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

const _filterCategories = [
  (label: 'Tout',          icon: LucideIcons.layoutGrid),
  (label: 'Favoris',       icon: LucideIcons.heart),
  (label: 'Petit-dej',     icon: LucideIcons.sunrise),
  (label: 'Protéiné',      icon: LucideIcons.dumbbell),
  (label: 'Végé',          icon: LucideIcons.leaf),
  (label: 'Vegan',         icon: LucideIcons.sprout),
  (label: 'Sans Gluten',   icon: LucideIcons.wheatOff),
  (label: 'Batch cooking', icon: LucideIcons.cookingPot),
];

// ── Video data ─────────────────────────────────────────────────────────────────
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
    duration: '20 min', difficulty: 'Facile', kcal: 180, phase: CyclePhase.menstrual),
  _VideoRecipe(name: 'Poke Bowl vitalité',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
    duration: '15 min', difficulty: 'Facile', kcal: 420, phase: CyclePhase.follicular),
  _VideoRecipe(name: 'Smoothie énergie max',
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&q=80',
    duration: '5 min', difficulty: 'Très facile', kcal: 280, phase: CyclePhase.ovulation),
  _VideoRecipe(name: 'Pasta réconfort',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=400&q=80',
    duration: '30 min', difficulty: 'Facile', kcal: 520, phase: CyclePhase.luteal),
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
  String _activeCategory = 'Tout';
  String _searchQuery    = '';
  final _searchCtrl      = TextEditingController();
  final Set<String> _favorites = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleFavorite(String name) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_favorites.contains(name)) {
        _favorites.remove(name);
      } else {
        _favorites.add(name);
      }
    });
  }

  List<RealRecipe> get _filtered {
    var list = _allRecipes.toList();

    if (_activeCategory == 'Favoris') {
      list = list.where((r) => _favorites.contains(r.name)).toList();
    } else if (_activeCategory != 'Tout') {
      list = list.where((r) => r.tags.contains(_activeCategory)).toList();
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
    final top      = MediaQuery.of(context).padding.top;
    final filtered = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _kCream,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            _StickyHeader(
              top: top,
              onBack: () => Navigator.pop(context),
              favCount: _favorites.length,
              onFavTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeCategory =
                  _activeCategory == 'Favoris' ? 'Tout' : 'Favoris');
              },
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _SearchBar(
                  controller: _searchCtrl,
                  query: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _filterCategories.length,
                    itemBuilder: (_, i) {
                      final c   = _filterCategories[i];
                      final sel = _activeCategory == c.label;
                      final isFavPill = c.label == 'Favoris';
                      return _CategoryPill(
                        label: c.label,
                        icon: c.icon,
                        selected: sel,
                        badge: isFavPill && _favorites.isNotEmpty
                            ? _favorites.length : null,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeCategory = c.label);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // Hero card (hidden in Favoris mode)
            if (_activeCategory != 'Favoris') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HeroCard(
                    recipe: _allRecipes.first,
                    isFavorite: _favorites.contains(_allRecipes.first.name),
                    onToggleFavorite: () => _toggleFavorite(_allRecipes.first.name),
                    onTap: () => _openRecipe(context, _allRecipes.first),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: LucideIcons.play, eyebrow: 'VIDÉOS',
                  title: 'Recettes rapides', action: 'Voir tout', onAction: () {},
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 178,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: _videoRecipes.length,
                    itemBuilder: (_, i) => _VideoCard(
                      recipe: _videoRecipes[i],
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RecipeVideoPlayerScreen(
                          recipeName: _videoRecipes[i].name,
                          imageUrl: _videoRecipes[i].imageUrl,
                          duration: _videoRecipes[i].duration,
                          difficulty: _videoRecipes[i].difficulty,
                          kcal: _videoRecipes[i].kcal,
                          phase: _videoRecipes[i].phase))),
                    ),
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: _SectionHeader(
                icon: _activeCategory == 'Favoris'
                    ? LucideIcons.heart : LucideIcons.utensils,
                eyebrow: _activeCategory == 'Favoris' ? 'MES FAVORIS' : 'RECETTES',
                title: _activeCategory == 'Favoris'
                    ? 'Mes favoris'
                    : _activeCategory == 'Tout' ? 'Toutes' : _activeCategory,
                action: '${filtered.length} résultat${filtered.length > 1 ? "s" : ""}',
              ),
            ),

            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 52),
                  child: Center(
                    child: Column(children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: _activeCategory == 'Favoris'
                              ? const Color(0xFFFFF0F3)
                              : _kMintBg,
                          borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          _activeCategory == 'Favoris'
                              ? LucideIcons.heartOff
                              : LucideIcons.search,
                          color: _activeCategory == 'Favoris'
                              ? const Color(0xFFE03050)
                              : _kGreen,
                          size: 26)),
                      const SizedBox(height: 16),
                      Text(
                        _activeCategory == 'Favoris'
                            ? 'Aucun favori pour l\'instant'
                            : 'Aucune recette',
                        style: GoogleFonts.outfit(
                          fontSize: 17, fontWeight: FontWeight.w700, color: _kText1)),
                      const SizedBox(height: 4),
                      Text(
                        _activeCategory == 'Favoris'
                            ? 'Appuie sur ♡ pour sauvegarder une recette'
                            : 'Essaie une autre catégorie',
                        style: GoogleFonts.inter(fontSize: 13, color: _kText2)),
                    ]),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RecipeCard(
                    recipe: filtered[i],
                    isFavorite: _favorites.contains(filtered[i].name),
                    onToggleFavorite: () => _toggleFavorite(filtered[i].name),
                    onTap: () => _openRecipe(context, filtered[i]),
                  ),
                ),
              ),
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
// STICKY HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _StickyHeader extends StatelessWidget {
  final double top;
  final VoidCallback onBack;
  final int favCount;
  final VoidCallback onFavTap;

  const _StickyHeader({
    required this.top,
    required this.onBack,
    required this.favCount,
    required this.onFavTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: top + 72,
      collapsedHeight: top + 60,
      backgroundColor: _kCream,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(builder: (_, __) {
        return Container(
          color: _kCream,
          padding: EdgeInsets.fromLTRB(20, top + 16, 20, 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _kMintBg, borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.chevronLeft, color: _kGreen, size: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('RECETTES', style: GoogleFonts.inter(
                  color: _kMint, fontSize: 9, fontWeight: FontWeight.w700,
                  letterSpacing: 3)),
                Text('Explorer', style: GoogleFonts.outfit(
                  color: _kGreen, fontSize: 22, fontWeight: FontWeight.w800,
                  letterSpacing: -0.4)),
              ]),
            ),
            // Favorites bookmark button with badge
            GestureDetector(
              onTap: onFavTap,
              child: Stack(clipBehavior: Clip.none, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: favCount > 0
                        ? const Color(0xFFFFF0F3)
                        : _kChipBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: favCount > 0
                          ? const Color(0xFFE03050).withOpacity(0.3)
                          : Colors.transparent)),
                  child: Icon(
                    favCount > 0 ? LucideIcons.heart : LucideIcons.heart,
                    color: favCount > 0
                        ? const Color(0xFFE03050)
                        : _kText2,
                    size: 16)),
                if (favCount > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE03050),
                        shape: BoxShape.circle),
                      child: Center(child: Text(
                        '$favCount',
                        style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w800,
                          color: Colors.white))))),
              ]),
            ),
          ]),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════════════════════
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchBar({
    required this.controller, required this.query,
    required this.onChanged, required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        const Icon(LucideIcons.search, size: 16, color: _kText2),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GoogleFonts.inter(fontSize: 13.5, color: _kText1),
            decoration: InputDecoration(
              hintText: 'Rechercher une recette…',
              hintStyle: GoogleFonts.inter(fontSize: 13.5, color: _kText2),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero),
          ),
        ),
        if (query.isNotEmpty)
          GestureDetector(
            onTap: onClear,
            child: Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: _kChipBg, shape: BoxShape.circle),
              child: const Icon(LucideIcons.x, size: 11, color: _kText2)),
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CATEGORY PILL
// ══════════════════════════════════════════════════════════════════════════════
class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final int? badge;
  final VoidCallback onTap;
  const _CategoryPill({
    required this.label, required this.icon,
    required this.selected, required this.onTap,
    this.badge,
  });

  bool get _isFav => label == 'Favoris';

  Color get _activeColor => _isFav ? const Color(0xFFE03050) : _kGreen;
  Color get _activeBg    => _isFav ? const Color(0xFFE03050) : _kGreen;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: selected ? _activeBg : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? _activeBg
              : _isFav && badge != null
                  ? const Color(0xFFE03050).withOpacity(0.4)
                  : _kBorder,
          width: 1.2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          selected && _isFav ? LucideIcons.heartHandshake : icon,
          size: 12,
          color: selected
              ? Colors.white
              : _isFav
                  ? const Color(0xFFE03050)
                  : _kText2),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? Colors.white
              : _isFav
                  ? const Color(0xFFE03050)
                  : _kText2)),
        if (badge != null && !selected) ...[
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFE03050),
              borderRadius: BorderRadius.circular(10)),
            child: Text('$badge', style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w800,
              color: Colors.white))),
        ],
      ]),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({
    required this.icon, required this.eyebrow, required this.title,
    this.action, this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: _kMintBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 14, color: _kGreen),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(eyebrow, style: GoogleFonts.inter(
              fontSize: 9, fontWeight: FontWeight.w700,
              color: _kMint, letterSpacing: 2.5)),
            Text(title, style: GoogleFonts.outfit(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: _kText1, letterSpacing: -0.3)),
          ]),
        ),
        if (action != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: onAction != null ? _kMintBg : _kChipBg,
              borderRadius: BorderRadius.circular(20)),
            child: GestureDetector(
              onTap: onAction,
              child: Text(action!, style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: onAction != null ? _kGreen : _kText2))),
          ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HERO CARD  +  favorite button
// ══════════════════════════════════════════════════════════════════════════════
class _HeroCard extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  const _HeroCard({
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(recipe.imageUrl, fit: BoxFit.cover,
            loadingBuilder: (_, child, p) =>
              p == null ? child : Container(color: _kMintBg),
            errorBuilder: (_, __, ___) =>
              Container(color: _kMintBg,
                child: const Center(child: Icon(
                  LucideIcons.image, color: _kMint, size: 36)))),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xE0000000)],
                stops: [0.25, 1.0]))),

          Positioned(top: 14, left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.star, size: 9, color: Colors.white),
                const SizedBox(width: 5),
                Text('En vedette', style: GoogleFonts.inter(
                  fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
              ]))),

          // Phase badge
          Positioned(top: 14, right: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pc.primary.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20)),
              child: Text(pc.name, style: GoogleFonts.inter(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),

          // ❤ Favorite button
          Positioned(top: 10, right: 10,
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? const Color(0xFFE03050)
                      : Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                  boxShadow: isFavorite ? [BoxShadow(
                    color: const Color(0xFFE03050).withOpacity(0.4),
                    blurRadius: 8, offset: const Offset(0, 3))] : []),
                child: Icon(
                  isFavorite ? LucideIcons.heart : LucideIcons.heart,
                  size: 16,
                  color: Colors.white)))),

          Positioned(bottom: 14, left: 16, right: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(recipe.name, style: GoogleFonts.outfit(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.3, height: 1.2)),
              const SizedBox(height: 8),
              Row(children: [
                _GlassBadge(icon: LucideIcons.clock, label: recipe.duration),
                const SizedBox(width: 8),
                _GlassBadge(icon: LucideIcons.flame, label: '${recipe.kcal} kcal'),
                const SizedBox(width: 8),
                _GlassBadge(icon: LucideIcons.barChart2, label: recipe.difficulty),
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
  final VoidCallback onTap;
  const _VideoCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          SizedBox(
            height: 108,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: pc.light)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0x88000000)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),
              Center(
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90), shape: BoxShape.circle),
                  child: Icon(LucideIcons.play, color: pc.primary, size: 13))),
              Positioned(bottom: 7, right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.50),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)))),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: _kText1, height: 1.3)),
                  Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
                ],
              ),
            ),
          ),
          Container(height: 2.5, color: pc.primary),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE CARD (list item)  +  favorite button
// ══════════════════════════════════════════════════════════════════════════════
class _RecipeCard extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;
  const _RecipeCard({
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFavorite
                ? const Color(0xFFE03050).withOpacity(0.25)
                : _kBorder),
          boxShadow: [BoxShadow(
            color: isFavorite
                ? const Color(0xFFE03050).withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          // Thumbnail
          SizedBox(
            width: 96,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(recipe.imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) =>
                    p == null ? child : Container(color: _kMintBg),
                  errorBuilder: (_, __, ___) =>
                    Container(color: _kMintBg,
                      child: const Center(child: Icon(
                        LucideIcons.image, color: _kMint, size: 22)))),
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(height: 3, color: pc.primary)),
              ]),
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 5, height: 5,
                      decoration: BoxDecoration(
                        color: pc.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(pc.name, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
                  ]),
                  const SizedBox(height: 3),
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: _kText1, height: 1.3)),
                  const SizedBox(height: 7),
                  Row(children: [
                    _MiniStat(LucideIcons.clock, recipe.duration),
                    const SizedBox(width: 10),
                    _MiniStat(LucideIcons.flame, '${recipe.kcal} kcal'),
                  ]),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 5, runSpacing: 4,
                    children: recipe.tags.take(2).map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _kChipBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: GoogleFonts.inter(
                        fontSize: 10, color: _kText2, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Favorite + chevron
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onToggleFavorite,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? const Color(0xFFFFEEF1)
                          : const Color(0xFFF4F4F4),
                      shape: BoxShape.circle),
                    child: Icon(
                      LucideIcons.heart,
                      size: 14,
                      color: isFavorite
                          ? const Color(0xFFE03050)
                          : _kText2))),
                const SizedBox(height: 6),
                const Icon(LucideIcons.chevronRight, size: 14, color: _kText2),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════
class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _GlassBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.30))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: Colors.white),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(
        fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MiniStat(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 10, color: _kText2),
    const SizedBox(width: 3),
    Text(label, style: GoogleFonts.inter(
      fontSize: 11, color: _kText2, fontWeight: FontWeight.w500)),
  ]);
}
