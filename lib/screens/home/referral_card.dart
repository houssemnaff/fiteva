import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

// ── Providers ──────────────────────────────────────────────────────────────────
final referralCodeProvider =
    AsyncNotifierProvider<_CodeNotifier, String>(_CodeNotifier.new);

class _CodeNotifier extends AsyncNotifier<String> {
  static const _key = 'referral_code';
  @override
  Future<String> build() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) return saved;
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    final code = 'FITEVA-' +
        List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    await prefs.setString(_key, code);
    return code;
  }
}

final referralCountProvider =
    AsyncNotifierProvider<_CountNotifier, int>(_CountNotifier.new);

class _CountNotifier extends AsyncNotifier<int> {
  static const _key = 'referral_count';
  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 2;
  }
}

/// Paliers de récompense déjà révélés (grattés) — persistés pour que la
/// carte reste révélée après un redémarrage de l'app.
final revealedRewardsProvider =
    AsyncNotifierProvider<_RevealedNotifier, Set<int>>(_RevealedNotifier.new);

class _RevealedNotifier extends AsyncNotifier<Set<int>> {
  static const _key = 'referral_revealed_rewards';
  @override
  Future<Set<int>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const [];
    return list.map(int.parse).toSet();
  }

  Future<void> reveal(int need) async {
    final current = state.asData?.value ?? <int>{};
    if (current.contains(need)) return;
    final updated = {...current, need};
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.map((e) => e.toString()).toList());
  }
}

// ── Reward model ───────────────────────────────────────────────────────────────
class _Reward {
  final int     need;
  final IconData icon;
  final String  title;
  final Color   color;
  final Color   bg;
  const _Reward({required this.need, required this.icon,
    required this.title, required this.color, required this.bg});
}

const _rewards = [
  _Reward(need: 1, icon: LucideIcons.star,   title: '+50 Points',
    color: Color(0xFF1C4D30), bg: Color(0xFFEAF3EC)),
  _Reward(need: 3, icon: LucideIcons.flame,  title: 'Premium 24h',
    color: Color(0xFFE0703C), bg: Color(0xFFFCEEE7)),
  _Reward(need: 5, icon: LucideIcons.trophy, title: 'Badge exclusif',
    color: Color(0xFFB8860B), bg: Color(0xFFFFF8E7)),
];

// ══════════════════════════════════════════════════════════════════════════════
// MAIN WIDGET — carte "ticket" (code + partage) + un palier de récompense à
// gratter dès qu'un ami installe l'app avec ton code et fait franchir un
// seuil — version simplifiée (pas de confettis/texture, juste le geste).
// ══════════════════════════════════════════════════════════════════════════════
class ReferralCard extends ConsumerStatefulWidget {
  const ReferralCard({super.key});
  @override
  ConsumerState<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends ConsumerState<ReferralCard> {
  final List<Offset> _strokes = [];
  Size _scratchSize = Size.zero;
  int? _revealingNeed;

  void _copyCode(BuildContext ctx, String code, AppL10n l10n) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(l10n.referralCodeCopied(code),
        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: const Color(0xFF166534),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _share(BuildContext ctx, String code, AppL10n l10n) {
    final msg = 'Rejoins-moi sur FitEva !\nCode : $code\nfiteva.app/invite/$code';
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(message: msg, l10n: l10n),
    );
  }

  // Palier en cours d'animation de révélation — garde la carte affichée le
  // temps de l'animation au lieu de la faire disparaître instantanément dès
  // que le palier passe dans "revealed".
  int? _revealAnimatingNeed;

  void _onScratchPan(DragUpdateDetails d, int need) {
    if (_revealingNeed != need) {
      // Un palier différent a été débloqué depuis — réinitialise les traits.
      _revealingNeed = need;
      _strokes.clear();
    }
    final pos = d.localPosition;
    if (pos.dx < 0 || pos.dy < 0 ||
        pos.dx > _scratchSize.width || pos.dy > _scratchSize.height) return;

    setState(() => _strokes.add(pos));
    HapticFeedback.selectionClick();

    if (_strokes.length > 45 && _revealAnimatingNeed != need) {
      HapticFeedback.mediumImpact();
      setState(() => _revealAnimatingNeed = need);
      Future.delayed(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        ref.read(revealedRewardsProvider.notifier).reveal(need);
        setState(() {
          _strokes.clear();
          _revealAnimatingNeed = null;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n       = ref.watch(l10nProvider);
    final codeAsync  = ref.watch(referralCodeProvider);
    final countAsync = ref.watch(referralCountProvider);
    final count      = countAsync.asData?.value ?? 0;
    final revealed   = ref.watch(revealedRewardsProvider).asData?.value ?? <int>{};
    final cs         = Theme.of(context).colorScheme;

    _Reward? nextToReveal;
    for (final r in _rewards) {
      final stillAnimating = _revealAnimatingNeed == r.need;
      if (count >= r.need && (!revealed.contains(r.need) || stillAnimating)) {
        nextToReveal = r;
        break;
      }
    }

    // Carte "ticket d'invitation" — dégradé vert plein, volontairement plus
    // visible que les autres cartes claires de l'accueil (c'est un CTA, pas
    // une donnée du jour) avec le code affiché comme un talon de billet.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1C4D30), Color(0xFF0E2B1A)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(
            color: const Color(0xFF1C4D30).withValues(alpha: 0.30),
            blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(children: [
          // ── Header ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle),
                child: const Icon(LucideIcons.gift, size: 19, color: Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.referralHeadline,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(l10n.referralHint,
                    style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.65))),
                ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.users, size: 11, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('$count', style: GoogleFonts.outfit(
                    fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                ]),
              ),
            ]),
          ),

          // ── Talon de billet — code + partage ────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: codeAsync.when(
              loading: () => const SizedBox(height: 40),
              error:   (_, __) => const SizedBox(),
              data: (code) => Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => _copyCode(context, code, l10n),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('TON CODE', style: GoogleFonts.inter(
                      fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 1.5,
                      color: cs.onSurfaceVariant)),
                    const SizedBox(height: 3),
                    Row(children: [
                      Flexible(child: Text(code, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 17, fontWeight: FontWeight.w900,
                          color: cs.onSurface, letterSpacing: 1))),
                      const SizedBox(width: 6),
                      Icon(LucideIcons.copy, size: 13, color: cs.onSurfaceVariant),
                    ]),
                  ]),
                )),
                GestureDetector(
                  onTap: () => _share(context, code, l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C4D30),
                      borderRadius: BorderRadius.circular(50)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.share2, color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(l10n.referralShare, style: GoogleFonts.inter(
                        color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          // ── Palier à gratter — dès qu'un ami installe et fait franchir
          // un nouveau seuil, cette zone apparaît pour révéler la récompense.
          if (nextToReveal != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
              child: _ScratchReveal(
                reward: nextToReveal,
                strokes: _strokes,
                revealing: _revealAnimatingNeed == nextToReveal.need,
                onPanUpdate: (d) => _onScratchPan(d, nextToReveal!.need),
                onSizeKnown: (s) => _scratchSize = s,
              ),
            ),

          // ── Paliers de récompense ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(children: List.generate(_rewards.length, (i) {
              final r        = _rewards[i];
              final unlocked = count >= r.need;
              final done     = revealed.contains(r.need);
              return Expanded(child: Padding(
                padding: EdgeInsets.only(right: i < _rewards.length - 1 ? 10 : 0),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: unlocked ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle),
                    child: Icon(
                      done ? Icons.check_rounded : (unlocked ? r.icon : LucideIcons.lock),
                      size: 13, color: Colors.white.withValues(alpha: unlocked ? 0.95 : 0.4))),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: unlocked ? 0.95 : 0.45))),
                    Text('${r.need} ami${r.need > 1 ? 's' : ''}',
                      style: GoogleFonts.inter(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
                  ])),
                ]),
              ));
            })),
          ),
        ]),
      ),
    );
  }
}

