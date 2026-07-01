// ignore_for_file: deprecated_member_use
import 'package:fiteva/core/nutrition/favorites_provider.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/Phasecolors.dart';
import 'package:fiteva/screens/nutrition/recipe_video_screen.dart';
import 'package:fiteva/screens/nutrition/recipes_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _kGreen  = Color(0xFF1C4D30);
const _kMint   = Color(0xFF7ABB98);
const _kMintBg = Color(0xFFEAF3EC);
const _kCream  = Color(0xFFFAFAF8);
const _kBorder = Color(0xFFECECEC);
const _kText1  = Color(0xFF111110);
const _kText2  = Color(0xFF6B7280);

class AllVideoRecipesScreen extends ConsumerWidget {
  const AllVideoRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final top = MediaQuery.of(context).padding.top;
    final nc  = NutritionColors.of(context);
    final l10n = ref.watch(l10nProvider);
    final dbVideos = ref.watch(videoRecipesProvider).asData?.value ?? videoRecipes;

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
                        color: nc.mintBg, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.chevronLeft, color: _kGreen, size: 18))),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l10n.recettesEyebrow, style: GoogleFonts.inter(
                      color: _kMint, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 3)),
                    Text(l10n.recettesVideos, style: GoogleFonts.outfit(
                      color: nc.text1, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: nc.mintBg, borderRadius: BorderRadius.circular(20)),
                    child: Text(l10n.recettesCount(dbVideos.length), style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w700, color: _kGreen))),
                ]),
              ),
            ),

            // Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _VideoGridCard(
                    recipe: dbVideos[i],
                    isFavorite: favorites.contains(dbVideos[i].name),
                    onToggleFavorite: () {
                      HapticFeedback.lightImpact();
                      ref.read(favoritesProvider.notifier).toggle(dbVideos[i].name);
                    },
                    onTap: () => Navigator.push(ctx, MaterialPageRoute(
                      builder: (_) => RecipeVideoPlayerScreen(recipe: dbVideos[i]))),
                    l10n: l10n,
                  ),
                  childCount: dbVideos.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Video grid card ───────────────────────────────────────────────────────────
class _VideoGridCard extends StatelessWidget {
  final VideoRecipe recipe;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final AppL10n l10n;
  const _VideoGridCard({
    required this.recipe,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final nc = NutritionColors.of(context);
    final pc = PhaseColors.forPhase(recipe.phase);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: nc.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: nc.border),
          boxShadow: nc.isDark ? [] : [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // Thumbnail
          Expanded(
            flex: 3,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(recipe.imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: pc.light)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xAA000000)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter))),
              // Play button
              Center(
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: recipe.videoAsset != null
                        ? _kGreen.withOpacity(0.92)
                        : Colors.white.withOpacity(0.88),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8)]),
                  child: Icon(LucideIcons.play,
                    color: recipe.videoAsset != null ? Colors.white : pc.primary,
                    size: 16))),
              // Video badge if has video
              if (recipe.videoAsset != null)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _kGreen,
                      borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.video, size: 9, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(l10n.recettesVideo, style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                    ]))),
              // Fav button
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: onToggleFavorite,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: isFavorite
                          ? const Color(0xFFE03050)
                          : Colors.black.withOpacity(0.40),
                      shape: BoxShape.circle),
                    child: Icon(
                      isFavorite ? LucideIcons.heart : LucideIcons.heart,
                      size: 13,
                      color: Colors.white)))),
              // Duration
              Positioned(
                bottom: 7, right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white, fontWeight: FontWeight.w600)))),
            ]),
          ),
          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(recipe.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5, fontWeight: FontWeight.w700,
                      color: nc.text1, height: 1.3)),
                  Row(children: [
                    Icon(LucideIcons.flame, size: 10, color: pc.primary),
                    const SizedBox(width: 3),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.w600, color: pc.primary)),
                    const Spacer(),
                    Text(recipe.difficulty, style: GoogleFonts.inter(
                      fontSize: 9.5, color: nc.text2)),
                  ]),
                ],
              ),
            ),
          ),
          Container(height: 3, color: pc.primary),
        ]),
      ),
    );
  }
}
