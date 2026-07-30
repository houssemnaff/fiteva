import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boutique_item.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FAVORITES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  // ── Color helpers — dérivés du ColorScheme du thème actif (palette Pro) ────

  Color _bg(ColorScheme cs)     => cs.surface;
  Color _surface(ColorScheme cs) => cs.surface;
  Color _ink(ColorScheme cs)     => cs.onSurface;
  Color _inkMuted(ColorScheme cs) => cs.onSurface.withValues(alpha: 0.55);
  Color _inkSubtle(ColorScheme cs) => cs.onSurface.withValues(alpha: 0.35);
  Color _divider(ColorScheme cs) => cs.outline;
  Color _chipBg(ColorScheme cs)  => cs.surfaceContainerHighest;

  Color _goldSurface(Brightness b) =>
      b == Brightness.light ? const Color(0xFFF7EDD8) : const Color(0xFF2A2010);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = Theme.of(context).brightness;
    final cs = Theme.of(context).colorScheme;
    final wishlist  = ref.watch(shopWishlistProvider);
    final allItems  = ref.watch(shopItemsProvider).asData?.value ?? <BoutiqueItem>[];
    final favorites = allItems.where((e) => wishlist.contains(e.id)).toList();

    void removeFromWishlist(BoutiqueItem item) {
      final key = '${item.brand}_${item.title}';
      ref.read(shopWishlistProvider.notifier).removeFromWishlist(key);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Retiré des favoris',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(milliseconds: 1800),
          backgroundColor: const Color(0xFF1C1C1C),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg(cs),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: favorites.isEmpty
                  ? _buildEmptyState(brightness, cs)
                  : _buildList(context, ref, favorites, brightness, cs, removeFromWishlist),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      decoration: BoxDecoration(
        color: _surface(cs),
        border: Border(bottom: BorderSide(color: _divider(cs), width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Icon(CupertinoIcons.chevron_left, color: _ink(cs), size: 20),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: cs.brightness == Brightness.dark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(CupertinoIcons.heart_fill, size: 16, color: cs.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  'Mes favoris',
                  style: GoogleFonts.outfit(
                    color: _ink(cs),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, WidgetRef ref, List<BoutiqueItem> items, Brightness brightness, ColorScheme cs, Function(BoutiqueItem) removeFromWishlist) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _FavoriteCard(
        item: items[i],
        userDiamonds: ref.read(shopProvider).diamonds,
        brightness: brightness,
        onRemove: () => removeFromWishlist(items[i]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoutiqueDetailScreen(item: items[i]),
          ),
        ),
        surface: _surface(cs),
        ink: _ink(cs),
        inkMuted: _inkMuted(cs),
        inkSubtle: _inkSubtle(cs),
        dividerColor: _divider(cs),
        chipBg: _chipBg(cs),
        goldSurface: _goldSurface(brightness),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(Brightness brightness, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: brightness == Brightness.dark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.heart_fill,
                size: 32,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _ink(cs),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des partenaires à vos favoris\nen appuyant sur le coeur.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _inkMuted(cs),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAVORITE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final BoutiqueItem item;
  final int userDiamonds;
  final Brightness brightness;
  final VoidCallback onRemove;
  final VoidCallback onTap;
  final Color surface;
  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color dividerColor;
  final Color chipBg;
  final Color goldSurface;

  static const Color _wishRed = Color(0xFFD04040);

  const _FavoriteCard({
    required this.item,
    required this.userDiamonds,
    required this.brightness,
    required this.onRemove,
    required this.onTap,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.inkSubtle,
    required this.dividerColor,
    required this.chipBg,
    required this.goldSurface,
  });

  bool get _canAfford => userDiamonds >= item.diamonds;

  @override
  Widget build(BuildContext context) {
    final isLight = brightness == Brightness.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 114,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
          border: isLight
              ? null
              : Border.all(color: dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            _buildImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.brand.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: inkSubtle,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ink,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _StarsBadge(
                          diamonds: item.diamonds,
                          canAfford: _canAfford,
                          inkSubtle: inkSubtle,
                          goldSurface: goldSurface,
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _wishRed.withValues(alpha: 0.10),
                            ),
                            child: const Icon(
                              CupertinoIcons.heart_fill,
                              color: _wishRed,
                              size: 16,
                            ),
                          ),
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

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 90,
              height: 90,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                placeholder: (_, __) => Container(color: chipBg),
                errorWidget: (_, __, ___) => Container(
                  color: chipBg,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: inkSubtle,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          if (item.discount.isNotEmpty)
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF16211A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.discount,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STARS BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _StarsBadge extends StatelessWidget {
  final int diamonds;
  final bool canAfford;
  final Color inkSubtle;
  final Color goldSurface;

  static const Color _gold = Color(0xFFC4972A);

  const _StarsBadge({
    required this.diamonds,
    required this.canAfford,
    required this.inkSubtle,
    required this.goldSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: goldSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canAfford)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                CupertinoIcons.lock_fill,
                size: 10,
                color: inkSubtle,
              ),
            ),
          Icon(
            LucideIcons.gem,
            size: 11,
            color: canAfford ? _gold : inkSubtle,
          ),
          const SizedBox(width: 5),
          Text(
            '$diamonds',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: canAfford ? _gold : inkSubtle,
            ),
          ),
        ],
      ),
    );
  }
}
