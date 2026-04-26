import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/models.dart';
import 'recipe_detail_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/shared/shared_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
// THEME CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════

const _kCream = Color(0xFFFAF8F4);
const _kParchment = Color(0xFFF3EFE7);
const _kBrown = Color(0xFF1C4D30);
const _kBrownLight = Color(0xFF2D5A45);
const _kBrownDark = Color(0xFF4A7C5F);
const _kTextDark = Color(0xFF1C1410);
const _kTextMid = Color(0xFF6EAB84);
const _kTextLight = Color(0xFFA09080);
const _kBorderColor = Color(0x1F7C5C3A); // 12% opacity
const _kBorderMid = Color(0x337C5C3A);   // 20% opacity

// ── Fonts ─────────────────────────────────────────────────────────────────────
// Add to pubspec.yaml:
//   fonts:
//     - family: CormorantGaramond
//       fonts:
//         - asset: assets/fonts/CormorantGaramond-Light.ttf
//           weight: 300
//         - asset: assets/fonts/CormorantGaramond-Regular.ttf
//           weight: 400
//         - asset: assets/fonts/CormorantGaramond-Medium.ttf
//           weight: 500
//         - asset: assets/fonts/CormorantGaramond-LightItalic.ttf
//           weight: 300
//           style: italic
//     - family: DMSans
//       fonts:
//         - asset: assets/fonts/DMSans-Light.ttf
//           weight: 300
//         - asset: assets/fonts/DMSans-Regular.ttf
//           weight: 400
//         - asset: assets/fonts/DMSans-Medium.ttf
//           weight: 500

const _kSerifFont = 'CormorantGaramond';
const _kSansFont = 'DMSans';

// ══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ══════════════════════════════════════════════════════════════════════════════

class RealRecipe {
  final String name;
  final String subtitle;
  final String imageUrl;
  final String duration;
  final int kcal;
  final int proteins;
  final String difficulty;
  final List<String> tags;
  final Color accent;

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
  });
}

const _allRecipes = [
  RealRecipe(
    name: 'Poke Bowl Saumon Avocat',
    subtitle: 'Riz, saumon mariné, avocat, edamame',
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
    duration: '20 min',
    kcal: 487,
    proteins: 32,
    difficulty: 'Facile',
    tags: ['Protéiné', 'Sans Gluten', 'Omega-3'],
    accent: Color(0xFF4A8B6F),
  ),
  RealRecipe(
    name: 'One Pot Pasta Poulet Pesto',
    subtitle: 'Pâtes crémeuses, poulet grillé, pesto maison',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=600&q=80',
    duration: '30 min',
    kcal: 562,
    proteins: 41,
    difficulty: 'Facile',
    tags: ['Protéiné', 'Savoureux'],
    accent: Color(0xFF2D5A45),
  ),
  RealRecipe(
    name: 'Avocado Toast Œuf Poché',
    subtitle: 'Pain complet, avocat, œuf poché, graines',
    imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c820?w=600&q=80',
    duration: '15 min',
    kcal: 324,
    proteins: 18,
    difficulty: 'Très facile',
    tags: ['Petit-dej', 'Végé'],
    accent: Color(0xFF5A7A35),
  ),
  RealRecipe(
    name: 'Bowl Méditerranéen Poulet',
    subtitle: 'Quinoa, poulet grillé, feta, olives, tomates',
    imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
    duration: '25 min',
    kcal: 445,
    proteins: 38,
    difficulty: 'Facile',
    tags: ['Protéiné', 'Sans Gluten'],
    accent: Color(0xFF1A6B8A),
  ),
  RealRecipe(
    name: 'Overnight Oats Protéinés',
    subtitle: 'Flocons avoine, whey, chia, fruits rouges',
    imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?w=600&q=80',
    duration: '5 min',
    kcal: 356,
    proteins: 28,
    difficulty: 'Très facile',
    tags: ['Petit-dej', 'Protéiné', 'Batch cooking'],
    accent: Color(0xFF8B3A6B),
  ),
  RealRecipe(
    name: 'Smoothie Bowl Acai Choco',
    subtitle: 'Acai, banane, cacao, granola croquant',
    imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600&q=80',
    duration: '10 min',
    kcal: 298,
    proteins: 14,
    difficulty: 'Très facile',
    tags: ['Petit-dej', 'Vegan'],
    accent: Color(0xFF6B2D8B),
  ),
];

