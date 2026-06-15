import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mock_data.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LOCAL PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  final Color bg, surface, surfaceAlt, ink, inkMuted, inkSubtle;
  final Color divider, chipBg, chipSel, chipSelFg, goldSurface;
  final bool  isDark;

  static const Color gold    = Color(0xFFC4972A);
  static const Color wishRed = Color(0xFFD04040);

  static _P of(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const _P._dark() : const _P._light();
  }

  const _P._light()
      : bg = const Color(0xFFF5F5F3), surface = const Color(0xFFFFFFFF),
        surfaceAlt = const Color(0xFFEEEEEC), ink = const Color(0xFF111110),
        inkMuted = const Color(0xFF777774), inkSubtle = const Color(0xFFAAAAAA),
        divider = const Color(0xFFE5E5E3), chipBg = const Color(0xFFEBEBEA),
        chipSel = const Color(0xFF111110), chipSelFg = const Color(0xFFFFFFFF),
        goldSurface = const Color(0xFFF7EDD8), isDark = false;

  const _P._dark()
      : bg = const Color(0xFF0F0F0F), surface = const Color(0xFF1C1C1C),
        surfaceAlt = const Color(0xFF252523), ink = const Color(0xFFF2F2F0),
        inkMuted = const Color(0xFF8A8A88), inkSubtle = const Color(0xFF5C5C5A),
        divider = const Color(0xFF2A2A28), chipBg = const Color(0xFF272725),
        chipSel = const Color(0xFFF2F2F0), chipSelFg = const Color(0xFF111110),
        goldSurface = const Color(0xFF2A2010), isDark = true;

  List<BoxShadow> get cardShadow => isDark ? [] : [
    BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 5))
  ];
  Border? get cardBorder => isDark ? Border.all(color: divider, width: 0.5) : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _Cat {
  final String key, label;
  final IconData icon;
  const _Cat({required this.key, required this.label, required this.icon});
}