// ── Zone de grattage — simplifiée (pas de texture/confettis) ────────────────
class _ScratchReveal extends StatelessWidget {
  final _Reward reward;
  final List<Offset> strokes;
  final bool revealing;
  final ValueChanged<DragUpdateDetails> onPanUpdate;
  final ValueChanged<Size> onSizeKnown;
  const _ScratchReveal({
    required this.reward, required this.strokes, required this.revealing,
    required this.onPanUpdate, required this.onSizeKnown,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(builder: (_, c) {
          onSizeKnown(Size(c.maxWidth, c.maxHeight));
          return Stack(children: [
            // Récompense en dessous — pop léger (scale + fade) une fois révélée
            Container(
              color: reward.bg,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.elasticOut,
                  scale: revealing ? 1.15 : 1.0,
                  child: Icon(reward.icon, size: 20, color: reward.color)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Récompense débloquée', style: GoogleFonts.inter(
                    fontSize: 9.5, fontWeight: FontWeight.w700, color: reward.color)),
                  Text(reward.title, style: GoogleFonts.outfit(
                    fontSize: 15, fontWeight: FontWeight.w800, color: reward.color)),
                ])),
              ]),
            ),
            // Voile à gratter — s'estompe pour laisser voir la récompense
            AnimatedOpacity(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              opacity: revealing ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: revealing,
                child: GestureDetector(
                  onPanUpdate: onPanUpdate,
                  child: RepaintBoundary(child: CustomPaint(
                    size: Size.infinite,
                    painter: _ScratchPainter(strokes: List.from(strokes)),
                  )),
                ),
              ),
            ),
            if (!revealing)
              IgnorePointer(child: Center(child: Row(
                mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.fingerprint, size: 15, color: Colors.white70),
                const SizedBox(width: 6),
                Text('Gratte pour révéler ta récompense', style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
              ]))),
          ]);
        }),
      ),
    );
  }
}

class _ScratchPainter extends CustomPainter {
  final List<Offset> strokes;
  const _ScratchPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = ui.Gradient.linear(
        Offset.zero, Offset(size.width, size.height),
        const [Color(0xFFB8B8B8), Color(0xFFD8D8D8), Color(0xFFA8A8A8)],
        const [0.0, 0.5, 1.0],
      ),
    );

    if (strokes.length > 1) {
      final clear = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = 34
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(strokes[0].dx, strokes[0].dy);
      for (var i = 1; i < strokes.length; i++) {
        path.lineTo(strokes[i].dx, strokes[i].dy);
      }
      canvas.drawPath(path, clear);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScratchPainter old) => old.strokes.length != strokes.length;
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARE SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _ShareSheet extends StatelessWidget {
  final String message;
  final AppL10n l10n;
  const _ShareSheet({required this.message, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(color: cs.outlineVariant,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(l10n.referralShareTitle,
          style: GoogleFonts.outfit(fontSize: 17,
            fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12)),
          child: Text(message,
            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant, height: 1.6))),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: message));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.referralCopied,
                style: GoogleFonts.inter(color: Colors.white,
                  fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF166534),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1C4D30),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                color: const Color(0xFF1C4D30).withValues(alpha: 0.25),
                blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.copy, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(l10n.referralCopyMsg,
                style: GoogleFonts.inter(color: Colors.white,
                  fontSize: 14, fontWeight: FontWeight.w700)),
            ])),
        ),
      ]),
    );
  }
}