const _filters = [
  'Tout',
  'Petit-dej',
  'Protéiné',
  'Végé',
  'Vegan',
  'Sans Gluten',
  'Batch cooking',
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
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RealRecipe> get _filtered {
    var list = _allRecipes.toList();
    if (_activeFilter != 'Tout') {
      list = list.where((r) => r.tags.contains(_activeFilter)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((r) =>
              r.name.toLowerCase().contains(q) ||
              r.subtitle.toLowerCase().contains(q) ||
              r.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _kCream,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: _Header(
                  onBack: () => Navigator.pop(context),
                ),
              ),
            ),

            // ── Search ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _LuxurySearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ),

            // ── Featured Hero ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _FeaturedHero(recipe: _allRecipes.first),
              ),
            ),

            // ── Filters ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _filters.length,
                    itemBuilder: (_, i) => _FilterChip(
                      label: _filters[i],
                      active: _activeFilter == _filters[i],
                      onTap: () => setState(() => _activeFilter = _filters[i]),
                    ),
                  ),
                ),
              ),
            ),

            // ── Section header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        _activeFilter == 'Tout'
                            ? 'Toutes les recettes'
                            : _activeFilter,
                        style: const TextStyle(
                          fontFamily: _kSerifFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: _kTextDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Text(
                      '${filtered.length} résultat${filtered.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontFamily: _kSansFont,
                        fontSize: 11,
                        color: _kTextLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Grid / Empty ─────────────────────────────────────────────────
            if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'Aucune recette trouvée',
                      style: TextStyle(
                        fontFamily: _kSansFont,
                        color: _kTextLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _RecipeGridCard(
                      recipe: filtered[i],
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(
                            recipe: RecipeItem(
                              '🍽',
                              filtered[i].name,
                              filtered[i].name,
                              filtered[i].accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),

            // ── Ornament footer ──────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Center(
                  child: Text(
                    '· · ·',
                    style: TextStyle(
                      color: _kTextLight,
                      fontSize: 14,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// HEADER
// ══════════════════════════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          _CircleIconBtn(
            icon: Icons.chevron_left_rounded,
            onTap: onBack,
          ),

          // Centred title block
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Overline
                const Text(
                  'COLLECTION',
                  style: TextStyle(
                    fontFamily: _kSansFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2.5,
                    color: _kTextLight,
                  ),
                ),
                const SizedBox(height: 2),
                // Title with italic accent
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: _kSerifFont,
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: _kTextDark,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: 'Toutes les  '),
                      TextSpan(
                        text: 'Recettes',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: _kBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              _CircleIconBtn(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _CircleIconBtn(
                icon: Icons.bookmark_outline_rounded,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CIRCLE ICON BUTTON
// ══════════════════════════════════════════════════════════════════════════════

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _kBorderMid),
        ),
        child: Icon(icon, size: 16, color: _kTextDark),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ══════════════════════════════════════════════════════════════════════════════

class _LuxurySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _LuxurySearchBar({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: _kTextLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: _kSansFont,
                fontSize: 13,
                color: _kTextDark,
              ),
              decoration: const InputDecoration(
                hintText: 'Recette, ingrédient, objectif…',
                hintStyle: TextStyle(
                  fontFamily: _kSansFont,
                  color: _kTextLight,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // Filter accent button
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _kBrown,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FEATURED HERO CARD
// ══════════════════════════════════════════════════════════════════════════════

class _FeaturedHero extends StatelessWidget {
  final RealRecipe recipe;
  const _FeaturedHero({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              recipe.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      color: recipe.accent.withOpacity(0.15),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: _kBrown,
                        ),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                color: recipe.accent.withOpacity(0.2),
                child: const Center(
                  child: Icon(Icons.restaurant, size: 60, color: _kTextLight),
                ),
              ),
            ),

            // Cinematic gradient overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xBF0F0802)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.25, 1.0],
                ),
              ),
            ),

            // "Recette du jour" badge — top left
            Positioned(
              top: 14,
              left: 14,
              child: _GlassBadge(label: 'RECETTE DU JOUR'),
            ),

            // Bookmark — top right
            Positioned(
              top: 12,
              right: 12,
              child: _GlassIconBtn(icon: Icons.bookmark_outline_rounded),
            ),

            // Info block — bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontFamily: _kSerifFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      recipe.subtitle,
                      style: TextStyle(
                        fontFamily: _kSansFont,
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _FeaturedPill(
                          icon: Icons.access_time_rounded,
                          label: recipe.duration,
                        ),
                        const SizedBox(width: 6),
                        _FeaturedPill(
                          icon: Icons.local_fire_department_outlined,
                          label: '${recipe.kcal} kcal',
                        ),
                        const SizedBox(width: 6),
                        _FeaturedPill(
                          icon: Icons.fitness_center_rounded,
                          label: '${recipe.proteins}g prot.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String label;
  const _GlassBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: _kSansFont,
          fontSize: 9.5,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  const _GlassIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Icon(icon, size: 15, color: Colors.white),
    );
  }
}

class _FeaturedPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturedPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _kSansFont,
              fontSize: 9.5,
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FILTER CHIP
// ══════════════════════════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _kBrownDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _kBrownDark : _kBorderMid,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: _kSansFont,
            fontSize: 11.5,
            fontWeight: FontWeight.w400,
            color: active ? Colors.white : _kTextMid,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RECIPE GRID CARD
// ══════════════════════════════════════════════════════════════════════════════

class _RecipeGridCard extends StatelessWidget {
  final RealRecipe recipe;
  final VoidCallback onTap;

  const _RecipeGridCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorderColor),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo area ──────────────────────────────────────────────────
            SizedBox(
              height: 130,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Container(
                            color: recipe.accent.withOpacity(0.12),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: _kBrown,
                              ),
                            ),
                          ),
                    errorBuilder: (_, __, ___) => Container(
                      color: recipe.accent.withOpacity(0.18),
                      child: const Center(
                        child: Icon(Icons.restaurant,
                            size: 36, color: _kTextLight),
                      ),
                    ),
                  ),

                  // Bottom gradient
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 55,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0x4D000000)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // Bookmark — top left
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xE6FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_outline_rounded,
                        size: 12,
                        color: _kBrown,
                      ),
                    ),
                  ),

                  // Difficulty — top right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.difficulty,
                        style: const TextStyle(
                          fontFamily: _kSansFont,
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),

                  // Duration — bottom left
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 9,
                            color: _kBrown,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            recipe.duration,
                            style: const TextStyle(
                              fontFamily: _kSansFont,
                              fontSize: 9,
                              color: _kBrownDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _kSerifFont,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: _kTextDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Stat chips: kcal + proteins
                    Row(
                      children: [
                        Expanded(
                          child: _StatChip(
                            value: '${recipe.kcal}',
                            label: 'kcal',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _StatChip(
                            value: '${recipe.proteins}g',
                            label: 'prot.',
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: recipe.tags
                          .take(2)
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _kBorderMid),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontFamily: _kSansFont,
                                  fontSize: 8.5,
                                  color: _kTextMid,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STAT CHIP
// ══════════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String value;
  final String label;

  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: _kParchment,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: _kSansFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _kBrownDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _kSansFont,
              fontSize: 8.5,
              color: _kTextLight,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}