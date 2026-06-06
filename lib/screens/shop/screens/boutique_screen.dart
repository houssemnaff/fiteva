import 'package:fiteva/screens/shop/screens/all_partenaires_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import 'boutique_detail_screen.dart';
import 'favorites_screen.dart';
import 'partner_form_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR PALETTE — light & dark
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkMuted;
  final Color inkSubtle;
  final Color divider;
  final Color chipBg;
  final Color chipSel;
  final Color chipSelFg;
  final Color goldSurface;
  final bool  isDark;

  static const Color gold    = Color(0xFFC4972A);
  static const Color wishRed = Color(0xFFD04040);

  static _C of(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const _C._dark() : const _C._light();
  }

  const _C._light()
      : bg          = const Color.fromARGB(255, 255, 255, 255),
        surface     = const Color(0xFFFFFFFF),
        surfaceAlt  = const Color(0xFFEEEEEC),
        ink         = const Color(0xFF111110),
        inkMuted    = const Color(0xFF777774),
        inkSubtle   = const Color(0xFFAAAAAA),
        divider     = const Color(0xFFE5E5E3),
        chipBg      = const Color(0xFFEBEBEA),
        chipSel     = const Color(0xFF111110),
        chipSelFg   = const Color(0xFFFFFFFF),
        goldSurface = const Color(0xFFF7EDD8),
        isDark      = false;

  const _C._dark()
      : bg          = const Color(0xFF0F0F0F),
        surface     = const Color(0xFF1C1C1C),
        surfaceAlt  = const Color(0xFF252523),
        ink         = const Color(0xFFF2F2F0),
        inkMuted    = const Color(0xFF8A8A88),
        inkSubtle   = const Color(0xFF5C5C5A),
        divider     = const Color(0xFF2A2A28),
        chipBg      = const Color(0xFF272725),
        chipSel     = const Color(0xFFF2F2F0),
        chipSelFg   = const Color(0xFF111110),
        goldSurface = const Color(0xFF2A2010),
        isDark      = true;
}

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  static const double rCard  = 16.0;
  static const double rChip  = 24.0;
  static const double rBtn   = 14.0;
  static const double rBadge = 6.0;

  static List<BoxShadow> card(_C c) => c.isDark
      ? []
      : [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 6))];

  static List<BoxShadow> soft(_C c) => c.isDark
      ? []
      : [BoxShadow(color: const Color(0xFF000000).withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))];

  static Border? cardBorder(_C c) =>
      c.isDark ? Border.all(color: c.divider, width: 0.5) : null;

  static TextStyle heading(_C c, double size,
          {FontWeight fw = FontWeight.w700, double ls = -0.5}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: c.ink, letterSpacing: ls, height: 1.1);

  static TextStyle body(_C c, double size,
          {Color? color, FontWeight fw = FontWeight.w400, double ls = 0.0}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: color ?? c.inkMuted, letterSpacing: ls, height: 1.5);

  static TextStyle label(_C c, double size,
          {Color? color, FontWeight fw = FontWeight.w600, double ls = 0.8}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: color ?? c.inkMuted, letterSpacing: ls);

  static TextStyle overline(_C c, double size, {Color? color}) =>
      TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: color ?? c.inkSubtle, letterSpacing: 1.8, height: 1.2);
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL — with icon
// ─────────────────────────────────────────────────────────────────────────────
class _Cat {
  final String   key;
  final String   label;
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
// SORT / FILTERS
// ─────────────────────────────────────────────────────────────────────────────
enum _Sort { none, topDeals, mostPopular, expiringSoon, discount10, discount20, discount30 }

extension _SortLabel on _Sort {
  String get label => switch (this) {
        _Sort.none         => 'Tout',
        _Sort.topDeals     => 'Meilleures offres',
        _Sort.mostPopular  => 'Plus populaires',
        _Sort.expiringSoon => 'Expire bientôt',
        _Sort.discount10   => '10% off',
        _Sort.discount20   => '20% off',
        _Sort.discount30   => '30%+ off',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTIQUE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BoutiqueScreen extends StatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  State<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

class _BoutiqueScreenState extends State<BoutiqueScreen> {
  String _cat            = 'all';
  _Sort  _sort           = _Sort.none;
  bool   _filterElevated = false;

  final Set<String> _wishlist    = {};
  final int         _userEtoiles = 60;
  final _scrollCtrl              = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final elevated = _scrollCtrl.offset > 80;
    if (elevated != _filterElevated) setState(() => _filterElevated = elevated);
  }

  @override
  void dispose() {
    _scrollCtrl..removeListener(_onScroll)..dispose();
    super.dispose();
  }

  List get _picks => mockItems.take(3).toList();

  List get _filtered {
    var list = List.from(mockItems);
    if (_cat != 'all') list = list.where((e) => e.category == _cat).toList();
    switch (_sort) {
      case _Sort.topDeals:
        list.sort((a, b) => (b.etoiles as int).compareTo(a.etoiles as int));
      case _Sort.mostPopular:
        list.sort((a, b) => (a.etoiles as int).compareTo(b.etoiles as int));
      case _Sort.expiringSoon:
        list = list.where((e) => e.discount != null && (e.discount as String).isNotEmpty).toList();
      case _Sort.discount10:
        list = list.where((e) => (e.discount as String? ?? '').contains('10')).toList();
      case _Sort.discount20:
        list = list.where((e) => (e.discount as String? ?? '').contains('20')).toList();
      case _Sort.discount30:
        list = list.where((e) {
          final d = e.discount as String? ?? '';
          return d.contains('30') || d.contains('40') || d.contains('50');
        }).toList();
      case _Sort.none:
        break;
    }
    return list;
  }

  void _selectCat(String key) => setState(() { _cat = key; _sort = _Sort.none; });
  void _toggleWish(String id) => setState(() {
        _wishlist.contains(id) ? _wishlist.remove(id) : _wishlist.add(id);
      });
  void _clearFilters() => setState(() { _cat = 'all'; _sort = _Sort.none; });

  void _openFavorites() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => FavoritesScreen(
          wishlist: Set.from(_wishlist),
          userEtoiles: _userEtoiles,
        ),
      ),
    ).then((updatedIds) {
      if (updatedIds != null && mounted) {
        setState(() {
          _wishlist
            ..clear()
            ..addAll(updatedIds as Set<String>);
        });
      }
    });
  }

  void _openPartnerForm() {
    Navigator.push(context,
        CupertinoPageRoute(builder: (_) => const PartnerFormScreen()));
  }

  void _showSortSheet() {
    final c = _C.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        c: c,
        selected: _sort,
        onSelect: (s) {
          setState(() { _sort = s; _cat = 'all'; });
          Navigator.pop(context);
        },
        onClear: () {
          setState(() => _sort = _Sort.none);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c        = _C.of(context);
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(c: c, etoiles: _userEtoiles, onFavoritesTap: _openFavorites),
                  const SizedBox(height: 28),
                  _PicksSection(
                    c: c,
                    items: _picks,
                    userEtoiles: _userEtoiles,
                    wishlist: _wishlist,
                    onWish: _toggleWish,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Sticky filter bar (single row + sort button) ─────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              cats: _kCats,
              selectedCat: _cat,
              selectedSort: _sort,
              elevated: _filterElevated,
              onCat: _selectCat,
              onFilterTap: _showSortSheet,
            ),
          ),

          // ── Section label ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: _SectionHeader(
                c: c,
                cat: _kCats.firstWhere((cat) => cat.key == _cat),
                count: filtered.length,
                onSeeAll: () => Navigator.push(context,
                    CupertinoPageRoute(builder: (_) => const AllPartenairesScreen())),
              ),
            ),
          ),
