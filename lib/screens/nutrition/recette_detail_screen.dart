// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/recipe_author_screen.dart';
import 'package:fiteva/screens/nutrition/recipes_list_screen.dart' show PhaseInfo;
import 'package:fiteva/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class Ingredient {
  final String name, qty, imageUrl;
  final int kcal;
  const Ingredient({
    required this.name, required this.qty,
    required this.kcal, required this.imageUrl,
  });
}

class RecipeStep {
  final int number;
  final String title, description;
  const RecipeStep({required this.number, required this.title, required this.description});
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC DATA (fallback)
// ─────────────────────────────────────────────────────────────────────────────
const _heroUrl =
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=900&q=80';

const _ingredients = [
  Ingredient(name: 'Flocons d\'avoine', qty: '80g',     kcal: 297, imageUrl: 'https://images.unsplash.com/photo-1517686469429-8bdb88b9f907?w=120&q=70'),
  Ingredient(name: 'Yaourt grec',       qty: '150g',    kcal: 88,  imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=120&q=70'),
  Ingredient(name: 'Banane',            qty: '1 pc',    kcal: 89,  imageUrl: 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=120&q=70'),
  Ingredient(name: 'Miel',              qty: '1 c.s.',  kcal: 64,  imageUrl: 'https://images.unsplash.com/photo-1558642452-9d2a7deb7f62?w=120&q=70'),
  Ingredient(name: 'Amandes',           qty: '20g',     kcal: 116, imageUrl: 'https://images.unsplash.com/photo-1574184864703-3487b13f0edd?w=120&q=70'),
  Ingredient(name: 'Whey protéine',     qty: '1 dose',  kcal: 120, imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=120&q=70'),
];

const _steps = [
  RecipeStep(number: 1, title: 'Préparer la base',    description: 'Mesurer 80g de flocons d\'avoine et les placer dans un bol. Ajouter une pincée de sel.'),
  RecipeStep(number: 2, title: 'Mixer les protéines', description: 'Mélanger 1 dose de whey avec 150g de yaourt grec jusqu\'à obtenir une texture lisse.'),
  RecipeStep(number: 3, title: 'Incorporer',          description: 'Incorporer délicatement le yaourt aux flocons. Trancher la banane et en ajouter la moitié.'),
  RecipeStep(number: 4, title: 'Garnir',              description: 'Ajouter le reste de banane, les amandes concassées et un filet de miel cru.'),
  RecipeStep(number: 5, title: 'Repos (optionnel)',   description: 'Couvrir et réfrigérer 10 min pour ramollir les flocons. Servir frais ou à température ambiante.'),
];

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class RecipeDetailScreen extends ConsumerStatefulWidget {
  final dynamic recipe;
  const RecipeDetailScreen({super.key, this.recipe});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  int _tab = 0;
  int _portions = 1;
  RecipeAuthor? _fetchedAuthor;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final r = widget.recipe;
    if (r is AppRecipe && r.author == null && r.userId != null) {
      final author = await RecipeService.fetchAuthor(r.userId!);
      if (author != null && mounted) {
        setState(() => _fetchedAuthor = author);
      }
    }
  }

  String get _recipeName {
    final r = widget.recipe;
    if (r is AppRecipe) return r.title.isNotEmpty ? r.title : 'Recette';
    try {
      final n = r?.name;
      if (n is String && n.isNotEmpty) return n;
      final t = r?.title;
      if (t is String && t.isNotEmpty) return t;
    } catch (_) {}
    return 'Recette';
  }

  String get _imageUrl {
    final r = widget.recipe;
    if (r is AppRecipe) return r.imageUrl.isNotEmpty ? r.imageUrl : _heroUrl;
    try {
      final e = r?.emoji;
      if (e is String && e.startsWith('http')) return e;
      final img = r?.imageUrl;
      if (img is String && img.startsWith('http')) return img;
    } catch (_) {}
    return _heroUrl;
  }

  String? get _authorName {
    final r = widget.recipe;
    if (r is AppRecipe) return r.author?.username ?? _fetchedAuthor?.username;
    try {
      final a = r?.author;
      if (a != null) return a.username as String?;
    } catch (_) {}
    return null;
  }

  String? get _authorId {
    final r = widget.recipe;
    if (r is AppRecipe) return r.userId;
    try {
      return r?.userId as String?;
    } catch (_) {}
    return null;
  }

  String get _phase {
    try {
      final r = widget.recipe;
      if (r is AppRecipe) return r.phase;
      final p = r?.phase;
      if (p is String) return p;
    } catch (_) {}
    return '';
  }

  String get _duration {
    try {
      final r = widget.recipe;
      if (r is AppRecipe && r.duration.isNotEmpty) return r.duration;
      final d = r?.duration;
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {}
    return '20 min';
  }

  String get _difficulty {
    try {
      final r = widget.recipe;
      if (r is AppRecipe) return r.difficulty;
      final d = r?.difficulty;
      if (d is String && d.isNotEmpty) return d;
    } catch (_) {}
    return 'Facile';
  }

  int get _kcal {
    try {
      final r = widget.recipe;
      if (r is AppRecipe) return r.kcal;
    } catch (_) {}
    return 198;
  }

  int get _proteins {
    try {
      final r = widget.recipe;
      if (r is AppRecipe) return r.proteins;
    } catch (_) {}
    return 38;
  }

  List<Map<String, dynamic>> get _realIngredients {
    try {
      final r = widget.recipe;
      if (r is AppRecipe && r.ingredients.isNotEmpty) return r.ingredients;
    } catch (_) {}
    return [];
  }

  List<Map<String, dynamic>> get _realSteps {
    try {
      final r = widget.recipe;
      if (r is AppRecipe && r.steps.isNotEmpty) return r.steps;
    } catch (_) {}
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final cs  = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final isFav = ref.watch(favoritesProvider).contains(_recipeName);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero image ─────────────────────────────────────────
            SliverToBoxAdapter(child: SizedBox(
              height: top + 260,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(_imageUrl, fit: BoxFit.cover,
                  loadingBuilder: (_, child, p) => p == null ? child
                      : Container(color: cs.primary.withOpacity(0.04)),
                  errorBuilder: (_, __, ___) => Container(
                    color: cs.primary.withOpacity(0.06),
                    child: Icon(LucideIcons.chefHat, size: 40,
                      color: cs.primary.withOpacity(0.15)))),

                // Top gradient
                Positioned(top: 0, left: 0, right: 0, height: top + 60,
                  child: DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent])))),

                // Bottom gradient
                Positioned(bottom: 0, left: 0, right: 0, height: 80,
                  child: DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter, end: Alignment.topCenter,
                      colors: [cs.surface, cs.surface.withOpacity(0)])))),

