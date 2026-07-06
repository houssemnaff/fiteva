import 'dart:async';
import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:fiteva/screens/shop/screens/all_partenaires_screen.dart';
import 'package:fiteva/widgets/shared_app_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../l10n/app_localizations.dart';
import '../models/boutique_item.dart';
import 'boutique_detail_screen.dart';
import 'favorites_screen.dart';
import 'partner_form_screen.dart';
import 'redemption_history_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOR PALETTE — un seul accent (couleur de marque de l'app), gris neutre
// pour le reste. Doré = points/étoiles, rouge = wishlist uniquement.
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
  final bool  isDark;

  static const Color brand     = Color(0xFF1C4D30);
  static const Color brandSoft = Color(0xFFE7EFE9);
  static const Color gold      = Color(0xFFB8892F);
  static const Color wishRed   = Color(0xFFC24A4A);

  static _C of(BuildContext ctx) {
    final dark = Theme.of(ctx).brightness == Brightness.dark;
    return dark ? const _C._dark() : const _C._light();
  }

  const _C._light()
      : bg         = const Color.fromARGB(255, 255, 255, 255),
        surface    = const Color(0xFFFFFFFF),
        surfaceAlt = const Color(0xFFEFEFEB),
        ink        = const Color(0xFF16211A),
        inkMuted   = const Color(0xFF6E786F),
        inkSubtle  = const Color(0xFFA8AEA6),
        divider    = const Color(0xFFE6E6E1),
        chipBg     = const Color(0xFFEFEFEB),
        isDark     = false;

  const _C._dark()
      : bg         = const Color(0xFF10140F),
        surface    = const Color(0xFF1A1F19),
        surfaceAlt = const Color(0xFF232923),
        ink        = const Color(0xFFEDF2EC),
        inkMuted   = const Color(0xFF919C90),
        inkSubtle  = const Color(0xFF5C645B),
        divider    = const Color(0xFF2A302A),
        chipBg     = const Color(0xFF232923),
        isDark     = true;
}

List<BoxShadow> _cardShadow(_C c) => c.isDark
    ? []
    : [BoxShadow(color: const Color(0xFF16211A).withValues(alpha: 0.06),
        blurRadius: 18, offset: const Offset(0, 6))];

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL
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

enum _Sort { none, topDeals, mostPopular, expiringSoon, discount10, discount20, discount30 }

// ─────────────────────────────────────────────────────────────────────────────
// BOUTIQUE SCREEN — catalogue en grille, header hero, contrôles compacts
// ─────────────────────────────────────────────────────────────────────────────
class BoutiqueScreen extends ConsumerStatefulWidget {
  const BoutiqueScreen({super.key});

  @override
  ConsumerState<BoutiqueScreen> createState() => _BoutiqueScreenState();
}

class _BoutiqueScreenState extends ConsumerState<BoutiqueScreen> {
  String _cat            = 'all';
  _Sort  _sort           = _Sort.none;
  bool   _filterElevated = false;
  int    _heroIndex      = 0;