if (filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: _PartnerBanner(c: c, onTap: _openPartnerForm),
              ),
            ),

          // ── Partner list or empty state ──────────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(c: c, onReset: _clearFilters),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final item = filtered[i];
                        final id   = '${item.brand}_${item.title}';
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: i < filtered.length - 1 ? 12 : 0),
                          child: _PartnerCard(
                            key: ValueKey(id),
                            item: item,
                            userEtoiles: _userEtoiles,
                            isWishlisted: _wishlist.contains(id),
                            onWish: () => _toggleWish(id),
                            onTap: () => Navigator.push(
                                ctx,
                                CupertinoPageRoute(
                                    builder: (_) => BoutiqueDetailScreen(
                                          item: item,
                                          userEtoiles: _userEtoiles,
                                        ))),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

          // ── Devenir partenaire banner ────────────────────────────────
          
          // ── Footer ──────────────────────────────────────────────────────
        
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER — title left, stars badge right
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final _C          c;
  final int         etoiles;
  final VoidCallback onFavoritesTap;
  const _Header({required this.c, required this.etoiles, required this.onFavoritesTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Boutique', style: _T.heading(c, 34, ls: -1.2)),
              const SizedBox(height: 4),
              Text('Récompenses partenaires', style: _T.body(c, 13.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Favorites button
        GestureDetector(
          onTap: onFavoritesTap,
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: c.divider, width: 1),
            ),
            child: Icon(CupertinoIcons.heart, size: 17, color: c.ink),
          ),
        ),
        const SizedBox(width: 10),
        // Stars badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: c.isDark
                ? _C.gold.withValues(alpha: 0.14)
                : const Color(0xFFF7EDD8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _C.gold.withValues(alpha: 0.35), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.star_fill, color: _C.gold, size: 14),
              const SizedBox(width: 7),
              Text(
                '$etoiles',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _C.gold,
                  fontSize: 15,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text('pts',
                  style: TextStyle(
                    color: _C.gold.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER BANNER — "Devenir partenaire" CTA
// ─────────────────────────────────────────────────────────────────────────────
class _PartnerBanner extends StatelessWidget {
  final _C          c;
  final VoidCallback onTap;
  const _PartnerBanner({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: c.isDark
                ? [const Color(0xFF1C1C1C), const Color(0xFF0D0D0D)]
                : [const Color(0xFF1A1A18), const Color(0xFF0D0D0B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _C.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.handshake_rounded, color: _C.gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Devenir partenaire',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Rejoignez notre réseau et bénéficiez de plus de visibilité.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(CupertinoIcons.chevron_right,
                  size: 13, color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PICKS SECTION — bento grid (tall left + two stacked right)
// ─────────────────────────────────────────────────────────────────────────────
class _PicksSection extends StatelessWidget {
  final _C c;
  final List items;
  final int userEtoiles;
  final Set<String> wishlist;
  final void Function(String) onWish;

  const _PicksSection({
    required this.c,
    required this.items,
    required this.userEtoiles,
    required this.wishlist,
    required this.onWish,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final main   = items[0];
    final mainId = '${main.brand}_${main.title}';
    final sub1   = items.length > 1 ? items[1] : null;
    final sub1Id = sub1 != null ? '${sub1.brand}_${sub1.title}' : '';
    final sub2   = items.length > 2 ? items[2] : null;
    final sub2Id = sub2 != null ? '${sub2.brand}_${sub2.title}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('À LA UNE', style: _T.overline(c, 10.5)),
            const SizedBox(width: 14),
            Expanded(child: Container(height: 1, color: c.divider)),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 280,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 54,
                child: _BentoCard(
                  item: main,
                  userEtoiles: userEtoiles,
                  isWishlisted: wishlist.contains(mainId),
                  onWish: () => onWish(mainId),
                  onTap: () => Navigator.push(context,
                      CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: main, userEtoiles: userEtoiles))),
                  compact: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 46,
                child: Column(
                  children: [
                    if (sub1 != null)
                      Expanded(
                        child: _BentoCard(
                          item: sub1,
                          userEtoiles: userEtoiles,
                          isWishlisted: wishlist.contains(sub1Id),
                          onWish: () => onWish(sub1Id),
                          onTap: () => Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: sub1, userEtoiles: userEtoiles))),
                          compact: true,
                        ),
                      ),
                    if (sub1 != null && sub2 != null) const SizedBox(height: 10),
                    if (sub2 != null)
                      Expanded(
                        child: _BentoCard(
                          item: sub2,
                          userEtoiles: userEtoiles,
                          isWishlisted: wishlist.contains(sub2Id),
                          onWish: () => onWish(sub2Id),
                          onTap: () => Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: sub2, userEtoiles: userEtoiles))),
                          compact: true,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatefulWidget {
  final dynamic item;
  final int userEtoiles;
  final bool isWishlisted;
  final VoidCallback onWish;
  final VoidCallback onTap;
  final bool compact;

  const _BentoCard({
    required this.item,
    required this.userEtoiles,
    required this.isWishlisted,
    required this.onWish,
    required this.onTap,
    required this.compact,
  });

  @override
  State<_BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<_BentoCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 110),
        lowerBound: 0.96, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_T.rCard),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _ProductImage(
                imageUrl: widget.item.imageUrl as String?,
                category: widget.item.category as String,
                width: double.infinity, height: double.infinity,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xBB000000)],
                    stops: [0.28, 1.0],
                  ),
                ),
              ),
              if (widget.item.discount != null && (widget.item.discount as String).isNotEmpty)
                Positioned(top: 10, left: 10,
                    child: _DiscountBadge(label: widget.item.discount as String)),
              Positioned(top: 8, right: 8,
                  child: _WishButton(isActive: widget.isWishlisted, onTap: widget.onWish)),
              Positioned(
                left: 12, right: 12, bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text((widget.item.brand as String).toUpperCase(),
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1.6)),
                    if (!widget.compact) ...[
                      const SizedBox(height: 3),
                      Text(widget.item.title as String, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                            color: Colors.white, height: 1.3)),
                    ],
                    const SizedBox(height: 8),
                    _StarsBadge(
                      etoiles: widget.item.etoiles as int,
                      canAfford: widget.userEtoiles >= (widget.item.etoiles as int),
                      onDark: true,
                    ),
                  ],
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
// STICKY FILTER BAR — single row of icon+text chips + "Trier" button
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final List<_Cat>  cats;
  final String      selectedCat;
  final _Sort       selectedSort;
  final bool        elevated;
  final ValueChanged<String> onCat;
  final VoidCallback         onFilterTap;

  const _FilterBarDelegate({
    required this.cats,
    required this.selectedCat,
    required this.selectedSort,
    required this.elevated,
    required this.onCat,
    required this.onFilterTap,
  });

  static const double _h = 54.0;

  @override double get minExtent => _h;
  @override double get maxExtent => _h;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.selectedCat != selectedCat ||
      old.selectedSort != selectedSort ||
      old.elevated != elevated;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final c         = _C.of(context);
    final hasFilter = selectedSort != _Sort.none;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _h,
      decoration: BoxDecoration(
        color: c.bg,
        border: elevated
            ? Border(bottom: BorderSide(color: c.divider, width: 1))
            : const Border(),
      ),
      child: Row(
        children: [
          // Category chips scroll
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _Chip(
                icon: cats[i].icon,
                label: cats[i].label,
                isSelected: selectedCat == cats[i].key,
                onTap: () => onCat(cats[i].key),
              ),
            ),
          ),
          // Sort / filter button
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 9, bottom: 9),
            child: GestureDetector(
              onTap: onFilterTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                decoration: BoxDecoration(
                  color: hasFilter ? c.chipSel : c.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: hasFilter
                      ? null
                      : Border.all(color: c.divider, width: 1),
                  boxShadow: hasFilter ? [] : _T.soft(c),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.slider_horizontal_3, size: 13,
                        color: hasFilter ? c.chipSelFg : c.inkMuted),
                    const SizedBox(width: 6),
                    Text('Trier',
                        style: _T.label(c, 12.5,
                            color: hasFilter ? c.chipSelFg : c.inkMuted,
                            ls: 0.1)),
                  ],
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
// SORT BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final _C c;
  final _Sort selected;
  final void Function(_Sort) onSelect;
  final VoidCallback onClear;

  const _SortSheet({
    required this.c,
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final sorts = _Sort.values.skip(1).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: _T.cardBorder(c),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: c.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('Trier et filtrer',
                    style: _T.heading(c, 17, fw: FontWeight.w700)),
                const Spacer(),
                if (selected != _Sort.none)
                  GestureDetector(
                    onTap: onClear,
                    child: Text('Effacer',
                        style: _T.body(c, 13,
                            color: _C.gold, fw: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ...sorts.map((s) {
            final isSel = selected == s;
            return GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? c.chipSel : c.chipBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(s.label,
                        style: _T.body(c, 14,
                            color: isSel ? c.chipSelFg : c.ink,
                            fw: FontWeight.w500)),
                    const Spacer(),
                    if (isSel)
                      Icon(CupertinoIcons.checkmark_circle_fill,
                          size: 18, color: c.chipSelFg),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP — icon + label
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatefulWidget {
  final IconData icon;
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_Chip> createState() => _ChipState();
}

class _ChipState extends State<_Chip> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 90),
        lowerBound: 0.93, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? c.chipSel : c.chipBg,
            borderRadius: BorderRadius.circular(_T.rChip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  key: ValueKey(widget.isSelected),
                  size: 14,
                  color: widget.isSelected ? c.chipSelFg : c.inkMuted,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: widget.isSelected ? c.chipSelFg : c.inkMuted,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final _C c;
  final _Cat cat;
  final int count;
  final VoidCallback onSeeAll;
  const _SectionHeader(
      {required this.c, required this.cat, required this.count, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          cat.key == 'all' ? 'PARTENAIRES' : cat.label.toUpperCase(),
          style: _T.overline(c, 11),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: c.chipBg, borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: _T.label(c, 10, color: c.inkMuted, ls: 0.2)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text('Voir plus', style: _T.body(c, 13, color: c.ink, fw: FontWeight.w600)),
              const SizedBox(width: 3),
              Icon(CupertinoIcons.chevron_right, size: 12, color: c.ink),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final _C c;
  final VoidCallback onReset;
  const _EmptyState({required this.c, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: c.chipBg, shape: BoxShape.circle),
            child: Icon(CupertinoIcons.search, size: 32, color: c.inkSubtle),
          ),
          const SizedBox(height: 22),
          Text('Aucun produit trouvé', style: _T.heading(c, 20, fw: FontWeight.w600)),
          const SizedBox(height: 10),
          Text('Aucun article ne correspond\nà tes filtres actuels.',
              textAlign: TextAlign.center, style: _T.body(c, 14)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(color: c.chipSel, borderRadius: BorderRadius.circular(_T.rChip)),
              child: Text('Réinitialiser les filtres',
                  style: _T.label(c, 14, color: c.chipSelFg, fw: FontWeight.w600, ls: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

}

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER CARD — horizontal list style
// ─────────────────────────────────────────────────────────────────────────────
class _PartnerCard extends StatefulWidget {
  final dynamic item;
  final int userEtoiles;
  final bool isWishlisted;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _PartnerCard({
    super.key,
    required this.item,
    required this.userEtoiles,
    required this.isWishlisted,
    required this.onWish,
    required this.onTap,
  });

  @override
  State<_PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<_PartnerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130),
        lowerBound: 0.97, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _canAfford => widget.userEtoiles >= (widget.item.etoiles as int);

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return GestureDetector(
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          height: 114,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(_T.rCard),
            boxShadow: _T.card(c),
            border: _T.cardBorder(c),
          ),
          child: Row(
            children: [
              // ── Image ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 90, height: 90,
                        child: _ProductImage(
                          imageUrl: widget.item.imageUrl as String?,
                          category: widget.item.category as String,
                          width: 90, height: 90,
                        ),
                      ),
                    ),
                    if (!_canAfford)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(color: Colors.black.withValues(alpha: 0.22)),
                        ),
                      ),
                    if (widget.item.discount != null &&
                        (widget.item.discount as String).isNotEmpty)
                      Positioned(
                        top: 5, left: 5,
                        child: _DiscountBadge(label: widget.item.discount as String),
                      ),
                    if (!_canAfford)
                      const Positioned(
                        bottom: 6, right: 6,
                        child: Icon(CupertinoIcons.lock_fill, size: 12, color: Colors.white),
                      ),
                  ],
                ),
              ),

              // ── Info ───────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (widget.item.brand as String).toUpperCase(),
                        style: _T.overline(c, 9, color: c.inkSubtle),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.title as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _T.body(c, 13.5, color: c.ink, fw: FontWeight.w600),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _StarsBadge(
                            etoiles: widget.item.etoiles as int,
                            canAfford: _canAfford,
                          ),
                          const Spacer(),
                          _WishButton(
                            isActive: widget.isWishlisted,
                            onTap: widget.onWish,
                            dark: c.isDark,
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
// WISH BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _WishButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final bool dark;
  const _WishButton({required this.isActive, required this.onTap, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: dark ? c.chipBg : Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: _T.soft(c),
          border: dark ? Border.all(color: c.divider, width: 0.5) : null,
        ),
        child: Icon(
          isActive ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          size: 14,
          color: isActive ? _C.wishRed : c.inkSubtle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DISCOUNT BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _DiscountBadge extends StatelessWidget {
  final String label;
  const _DiscountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF111110),
        borderRadius: BorderRadius.circular(_T.rBadge),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 9.5, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: 0.3)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STARS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _StarsBadge extends StatelessWidget {
  final int etoiles;
  final bool canAfford;
  final bool onDark;
  const _StarsBadge(
      {required this.etoiles, required this.canAfford, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final c       = _C.of(context);
    final bgColor = onDark
        ? Colors.white.withValues(alpha: 0.14)
        : (canAfford ? c.goldSurface : c.chipBg);
    final fgColor = onDark ? Colors.white : (canAfford ? _C.gold : c.inkSubtle);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.star_fill, size: 10, color: fgColor),
              const SizedBox(width: 5),
              Text('$etoiles',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fgColor)),
            ],
          ),
        ),
        if (!canAfford && !onDark) ...[
          const SizedBox(width: 5),
          Icon(CupertinoIcons.lock_fill, size: 10, color: c.inkSubtle),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT IMAGE (icon fallback)
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String  category;
  final double  width;
  final double  height;

  const _ProductImage(
      {required this.imageUrl,
      required this.category,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!,
          width: width, height: height, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _Placeholder(category: category));
    }
    return _Placeholder(category: category);
  }
}

class _Placeholder extends StatelessWidget {
  final String category;
  const _Placeholder({required this.category});

  static const Map<String, IconData> _icons = {
    'mamans':    Icons.favorite_rounded,
    'baby':      Icons.child_care,
    'sport':     Icons.fitness_center,
    'vitamines': Icons.eco_rounded,
    'skincare':  Icons.spa_rounded,
    'home':      Icons.home_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return Container(
      width: double.infinity, height: double.infinity,
      color: c.surfaceAlt,
      child: Icon(_icons[category] ?? Icons.shopping_bag_outlined, size: 32, color: c.inkSubtle),
    );
  }
}