                // Phase pill on image
                if (_phase.isNotEmpty)
                  Positioned(bottom: 14, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: PhaseInfo.from(_phase).color,
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        Text(PhaseInfo.from(_phase).label,
                          style: GoogleFonts.inter(fontSize: 10,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    )),

                // Back + fav
                Positioned(top: top + 10, left: 16, right: 16,
                  child: Row(children: [
                    _CircleBtn(icon: LucideIcons.chevronLeft,
                      onTap: () => Navigator.maybePop(context)),
                    const Spacer(),
                    _CircleBtn(
                      icon: isFav ? LucideIcons.heartOff : LucideIcons.heart,
                      iconColor: isFav ? cs.primary : Colors.white,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(favoritesProvider.notifier).toggle(_recipeName);
                      }),
                  ])),
              ]),
            )),

            // ── Title + meta ───────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_recipeName, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800,
                      color: cs.onSurface, height: 1.15, letterSpacing: -0.3)),
                  const SizedBox(height: 10),

                  // Meta row
                  Row(children: [
                    _MetaChip(LucideIcons.clock, _duration, cs),
                    const SizedBox(width: 8),
                    _MetaChip(LucideIcons.flame, '$_kcal kcal', cs),
                    const SizedBox(width: 8),
                    _MetaChip(LucideIcons.chefHat, _difficulty, cs),
                  ]),

                  // Author
                  if (_authorName != null) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _authorId != null ? () {
                        HapticFeedback.lightImpact();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => RecipeAuthorScreen(
                            userId: _authorId!, username: _authorName!)));
                      } : null,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cs.outline.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              shape: BoxShape.circle),
                            child: Center(child: Text(
                              _authorName![0].toUpperCase(),
                              style: GoogleFonts.outfit(fontSize: 15,
                                fontWeight: FontWeight.w800, color: cs.primary)))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_authorName!, style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: cs.onSurface)),
                              Text('Publié par', style: GoogleFonts.inter(
                                fontSize: 10.5, color: cs.onSurface.withOpacity(0.4))),
                            ])),
                          if (_authorId != null)
                            Icon(LucideIcons.chevronRight, size: 16,
                              color: cs.onSurface.withOpacity(0.25)),
                        ]),
                      ),
                    ),
                  ],
                ],
              ),
            )),

            // ── Phase tip card ────────────────────────────────────────
            if (_phase.isNotEmpty)
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _PhaseTip(phase: _phase),
              )),

            // ── Macro cards ────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                _MacroCard('Protéines', '${_proteins * _portions}g', const Color(0xFF5BAE8A), cs),
                const SizedBox(width: 8),
                _MacroCard('Calories', '${_kcal * _portions}', const Color(0xFF6B8FD4), cs),
                const SizedBox(width: 8),
                _MacroCard('Portions', '$_portions', const Color(0xFFF4A940), cs),
              ]),
            )),

            // ── Portions ───────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: List.generate(4, (i) {
                    final n = i + 1;
                    final sel = n == _portions;
                    return Expanded(child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _portions = n);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 34,
                        decoration: BoxDecoration(
                          color: sel ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text('$n ${n == 1 ? 'portion' : 'portions'}',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : cs.onSurface.withOpacity(0.4)))),
                    ));
                  }),
                ),
              ),
            )),

            // ── Tab bar ────────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: List.generate(3, (i) {
                    final sel = i == _tab;
                    final labels = ['Ingrédients', 'Étapes', 'Nutrition'];
                    return Expanded(child: GestureDetector(
                      onTap: () => setState(() => _tab = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 36,
                        decoration: BoxDecoration(
                          color: sel ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: Text(labels[i], style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : cs.onSurface.withOpacity(0.45)))),
                    ));
                  }),
                ),
              ),
            )),

            // ── Tab content ────────────────────────────────────────
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: switch (_tab) {
                    0 => _IngredientsTab(portions: _portions, realIngredients: _realIngredients),
                    1 => _StepsTab(realSteps: _realSteps),
                    _ => _NutritionTab(portions: _portions, kcal: _kcal, proteins: _proteins),
                  }),
              ),
            )),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _CircleBtn({
    required this.icon, required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 18)),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  const _MetaChip(this.icon, this.label, this.cs);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: cs.outline.withOpacity(0.06),
      borderRadius: BorderRadius.circular(8)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: cs.primary),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface)),
    ]),
  );
}

