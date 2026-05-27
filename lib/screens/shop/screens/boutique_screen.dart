import 'package:fiteva/screens/shop/screens/all_partenaires_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/etoiles_card.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
class _T {
  // Palette — éditorial neutre
  static const Color bg        = Color(0xFFF8F7F5);
  static const Color surface   = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2F1EF);
  static const Color ink       = Color(0xFF141414);
  static const Color inkMuted  = Color(0xFF8A8A8A);
  static const Color inkFaint  = Color(0xFFBBBBBB);
  static const Color divider   = Color(0xFFE8E7E5);
  static const Color chipBg    = Color(0xFFEDECEA);
  static const Color chipSel   = Color(0xFF141414);
  static const Color chipSelFg = Color(0xFFFFFFFF);
  static const Color gold      = Color(0xFFD4AF37);
  static const Color wishActive = Color(0xFFE05252);
  static const Color badge     = Color(0xFF141414);
  static const Color badgeFg   = Color(0xFFFFFFFF);

  // Radii
  static const double rCard  = 20.0;
  static const double rChip  = 30.0;
  static const double rBtn   = 14.0;
  static const double rBadge = 8.0;
  static const double rSearch = 14.0;

  // Shadows
  static List<BoxShadow> card() => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.055),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> soft() => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.035),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  // Typography helpers
  static TextStyle heading(double size, {FontWeight fw = FontWeight.w700, double ls = -0.5}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: ink, letterSpacing: ls, height: 1.1);

  static TextStyle body(double size, {Color? color, FontWeight fw = FontWeight.w400, double ls = 0.1}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: color ?? inkMuted, letterSpacing: ls, height: 1.5);

  static TextStyle label(double size, {Color? color, FontWeight fw = FontWeight.w600, double ls = 1.2}) =>
      TextStyle(fontSize: size, fontWeight: fw, color: color ?? inkMuted, letterSpacing: ls);
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _Cat {
  final String key;
  final String label;
  final String emoji;
  const _Cat({required this.key, required this.label, required this.emoji});
}

const _kCats = [
  _Cat(key: 'all',       label: 'Tout',      emoji: '✦'),
  _Cat(key: 'mamans',    label: 'Mamans',    emoji: '🤰'),
  _Cat(key: 'baby',      label: 'Baby',      emoji: '🍼'),
  _Cat(key: 'sport',     label: 'Sport',     emoji: '💪'),
  _Cat(key: 'vitamines', label: 'Vitamines', emoji: '🌿'),
  _Cat(key: 'skincare',  label: 'Skincare',  emoji: '✨'),
  _Cat(key: 'home',      label: 'Home',      emoji: '🏡'),
];

// ─────────────────────────────────────────────────────────────────────────────
// SORT / SPECIAL FILTERS
// ─────────────────────────────────────────────────────────────────────────────
enum _Sort { none, topDeals, mostPopular, expiringSoon, discount10, discount20, discount30 }