  final _scrollCtrl = ScrollController();
  final _heroCtrl   = PageController(viewportFraction: 1.0);
  Timer? _heroTimer;
  int    _heroCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.invalidate(shopItemsProvider));
  }

  void _onScroll() {
    final elevated = _scrollCtrl.offset > 40;
    if (elevated != _filterElevated) setState(() => _filterElevated = elevated);
  }

  // Balayage automatique du hero — avance d'une carte toutes les 1.2s.
  void _startHeroAutoSlide(int count) {
    if (_heroTimer != null && _heroCount == count) return;
    _heroTimer?.cancel();
    _heroCount = count;
    if (count <= 1) return;
    _heroTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted || !_heroCtrl.hasClients) return;
      final next = (_heroIndex + 1) % count;
      _heroCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onHeroPageChanged(int i, int count) {
    setState(() => _heroIndex = i);
    _startHeroAutoSlide(count); // relance le minuteur après un swipe manuel
  }

  @override
  void dispose() {
    _scrollCtrl..removeListener(_onScroll)..dispose();
    _heroCtrl.dispose();
    _heroTimer?.cancel();
    super.dispose();
  }

  List<BoutiqueItem> _getFiltered(List<BoutiqueItem> items) {
    var list = List<BoutiqueItem>.from(items);
    if (_cat != 'all') list = list.where((e) => e.category == _cat).toList();
    switch (_sort) {
      case _Sort.topDeals:
        list.sort((a, b) => b.etoiles.compareTo(a.etoiles));
      case _Sort.mostPopular:
        list.sort((a, b) => a.etoiles.compareTo(b.etoiles));
      case _Sort.expiringSoon:
        list = list.where((e) => e.discount.isNotEmpty).toList();
      case _Sort.discount10:
        list = list.where((e) => e.discount.contains('10')).toList();
      case _Sort.discount20:
        list = list.where((e) => e.discount.contains('20')).toList();
      case _Sort.discount30:
        list = list.where((e) {
          final d = e.discount;
          return d.contains('30') || d.contains('40') || d.contains('50');
        }).toList();
      case _Sort.none:
        break;
    }
    return list;
  }

  void _selectCat(String key) => setState(() { _cat = key; _sort = _Sort.none; });
  void _toggleWish(String id) => ref.read(shopWishlistProvider.notifier).toggleWishlist(id);
  void _clearFilters() => setState(() { _cat = 'all'; _sort = _Sort.none; });

  void _openFavorites() => Navigator.push(context,
      CupertinoPageRoute(builder: (_) => const FavoritesScreen()));

  void _openHistory() => Navigator.push(context,
      CupertinoPageRoute(builder: (_) => const RedemptionHistoryScreen()));

  void _openPartnerForm() => Navigator.push(context,
      CupertinoPageRoute(builder: (_) => const PartnerFormScreen()));

  // L'historique n'a pas besoin d'une icône dédiée en permanence dans le
  // header — un seul bouton "plus" suffit.
  void _showMoreMenu() {
    final c = _C.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreMenuSheet(
        c: c,
        onHistory: () { Navigator.pop(context); _openHistory(); },
      ),
    );
  }

  void _showSortSheet() {
    final c    = _C.of(context);
    final l10n = ref.read(l10nProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        c: c,
        l10n: l10n,
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
    final c          = _C.of(context);
    final shop       = ref.watch(shopProvider);
    final userPoints = shop.points;
    final l10n       = ref.watch(l10nProvider);
    final wishlist   = ref.watch(shopWishlistProvider);
    final allItems   = ref.watch(shopItemsProvider).asData?.value ?? <BoutiqueItem>[];
    final filtered   = _getFiltered(allItems);
    final isLoading  = ref.watch(shopItemsProvider).isLoading;
    final hero       = allItems.take(5).toList();

    return Scaffold(
      backgroundColor: c.bg,
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SharedAppHeader.sliver(
            eyebrow:    l10n.boutiqueEyebrow,
            title:      l10n.boutiqueTitle,
            accentColor: _C.brand,
            bgColor:     c.bg,
            actions: [
              _PointsPill(c: c, points: userPoints),
              const SizedBox(width: 8),
              _CircleIconButton(
                c: c,
                icon: CupertinoIcons.heart,
                count: wishlist.length,
                onTap: _openFavorites,
              ),
              const SizedBox(width: 8),
              _CircleIconButton(
                c: c,
                icon: CupertinoIcons.ellipsis,
                count: 0,
                onTap: _showMoreMenu,
              ),
            ],
          ),

          if (!isLoading && hero.isNotEmpty)
            SliverToBoxAdapter(
              child: Builder(builder: (_) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _startHeroAutoSlide(hero.length));
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: _HeroBanner(
                    c: c,
                    items: hero,
                    controller: _heroCtrl,
                    index: _heroIndex,
                    onPageChanged: (i) => _onHeroPageChanged(i, hero.length),
                    onTap: (item) => Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: item))),
                  ),
                );
              }),
            ),

          if (isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: _HeroSkeleton(c: c),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 18)),

          SliverPersistentHeader(
            pinned: true,
            delegate: _ControlBarDelegate(
              cats: _kCats,
              selectedCat: _cat,
              selectedSort: _sort,
              elevated: _filterElevated,
              l10n: l10n,
              onCat: _selectCat,
              onFilterTap: _showSortSheet,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: isLoading
                  ? _SkeletonLine(c: c)
                  : Row(
                      children: [
                        Text('${filtered.length} ${l10n.boutiquePartenaires.toLowerCase()}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.inkMuted)),
                        const SizedBox(width: 12),
                        _SortLink(c: c, l10n: l10n, active: _sort != _Sort.none, onTap: _showSortSheet),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              CupertinoPageRoute(builder: (_) => const AllPartenairesScreen())),
                          child: Row(children: [
                            Text(l10n.boutiqueVoirPlus,
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.ink)),
                            const SizedBox(width: 3),
                            Icon(CupertinoIcons.chevron_right, size: 12, color: c.ink),
                          ]),
                        ),
                      ],
                    ),
            ),
          ),

          if (!isLoading && filtered.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: _PartnerLink(c: c, l10n: l10n, onTap: _openPartnerForm),
              ),
            ),

          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              sliver: SliverToBoxAdapter(child: _GridSkeleton(c: c)),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(c: c, l10n: l10n, onReset: _clearFilters),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item       = filtered[i];
                    final isRedeemed = shop.isRedeemed(item.id);
                    return _GridProductCard(
                      key: ValueKey(item.id),
                      c: c,
                      item: item,
                      l10n: l10n,
                      userEtoiles: userPoints,
                      isWishlisted: wishlist.contains(item.id),
                      isRedeemed: isRedeemed,
                      onWish: () => _toggleWish(item.id),
                      onTap: () => Navigator.push(
                          ctx,
                          CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: item))),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER — points pill + wishlist button
