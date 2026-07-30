import 'dart:ui';
import 'package:fiteva/core/shop/shop_provider.dart';
import 'package:fiteva/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../models/boutique_item.dart';
import 'package:fiteva/screens/shop/widgets/promo_modal.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE — dérivée du ColorScheme du thème actif (donc de la palette Pro),
// même logique que community_screen.dart / boutique_screen.dart, au lieu des
// couleurs aléatoires par item (item.primaryColor/secondaryColor) et de la
// palette empruntée à un autre module qui rendaient cet écran incohérent.
// warning/urgent = statuts sémantiques fixes (pas la marque).
// ─────────────────────────────────────────────────────────────────────────────
class _P {
  final Color bg, surface, surfaceAlt, ink, inkMuted, inkSubtle, divider, chipBg;
  final Color accent, accentSoft;
  final bool  isDark;

  static const Color gold    = Color(0xFFB8892F);
  static const Color warning = Color(0xFFB8892F);
  static const Color urgent  = Color(0xFFC24A4A);

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

  List<BoxShadow> get cardShadow => isDark ? [] : [
    BoxShadow(color: ink.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 5)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTIQUE DETAIL SCREEN
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

  bool get _canAfford       => ref.read(shopProvider).canAfford(widget.item.diamonds);
  bool get _alreadyRedeemed => ref.read(shopProvider).isRedeemed(widget.item.id);

  int get _daysLeft {
    try {
      final raw = widget.item.validUntil;
      DateTime? deadline;
      if (raw.contains('/')) {
        final parts = raw.split('/');
        if (parts.length == 3) {
          deadline = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
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
    const totalDays = 90;
    return (_daysLeft / totalDays).clamp(0.0, 1.0);
  }

  Color get _progressColor {
    if (_daysLeft <= 7) return _P.urgent;
    if (_daysLeft <= 20) return _P.gold;
    return _P.of(context).accent;
  }

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

    _ctaBounceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120),
      lowerBound: 0.94, upperBound: 1.0, value: 1.0,
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
    setState(() {});
  }

  void _onCtaTapCancel() => _ctaBounceCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final p    = _P.of(context);
    ref.watch(l10nProvider);
    return Scaffold(
      backgroundColor: p.bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context, p),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _entryFade,
                    child: SlideTransition(
                      position: _entrySlide,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBadgeRow(context, p),
                            const SizedBox(height: 12),
                            _buildTitleBlock(context, p),
                            const SizedBox(height: 22),
                            _buildOfferSummaryCard(context, p),
                            const SizedBox(height: 14),
                            _buildDescriptionCard(context, p),
                            const SizedBox(height: 14),
                            _buildHowToUseCard(context, p),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCTABar(context, p),
        ],
      ),
    );
  }

  // ── Sliver App Bar — image + retour/partage, sans dégradé coloré aléatoire ──
  Widget _buildSliverAppBar(BuildContext context, _P p) {
    final item = widget.item;
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: p.surfaceAlt,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.22), shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.chevron_left, color: Colors.white, size: 17),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: p.surfaceAlt),
            Hero(
              tag: 'boutique-image-${item.title}',
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => Container(color: Colors.transparent),
                errorWidget: (_, __, ___) => Container(color: p.surfaceAlt),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x66000000)],
                  stops: [0.55, 1.0],
                ),
              ),
            ),
            if (item.discount.isNotEmpty)
              Positioned(
                left: 20, bottom: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF16211A), borderRadius: BorderRadius.circular(20)),
                  child: Text(item.discount,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeRow(BuildContext context, _P p) {
    final item = widget.item;
    return Row(
      children: [
        if (item.category.isNotEmpty) ...[
          _Chip(label: item.category, background: p.chipBg, foreground: p.inkMuted),
          const SizedBox(width: 8),
        ],
        if (_isLimited)
          _Chip(label: '${_daysLeft}j restants', background: const Color(0xFFF3E4E4), foreground: _P.urgent),
      ],
    );
  }

  Widget _buildTitleBlock(BuildContext context, _P p) {
    final item = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.brand.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.inkSubtle, letterSpacing: 1.4)),
        const SizedBox(height: 5),
        Text(item.title.isEmpty ? 'Offre partenaire' : item.title,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w800, color: p.ink, letterSpacing: -0.6, height: 1.15)),
      ],
    );
  }

  Widget _buildOfferSummaryCard(BuildContext context, _P p) {
    final item      = widget.item;
    final shop      = ref.watch(shopProvider);
    final canAfford = shop.canAfford(item.diamonds);
    final shortage  = item.diamonds - shop.diamonds;
    final l10n      = ref.read(l10nProvider);

    return _Card(
      p: p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.detailResume,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: p.isDark ? _P.gold.withValues(alpha: 0.16) : const Color(0xFFF6EFDF),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(CupertinoIcons.star_fill, color: _P.gold, size: 17),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.detailCout, style: TextStyle(fontSize: 12, color: p.inkMuted)),
                  Text('${item.diamonds} ${l10n.detailDiamonds}',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _P.gold, letterSpacing: -0.3)),
                ],
              ),
            ],
          ),

          _DividerLine(p: p),

          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: p.chipBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(CupertinoIcons.calendar, color: p.inkMuted, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.detailValable, style: TextStyle(fontSize: 12, color: p.inkMuted)),
                    Text(item.validUntil.isEmpty ? l10n.detailNonPrecise : item.validUntil,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink, letterSpacing: -0.2)),
                    if (_daysLeft < 999) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressRatio, minHeight: 4,
                          backgroundColor: p.divider,
                          valueColor: AlwaysStoppedAnimation(_progressColor),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(_daysLeft <= 1 ? l10n.detailExpireDemain : '$_daysLeft jours restants',
                          style: TextStyle(fontSize: 11, color: _progressColor, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ],
          ),

          _DividerLine(p: p),

          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: canAfford
                      ? p.accent.withValues(alpha: p.isDark ? 0.22 : 0.10)
                      : _P.warning.withValues(alpha: p.isDark ? 0.22 : 0.10),
                  borderRadius: BorderRadius.circular(10)),
                child: Icon(
                  canAfford ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.lock_fill,
                  color: canAfford ? p.accent : _P.warning, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.detailMesDiamonds, style: TextStyle(fontSize: 12, color: p.inkMuted)),
                  Row(
                    children: [
                      Text('${shop.diamonds} ${l10n.detailDisponibles}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                              color: canAfford ? p.accent : _P.warning, letterSpacing: -0.2)),
                      if (!canAfford) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: _P.warning.withValues(alpha: p.isDark ? 0.20 : 0.12),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('−$shortage',
                              style: const TextStyle(fontSize: 11, color: _P.warning, fontWeight: FontWeight.w700)),
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

  Widget _buildDescriptionCard(BuildContext context, _P p) {
    final desc = widget.item.description;
    if (desc.isEmpty) return const SizedBox.shrink();
    final l10n = ref.read(l10nProvider);

    return _Card(
      p: p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.detailAPropos, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 12),
          Text(desc, style: TextStyle(fontSize: 14, color: p.inkMuted, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildHowToUseCard(BuildContext context, _P p) {
    final l10n = ref.read(l10nProvider);
    return _Card(
      p: p,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.detailComment, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 16),
          _StepRow(p: p, number: '01', text: l10n.detailStep1, isLast: false),
          _StepRow(p: p, number: '02', text: l10n.detailStep2, isLast: false),
          _StepRow(p: p, number: '03', text: l10n.detailStep3, isLast: false),
          _StepRow(p: p, number: '04', text: l10n.detailStep4, isLast: true),
        ],
      ),
    );
  }

  Widget _buildCTABar(BuildContext context, _P p) {
    final shop      = ref.watch(shopProvider);
    final canAfford = shop.canAfford(widget.item.diamonds);
    final redeemed  = shop.isRedeemed(widget.item.id);
    final shortage  = widget.item.diamonds - shop.diamonds;
    final ctaActive = canAfford && !redeemed;
    final l10n      = ref.read(l10nProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).padding.bottom + 18),
      decoration: BoxDecoration(color: p.surface, border: Border(top: BorderSide(color: p.divider, width: 1))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (redeemed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: p.isDark ? 0.18 : 0.10), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: p.accent),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(l10n.detailDejaEchange,
                          style: TextStyle(color: p.accent, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            )
          else if (!canAfford)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                    color: _P.warning.withValues(alpha: p.isDark ? 0.18 : 0.10), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.info_circle, size: 14, color: _P.warning),
                    const SizedBox(width: 7),
                    Flexible(
                      child: Text(l10n.detailManque(shortage),
                          style: const TextStyle(color: _P.warning, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

          ScaleTransition(
            scale: _ctaScale,
            child: GestureDetector(
              onTapDown: _onCtaTapDown,
              onTapUp: _onCtaTapUp,
              onTapCancel: _onCtaTapCancel,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: ctaActive ? p.accent : p.chipBg,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: ctaActive
                      ? [BoxShadow(color: p.accent.withValues(alpha: 0.30), blurRadius: 16, offset: const Offset(0, 6))]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      redeemed
                          ? Icons.check_circle_rounded
                          : ctaActive ? LucideIcons.sparkles : CupertinoIcons.lock_fill,
                      color: ctaActive ? Colors.white : p.inkSubtle, size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      redeemed
                          ? l10n.detailDejaEchangeBtn
                          : ctaActive ? l10n.detailEchangerDiamonds(widget.item.diamonds) : l10n.detailDiamondsInsuff,
                      style: GoogleFonts.outfit(
                          color: ctaActive ? Colors.white : p.inkSubtle,
                          fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (redeemed) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.item.promoCode));
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.detailCopierCode(widget.item.promoCode)),
                  duration: const Duration(seconds: 2),
                  backgroundColor: p.accent,
                ));
              },
              child: Text(
                l10n.detailCopierCode(widget.item.promoCode),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.accent,
                    decoration: TextDecoration.underline, decorationColor: p.accent),
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
  final _P p;
  final Widget child;
  const _Card({required this.p, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: p.isDark ? Border.all(color: p.divider, width: 1) : null,
        boxShadow: p.cardShadow,
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  final _P p;
  const _DividerLine({required this.p});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(height: 1, color: p.divider),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  const _Chip({required this.label, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: foreground, letterSpacing: 0.2)),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _P p;
  final String number;
  final String text;
  final bool isLast;
  const _StepRow({required this.p, required this.number, required this.text, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(number, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ),
            if (!isLast) Container(width: 1, height: 24, color: p.divider),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(text, style: TextStyle(fontSize: 14, color: p.inkMuted, height: 1.4)),
          ),
        ),
      ],
    );
  }
}