extension _SortLabel on _Sort {
  String get label => switch (this) {
    _Sort.none          => 'Tout',
    _Sort.topDeals      => '🔥 Meilleures offres',
    _Sort.mostPopular   => '⭐ Plus populaires',
    _Sort.expiringSoon  => '⏳ Expire bientôt',
    _Sort.discount10    => '10% off',
    _Sort.discount20    => '20% off',
    _Sort.discount30    => '30%+ off',
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

class _BoutiqueScreenState extends State<BoutiqueScreen>
    with TickerProviderStateMixin {

  // ── State ────────────────────────────────────────────────────────────────
  String _cat       = 'all';
  _Sort  _sort      = _Sort.none;
  String _query     = '';
  bool   _searching = false;

  final Set<String> _wishlist = {};

  final int _userEtoiles = 60;

  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();

  bool _filterElevated = false;
  bool _showSearch     = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text));
  }

  void _onScroll() {
    final elevated = _scrollCtrl.offset > 110;
    if (elevated != _filterElevated) setState(() => _filterElevated = elevated);
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────
  List get _featured => mockItems.take(4).toList();

  List get _filtered {
    var list = List.from(mockItems);

    // Category
    if (_cat != 'all') list = list.where((e) => e.category == _cat).toList();

    // Search
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((e) {
        return (e.title  as String).toLowerCase().contains(q) ||
               (e.brand  as String).toLowerCase().contains(q) ||
               (e.category as String).toLowerCase().contains(q);
      }).toList();
    }

    // Sort / special filters
    switch (_sort) {
      case _Sort.topDeals:
        list.sort((a, b) => (b.etoiles as int).compareTo(a.etoiles as int));
        break;
      case _Sort.mostPopular:
        // sort by etoiles ascending (cheaper = most popular proxy)
        list.sort((a, b) => (a.etoiles as int).compareTo(b.etoiles as int));
        break;
      case _Sort.expiringSoon:
        // proxy: items with a discount
        list = list.where((e) =>
          e.discount != null && (e.discount as String).isNotEmpty).toList();
        break;
      case _Sort.discount10:
        list = list.where((e) =>
          (e.discount as String? ?? '').contains('10')).toList();
        break;
      case _Sort.discount20:
        list = list.where((e) =>
          (e.discount as String? ?? '').contains('20')).toList();
        break;
      case _Sort.discount30:
        list = list.where((e) {
          final d = e.discount as String? ?? '';
          return d.contains('30') || d.contains('40') || d.contains('50');
        }).toList();
        break;
      case _Sort.none:
        break;
    }

    return list;
  }

  void _selectCat(String key)    => setState(() { _cat  = key; _sort = _Sort.none; });
  void _selectSort(_Sort s)      => setState(() { _sort = s;   _cat  = 'all'; });
  void _toggleWish(String id)    => setState(() {
    _wishlist.contains(id) ? _wishlist.remove(id) : _wishlist.add(id);
  });
  void _clearFilters()           => setState(() {
    _cat = 'all'; _sort = _Sort.none; _query = ''; _searchCtrl.clear();
  });

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (_showSearch) {
      Future.delayed(const Duration(milliseconds: 80), () => _searchFocus.requestFocus());
    } else {
      _searchFocus.unfocus();
      _searchCtrl.clear();
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 60, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    onSearchTap: _toggleSearch,
                    isSearching: _showSearch,
                  ),
                  const SizedBox(height: 18),
                  // Search bar (animated)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: _showSearch
                        ? _SearchBar(controller: _searchCtrl, focus: _searchFocus)
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 18),
                  // Étoiles card
                  _EtoilesWrapper(etoiles: _userEtoiles),
                  const SizedBox(height: 26),
                  // À LA UNE section
                  _FeaturedSection(
                    items: _featured,
                    userEtoiles: _userEtoiles,
                    wishlist: _wishlist,
                    onWish: _toggleWish,
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ),

          // ── Sticky filter bar ────────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterBarDelegate(
              cats: _kCats,
              sorts: _Sort.values.skip(1).toList(),
              selectedCat: _cat,
              selectedSort: _sort,
              elevated: _filterElevated,
              onCat: _selectCat,
              onSort: _selectSort,
            ),
          ),

          // ── Section label ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
              child: _SectionHeader(
                cat: _kCats.firstWhere((c) => c.key == _cat),
                count: filtered.length,
                onSeeAll: () => Navigator.push(context,
                  CupertinoPageRoute(builder: (_) => const AllPartenairesScreen())),
              ),
            ),
          ),

          // ── Grid ─────────────────────────────────────────────────────────
          filtered.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(onReset: _clearFilters),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.65,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final item = filtered[i];
                      final id = '${item.brand}_${item.title}';
                        return _ProductCard(
                          key: ValueKey(id),
                          item: item,
                          userEtoiles: _userEtoiles,
                          isWishlisted: _wishlist.contains(id),
                          onWish: () => _toggleWish(id),
                          onTap: () => Navigator.push(ctx,
                            CupertinoPageRoute(
                              builder: (_) => BoutiqueDetailScreen(
                                item: item,
                                userEtoiles: _userEtoiles,
                              ),
                            )),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

          // ── Footer button ────────────────────────────────────────────────
          if (filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 60),
                child: _SeeAllButton(
                  onTap: () => Navigator.push(context,
                    CupertinoPageRoute(builder: (_) => const AllPartenairesScreen())),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final VoidCallback onSearchTap;
  final bool isSearching;
  const _Header({required this.onSearchTap, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Boutique', style: _T.heading(34, ls: -1.2)),
              const SizedBox(height: 5),
              Text('Échange tes étoiles contre des récompenses.',
                  style: _T.body(13.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Search icon
        _IconBtn(
          icon: isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
          onTap: onSearchTap,
        ),
        const SizedBox(width: 10),
        // Profile icon
        _IconBtn(
          icon: CupertinoIcons.person_fill,
          onTap: () {},
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _T.surface,
          shape: BoxShape.circle,
          boxShadow: _T.soft(),
        ),
        child: Icon(icon, size: 16, color: _T.ink),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focus;
  const _SearchBar({required this.controller, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.rSearch),
        boxShadow: _T.soft(),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(CupertinoIcons.search, size: 16, color: _T.inkFaint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              style: _T.body(14, color: _T.ink, ls: 0.0),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit, une marque…',
                hintStyle: _T.body(14, ls: 0.0),
                border: InputBorder.none,
                isDense: true,
              ),
              cursorColor: _T.ink,
              cursorWidth: 1.5,
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: controller.clear,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(CupertinoIcons.xmark_circle_fill,
                    size: 16, color: _T.inkFaint),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ÉTOILES WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class _EtoilesWrapper extends StatelessWidget {
  final int etoiles;
  const _EtoilesWrapper({required this.etoiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _T.card(),
      ),
      child: EtoilesCard(etoiles: etoiles),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// À LA UNE — FEATURED SECTION (horizontal scroll)
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturedSection extends StatelessWidget {
  final List items;
  final int userEtoiles;
  final Set<String> wishlist;
  final void Function(String) onWish;

  const _FeaturedSection({
    required this.items,
    required this.userEtoiles,
    required this.wishlist,
    required this.onWish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text('À LA UNE', style: _T.label(10, ls: 1.6)),
            const SizedBox(width: 8),
            Container(
              width: 4, height: 4,
              decoration: const BoxDecoration(
                color: _T.gold, shape: BoxShape.circle),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (ctx, i) {
              final item = items[i];
            final id = '${item.brand}_${item.title}';
              return _FeaturedCard(
                item: item,
                userEtoiles: userEtoiles,
                isWishlisted: wishlist.contains(id),
                onWish: () => onWish(id),
                onTap: () => Navigator.push(ctx,
                  CupertinoPageRoute(
                    builder: (_) => BoutiqueDetailScreen(
                      item: item, userEtoiles: userEtoiles))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  final dynamic item;
  final int userEtoiles;
  final bool isWishlisted;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.item,
    required this.userEtoiles,
    required this.isWishlisted,
    required this.onWish,
    required this.onTap,
  });

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120),
        lowerBound: 0.96, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _canAfford => widget.userEtoiles >= (widget.item.etoiles as int);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.rCard),
            boxShadow: _T.card(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(_T.rCard)),
                      child: _ProductImage(
                        imageUrl: widget.item.imageUrl as String?,
                        category: widget.item.category as String,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Wish button
                    Positioned(
                      top: 8, right: 8,
                      child: _WishButton(
                        isActive: widget.isWishlisted,
                        onTap: widget.onWish,
                      ),
                    ),
                    // Discount badge
                    if (widget.item.discount != null &&
                        (widget.item.discount as String).isNotEmpty)
                      Positioned(
                        top: 8, left: 8,
                        child: _DiscountBadge(label: widget.item.discount as String),
                      ),
                  ],
                ),
              ),
              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((widget.item.brand as String).toUpperCase(),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: _T.label(8.5, ls: 1.4)),
                    const SizedBox(height: 3),
                    Text(widget.item.title as String,
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: _T.body(11.5, color: _T.ink, fw: FontWeight.w500, ls: -0.1)),
                    const SizedBox(height: 6),
                    _StarsBadge(
                      etoiles: widget.item.etoiles as int,
                      canAfford: _canAfford,
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
// STICKY FILTER BAR DELEGATE
// ─────────────────────────────────────────────────────────────────────────────
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final List<_Cat>  cats;
  final List<_Sort> sorts;
  final String      selectedCat;
  final _Sort       selectedSort;
  final bool        elevated;
  final ValueChanged<String> onCat;
  final ValueChanged<_Sort>  onSort;

  const _FilterBarDelegate({
    required this.cats,
    required this.sorts,
    required this.selectedCat,
    required this.selectedSort,
    required this.elevated,
    required this.onCat,
    required this.onSort,
  });

  static const double _h = 100.0;

  @override double get minExtent => _h;
  @override double get maxExtent => _h;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.selectedCat != selectedCat ||
      old.selectedSort != selectedSort ||
      old.elevated != elevated;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _h,
      decoration: BoxDecoration(
        color: _T.bg,
        boxShadow: elevated
            ? [BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.055),
                blurRadius: 10,
                offset: const Offset(0, 3),
              )]
            : [],
      ),
      child: Column(
        children: [
          // Row 1: categories
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => _Chip(
                emoji: cats[i].emoji,
                label: cats[i].label,
                isSelected: selectedCat == cats[i].key,
                onTap: () => onCat(cats[i].key),
              ),
            ),
          ),
          // Row 2: sort / special filters
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
              itemCount: sorts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => _Chip(
                emoji: null,
                label: sorts[i].label,
                isSelected: selectedSort == sorts[i],
                onTap: () => onSort(sorts[i]),
                small: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatefulWidget {
  final String? emoji;
  final String  label;
  final bool    isSelected;
  final VoidCallback onTap;
  final bool small;

  const _Chip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.small = false,
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
    final fs   = widget.small ? 11.5 : 12.0;
    final efs  = widget.small ? 12.0 : 13.0;
    final phx  = widget.small ? 10.0 : 13.0;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp:   (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: phx, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected ? _T.chipSel : _T.chipBg,
            borderRadius: BorderRadius.circular(_T.rChip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.emoji != null) ...[
                Text(widget.emoji!, style: TextStyle(fontSize: efs)),
                const SizedBox(width: 5),
              ],
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: fs,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: widget.isSelected ? _T.chipSelFg : _T.inkMuted,
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
  final _Cat  cat;
  final int   count;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.cat, required this.count, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          cat.key == 'all' ? 'PARTENAIRES' : cat.label.toUpperCase(),
          style: _T.label(10.5, ls: 1.6),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: _T.chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$count', style: _T.label(10, color: _T.inkMuted, ls: 0.3)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('Voir plus →',
              style: _T.body(13, color: _T.ink, fw: FontWeight.w500, ls: 0.1)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _T.chipBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 22),
          Text('Aucun produit trouvé',
            style: _T.heading(20, fw: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            'Aucun article ne correspond\nà tes filtres actuels.',
            textAlign: TextAlign.center,
            style: _T.body(14),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: _T.ink,
                borderRadius: BorderRadius.circular(_T.rChip),
              ),
              child: Text('Réinitialiser les filtres',
                style: _T.label(14, color: Colors.white, ls: 0.3, fw: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEE ALL BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SeeAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(_T.rBtn),
          border: Border.all(color: _T.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Voir tous les partenaires',
              style: _T.body(14, color: _T.ink, fw: FontWeight.w600, ls: 0.1)),
            const SizedBox(width: 7),
            const Icon(CupertinoIcons.arrow_right, size: 13, color: _T.ink),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT CARD (grid)
// ─────────────────────────────────────────────────────────────────────────────
class _ProductCard extends StatefulWidget {
  final dynamic  item;
  final int      userEtoiles;
  final bool     isWishlisted;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _ProductCard({
    super.key,
    required this.item,
    required this.userEtoiles,
    required this.isWishlisted,
    required this.onWish,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 130),
        lowerBound: 0.96, upperBound: 1.0, value: 1.0);
    _fade = Tween<double>(begin: 0.88, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  bool get _canAfford => widget.userEtoiles >= (widget.item.etoiles as int);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => _ctrl.reverse(),
      onTapUp:     (_) { _ctrl.forward(); widget.onTap(); },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: FadeTransition(
          opacity: _fade,
          child: Container(
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(_T.rCard),
              boxShadow: _T.card(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image (70% of card) ──
                Expanded(
                  flex: 7,
                  child: Stack(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(_T.rCard)),
                        child: _ProductImage(
                          imageUrl: widget.item.imageUrl as String?,
                          category: widget.item.category as String,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Frosted lock overlay
                      if (!_canAfford)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(_T.rCard)),
                            child: Container(
                              color: Colors.black.withOpacity(0.13)),
                          ),
                        ),
                      // Discount badge
                      if (widget.item.discount != null &&
                          (widget.item.discount as String).isNotEmpty)
                        Positioned(
                          top: 10, left: 10,
                          child: _DiscountBadge(label: widget.item.discount as String),
                        ),
                      // Wish button
                      Positioned(
                        top: 8, right: 8,
                        child: _WishButton(
                          isActive: widget.isWishlisted,
                          onTap: widget.onWish,
                        ),
                      ),
                      // Lock icon
                      if (!_canAfford)
                        const Positioned(
                          bottom: 10, right: 10,
                          child: Icon(CupertinoIcons.lock_fill,
                              size: 14, color: Colors.white),
                        ),
                    ],
                  ),
                ),

                // ── Info (30% of card) ──
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((widget.item.brand as String).toUpperCase(),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: _T.label(8.5, ls: 1.4)),
                            const SizedBox(height: 2),
                            Text(widget.item.title as String,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: _T.body(12, color: _T.ink, fw: FontWeight.w500, ls: -0.1)),
                          ],
                        ),
                        _StarsBadge(
                          etoiles: widget.item.etoiles as int,
                          canAfford: _canAfford,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
  const _WishButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: _T.soft(),
        ),
        child: Icon(
          isActive ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          size: 14,
          color: isActive ? _T.wishActive : _T.inkMuted,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _T.badge,
        borderRadius: BorderRadius.circular(_T.rBadge),
      ),
      child: Text(label,
        style: _T.label(9.5, color: _T.badgeFg, ls: 0.4, fw: FontWeight.w700)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STARS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _StarsBadge extends StatelessWidget {
  final int  etoiles;
  final bool canAfford;
  const _StarsBadge({required this.etoiles, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: canAfford
                ? _T.gold.withOpacity(0.12)
                : _T.chipBg,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.star_fill, size: 9,
                  color: canAfford ? _T.gold : _T.inkMuted),
              const SizedBox(width: 4),
              Text('$etoiles',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: canAfford ? _T.gold : _T.inkMuted,
                  letterSpacing: 0.1,
                )),
            ],
          ),
        ),
        if (!canAfford) ...[
          const SizedBox(width: 5),
          const Icon(CupertinoIcons.lock_fill, size: 10, color: _T.inkMuted),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT IMAGE (with fallback)
// ─────────────────────────────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String  category;
  final double  width;
  final double  height;

  const _ProductImage({
    required this.imageUrl,
    required this.category,
    required this.width,
    required this.height,
  });

  static const Map<String, String> _emoji = {
    'mamans':    '🤰',
    'baby':      '🍼',
    'sport':     '💪',
    'vitamines': '🌿',
    'skincare':  '✨',
    'home':      '🏡',
  };

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: width, height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Placeholder(category: category),
      );
    }
    return _Placeholder(category: category);
  }
}

class _Placeholder extends StatelessWidget {
  final String category;
  const _Placeholder({required this.category});

  static const Map<String, String> _emoji = {
    'mamans':    '🤰',
    'baby':      '🍼',
    'sport':     '💪',
    'vitamines': '🌿',
    'skincare':  '✨',
    'home':      '🏡',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: _T.surfaceAlt,
      child: Center(
        child: Text(
          _emoji[category] ?? '🛍️',
          style: const TextStyle(fontSize: 38),
        ),
      ),
    );
  }
}