class _MacroCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final ColorScheme cs;
  const _MacroCard(this.label, this.value, this.color, this.cs);

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(
        fontSize: 9, fontWeight: FontWeight.w600,
        color: color.withOpacity(0.7))),
    ]),
  ));
}

// ─────────────────────────────────────────────────────────────────────────────
// INGREDIENTS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _IngredientsTab extends StatelessWidget {
  final int portions;
  final List<Map<String, dynamic>> realIngredients;
  const _IngredientsTab({required this.portions, required this.realIngredients});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (realIngredients.isNotEmpty) {
      return Column(
        children: realIngredients.map((ing) {
          final name = ing['name'] as String? ?? '';
          final qty = ing['qty'] as String? ?? '';
          final kcal = ing['kcal'] as int? ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.outline.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(LucideIcons.salad, size: 16,
                    color: cs.primary.withOpacity(0.4))),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    if (qty.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(qty, style: GoogleFonts.inter(
                        fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
                    ],
                  ])),
                if (kcal > 0)
                  Text('${kcal * portions} kcal', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
              ]),
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: _ingredients.map((ing) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.outline.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(ing.imageUrl,
                width: 44, height: 44, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(LucideIcons.salad, size: 16,
                    color: cs.onSurface.withOpacity(0.15))))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.name, style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
                const SizedBox(height: 2),
                Text(ing.qty, style: GoogleFonts.inter(
                  fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
              ])),
            Text('${ing.kcal * portions} kcal', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
          ]),
        ),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEPS TAB
// ─────────────────────────────────────────────────────────────────────────────
class _StepsTab extends StatefulWidget {
  final List<Map<String, dynamic>> realSteps;
  const _StepsTab({required this.realSteps});
  @override
  State<_StepsTab> createState() => _StepsTabState();
}

