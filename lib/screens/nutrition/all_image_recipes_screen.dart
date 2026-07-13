// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/Phasecolors.dart';
import 'package:fiteva/screens/nutrition/recette_detail_screen.dart';
import 'package:fiteva/screens/nutrition/recipes_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'models/models.dart';

Color _kGreen(BuildContext c) => Theme.of(c).colorScheme.primary;
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFAFAF8);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF111110);
const _kText2  = Color(0xFF6B7280);
const _kChipBg = Color(0xFFF2F2F0);

class AllImageRecipesScreen extends ConsumerStatefulWidget {
  const AllImageRecipesScreen({super.key});

  @override
  ConsumerState<AllImageRecipesScreen> createState() => _AllImageRecipesScreenState();
}

class _AllImageRecipesScreenState extends ConsumerState<AllImageRecipesScreen> {
  String _search = '';
  final _ctrl = TextEditingController();

  List<RealRecipe> _filtered(List<RealRecipe> recipes) {
    if (_search.isEmpty) return recipes;
    final q = _search.toLowerCase();
    return recipes.where((r) =>
      r.name.toLowerCase().contains(q) ||
      r.subtitle.toLowerCase().contains(q) ||
      r.tags.any((t) => t.toLowerCase().contains(q))).toList();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final top       = MediaQuery.of(context).padding.top;
    final favorites = ref.watch(favoritesProvider);
    final nc        = NutritionColors.of(context);
    final l10n      = ref.watch(l10nProvider);
    final recipes   = ref.watch(imageRecipesProvider).asData?.value ?? allRecipes;
    final filtered  = _filtered(recipes);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (nc.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: nc.bg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // Header
            SliverToBoxAdapter(
              child: Container(
                color: nc.surface,
                padding: EdgeInsets.fromLTRB(20, top + 16, 20, 16),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _kMintBg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.chevronLeft, color: _kGreen(context), size: 18))),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.recettesEyebrow, style: GoogleFonts.inter(
                      color: _kMint, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
                    Text(l10n.recettesPhotos, style: GoogleFonts.outfit(
                      color: _kGreen(context), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _kMintBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(l10n.recettesCount(recipes.length), style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen(context)))),
                ]),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _kBorder),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6, offset: const Offset(0, 2))]),
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(children: [
                    const Icon(LucideIcons.search, size: 15, color: _kText2),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onChanged: (v) => setState(() => _search = v),
                        style: GoogleFonts.inter(fontSize: 13.5, color: _kText1),
                        decoration: InputDecoration(
                          hintText: 'Rechercher une recette…',
                          hintStyle: GoogleFonts.inter(fontSize: 13.5, color: _kText2),
                          border: InputBorder.none, isDense: true,
                          contentPadding: EdgeInsets.zero))),
                    if (_search.isNotEmpty)
                      GestureDetector(
                        onTap: () { _ctrl.clear(); setState(() => _search = ''); },
                        child: Container(
                          width: 19, height: 19,
                          decoration: BoxDecoration(color: _kChipBg, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.x, size: 10, color: _kText2))),
                  ]),
                ),
              ),
            ),

            // Count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Text(l10n.recettesResults(filtered.length),
                  style: GoogleFonts.inter(fontSize: 12, color: _kText2, fontWeight: FontWeight.w500)),
              ),
            ),

            // List
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(child: Column(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(color: _kMintBg, borderRadius: BorderRadius.circular(18)),
                      child: Icon(LucideIcons.search, color: _kGreen(context), size: 24)),
                    const SizedBox(height: 14),
                    Text(l10n.recettesAucune, style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w700, color: _kText1)),
                    const SizedBox(height: 4),
                    Text(l10n.recettesEssaie, style: GoogleFonts.inter(
                      fontSize: 13, color: _kText2)),
                  ])),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 60),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _ImageRecipeCard(
                    recipe: filtered[i],
                    isFavorite: favorites.contains(filtered[i].name),
                    onToggleFavorite: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggle(filtered[i].name);
                    },
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeDetailScreen(
                        recipe: RecipeItem(
                          filtered[i].imageUrl,
                          filtered[i].name,
                          filtered[i].name,
                          filtered[i].accent)))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Image recipe card ─────────────────────────────────────────────────────────
class _ImageRecipeCard extends StatelessWidget {
  final RealRecipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite, onTap;
  const _ImageRecipeCard({
    required this.recipe, required this.isFavorite,
    required this.onToggleFavorite, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isFavorite
                ? const Color(0xFFE03050).withOpacity(0.25)
                : nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))]),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          SizedBox(
            width: 100,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                loadingBuilder: (_, child, p) =>
                  p == null ? child : Container(color: nc.mintBg),
                errorBuilder: (_, __, ___) =>
                  Container(color: nc.mintBg,
                    child: const Center(child: Icon(LucideIcons.image, color: NutritionColors.mint, size: 22)))),
              Positioned(bottom: 0, left: 0, right: 0,
                child: Container(height: 3, color: pc.primary)),
            ]),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(width: 5, height: 5,
                      decoration: BoxDecoration(color: pc.primary, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(pc.name, style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w600, color: pc.primary)),
                  ]),
                  const SizedBox(height: 3),
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5, fontWeight: FontWeight.w700,
                      color: nc.text1, height: 1.3)),
                  const Spacer(),
                  Row(children: [
                    Icon(LucideIcons.clock, size: 10, color: nc.text2),
                    const SizedBox(width: 4),
                    Text(recipe.duration, style: GoogleFonts.inter(
                      fontSize: 11, color: nc.text2)),
                    const SizedBox(width: 10),
                    Icon(LucideIcons.flame, size: 10, color: pc.primary),
                    const SizedBox(width: 4),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: pc.primary)),
                  ]),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? const Color(0xFFE03050).withOpacity(nc.isDark ? 0.25 : 0.10)
                      : nc.chipBg,
                  shape: BoxShape.circle),
                child: Icon(LucideIcons.heart, size: 14,
                  color: isFavorite ? const Color(0xFFE03050) : nc.text2))),
          ),
        ]),
      ),
    );
  }
}
