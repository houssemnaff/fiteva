import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_data.dart';
import '../models/boutique_item.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FAVORITES SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class FavoritesScreen extends ConsumerStatefulWidget {
  final Set<String> wishlist;

  const FavoritesScreen({
    super.key,
    required this.wishlist,
  });

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  late Set<String> _local;

  @override
  void initState() {
    super.initState();
    _local = Set<String>.from(widget.wishlist);
  }

  // ── Color helpers (brightness-inline) ─────────────────────────────────────

  Color _bg(Brightness b) =>
      b == Brightness.light ? const Color(0xFFF5F5F3) : const Color(0xFF0F0F0F);

  Color _surface(Brightness b) =>
      b == Brightness.light ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C);

  Color _ink(Brightness b) =>
      b == Brightness.light ? const Color(0xFF111110) : const Color(0xFFF2F2F0);

  Color _inkMuted(Brightness b) =>
      b == Brightness.light ? const Color(0xFF777774) : const Color(0xFF8A8A88);

  Color _inkSubtle(Brightness b) =>
      b == Brightness.light ? const Color(0xFFAAAAAA) : const Color(0xFF5C5C5A);

  Color _divider(Brightness b) =>
      b == Brightness.light ? const Color(0xFFE5E5E3) : const Color(0xFF2A2A28);

  Color _chipBg(Brightness b) =>
      b == Brightness.light ? const Color(0xFFEBEBEA) : const Color(0xFF272725);

  Color _goldSurface(Brightness b) =>
      b == Brightness.light ? const Color(0xFFF7EDD8) : const Color(0xFF2A2010);

  // ── Filtered items ─────────────────────────────────────────────────────────

  List<BoutiqueItem> get _favorites => mockItems
      .where((e) => _local.contains('${e.brand}_${e.title}'))
      .toList();

  // ── Remove from wishlist ───────────────────────────────────────────────────

  void _removeFromWishlist(BoutiqueItem item) {
    final key = '${item.brand}_${item.title}';
    setState(() => _local.remove(key));
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

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final favorites = _favorites;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.pop(context, _local);
      },
      child: Scaffold(
        backgroundColor: _bg(brightness),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(brightness),
              Container(height: 0.5, color: _divider(brightness)),
              Expanded(
                child: favorites.isEmpty
                    ? _buildEmptyState(brightness)
                    : _buildList(favorites, brightness),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(Brightness brightness) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SizedBox(
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context, _local),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.transparent,
                  child: Icon(
                    CupertinoIcons.chevron_left,
                    color: _ink(brightness),
                    size: 20,
                  ),
                ),
              ),
            ),
            Text(
              'Mes favoris',
              style: TextStyle(
                color: _ink(brightness),
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildList(List<BoutiqueItem> items, Brightness brightness) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _FavoriteCard(
        item: items[i],
        userEtoiles: ref.read(shopProvider).points,
        brightness: brightness,
        onRemove: () => _removeFromWishlist(items[i]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BoutiqueDetailScreen(item: items[i]),
          ),
        ),
        surface: _surface(brightness),
        ink: _ink(brightness),
        inkMuted: _inkMuted(brightness),
        inkSubtle: _inkSubtle(brightness),
        dividerColor: _divider(brightness),
        chipBg: _chipBg(brightness),
        goldSurface: _goldSurface(brightness),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(Brightness brightness) {
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
                color: _chipBg(brightness),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.heart,
                size: 32,
                color: _inkSubtle(brightness),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun favori',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _ink(brightness),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des partenaires à vos favoris\nen appuyant sur le coeur.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _inkMuted(brightness),
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
  final int userEtoiles;
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
    required this.userEtoiles,
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

  bool get _canAfford => userEtoiles >= item.etoiles;

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
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: inkSubtle,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
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
                          etoiles: item.etoiles,
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
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 90,
              height: 90,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF111110),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  item.discount,
                  style: const TextStyle(
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
  final int etoiles;
  final bool canAfford;
  final Color inkSubtle;
  final Color goldSurface;

  static const Color _gold = Color(0xFFC4972A);

  const _StarsBadge({
    required this.etoiles,
    required this.canAfford,
    required this.inkSubtle,
    required this.goldSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: goldSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!canAfford)
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Icon(
                CupertinoIcons.lock_fill,
                size: 9,
                color: inkSubtle,
              ),
            ),
          Icon(
            Icons.star_rounded,
            size: 10,
            color: canAfford ? _gold : inkSubtle,
          ),
          const SizedBox(width: 3),
          Text(
            '$etoiles',
            style: TextStyle(
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
