import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boutique_item.dart';
import '../widgets/info_row.dart';
import 'package:fiteva/screens/shop/widgets/promo_modal.dart';
import 'package:fiteva/screens/nutrition/nutrition_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BOUTIQUE DETAIL SCREEN — Premium redesign
// Style : Sephora × Nike app × Editorial luxury
// ─────────────────────────────────────────────────────────────────────────────
class BoutiqueDetailScreen extends ConsumerStatefulWidget {
  final BoutiqueItem item;

  const BoutiqueDetailScreen({super.key, required this.item});

  @override
  ConsumerState<BoutiqueDetailScreen> createState() => _BoutiqueDetailScreenState();
}

class _BoutiqueDetailScreenState extends ConsumerState<BoutiqueDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  late final AnimationController _ctaBounceCtrl;
  late final Animation<double> _ctaScale;

  // ── Derived (use ref.watch only inside build via _shopLive) ───────────────
  // For tap handlers (outside build), use ref.read via _shop.
  ShopState get _shop         => ref.read(shopProvider);
  bool get _canAfford         => ref.read(shopProvider).canAfford(widget.item.etoiles);
  bool get _alreadyRedeemed   => ref.read(shopProvider).isRedeemed(widget.item.id);

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
    if (!_canAfford || _alreadyRedeemed) return;
    _ctaBounceCtrl.reverse();
  }

  void _onCtaTapUp(_) async {
    if (!_canAfford || _alreadyRedeemed) return;
    _ctaBounceCtrl.forward();

    final ok = await ref.read(shopProvider.notifier).redeem(widget.item);
    if (!ok || !mounted) return;

    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PromoModal(item: widget.item),
    );
    setState(() {}); // refresh CTA state
  }

  void _onCtaTapCancel() => _ctaBounceCtrl.forward();

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final nc   = NutritionColors.of(context);
    final l10n = ref.watch(l10nProvider);
    return Scaffold(
      backgroundColor: nc.bg,
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
                      Text(
                        ref.read(l10nProvider).detailOffreLimitee,
                        style: const TextStyle(
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
                  Text(
                    ref.read(l10nProvider).detailSurSite,
                    style: const TextStyle(
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
    final nc   = NutritionColors.of(context);
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.brand ?? '',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: nc.text2,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.title ?? 'Offre partenaire',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: nc.text1,
            letterSpacing: -0.7,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  // ── Offer Summary Card ─────────────────────────────────────────────────────
  Widget _buildOfferSummaryCard(BuildContext context) {
    final nc        = NutritionColors.of(context);
    final item      = widget.item;
    final shop      = ref.watch(shopProvider);
    final canAfford = shop.canAfford(item.etoiles);
    final shortage  = item.etoiles - shop.points;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.read(l10nProvider).detailResume,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: nc.text1,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 18),

          // Cost row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.water_drop_rounded, color: item.primaryColor, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.read(l10nProvider).detailCout,
                    style: TextStyle(fontSize: 12, color: nc.text2, fontWeight: FontWeight.w400)),
                  Text('${item.etoiles} ${ref.read(l10nProvider).detailEtoiles}',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: item.primaryColor, letterSpacing: -0.3)),
                ],
              ),
            ],
          ),

          const _DividerLine(),

          // Validity row
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: nc.surface2, borderRadius: BorderRadius.circular(10)),
                child: Icon(CupertinoIcons.calendar, color: nc.text2, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.read(l10nProvider).detailValable,
                      style: TextStyle(fontSize: 12, color: nc.text2, fontWeight: FontWeight.w400)),
                    Text(item.validUntil ?? ref.read(l10nProvider).detailNonPrecise,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                        color: nc.text1, letterSpacing: -0.2)),
                    if (_daysLeft < 999) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressRatio,
                          minHeight: 4,
                          backgroundColor: nc.border,
                          valueColor: AlwaysStoppedAnimation(_progressColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _daysLeft <= 1 ? ref.read(l10nProvider).detailExpireDemain : '$_daysLeft jours restants',
                        style: TextStyle(fontSize: 11, color: _progressColor, fontWeight: FontWeight.w500)),
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
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: canAfford
                      ? const Color(0xFF2E7D32).withOpacity(nc.isDark ? 0.25 : 0.12)
                      : const Color(0xFFFB8C00).withOpacity(nc.isDark ? 0.25 : 0.12),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  canAfford ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.lock_fill,
                  color: canAfford ? const Color(0xFF2E7D32) : const Color(0xFFFB8C00),
                  size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.read(l10nProvider).detailMesEtoiles,
                    style: TextStyle(fontSize: 12, color: nc.text2, fontWeight: FontWeight.w400)),
                  Row(
                    children: [
                      Text('${shop.points} ${ref.read(l10nProvider).detailDisponibles}',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: canAfford ? const Color(0xFF2E7D32) : const Color(0xFFFB8C00),
                          letterSpacing: -0.2)),
                      if (!canAfford) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFB8C00).withOpacity(nc.isDark ? 0.20 : 0.12),
                            borderRadius: BorderRadius.circular(6)),
                          child: Text('−$shortage',
                            style: const TextStyle(fontSize: 11, color: Color(0xFFFB8C00), fontWeight: FontWeight.w700))),
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
    final nc   = NutritionColors.of(context);
    final desc = widget.item.description ?? '';
    if (desc.isEmpty) return const SizedBox.shrink();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.read(l10nProvider).detailAPropos,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: nc.text1, letterSpacing: -0.1)),
          const SizedBox(height: 12),
          Text(desc,
            style: TextStyle(fontSize: 14, color: nc.text2, height: 1.65, letterSpacing: -0.1)),
        ],
      ),
    );
  }

  // ── How To Use Card ────────────────────────────────────────────────────────
  Widget _buildHowToUseCard(BuildContext context) {
    final nc = NutritionColors.of(context);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.read(l10nProvider).detailComment,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: nc.text1, letterSpacing: -0.1)),
          const SizedBox(height: 16),
          _StepRow(
              number: '01',
              text: ref.read(l10nProvider).detailStep1,
              isLast: false),
          _StepRow(
              number: '02',
              text: ref.read(l10nProvider).detailStep2,
              isLast: false),
          _StepRow(
              number: '03',
              text: ref.read(l10nProvider).detailStep3,
              isLast: false),
          _StepRow(
              number: '04',
              text: ref.read(l10nProvider).detailStep4,
              isLast: true),
        ],
      ),
    );
  }

  // ── Similar Offers ─────────────────────────────────────────────────────────
  Widget _buildSimilarOffersSection(BuildContext context) {
    final nc = NutritionColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 14),
          child: Text(ref.read(l10nProvider).detailOffresSimilaires,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: nc.text1, letterSpacing: -0.4)),
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
                color: nc.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: nc.border),
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
                      child: Text('${(i + 1) * 10}%',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                          color: widget.item.primaryColor, letterSpacing: -1)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Partenaire ${i + 1}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: nc.text1),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text('${(i + 1) * 50} étoiles',
                          style: TextStyle(fontSize: 11, color: nc.text2)),
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
    final shop     = ref.watch(shopProvider);
    final canAfford    = shop.canAfford(widget.item.etoiles);
    final redeemed     = shop.isRedeemed(widget.item.id);
    final shortage     = widget.item.etoiles - shop.points;
    final ctaActive    = canAfford && !redeemed;

    final nc = NutritionColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 18),
      decoration: BoxDecoration(
        color: nc.surface,
        border: Border(top: BorderSide(color: nc.border, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Already redeemed banner
          if (redeemed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(nc.isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(ref.read(l10nProvider).detailDejaEchange,
                        style: const TextStyle(color: Color(0xFF2E7D32),
                          fontSize: 12.5, fontWeight: FontWeight.w500)),
                    ),
                  ])))
          else if (!canAfford)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB8C00).withOpacity(nc.isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.info_circle, size: 14, color: Color(0xFFFB8C00)),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        ref.read(l10nProvider).detailManque(shortage),
                        style: const TextStyle(color: Color(0xFFFB8C00),
                          fontSize: 12.5, fontWeight: FontWeight.w500)),
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
                  gradient: ctaActive
                      ? LinearGradient(
                          colors: [
                            widget.item.primaryColor,
                            widget.item.secondaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: ctaActive ? null : nc.surface2,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: ctaActive
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
                      redeemed
                          ? Icons.check_circle_rounded
                          : ctaActive
                              ? CupertinoIcons.sparkles
                              : CupertinoIcons.lock_fill,
                      color: ctaActive ? Colors.white : const Color(0xFFA0A09A),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      redeemed
                          ? ref.read(l10nProvider).detailDejaEchangeBtn
                          : ctaActive
                              ? ref.read(l10nProvider).detailEchangerEtoiles(widget.item.etoiles)
                              : ref.read(l10nProvider).detailEtoilesInsuff,
                      style: TextStyle(
                        color: ctaActive ? Colors.white : const Color(0xFFA0A09A),
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

          // Copy promo code (shown after redemption)
          if (redeemed) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.item.promoCode));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ref.read(l10nProvider).detailCopierCode(widget.item.promoCode)),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF2E7D32)));
              },
              child: Text(
                ref.read(l10nProvider).detailCopierCode(widget.item.promoCode),
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF2E7D32)),
              )),
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
    final nc = NutritionColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: nc.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: nc.border),
        boxShadow: nc.isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4)),
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
    final nc = NutritionColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(height: 1, color: nc.border),
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
    final nc = NutritionColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: nc.text1, borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(number,
                  style: TextStyle(color: nc.bg, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 24, color: nc.border),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(text,
              style: TextStyle(fontSize: 14, color: nc.text2, fontWeight: FontWeight.w400, height: 1.4)),
          ),
        ),
      ],
    );
  }
}