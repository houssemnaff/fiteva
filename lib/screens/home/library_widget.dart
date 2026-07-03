import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/core/nutrition/favorites_provider.dart' as nutrition;
import 'package:fiteva/core/shop/shop_provider.dart' as shop_provider;
import 'package:fiteva/screens/home/favorites_bottom_sheet.dart';
import 'package:fiteva/screens/shop/models/boutique_item.dart';
import 'package:fiteva/screens/workout/programme_detail_screen.dart';
import 'package:fiteva/l10n/app_localizations.dart';

class LibrarySection extends ConsumerStatefulWidget {
  const LibrarySection();

  @override
  ConsumerState<LibrarySection> createState() => _LibrarySectionState();
}

class _LibrarySectionState extends ConsumerState<LibrarySection> {
  int _selectedTab = 0;

  List<Map<String, dynamic>> get _tabs => FavoritesBottomSheet.tabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = ref.watch(l10nProvider);
    final programFavorites = ref.watch(favoritesProvider);
    final recipeFavorites = ref.watch(nutrition.favoritesProvider);
    final shopWishlist = ref.watch(shop_provider.shopWishlistProvider);
    final shopItemsAsync = ref.watch(shop_provider.shopItemsProvider);
    final shopItems = shopItemsAsync.maybeWhen(
      data: (d) => d,
      orElse: () => <BoutiqueItem>[],
    );

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
                child: Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    border: Border.all(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      width: 1,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Text(
    l10n.sectionVoirTout,
    style: GoogleFonts.inter(
      color: Theme.of(context).colorScheme.primary,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),
)
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
        _buildContent(_selectedTab, programFavorites, recipeFavorites, shopWishlist, allPrograms, shopItems, cs),
      ],
    );
  }

  Widget _buildContent(int tab, Set<String> programFavorites, Set<String> recipeFavorites, Set<String> shopWishlist, List<dynamic> allPrograms, List<BoutiqueItem> shopItems, ColorScheme cs) {
    final items = FavoritesBottomSheet.getFavoriteItems(tab, programFavorites, recipeFavorites, shopWishlist, allPrograms, shopItems);
    final type = _tabs[tab]['type'] as FavoriteType;

    return _buildHorizontalList(
      items,
      type: type,
      cs: cs,
      onRemove: (id) async {
        if (tab == 0) {
          await ref.read(favoritesProvider.notifier).toggleFavorite(id);
        } else if (tab == 1) {
          await ref.read(nutrition.favoritesProvider.notifier).toggle(id);
        } else {
          await ref.read(shop_provider.shopWishlistProvider.notifier).removeFromWishlist(id);
        }
      },
      onItemTap: (item) {
        if (tab == 0) {
          final progId = (item['id'] as String).replaceFirst('prog:', '');
          final prog = allPrograms.firstWhere(
            (p) => p.id == progId,
            orElse: () => null,
          );
          if (prog != null) {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => WorkoutDetailScreen(program: prog),
            ));
          }
        } else if (tab == 1) {
          Navigator.of(context).pushNamed('/nutrition');
        } else {
          Navigator.of(context).pushNamed('/boutique');
        }
      },
    );
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

  Widget _buildHorizontalList(List<Map<String, dynamic>> items, {required FavoriteType type, required ColorScheme cs, required Function(String) onRemove, Function(Map<String, dynamic>)? onItemTap}) {
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
            onTap: () => onItemTap?.call(item),
            onUnfav: () async => await onRemove(item['id']! as String),
            colorScheme: cs,
          );
        },
      ),
    );
  }
}

// ── Carte verticale pour scroll horizontal ───────────────────
class _FavoriteCardVertical extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final FavoriteType type;
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
      case FavoriteType.workout: return LucideIcons.dumbbell;
      case FavoriteType.recipe: return LucideIcons.utensils;
      case FavoriteType.product: return LucideIcons.shoppingBag;
    }
  }

  Widget _placeholder() {
    return Container(
      color: colorScheme.outline.withValues(alpha: 0.3),
      child: Center(
        child: Icon(_typeIcon,
            color: colorScheme.onSurface.withValues(alpha: 0.5), size: 28),
      ),
    );
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
                    child: imageAsset.isEmpty
                        ? _placeholder()
                        : (imageAsset.startsWith('http://') || imageAsset.startsWith('https://'))
                            ? Image.network(
                                imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
                              )
                            : Image.asset(
                                imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _placeholder(),
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
