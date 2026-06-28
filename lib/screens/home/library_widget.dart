import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/core/nutrition/favorites_provider.dart' as nutrition;
import 'package:fiteva/core/shop/shop_provider.dart' as shop_provider;
import 'package:fiteva/screens/home/favorites_bottom_sheet.dart';
import 'package:fiteva/l10n/app_localizations.dart';

class LibrarySection extends ConsumerStatefulWidget {
  const LibrarySection();

  @override
  ConsumerState<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends ConsumerState<LibrarySection> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = const [
    {'label': 'Workouts', 'icon': LucideIcons.dumbbell},
    {'label': 'Recettes', 'icon': LucideIcons.utensils},
    {'label': 'Boutique', 'icon': LucideIcons.shoppingBag},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final favorites = ref.watch(favoritesProvider);
    final recipeFavorites = ref.watch(nutrition.favoritesProvider);
    final shopWishlist = ref.watch(shop_provider.shopWishlistProvider);
    final allWorkouts = ref.watch(workoutsProvider);

    // Watch all program providers
    final sallePrograms = ref.watch(salleProgramsProvider);
    final homePrograms = ref.watch(homeProgramsProvider);
    final dancePrograms = ref.watch(danceProgramsProvider);
    final recuperationPrograms = ref.watch(recuperationProgramsProvider);
    final grossessePrograms = ref.watch(grossesseProgramsProvider);

    // Combine all programs
    final allPrograms = [
      ...sallePrograms,
      ...homePrograms,
      ...dancePrograms,
      ...recuperationPrograms,
      ...grossessePrograms,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.heart,
                      size: 20, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Mes favoris',
                    style: GoogleFonts.outfit(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const FavoritesBottomSheet(),
                  );
                },
                child: Text(
                  l10n.sectionVoirTout,
                  style: GoogleFonts.inter(
                    color: cs.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Tab bar ───────────────────────────────────────────
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = index == _selectedTab;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? cs.primary
                        : cs.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _tabs[index]['icon'] as IconData,
                        size: 14,
                        color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _tabs[index]['label'] as String,
                        style: GoogleFonts.inter(
                          color: selected ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Content ─────────────────────────────────────────
        if (_selectedTab == 0)
          _buildWorkoutList(favorites, allWorkouts, allPrograms, cs),
        if (_selectedTab == 1)
          _buildRecipeList(recipeFavorites, cs),
        if (_selectedTab == 2)
          _buildProductList(shopWishlist, cs),
      ],
    );
  }

  Widget _buildWorkoutList(Set<String> favorites, List<dynamic> allWorkouts, List<dynamic> allPrograms, ColorScheme cs) {
    // Filter workouts by ID
    final filteredWorkouts = allWorkouts
        .where((w) => favorites.contains(w.id))
        .map((w) => {
          'id': w.id,
          'title': w.title,
          'subtitle': '${w.duration} · ${w.level}',
          'image': w.imageUrl,
        })
        .toList();

    // Filter programs by name
    final filteredPrograms = allPrograms
        .where((p) => favorites.contains(p.name))
        .map((p) => {
          'id': p.name,
          'title': p.name,
          'subtitle': '${p.duration} · ${p.sessions}',
          'image': p.imageUrl,
        })
        .toList();

    // Combine both
    final allItems = [...filteredWorkouts, ...filteredPrograms];

    return _buildHorizontalList(allItems, type: _FavType.workout, cs: cs, onRemove: (id) async {
      await ref.read(favoritesProvider.notifier).toggleFavorite(id);
    });
  }

  Widget _buildRecipeList(Set<String> favorites, ColorScheme cs) {
    // Show only favorited recipe IDs - the actual recipe data should come from a real provider
    if (favorites.isEmpty) {
      return _buildEmptyState(cs);
    }

    final filteredItems = favorites
        .map((id) => {
          'id': id,
          'title': id,
          'subtitle': 'Recipe',
          'image': 'assets/images/recipe.jpg',
        })
        .toList();

    return _buildHorizontalList(filteredItems, type: _FavType.recipe, cs: cs, onRemove: (id) async {
      ref.read(nutrition.favoritesProvider.notifier).toggle(id);
    });
  }

  Widget _buildProductList(Set<String> wishlist, ColorScheme cs) {
    if (wishlist.isEmpty) {
      return _buildEmptyState(cs);
    }

    final filteredItems = wishlist
        .map((id) => {
          'id': id,
          'title': id,
          'subtitle': 'Produit',
          'image': 'assets/images/product.jpg',
        })
        .toList();

    return _buildHorizontalList(filteredItems, type: _FavType.product, cs: cs, onRemove: (id) async {
      await ref.read(shop_provider.shopWishlistProvider.notifier).removeFromWishlist(id);
    });
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.heartOff, size: 36, color: cs.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            Text(
              'Aucun favori pour le moment',
              style: GoogleFonts.inter(
                color: cs.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> items, {required _FavType type, required ColorScheme cs, required Function(String) onRemove}) {
    if (items.isEmpty) {
      return _buildEmptyState(cs);
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _FavoriteCardVertical(
            id: item['id']! as String,
            title: item['title']! as String,
            subtitle: item['subtitle']! as String,
            imageAsset: item['image']! as String,
            type: type,
            onTap: () {},
            onUnfav: () async => await onRemove(item['id']! as String),
            colorScheme: cs,
          );
        },
      ),
    );
  }
}

enum _FavType { workout, recipe, product }

// ── Carte verticale pour scroll horizontal ───────────────────
class _FavoriteCardVertical extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final _FavType type;
  final VoidCallback onTap;
  final VoidCallback onUnfav;
  final ColorScheme colorScheme;

  const _FavoriteCardVertical({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.type,
    required this.onTap,
    required this.onUnfav,
    required this.colorScheme,
  });

  IconData get _typeIcon {
    switch (type) {
      case _FavType.workout: return LucideIcons.dumbbell;
      case _FavType.recipe: return LucideIcons.utensils;
      case _FavType.product: return LucideIcons.shoppingBag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image + bouton unfav ────────────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    width: 140,
                    height: 110,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.outline.withValues(alpha: 0.3),
                        child: Center(
                          child: Icon(_typeIcon,
                              color: colorScheme.onSurface.withValues(alpha: 0.5), size: 28),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onUnfav,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.heartOff,
                        size: 14,
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Titre + sous-titre ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
