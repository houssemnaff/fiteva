import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/boutique_item.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE — dérivée du ColorScheme du thème actif (donc de la palette Pro),
// même logique que community_screen.dart / boutique_screen.dart.
// Or = points, rouge = wishlist : couleurs sémantiques fixes.
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  final Color bg, surface, surfaceAlt, ink, inkMuted, inkSubtle, divider, chipBg;
  final Color accent, accentSoft;
  final bool  isDark;

  static const Color gold    = Color(0xFFB8892F);
  static const Color wishRed = Color(0xFFC24A4A);

  factory _P.of(BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    return _P._(
      bg:         cs.surface,
      surface:    cs.surface,
      surfaceAlt: cs.surfaceContainerHighest,
      ink:        cs.onSurface,
      inkMuted:   cs.onSurface.withValues(alpha: 0.55),
      inkSubtle:  cs.onSurface.withValues(alpha: 0.35),
      divider:    cs.outline,
      chipBg:     cs.surfaceContainerHighest,
      accent:     cs.primary,
      accentSoft: cs.secondaryContainer,
      isDark:     cs.brightness == Brightness.dark,
    );
  }

  const _P._({
    required this.bg, required this.surface, required this.surfaceAlt,
    required this.ink, required this.inkMuted, required this.inkSubtle,
    required this.divider, required this.chipBg,
    required this.accent, required this.accentSoft,
    required this.isDark,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _Cat {
  final String key, label;
  const _Cat({required this.key, required this.label});
}

const _kCats = [
  _Cat(key: 'all',       label: 'Tout'),
  _Cat(key: 'mamans',    label: 'Mamans'),
  _Cat(key: 'baby',      label: 'Baby'),
  _Cat(key: 'sport',     label: 'Sport'),
  _Cat(key: 'vitamines', label: 'Vitamines'),
  _Cat(key: 'skincare',  label: 'Skincare'),
  _Cat(key: 'home',      label: 'Maison'),
];

const Map<String, IconData> _catIcons = {
  'mamans':    Icons.favorite_rounded,
  'baby':      Icons.child_care,
  'sport':     Icons.fitness_center,
  'vitamines': Icons.eco_rounded,
  'skincare':  Icons.spa_rounded,
  'home':      Icons.home_rounded,
};

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN — fond blanc, liste propre séparée par des filets fins
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

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
    _scrollCtrl.addListener(() {
      final e = _scrollCtrl.offset > 6;
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

  List<BoutiqueItem> _getFiltered(List<BoutiqueItem> items) => items.where((e) {
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
    final allItems = ref.watch(shopItemsProvider).asData?.value ?? <BoutiqueItem>[];
    final filtered = _getFiltered(allItems);
    final wishlist = ref.watch(shopWishlistProvider);
    final shop     = ref.watch(shopProvider);
    final l10n     = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          _Header(p: p, l10n: l10n, elevated: _elevated, onBack: () => Navigator.pop(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: _SearchField(p: p, l10n: l10n, ctrl: _searchCtrl, focus: _searchFocus, search: _search),
          ),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _kCats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _CatPill(
                p: p,
                label: _kCats[i].label,
                isSelected: _cat == _kCats[i].key,
                onTap: () => setState(() => _cat = _kCats[i].key),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text('${filtered.length} partenaire${filtered.length > 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.inkMuted)),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(p: p, l10n: l10n)
                : ListView.separated(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: p.divider),
                    itemBuilder: (ctx, i) {
                      final item = filtered[i];
                      return _PartnerRow(
                        p: p,
                        item: item,
                        isWishlisted: wishlist.contains(item.id),
                        isRedeemed: shop.isRedeemed(item.id),
                        canAfford: shop.canAfford(item.diamonds),
                        onWish: () => _toggleWish(item.id),
                        onTap: () => Navigator.push(
                            ctx,
                            CupertinoPageRoute(builder: (_) => BoutiqueDetailScreen(item: item))),
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
// HEADER — simple, blanc, titre + retour texte
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final _P p;
  final AppL10n l10n;
  final bool elevated;
  final VoidCallback onBack;
  const _Header({required this.p, required this.l10n, required this.elevated, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: p.bg,
        border: elevated ? Border(bottom: BorderSide(color: p.divider, width: 1)) : const Border(),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Icon(CupertinoIcons.back, size: 22, color: p.ink),
              ),
              const SizedBox(width: 14),
              Text(l10n.allPartPartenaires,
                  style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w800, color: p.ink, letterSpacing: -0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH FIELD — champ plein (fill gris clair), pas de bordure
// ─────────────────────────────────────────────────────────────────────────────
class _SearchField extends StatelessWidget {
  final _P p;
  final AppL10n l10n;
  final TextEditingController ctrl;
  final FocusNode focus;
  final String search;
  const _SearchField({required this.p, required this.l10n, required this.ctrl, required this.focus, required this.search});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(CupertinoIcons.search, size: 17, color: p.inkSubtle),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: ctrl,
              focusNode: focus,
              style: TextStyle(fontSize: 14.5, color: p.ink),
              decoration: InputDecoration(
                hintText: l10n.allPartSearch,
                hintStyle: TextStyle(fontSize: 14.5, color: p.inkSubtle),
                border: InputBorder.none,
                isDense: true,
              ),
              cursorColor: p.accent,
              cursorWidth: 1.5,
            ),
          ),
          if (search.isNotEmpty)
            GestureDetector(
              onTap: ctrl.clear,
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(CupertinoIcons.xmark_circle_fill, size: 17, color: p.inkSubtle),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CAT PILL — pilule texte simple, sans icône
// ─────────────────────────────────────────────────────────────────────────────
class _CatPill extends StatelessWidget {
  final _P p;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CatPill({required this.p, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? p.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: isSelected ? p.accent : p.divider, width: 1.2),
          boxShadow: isSelected ? [
            BoxShadow(color: p.accent.withValues(alpha: 0.2),
              blurRadius: 8, offset: const Offset(0, 3)),
          ] : null,
        ),
        child: Text(label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : p.inkMuted,
            )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTNER ROW — ligne épurée, séparée par filet, sans ombre ni bordure
// ─────────────────────────────────────────────────────────────────────────────
class _PartnerRow extends StatelessWidget {
  final _P p;
  final BoutiqueItem item;
  final bool isWishlisted;
  final bool isRedeemed;
  final bool canAfford;
  final VoidCallback onWish;
  final VoidCallback onTap;

  const _PartnerRow({
    required this.p,
    required this.item,
    required this.isWishlisted,
    required this.isRedeemed,
    required this.canAfford,
    required this.onWish,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 72, height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _NetImage(url: item.imageUrl, category: item.category, p: p),
                    if (!canAfford && !isRedeemed)
                      Container(color: Colors.black.withValues(alpha: 0.16)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.brand.toUpperCase(),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w700,
                          color: p.inkSubtle, letterSpacing: 1.2)),
                  const SizedBox(height: 3),
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink)),
                  const SizedBox(height: 7),
                  Row(children: [
                    if (item.discount.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item.discount,
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: p.accent)),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 3, height: 3, decoration: BoxDecoration(color: p.divider, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                    ],
                    isRedeemed
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.accentSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.check_circle_rounded, size: 11, color: p.accent),
                              const SizedBox(width: 4),
                              Text('Échangé', style: GoogleFonts.inter(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: p.accent)),
                            ]),
                          )
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.gem, size: 11, color: canAfford ? _P.gold : p.inkSubtle),
                            const SizedBox(width: 4),
                            Text('${item.diamonds} pts',
                                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600,
                                    color: canAfford ? p.ink : p.inkSubtle)),
                          ]),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onWish,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: p.chipBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(isWishlisted ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                    size: 16, color: isWishlisted ? _P.wishRed : p.inkSubtle),
              ),
            ),
          ],
        ),
      ),
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
  const _NetImage({required this.url, required this.category, required this.p});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    color: p.surfaceAlt,
    child: Icon(_catIcons[category] ?? Icons.shopping_bag_outlined, size: 22, color: p.inkSubtle),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final _P p;
  final AppL10n l10n;
  const _EmptyState({required this.p, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(color: p.chipBg, shape: BoxShape.circle),
            child: Icon(CupertinoIcons.bag, size: 30, color: p.inkSubtle),
          ),
          const SizedBox(height: 20),
          Text(l10n.allPartAucun, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink)),
          const SizedBox(height: 8),
          Text(l10n.allPartEssayer, style: TextStyle(fontSize: 14, color: p.inkMuted)),
        ],
      ),
    );
  }
}