// ─────────────────────────────────────────────────────────────────────────────
class _PointsPill extends StatelessWidget {
  final _C c;
  final int points;
  const _PointsPill({required this.c, required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _C.brand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.star_fill, color: _C.gold, size: 13),
          const SizedBox(width: 6),
          Text('$points', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final _C c;
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  const _CircleIconButton({required this.c, required this.icon, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: c.divider, width: 1),
            ),
            child: Icon(icon, size: 17, color: c.ink),
          ),
          if (count > 0)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: _C.wishRed, shape: BoxShape.circle),
                child: Center(
                  child: Text('$count',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE MENU — regroupe historique + devenir partenaire dans un seul tiroir
// ─────────────────────────────────────────────────────────────────────────────
class _MoreMenuSheet extends StatelessWidget {
  final _C c;
  final VoidCallback onHistory;
  const _MoreMenuSheet({required this.c, required this.onHistory});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(22)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: c.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 10),
            _MenuTile(c: c, icon: CupertinoIcons.clock, label: 'Mon activité', onTap: onHistory),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _C c;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({required this.c, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: c.ink),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER — grand visuel plein cadre, carrousel avec indicateurs
// ─────────────────────────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  final _C c;
  final List<BoutiqueItem> items;
  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;
  final void Function(BoutiqueItem) onTap;

  const _HeroBanner({
    required this.c,
    required this.items,
    required this.controller,
    required this.index,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => onTap(item),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: _cardShadow(c),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _ProductImage(imageUrl: item.imageUrl, category: item.category),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0xB4000000)],
                            stops: [0.35, 1.0],
                          ),
                        ),
                      ),
                      if (item.discount.isNotEmpty)
                        Positioned(top: 14, left: 14, child: _DiscountBadge(label: item.discount)),
                      Positioned(
                        left: 18, right: 18, bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.brand.toUpperCase(),
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.65), letterSpacing: 1.6)),
                            const SizedBox(height: 4),
                            Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                                    color: Colors.white, letterSpacing: -0.4)),
                            const SizedBox(height: 8),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(CupertinoIcons.star_fill, size: 12, color: _C.gold),
                              const SizedBox(width: 5),
                              Text('${item.etoiles} pts',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: active ? _C.brand : c.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER BANNER
// ─────────────────────────────────────────────────────────────────────────────
// Lien discret plutôt qu'une carte pleine largeur — la mise en avant d'une
// carte colorée pour chaque visite du shop n'était pas justifiée pour une
// action secondaire.
class _PartnerLink extends StatelessWidget {
  final _C          c;
  final AppL10n     l10n;
  final VoidCallback onTap;
  const _PartnerLink({required this.c, required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(Icons.handshake_rounded, size: 15, color: _C.brand),
          const SizedBox(width: 8),
          Text(l10n.boutiquePartner,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.brand)),
          const SizedBox(width: 4),
          Icon(CupertinoIcons.chevron_right, size: 12, color: _C.brand),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTROL BAR — avatars ronds (catégories) + pilule "Trier" texte
// ─────────────────────────────────────────────────────────────────────────────
class _ControlBarDelegate extends SliverPersistentHeaderDelegate {
  final List<_Cat>  cats;
  final String      selectedCat;
  final _Sort       selectedSort;
  final bool        elevated;
  final AppL10n     l10n;
  final ValueChanged<String> onCat;
  final VoidCallback         onFilterTap;

  const _ControlBarDelegate({
    required this.cats,
    required this.selectedCat,
    required this.selectedSort,
    required this.elevated,
    required this.l10n,
    required this.onCat,
    required this.onFilterTap,
  });

  static const double _h = 88.0;

  @override double get minExtent => _h;
  @override double get maxExtent => _h;

  @override
  bool shouldRebuild(_ControlBarDelegate old) =>
      old.selectedCat != selectedCat ||
      old.selectedSort != selectedSort ||
      old.elevated != elevated ||
      old.l10n != l10n;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final c = _C.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _h,
      decoration: BoxDecoration(
        color: c.bg,
        border: elevated ? Border(bottom: BorderSide(color: c.divider, width: 1)) : const Border(),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 6),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) => _CatAvatar(
          icon: cats[i].icon,
          label: cats[i].label,
          isSelected: selectedCat == cats[i].key,
          onTap: () => onCat(cats[i].key),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SORT LINK — lien texte souligné avec pastille dorée si un tri est actif
// ─────────────────────────────────────────────────────────────────────────────
class _SortLink extends StatelessWidget {
  final _C c;
  final AppL10n l10n;
  final bool active;
  final VoidCallback onTap;
  const _SortLink({required this.c, required this.l10n, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.arrow_up_arrow_down, size: 12, color: active ? _C.brand : c.inkMuted),
          const SizedBox(width: 5),
          Text(l10n.boutiqueTrier,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? _C.brand : c.inkMuted,
                decoration: TextDecoration.underline,
                decorationColor: active ? _C.brand : c.inkMuted,
              )),
          if (active) ...[
            const SizedBox(width: 4),
            Container(width: 5, height: 5,
                decoration: const BoxDecoration(color: _C.gold, shape: BoxShape.circle)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAT AVATAR — icône ronde + libellé sous l'icône sélectionnée
// ─────────────────────────────────────────────────────────────────────────────
class _CatAvatar extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     isSelected;
  final VoidCallback onTap;
  const _CatAvatar({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: isSelected ? _C.brand : c.chipBg,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: _C.gold, width: 1.6) : null,
            ),
            child: Icon(icon, size: 18, color: isSelected ? Colors.white : c.inkMuted),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 54,
            height: 13,
            child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.0,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? c.ink : c.inkSubtle,
                )),
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
  final AppL10n l10n;
  final _Sort selected;
  final void Function(_Sort) onSelect;
  final VoidCallback onClear;

  const _SortSheet({
    required this.c,
    required this.l10n,
    required this.selected,
    required this.onSelect,
    required this.onClear,
  });

  String _sortLabel(_Sort s) => switch (s) {
    _Sort.none         => l10n.boutiqueSortAll,
    _Sort.topDeals     => l10n.boutiqueSortTopDeals,
    _Sort.mostPopular  => l10n.boutiqueSortPopular,
    _Sort.expiringSoon => l10n.boutiqueSortExpiring,
    _Sort.discount10   => '10% off',
    _Sort.discount20   => '20% off',
    _Sort.discount30   => '30%+ off',
  };

  IconData _sortIcon(_Sort s) => switch (s) {
    _Sort.topDeals     => CupertinoIcons.tag_fill,
    _Sort.mostPopular  => CupertinoIcons.flame_fill,
    _Sort.expiringSoon => CupertinoIcons.timer,
    _Sort.discount10   => CupertinoIcons.percent,
    _Sort.discount20   => CupertinoIcons.percent,
    _Sort.discount30   => CupertinoIcons.percent,
    _Sort.none         => CupertinoIcons.circle,
  };

  @override
  Widget build(BuildContext context) {
    final sorts = _Sort.values.skip(1).toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: c.isDark ? Border.all(color: c.divider, width: 0.5) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(color: c.divider, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(l10n.boutiqueSortFilter,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.ink)),
                const Spacer(),
                if (selected != _Sort.none)
                  GestureDetector(
                    onTap: onClear,
                    child: Text(l10n.boutiqueClear,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.brand)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: sorts.map((s) {
                final isSel = selected == s;
                return GestureDetector(
                  onTap: () => onSelect(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSel ? _C.brand : c.chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSel ? _C.brand : c.divider, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_sortIcon(s), size: 14, color: isSel ? Colors.white : c.inkMuted),
                        const SizedBox(width: 7),
                        Text(_sortLabel(s),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                color: isSel ? Colors.white : c.ink)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final _C c;
  final AppL10n l10n;
  final VoidCallback onReset;
  const _EmptyState({required this.c, required this.l10n, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: c.chipBg, shape: BoxShape.circle),
            child: Icon(CupertinoIcons.search, size: 30, color: c.inkSubtle),
          ),
          const SizedBox(height: 20),
          Text(l10n.boutiqueAucunProduit,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: c.ink)),
          const SizedBox(height: 8),
          Text(l10n.boutiqueAucunArticle,
              textAlign: TextAlign.center, style: TextStyle(fontSize: 13.5, color: c.inkMuted, height: 1.5)),
          const SizedBox(height: 26),
          GestureDetector(
            onTap: onReset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
              decoration: BoxDecoration(color: _C.brand, borderRadius: BorderRadius.circular(12)),
              child: Text(l10n.boutiqueReset,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRID PRODUCT CARD — catalogue 2 colonnes
// ─────────────────────────────────────────────────────────────────────────────
class _GridProductCard extends StatelessWidget {
  final _C c;
  final BoutiqueItem item;
  final AppL10n l10n;
  final int userEtoiles;
  final bool isWishlisted;
  final bool isRedeemed;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _GridProductCard({
    super.key,
    required this.c,
    required this.item,
    required this.l10n,
    required this.userEtoiles,
    required this.isWishlisted,
    required this.isRedeemed,
    required this.onWish,
    required this.onTap,
  });

  bool get _canAfford => userEtoiles >= item.etoiles;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow(c),
          border: c.isDark ? Border.all(color: c.divider, width: 1) : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imageUrl: item.imageUrl, category: item.category),
                  if (!_canAfford && !isRedeemed)
                    Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.16))),
                  if (item.discount.isNotEmpty)
                    Positioned(top: 8, left: 8, child: _DiscountBadge(label: item.discount)),
                  Positioned(top: 8, right: 8,
                      child: _WishButton(isActive: isWishlisted, onTap: onWish)),
                  if (!_canAfford && !isRedeemed)
                    const Positioned(bottom: 8, right: 8,
                        child: Icon(CupertinoIcons.lock_fill, size: 13, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.brand.toUpperCase(),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700,
                            color: c.inkSubtle, letterSpacing: 1.2)),
                    const SizedBox(height: 3),
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.ink,
                            letterSpacing: -0.1, height: 1.22)),
                    const Spacer(),
                    isRedeemed
                        ? _RedeemedTag(c: c, label: l10n.boutiqueEchange)
                        : _StarsBadge(c: c, etoiles: item.etoiles, canAfford: _canAfford),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _WishButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _WishButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = _C.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          size: 13,
          color: isActive ? _C.wishRed : c.inkSubtle,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final String label;
  const _DiscountBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFF16211A), borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.3)),
    );
  }
}

