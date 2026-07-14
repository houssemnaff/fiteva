// ignore_for_file: deprecated_member_use
import 'package:fiteva/services/recipe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RecipeAuthorScreen extends ConsumerWidget {
  final String userId;
  final String username;
  const RecipeAuthorScreen({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final top = MediaQuery.of(context).padding.top;
    final recipesAsync = ref.watch(authorRecipesProvider(userId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
            child: Column(children: [
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(LucideIcons.chevronLeft,
                    color: cs.onSurface, size: 22)),
                const Spacer(),
              ]),
              const SizedBox(height: 24),

              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
                child: Center(child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: GoogleFonts.outfit(
                    fontSize: 32, fontWeight: FontWeight.w800,
                    color: cs.primary))),
              ),
              const SizedBox(height: 12),

              Text(username, style: GoogleFonts.outfit(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: cs.onSurface)),
              const SizedBox(height: 4),
              Text('Chef Fiteva', style: GoogleFonts.inter(
                fontSize: 13, color: cs.onSurface.withOpacity(0.5))),

              const SizedBox(height: 20),

              // Stats row
              recipesAsync.when(
                data: (recipes) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(
                      icon: LucideIcons.chefHat,
                      value: '${recipes.length}',
                      label: 'Recettes',
                      color: cs.primary),
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: LucideIcons.flame,
                      value: '${recipes.fold(0, (s, r) => s + r.kcal)}',
                      label: 'kcal total',
                      color: const Color(0xFFF59E0B)),
                  ],
                ),
                loading: () => const SizedBox(height: 40),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),
              Divider(height: 1, color: cs.outline.withOpacity(0.1)),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('SES RECETTES', style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.4),
                  letterSpacing: 2.0))),
              const SizedBox(height: 12),
            ]),
          )),

          // ── Recipe grid ─────────────────────────────────────────────────
          recipesAsync.when(
            data: (recipes) {
              if (recipes.isEmpty) {
                return SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Column(children: [
                    Icon(LucideIcons.chefHat, size: 32,
                      color: cs.onSurface.withOpacity(0.15)),
                    const SizedBox(height: 12),
                    Text('Pas encore de recettes',
                      style: GoogleFonts.inter(fontSize: 14,
                        color: cs.onSurface.withOpacity(0.35))),
                  ]))));
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _RecipeCard(recipe: recipes[i]),
                    childCount: recipes.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12)));
            },
            loading: () => SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(
                strokeWidth: 2, color: cs.primary)))),
            error: (_, __) => SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Erreur de chargement',
                style: GoogleFonts.inter(color: cs.onSurface.withOpacity(0.4)))))),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon, required this.value,
    required this.label, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.outfit(
            fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.inter(
            fontSize: 10, color: color.withOpacity(0.7))),
        ]),
      ]),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final AppRecipe recipe;
  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: navigate to recipe detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline.withOpacity(0.1)),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 3))]),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // Image
          Expanded(
            flex: 3,
            child: Stack(fit: StackFit.expand, children: [
              recipe.imageUrl.isNotEmpty
                  ? Image.network(recipe.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.primary.withOpacity(0.08),
                        child: Icon(LucideIcons.chefHat,
                          size: 28, color: cs.primary.withOpacity(0.3))))
                  : Container(
                      color: cs.primary.withOpacity(0.08),
                      child: Icon(LucideIcons.chefHat,
                        size: 28, color: cs.primary.withOpacity(0.3))),
              if (recipe.videoUrl != null)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.video, size: 9, color: Colors.white),
                      SizedBox(width: 3),
                      Text('Vidéo', style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w700,
                        color: Colors.white)),
                    ]))),
              Positioned(
                bottom: 7, right: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(6)),
                  child: Text(recipe.duration, style: GoogleFonts.inter(
                    fontSize: 9, color: Colors.white,
                    fontWeight: FontWeight.w600)))),
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
                  Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5, fontWeight: FontWeight.w700,
                      color: cs.onSurface, height: 1.3)),
                  Row(children: [
                    Icon(LucideIcons.flame, size: 10, color: cs.primary),
                    const SizedBox(width: 3),
                    Text('${recipe.kcal} kcal', style: GoogleFonts.inter(
                      fontSize: 10.5, fontWeight: FontWeight.w600,
                      color: cs.primary)),
                    const Spacer(),
                    Text(recipe.difficulty, style: GoogleFonts.inter(
                      fontSize: 9.5, color: cs.onSurface.withOpacity(0.45))),
                  ]),
                ]),
            ),
          ),
          Container(height: 3, color: cs.primary),
        ]),
      ),
    );
  }
}
