import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boutique_item.dart';
import '../widgets/info_row.dart';
import 'package:fiteva/screens/shop/widgets/promo_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOUTIQUE DETAIL SCREEN — Premium redesign
// Style : Sephora × Nike app × Editorial luxury
// ─────────────────────────────────────────────────────────────────────────────
class BoutiqueDetailScreen extends StatefulWidget {
  final BoutiqueItem item;
  final int userEtoiles;

  const BoutiqueDetailScreen({
    super.key,
    required this.item,
    required this.userEtoiles,
  });

  @override
  State<BoutiqueDetailScreen> createState() => _BoutiqueDetailScreenState();
}

class _BoutiqueDetailScreenState extends State<BoutiqueDetailScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _ctaPressed = false;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  late final AnimationController _ctaBounceCtrl;
  late final Animation<double> _ctaScale;

  // ── Derived ────────────────────────────────────────────────────────────────
  bool get _canAfford => widget.userEtoiles >= widget.item.etoiles;

  int get _daysLeft {
    try {
      // Supports "31/12/2025" or "2025-12-31"
      final raw = widget.item.validUntil ?? '';
      DateTime? deadline;
      if (raw.contains('/')) {
        final parts = raw.split('/');
        if (parts.length == 3) {
          deadline = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } else if (raw.contains('-')) {
        deadline = DateTime.tryParse(raw);
      }
      if (deadline == null) return 999;
      return deadline.difference(DateTime.now()).inDays.clamp(0, 999);
    } catch (_) {
      return 999;
    }
  }

  bool get _isLimited => _daysLeft < 30;

  double get _progressRatio {
    // Assume offers are ~90 days long; show remaining fraction
    const totalDays = 90;
    return (_daysLeft / totalDays).clamp(0.0, 1.0);
  }

  Color get _progressColor {
    if (_daysLeft <= 7) return const Color(0xFFE53935);
    if (_daysLeft <= 20) return const Color(0xFFFB8C00);
    return const Color(0xFF2E7D32);
  }

  // ── Init ───────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _ctaBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _ctaScale = _ctaBounceCtrl;

    Future.microtask(() => _entryCtrl.forward());
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _ctaBounceCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _onCtaTapDown(_) {
    if (!_canAfford) return;
    _ctaBounceCtrl.reverse();
  }

  void _onCtaTapUp(_) {
    if (!_canAfford) return;
    _ctaBounceCtrl.forward();
    _showPromoModal(context);
  }

  void _onCtaTapCancel() => _ctaBounceCtrl.forward();

  void _showPromoModal(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromoModal(item: widget.item),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryFade,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBadgeRow(context),
                            const SizedBox(height: 14),
                            _buildTitleBlock(context),
                            const SizedBox(height: 24),
                            _buildOfferSummaryCard(context),
                            const SizedBox(height: 16),
                            _buildDescriptionCard(context),
                            const SizedBox(height: 16),
                            _buildHowToUseCard(context),
                            const SizedBox(height: 16),
                            _buildSimilarOffersSection(context),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCTABar(context),
        ],
      ),
    );
  }

  // ── Sliver App Bar ─────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    final item = widget.item;
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      backgroundColor: item.primaryColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.chevron_left,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Share placeholder
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.share,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [item.primaryColor, item.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Hero image
            Hero(
              tag: 'boutique-image-${item.title ?? ''}',
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? '',
                fit: BoxFit.cover,
                memCacheWidth: 800,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => Container(color: Colors.transparent),
                errorWidget: (_, __, ___) => Container(
                  color: item.primaryColor.withOpacity(0.3),
                ),
              ),
            ),
            // Gradient overlay — smooth 3-stop
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x33000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.3, 0.62, 1.0],
                ),
              ),
            ),
            // Limited badge
            if (_isLimited)
              Positioned(
                top: 96,
                right: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'OFFRE LIMITÉE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Bottom overlay text
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (item.brand ?? '').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.discount ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      height: 0.9,
                      letterSpacing: -3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'sur le site',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Badge Row ──────────────────────────────────────────────────────────────
  Widget _buildBadgeRow(BuildContext context) {
    final item = widget.item;
    return Row(
      children: [
        if ((item.category ?? '').isNotEmpty) ...[
          _Chip(
            label: item.category!,
            background: item.primaryColor.withOpacity(0.10),
            foreground: item.primaryColor,
          ),
          const SizedBox(width: 8),
        ],
        if (_isLimited)
          _Chip(
            label: '${_daysLeft}j restants',
            background: const Color(0xFFFFEBEE),
            foreground: const Color(0xFFE53935),
          ),
      ],
    );
  }

  // ── Title Block ────────────────────────────────────────────────────────────
  Widget _buildTitleBlock(BuildContext context) {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.brand ?? '',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA0A09A),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.title ?? 'Offre partenaire',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  // ── Offer Summary Card ─────────────────────────────────────────────────────
  Widget _buildOfferSummaryCard(BuildContext context) {
    final item = widget.item;
    final shortage = item.etoiles - widget.userEtoiles;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé de l\'offre',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 18),

          // Cost row — highlighted
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: item.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coût de l\'offre',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA0A09A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${item.etoiles} étoiles',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: item.primaryColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const _DividerLine(),

          // Validity row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.calendar,
                  color: Color(0xFF5A5A5A),
                  size: 17,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Valable jusqu\'au',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA0A09A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      item.validUntil ?? 'Non précisé',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    // Days left progress
                    if (_daysLeft < 999) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressRatio,
                          minHeight: 4,
                          backgroundColor: const Color(0xFFF0F0ED),
                          valueColor:
                              AlwaysStoppedAnimation(_progressColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _daysLeft <= 1
                            ? 'Expire demain !'
                            : '$_daysLeft jours restants',
                        style: TextStyle(
                          fontSize: 11,
                          color: _progressColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const _DividerLine(),

          // User etoiles row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _canAfford
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _canAfford
                      ? CupertinoIcons.checkmark_circle_fill
                      : CupertinoIcons.lock_fill,
                  color: _canAfford
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFFB8C00),
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes étoiles',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA0A09A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${widget.userEtoiles} disponibles',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _canAfford
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFFB8C00),
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (!_canAfford) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '−$shortage',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFFB8C00),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Description Card ───────────────────────────────────────────────────────
  Widget _buildDescriptionCard(BuildContext context) {
    final desc = widget.item.description ?? '';
    if (desc.isEmpty) return const SizedBox.shrink();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'À propos de l\'offre',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5A5A5A),
              height: 1.65,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ── How To Use Card ────────────────────────────────────────────────────────
  Widget _buildHowToUseCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Comment ça marche ?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.1,
            ),
          ),
          SizedBox(height: 16),
          _StepRow(
              number: '01',
              text: 'Appuie sur "Échanger mes étoiles"',
              isLast: false),
          _StepRow(
              number: '02',
              text: 'Reçois ton code promo et QR code',
              isLast: false),
          _StepRow(
              number: '03',
              text: 'Télécharge ta carte en PDF',
              isLast: false),
          _StepRow(
              number: '04',
              text: 'Utilise-le lors de ta commande',
              isLast: true),
        ],
      ),
    );
  }

  // ── Similar Offers ─────────────────────────────────────────────────────────
  Widget _buildSimilarOffersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 14),
          child: Text(
            'Offres similaires',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.4,
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: 4,
            itemBuilder: (ctx, i) => Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: widget.item.primaryColor.withOpacity(0.15),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${(i + 1) * 10}%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: widget.item.primaryColor,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Partenaire ${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${(i + 1) * 50} étoiles',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFA0A09A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── CTA Bar ────────────────────────────────────────────────────────────────
  Widget _buildCTABar(BuildContext context) {
    final shortage = widget.item.etoiles - widget.userEtoiles;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFF1A1A1A).withOpacity(0.07),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Missing etoiles warning
          if (!_canAfford)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.info_circle,
                      size: 14,
                      color: Color(0xFFFB8C00),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Il te manque $shortage étoile${shortage > 1 ? 's' : ''} pour débloquer cette offre',
                      style: const TextStyle(
                        color: Color(0xFFFB8C00),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Main CTA button
          ScaleTransition(
            scale: _ctaScale,
            child: GestureDetector(
              onTapDown: _onCtaTapDown,
              onTapUp: _onCtaTapUp,
              onTapCancel: _onCtaTapCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _canAfford
                      ? LinearGradient(
                          colors: [
                            widget.item.primaryColor,
                            widget.item.secondaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: _canAfford ? null : const Color(0xFFF0F0ED),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _canAfford
                      ? [
                          BoxShadow(
                            color: widget.item.primaryColor.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _canAfford
                          ? CupertinoIcons.sparkles
                          : CupertinoIcons.lock_fill,
                      color: _canAfford
                          ? Colors.white
                          : const Color(0xFFA0A09A),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _canAfford
                          ? 'Échanger ${widget.item.etoiles} étoiles'
                          : 'Étoiles insuffisantes',
                      style: TextStyle(
                        color: _canAfford
                            ? Colors.white
                            : const Color(0xFFA0A09A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Copy promo placeholder
          if (_canAfford) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Copy placeholder
              },
              child: const Text(
                'Copier le code promo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA0A09A),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFA0A09A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        height: 1,
        color: const Color(0xFFF0F0ED),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  const _Chip(
      {required this.label,
      required this.background,
      required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: foreground,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;
  final bool isLast;
  const _StepRow(
      {required this.number, required this.text, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFF0F0ED),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3A3A3A),
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}