class _RedeemedTag extends StatelessWidget {
  final _C c;
  final String label;
  const _RedeemedTag({required this.c, this.label = 'Échangé'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _C.brandSoft, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle_rounded, size: 11, color: _C.brand),
        const SizedBox(width: 4),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _C.brand, fontSize: 10.5, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _StarsBadge extends StatelessWidget {
  final _C c;
  final int etoiles;
  final bool canAfford;
  const _StarsBadge({required this.c, required this.etoiles, required this.canAfford});

  @override
  Widget build(BuildContext context) {
    final bgColor = canAfford ? (c.isDark ? _C.gold.withValues(alpha: 0.16) : const Color(0xFFF6EFDF)) : c.chipBg;
    final fgColor = canAfford ? _C.gold : c.inkSubtle;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.star_fill, size: 10, color: fgColor),
          const SizedBox(width: 5),
          Text('$etoiles', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: fgColor)),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String  category;

  const _ProductImage({required this.imageUrl, required this.category});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(imageUrl!,
          fit: BoxFit.cover,
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
      child: Icon(_icons[category] ?? Icons.shopping_bag_outlined, size: 26, color: c.inkSubtle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SKELETONS
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSkeleton extends StatelessWidget {
  final _C c;
  const _HeroSkeleton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1200),
      baseColor: c.surfaceAlt.withValues(alpha: 0.6),
      highlightColor: c.surfaceAlt.withValues(alpha: 0.95),
      child: _SkeletonBox(height: 200, radius: 22, c: c, width: double.infinity),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  final _C c;
  const _GridSkeleton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1200),
      baseColor: c.surfaceAlt.withValues(alpha: 0.6),
      highlightColor: c.surfaceAlt.withValues(alpha: 0.95),
      child: Row(
        children: [
          Expanded(child: _SkeletonBox(height: 230, radius: 16, c: c, width: double.infinity)),
          const SizedBox(width: 14),
          Expanded(child: _SkeletonBox(height: 230, radius: 16, c: c, width: double.infinity)),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final _C c;
  const _SkeletonLine({required this.c});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1200),
      baseColor: c.surfaceAlt.withValues(alpha: 0.6),
      highlightColor: c.surfaceAlt.withValues(alpha: 0.95),
      child: Row(
        children: [
          _SkeletonBox(height: 12, radius: 6, c: c, width: 90),
          const Spacer(),
          _SkeletonBox(height: 12, radius: 6, c: c, width: 60),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;
  final _C c;
  final double? width;

  const _SkeletonBox({required this.height, required this.radius, required this.c, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radius)),
    );
  }
}