class _StepsTabState extends State<_StepsTab> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final steps = widget.realSteps.isNotEmpty
        ? List.generate(widget.realSteps.length, (i) {
            final s = widget.realSteps[i];
            return RecipeStep(
              number: i + 1,
              title: s['title'] as String? ?? 'Étape ${i + 1}',
              description: s['description'] as String? ?? '',
            );
          })
        : _steps;

    return Column(
      children: steps.map((step) {
        final isDone = _done.contains(step.number);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                isDone ? _done.remove(step.number) : _done.add(step.number);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDone
                    ? cs.primary.withOpacity(0.06)
                    : cs.outline.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: isDone
                    ? Border.all(color: cs.primary.withOpacity(0.15))
                    : null),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? cs.primary : cs.outline.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8)),
                  child: Center(child: isDone
                      ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                      : Text('${step.number}', style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: cs.onSurface.withOpacity(0.4))))),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      decorationColor: cs.onSurface.withOpacity(0.3))),
                    const SizedBox(height: 4),
                    Text(step.description, style: GoogleFonts.inter(
                      fontSize: 12, color: cs.onSurface.withOpacity(0.45),
                      height: 1.5)),
                  ])),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NUTRITION TAB
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionTab extends StatelessWidget {
  final int portions;
  final int kcal;
  final int proteins;
  const _NutritionTab({required this.portions, required this.kcal, required this.proteins});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final macros = [
      ('Protéines', proteins * portions, 60, const Color(0xFF5BAE8A)),
      ('Calories',  kcal * portions, 1800, const Color(0xFF6B8FD4)),
    ];

    return Column(children: [
      // Kcal summary
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.outline.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          SizedBox(
            width: 60, height: 60,
            child: CustomPaint(
              painter: _RingPainter(
                progress: ((kcal * portions) / 1800).clamp(0.0, 1.0),
                trackColor: cs.outline.withOpacity(0.08),
                fillColor: cs.primary),
              child: Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${kcal * portions}', style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w800, color: cs.onSurface)),
                  Text('kcal', style: GoogleFonts.inter(
                    fontSize: 9, color: cs.onSurface.withOpacity(0.4))),
                ])))),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objectif journalier', style: GoogleFonts.inter(
                fontSize: 11, color: cs.onSurface.withOpacity(0.4))),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ((kcal * portions) / 1800).clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: cs.outline.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(cs.primary))),
              const SizedBox(height: 4),
              Text('${kcal * portions} / 1 800 kcal',
                style: GoogleFonts.inter(fontSize: 11,
                  color: cs.onSurface.withOpacity(0.4))),
            ])),
        ]),
      ),

      const SizedBox(height: 12),

      // Macros
      ...macros.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(m.$1, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: m.$4.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6)),
              child: Text('${m.$2}g', style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: m.$4))),
          ]),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (m.$2 / m.$3).clamp(0, 1).toDouble(),
              minHeight: 4,
              backgroundColor: m.$4.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(m.$4))),
        ]),
      )),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RING PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor, fillColor;
  const _RingPainter({
    required this.progress, required this.trackColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = (size.width - 10) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 6 ..color = trackColor;
    final fill = Paint()
      ..style = PaintingStyle.stroke ..strokeWidth = 6
      ..strokeCap = StrokeCap.round ..color = fillColor;
    canvas.drawCircle(c, r, track);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r),
      -1.5708, progress * 2 * 3.14159, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// PHASE TIP
// ─────────────────────────────────────────────────────────────────────────────
class _PhaseTip extends StatelessWidget {
  final String phase;
  const _PhaseTip({required this.phase});

  String get _tip => switch (phase) {
    'menstrual' =>
      'Pendant tes règles, privilégie le fer et le magnésium pour compenser les pertes et réduire la fatigue.',
    'follicular' =>
      'En phase folliculaire, les protéines et fibres soutiennent la montée d\'énergie et la reconstruction.',
    'ovulation' =>
      'Autour de l\'ovulation, les antioxydants et le zinc favorisent l\'équilibre hormonal.',
    'luteal' =>
      'En phase lutéale, les glucides complexes et le calcium aident à stabiliser l\'humeur.',
    _ =>
      'Cette recette est conçue pour soutenir ton bien-être avec des ingrédients riches en nutriments essentiels.',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pi = PhaseInfo.from(phase);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: pi.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pi.color.withOpacity(0.12))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(LucideIcons.lightbulb, size: 15, color: pi.color),
        const SizedBox(width: 10),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pi.label, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w700, color: pi.color)),
            const SizedBox(height: 3),
            Text(_tip, style: GoogleFonts.inter(
              fontSize: 11.5, color: cs.onSurface.withOpacity(0.6), height: 1.5)),
          ])),
      ]),
    );
  }
}