const _kCats = [
  _Cat(key: 'all',       label: 'Tout',      icon: Icons.apps_rounded),
  _Cat(key: 'mamans',    label: 'Mamans',    icon: Icons.favorite_rounded),
  _Cat(key: 'baby',      label: 'Baby',      icon: Icons.child_care),
  _Cat(key: 'sport',     label: 'Sport',     icon: Icons.fitness_center),
  _Cat(key: 'vitamines', label: 'Vitamines', icon: Icons.eco_rounded),
  _Cat(key: 'skincare',  label: 'Skincare',  icon: Icons.spa_rounded),
  _Cat(key: 'home',      label: 'Maison',    icon: Icons.home_rounded),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class AllPartenairesScreen extends ConsumerStatefulWidget {
  const AllPartenairesScreen({super.key});

  @override
  ConsumerState<AllPartenairesScreen> createState() => _AllPartenairesScreenState();
}

class _AllPartenairesScreenState extends ConsumerState<AllPartenairesScreen> {
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  final _scrollCtrl  = ScrollController();

  String _search   = '';
  String _cat      = 'all';
  bool   _elevated = false;

  static const int _kUserEtoiles = 60;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
    _scrollCtrl.addListener(() {
      final e = _scrollCtrl.offset > 10;
      if (e != _elevated) setState(() => _elevated = e);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List get _filtered => mockItems.where((e) {
    final q = _search.toLowerCase();
    final matchSearch = q.isEmpty ||
        e.brand.toLowerCase().contains(q) ||
        e.title.toLowerCase().contains(q);
    final matchCat = _cat == 'all' || e.category.toLowerCase() == _cat.toLowerCase();
    return matchSearch && matchCat;
  }).toList();

  void _toggleWish(String id) => ref.read(shopWishlistProvider.notifier).toggleWishlist(id);

  @override
  Widget build(BuildContext context) {
    final p        = _P.of(context);
    final filtered = _filtered;
    final wishlist = ref.watch(shopWishlistProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          // ── Sticky header ──────────────────────────────────────────────
          _StickyHeader(
            p: p,
            elevated: _elevated,
            cat: _cat,
            searchCtrl: _searchCtrl,
            searchFocus: _searchFocus,
            search: _search,
            onCat: (k) => setState(() => _cat = k),
            onBack: () => Navigator.pop(context),
          ),
          // ── Count row ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
            child: Row(
              children: [
                Text(
                  '${filtered.length} partenaire${filtered.length > 1 ? 's' : ''}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: p.inkSubtle,
                      letterSpacing: 0.4),
                ),
              ],
            ),
          ),
          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(p: p)
                : ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      final id   = '${item.brand}_${item.title}';
                      return _PartnerCard(
                        p: p,
                        item: item,
                        isWishlisted: wishlist.contains(id),
                        onWish: () => _toggleWish(id),
                        onTap: () => Navigator.push(
                            ctx,
                            CupertinoPageRoute(
                                builder: (_) => BoutiqueDetailScreen(item: item))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY HEADER (app bar + search + chips)
// ─────────────────────────────────────────────────────────────────────────────
class _StickyHeader extends StatelessWidget {
  final _P p;
  final bool elevated;
  final String cat;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final String search;
  final ValueChanged<String> onCat;
  final VoidCallback onBack;

  const _StickyHeader({
    required this.p,
    required this.elevated,
    required this.cat,
    required this.searchCtrl,
    required this.searchFocus,
    required this.search,
    required this.onCat,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: p.bg,
        border: elevated
            ? Border(bottom: BorderSide(color: p.divider, width: 1))
            : const Border(),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nav row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: onBack,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.chevron_left, size: 15, color: p.ink),
                          const SizedBox(width: 3),
                          Text('Boutique',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: p.ink)),
                        ],
                      ),
                    ),
                  ),
                  Text('Partenaires',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: p.ink,
                          letterSpacing: -0.3)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: p.divider, width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(CupertinoIcons.search, size: 16, color: p.inkSubtle),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        focusNode: searchFocus,
                        style: TextStyle(fontSize: 14, color: p.ink),
                        decoration: InputDecoration(
                          hintText: 'Rechercher un partenaire…',
                          hintStyle: TextStyle(fontSize: 14, color: p.inkSubtle),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        cursorColor: p.ink,
                        cursorWidth: 1.5,
                      ),
                    ),
                    if (search.isNotEmpty)
                      GestureDetector(
                        onTap: searchCtrl.clear,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(CupertinoIcons.xmark_circle_fill,
                              size: 16, color: p.inkSubtle),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Category chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                itemCount: _kCats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c     = _kCats[i];
                  final isSel = cat == c.key;
                  return GestureDetector(
                    onTap: () => onCat(c.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSel ? p.chipSel : p.chipBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.icon, size: 13,
                              color: isSel ? p.chipSelFg : p.inkMuted),
                          const SizedBox(width: 6),
                          Text(c.label,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSel ? p.chipSelFg : p.inkMuted,
                                  letterSpacing: 0.1)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER CARD — horizontal list style
// ─────────────────────────────────────────────────────────────────────────────
class _PartnerCard extends ConsumerStatefulWidget {
  final _P p;
  final dynamic item;
  final bool isWishlisted;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _PartnerCard({
    required this.p,
    required this.item,
    required this.isWishlisted,
    required this.onWish,
    required this.onTap,
  });

  @override
  ConsumerState<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends ConsumerState<_PartnerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 130),
        lowerBound: 0.97,
        upperBound: 1.0,
        value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _can => ref.read(shopProvider).canAfford(widget.item.etoiles as int);

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          height: 114,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: p.cardShadow,
            border: p.cardBorder,
          ),
          child: Row(
            children: [
              // Image
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 90, height: 90,
                        child: _NetImage(
                            url: widget.item.imageUrl as String?,
                            category: widget.item.category as String,
                            p: p),
                      ),
                    ),
                    if (!_can)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                              color: Colors.black.withValues(alpha: 0.22)),
                        ),
                      ),
                    if (widget.item.discount != null &&
                        (widget.item.discount as String).isNotEmpty)
                      Positioned(
                        top: 5, left: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFF111110),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(widget.item.discount as String,
                              style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3)),
                        ),
                      ),
                    if (!_can)
                      const Positioned(
                        bottom: 6, right: 6,
                        child: Icon(CupertinoIcons.lock_fill,
                            size: 12, color: Colors.white),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.item.brand as String).toUpperCase(),
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: p.inkSubtle,
                            letterSpacing: 1.8,
                            height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.title as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                            height: 1.3),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _StarsBadge(
                              p: p,
                              etoiles: widget.item.etoiles as int,
                              can: _can),
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.onWish,
                            child: Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                color: p.isDark
                                    ? p.chipBg
                                    : Colors.white.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                                border: p.isDark
                                    ? Border.all(
                                        color: p.divider, width: 0.5)
                                    : null,
                              ),
                              child: Icon(
                                widget.isWishlisted
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                size: 14,
                                color: widget.isWishlisted
                                    ? _P.wishRed
                                    : p.inkSubtle,
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STARS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _StarsBadge extends StatelessWidget {
  final _P p;
  final int etoiles;
  final bool can;
  const _StarsBadge(
      {required this.p, required this.etoiles, required this.can});

  @override
  Widget build(BuildContext context) {
    final bg = can ? p.goldSurface : p.chipBg;
    final fg = can ? _P.gold : p.inkSubtle;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(CupertinoIcons.star_fill, size: 10, color: fg),
            const SizedBox(width: 5),
            Text('$etoiles',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
          ]),
        ),
        if (!can) ...[
          const SizedBox(width: 5),
          Icon(CupertinoIcons.lock_fill, size: 10, color: p.inkSubtle),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NET IMAGE
// ─────────────────────────────────────────────────────────────────────────────
class _NetImage extends StatelessWidget {
  final String? url;
  final String  category;
  final _P      p;
  const _NetImage(
      {required this.url, required this.category, required this.p});

  static const Map<String, IconData> _icons = {
    'mamans': Icons.favorite_rounded,
    'baby': Icons.child_care,
    'sport': Icons.fitness_center,
    'vitamines': Icons.eco_rounded,
    'skincare': Icons.spa_rounded,
    'home': Icons.home_rounded,
  };

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(url!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: p.surfaceAlt,
    child: Icon(_icons[category] ?? Icons.shopping_bag_outlined,
        size: 28, color: p.inkSubtle),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final _P p;
  const _EmptyState({required this.p});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: p.chipBg, shape: BoxShape.circle),
            child: Icon(CupertinoIcons.bag, size: 32, color: p.inkSubtle),
          ),
          const SizedBox(height: 20),
          Text('Aucun partenaire trouvé',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: p.ink)),
          const SizedBox(height: 8),
          Text('Essayez un autre filtre ou mot-clé.',
              style: TextStyle(fontSize: 14, color: p.inkMuted)),
        ],
      ),
    );
  }
}
