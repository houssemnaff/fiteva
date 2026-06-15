import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/core/nutrition/favorites_provider.dart' as nutrition;
import 'package:fiteva/core/shop/shop_provider.dart' as shop_provider;

enum FavoriteType { workout, recipe, product }

class FavoritesBottomSheet extends ConsumerStatefulWidget {
  const FavoritesBottomSheet({super.key});

  @override
  ConsumerState<FavoritesBottomSheet> createState() => _FavoritesBottomSheetState();
}

class _FavoritesBottomSheetState extends ConsumerState<FavoritesBottomSheet> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Programmes', 'icon': LucideIcons.dumbbell, 'type': FavoriteType.workout},
    {'label': 'Recettes', 'icon': LucideIcons.utensils, 'type': FavoriteType.recipe},
    {'label': 'Boutique', 'icon': LucideIcons.shoppingBag, 'type': FavoriteType.product},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final programFavorites = ref.watch(favoritesProvider);
    final recipeFavorites = ref.watch(nutrition.favoritesProvider);
    final shopWishlist = ref.watch(shop_provider.shopWishlistProvider);

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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mes favoris',
                    style: GoogleFonts.outfit(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tab bar
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

          // Content grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildContent(_selectedTab, programFavorites, recipeFavorites, shopWishlist, allPrograms, cs),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getItems(int tab, Set<String> programFavorites, Set<String> recipeFavorites, Set<String> shopWishlist, List<dynamic> allPrograms) {
    if (tab == 0) {
      // Programs - filter by name
      return allPrograms
          .where((p) => programFavorites.contains(p.name))
          .map((p) => {
            'id': p.name,
            'title': p.name,
            'subtitle': '${p.duration} · ${p.sessions}',
            'image': p.imageUrl,
          })
          .toList();
    } else if (tab == 1) {
      // Recipes - show only favorited recipe IDs
      return recipeFavorites
          .map((id) => {
            'id': id,
            'title': id,
            'subtitle': 'Recipe',
            'image': 'assets/images/recipe.jpg',
          })
          .toList();
    } else {
      // Products - show shop wishlist items
      return shopWishlist
          .map((id) => {
            'id': id,
            'title': id,
            'subtitle': 'Produit',
            'image': 'assets/images/product.jpg',
          })
          .toList();
    }
  }

  Widget _buildContent(int tab, Set<String> programFavorites, Set<String> recipeFavorites, Set<String> shopWishlist, List<dynamic> allPrograms, ColorScheme cs) {
    final items = _getItems(tab, programFavorites, recipeFavorites, shopWishlist, allPrograms);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _FavoriteCard(
          id: item['id']! as String,
          title: item['title']! as String,
          subtitle: item['subtitle']! as String,
          imageAsset: item['image']! as String,
          type: _tabs[tab]['type'] as FavoriteType,
          onRemove: () async => await _removeItem(item['id']! as String, tab),
          colorScheme: cs,
          isPlaceholder: tab != 0,
        );
      },
    );
  }

  Future<void> _removeItem(String id, int tab) async {
    if (tab == 0) {
      // Remove from programs favorites
      await ref.read(favoritesProvider.notifier).toggleFavorite(id);
    } else if (tab == 1) {
      // Remove from recipes favorites
      ref.read(nutrition.favoritesProvider.notifier).toggle(id);
    } else if (tab == 2) {
      // Remove from shop wishlist
      await ref.read(shop_provider.shopWishlistProvider.notifier).removeFromWishlist(id);
    }
  }
}

class _FavoriteCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final FavoriteType type;
  final VoidCallback onRemove;
  final ColorScheme colorScheme;
  final bool isPlaceholder;

  const _FavoriteCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.type,
    required this.onRemove,
    required this.colorScheme,
    this.isPlaceholder = false,
  });

  IconData get _typeIcon {
    switch (type) {
      case FavoriteType.workout:
        return LucideIcons.dumbbell;
      case FavoriteType.recipe:
        return LucideIcons.utensils;
      case FavoriteType.product:
        return LucideIcons.shoppingBag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: isPlaceholder
                      ? Container(
                          color: colorScheme.surfaceContainerHigh,
                          child: Center(
                            child: Icon(
                              _typeIcon,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                              size: 40,
                            ),
                          ),
                        )
                      : Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.surfaceContainerHigh,
                            child: Center(
                              child: Icon(
                                _typeIcon,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
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
    );
  }
}
