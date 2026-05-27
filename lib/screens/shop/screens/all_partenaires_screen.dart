import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../widgets/boutique_card.dart';
import 'boutique_detail_screen.dart';

// ─────────────────────────────────────────────
// DATA MODEL — filtre catégorie
// ─────────────────────────────────────────────
class _CategoryFilter {
  final String id;
  final String label;
  const _CategoryFilter({required this.id, required this.label});
}

const _kCategories = [
  _CategoryFilter(id: 'all', label: 'Tout'),
  _CategoryFilter(id: 'mamans', label: 'Mamans'),
  _CategoryFilter(id: 'baby', label: 'Baby'),
  _CategoryFilter(id: 'sport', label: 'Sport'),
  _CategoryFilter(id: 'vitamines', label: 'Vitamines'),
  _CategoryFilter(id: 'skincare', label: 'Skincare'),
  _CategoryFilter(id: 'home', label: 'Home'),
];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────
class AllPartenairesScreen extends StatefulWidget {
  const AllPartenairesScreen({super.key});

  @override
  State<AllPartenairesScreen> createState() => _AllPartenairesScreenState();
}

class _AllPartenairesScreenState extends State<AllPartenairesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  String _search = '';
  String _activeCategory = 'all';
  bool _searchFocused = false;

  late final AnimationController _filterAnimCtrl;

  @override
  void initState() {
    super.initState();
    _filterAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    _searchCtrl.addListener(() {
      setState(() => _search = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _scrollCtrl.dispose();
    _filterAnimCtrl.dispose();
    super.dispose();
  }

  // ── Filtrage ──────────────────────────────
  List get _filtered => mockItems.where((e) {
        final q = _search.toLowerCase();
        final matchSearch = q.isEmpty ||
            e.brand.toLowerCase().contains(q) ||
            e.title.toLowerCase().contains(q) ||
            (e.category?.toLowerCase().contains(q) ?? false);

        final matchCat = _activeCategory == 'all' ||
            (e.category?.toLowerCase() == _activeCategory.toLowerCase());

        return matchSearch && matchCat;
      }).toList();

  void _selectCategory(String id) {
    if (_activeCategory == id) return;
    _filterAnimCtrl.forward(from: 0);
    setState(() => _activeCategory = id);
    // Scroll grid to top on filter change
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ─────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(cs),
            const SizedBox(height: 4),
            _buildSearchBar(),
            const SizedBox(height: 12),
            _buildCategoryBar(),
            const SizedBox(height: 12),
            _buildResultCount(filtered.length),
            const SizedBox(height: 8),
            Expanded(child: _buildGrid(filtered, cs)),
          ],
        ),
      ),
    );
  }

  // ── 1. Header ─────────────────────────────
  Widget _buildHeader(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back button — gauche
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.chevron_left,
                      size: 16,
                      color: const Color(0xFF1A1A1A),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Boutique',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Titre — centré
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Partenaires',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 20,
                height: 1.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Search Bar ──────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _searchFocused
              ? Colors.white
              : const Color(0xFFF0F0ED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _searchFocused
                ? const Color(0xFF1A1A1A).withOpacity(0.22)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: _searchFocused
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: _searchCtrl,
          focusNode: _searchFocus,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher un partenaire…',
            hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF1A1A1A).withOpacity(0.35),
              letterSpacing: -0.2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(
                CupertinoIcons.search,
                size: 17,
                color: const Color(0xFF1A1A1A).withOpacity(0.4),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 42),
            suffixIcon: _search.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      _searchFocus.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        CupertinoIcons.xmark_circle_fill,
                        size: 17,
                        color: const Color(0xFF1A1A1A).withOpacity(0.3),
                      ),
                    ),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 36),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  // ── 3. Category Bar ────────────────────────
  Widget _buildCategoryBar() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _kCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final cat = _kCategories[i];
          final isActive = cat.id == _activeCategory;
          return GestureDetector(
            onTap: () => _selectCategory(cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFFF0F0ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : const Color(0xFF5A5A5A),
                  letterSpacing: -0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── 4. Result Count ────────────────────────
  Widget _buildResultCount(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '${count} partenaire${count > 1 ? 's' : ''}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFFA0A09A),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── 5. Grid ────────────────────────────────
  Widget _buildGrid(List filtered, ColorScheme cs) {
    if (filtered.isEmpty) return const _EmptyState();

    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) {
        return _PremiumCardWrapper(
          index: i,
          child: BoutiqueCard(
            item: filtered[i],
            userEtoiles: 60,
            onTap: () => Navigator.push(
              ctx,
              CupertinoPageRoute(
                builder: (_) => BoutiqueDetailScreen(
                  item: filtered[i],
                  userEtoiles: 60,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// CARD WRAPPER — fade-in + tap scale
// ─────────────────────────────────────────────
class _PremiumCardWrapper extends StatefulWidget {
  final Widget child;
  final int index;
  const _PremiumCardWrapper({required this.child, required this.index});

  @override
  State<_PremiumCardWrapper> createState() => _PremiumCardWrapperState();
}

class _PremiumCardWrapperState extends State<_PremiumCardWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + widget.index * 40),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Staggered delay
    Future.delayed(Duration(milliseconds: widget.index * 35), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _scale = 0.96),
          onTapUp: (_) => setState(() => _scale = 1.0),
          onTapCancel: () => setState(() => _scale = 1.0),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY STATE PREMIUM
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  CupertinoIcons.bag,
                  size: 26,
                  color: Color(0xFFA0A09A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun partenaire trouvé',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez un autre filtre\nou mot-clé',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFA0A09A),
                height: 1.5,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}