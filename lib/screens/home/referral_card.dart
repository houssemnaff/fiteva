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

// ── Reward model ───────────────────────────────────────────────────────────────
class _Reward {
  final int     need;
  final IconData icon;
  final String  title;
  final String  sub;
  final Color   color;
  const _Reward({required this.need, required this.icon,
    required this.title, required this.sub, required this.color});
}

const _rewards = [
  _Reward(need: 1, icon: LucideIcons.star,   title: '+50 Points',    sub: 'Bonus immédiat sur ton compte', color: Color(0xFF22C55E)),
  _Reward(need: 3, icon: LucideIcons.flame,  title: 'Premium 24h',   sub: 'Accès illimité pendant 24h',    color: Color(0xFFFF6B35)),
  _Reward(need: 5, icon: LucideIcons.trophy, title: 'Badge Exclusif', sub: 'Visible sur ton profil',         color: Color(0xFFF59E0B)),
];

const _mockFriends = [
  (name: 'Sara B.',  initial: 'S', joined: true),
  (name: 'Ahmed K.', initial: 'A', joined: true),
  (name: 'Nour M.',  initial: 'N', joined: false),
];

// ══════════════════════════════════════════════════════════════════════════════
// MAIN WIDGET
// ══════════════════════════════════════════════════════════════════════════════
class ReferralCard extends ConsumerStatefulWidget {
  const ReferralCard({super.key});
  @override
  ConsumerState<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends ConsumerState<ReferralCard>
    with TickerProviderStateMixin {

  int              _selected  = 0;
  // Per-reward scratch strokes + completion
  final List<List<Offset>> _strokes = [[], [], []];
  final List<bool>         _done    = [false, false, false];
  Size                     _cardSize = Size.zero;

  // Confetti
  late AnimationController _confCtrl;
  List<_Confetti>          _confetti = [];
  bool                     _showConf = false;

  @override
  void initState() {
    super.initState();
    _confCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _confCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted)
        setState(() => _showConf = false);
    });
  }

  @override
  void dispose() {
    _confCtrl.dispose();
    super.dispose();
  }

  // ── Scratch logic ─────────────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails d, int count) {
    final i = _selected;
    if (_done[i] || count < _rewards[i].need) return;
    final pos = d.localPosition;
    if (pos.dx < 0 || pos.dy < 0 ||
        pos.dx > _cardSize.width || pos.dy > _cardSize.height) return;

    setState(() => _strokes[i].add(pos));
    HapticFeedback.selectionClick();

    // Complete when ~65% covered (approx by stroke count + spread)
    if (_strokes[i].length > 100 && !_done[i]) {
      setState(() => _done[i] = true);
      _launchConfetti();
    }
  }

  void _launchConfetti() {
    final rng = Random();
    setState(() {
      _showConf = true;
      _confetti = List.generate(55, (_) => _Confetti(
        x:     0.05 + rng.nextDouble() * 0.9,
        y:     0.0  + rng.nextDouble() * 0.3,
        color: [
          const Color(0xFF22C55E), const Color(0xFFF59E0B),
          const Color(0xFFFF6B35), Colors.white,
          const Color(0xFF818CF8), const Color(0xFFF472B6),
        ][rng.nextInt(6)],
        size:  4 + rng.nextDouble() * 6,
        angle: rng.nextDouble() * 2 * pi,
        speed: 0.4 + rng.nextDouble() * 0.6,
      ));
    });
    _confCtrl..reset()..forward();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
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
      builder: (_) => _ShareSheet(
        message: msg, l10n: l10n,
        surf: Theme.of(ctx).brightness == Brightness.dark
            ? const Color(0xFF1A1A1A) : Colors.white,
        ink: Theme.of(ctx).brightness == Brightness.dark
            ? const Color(0xFFF0F0EE) : const Color(0xFF111110),
        muted: Theme.of(ctx).brightness == Brightness.dark
            ? const Color(0xFF888886) : const Color(0xFF6B6B68),
        div: Theme.of(ctx).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n       = ref.watch(l10nProvider);
    final codeAsync  = ref.watch(referralCodeProvider);
    final countAsync = ref.watch(referralCountProvider);
    final count      = countAsync.asData?.value ?? 0;
    final dark       = Theme.of(context).brightness == Brightness.dark;

    final surf  = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final ink   = dark ? const Color(0xFFF0F0EE) : const Color(0xFF111110);
    final muted = dark ? const Color(0xFF888886) : const Color(0xFF6B6B68);
    final div   = dark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0EE);
    final green = const Color(0xFF22C55E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Stack(clipBehavior: Clip.none, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Header ───────────────────────────────────────────────────────
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.referralHeadline,
                  style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800,
                    color: ink, letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text(l10n.referralHint,
                  style: GoogleFonts.inter(fontSize: 12, color: muted)),
              ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(LucideIcons.users, size: 12, color: green),
                const SizedBox(width: 5),
                Text('$count invitée${count != 1 ? 's' : ''}',
                  style: GoogleFonts.inter(fontSize: 12,
                    fontWeight: FontWeight.w700, color: green)),
              ]),
            ),
          ]),

          const SizedBox(height: 18),

          // ── Reward selector tabs ─────────────────────────────────────────
          Row(children: List.generate(3, (i) {
            final r        = _rewards[i];
            final unlocked = count >= r.need;
            final active   = _selected == i;
            return Expanded(child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: active && unlocked
                        ? r.color.withValues(alpha: 0.12)
                        : active
                            ? (dark ? const Color(0xFF222222) : const Color(0xFFF6F7F5))
                            : (dark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0EE)),
                    borderRadius: BorderRadius.circular(12),
                    border: active
                        ? Border.all(
                            color: unlocked
                                ? r.color.withValues(alpha: 0.35)
                                : (dark ? const Color(0xFF3A3A3A) : const Color(0xFFDDDDDB)),
                            width: 1.2)
                        : null,
                  ),
                  child: Column(children: [
                    Icon(
                      _done[i] ? LucideIcons.checkCircle2 : (unlocked ? r.icon : LucideIcons.lock),
                      size: 16,
                      color: active && unlocked ? r.color : muted),
                    const SizedBox(height: 4),
                    Text('${r.need} ami${r.need > 1 ? 'es' : 'e'}',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700,
                        color: active && unlocked ? r.color : muted)),
                  ]),
                ),
              ),
            ));
          })),

          const SizedBox(height: 12),

          // ── Scratch card ──────────────────────────────────────────────────
          _buildScratchCard(count, dark, muted),

          const SizedBox(height: 16),

          // ── Code ─────────────────────────────────────────────────────────
          codeAsync.when(
            loading: () => const SizedBox(height: 60),
            error:   (_, __) => const SizedBox(),
            data: (code) => Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              decoration: BoxDecoration(
                color: surf,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.15 : 0.04),
                  blurRadius: 8, offset: const Offset(0, 2))]),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                 
                    const SizedBox(height: 4),
                    Text(code,
                      style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w900,
                        color: ink, letterSpacing: 1.5)),
                  ])),
            
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _share(context, code, l10n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                        color: green.withValues(alpha: 0.25),
                        blurRadius: 8, offset: const Offset(0, 3))]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.share2, color: Colors.white, size: 13),
                      const SizedBox(width: 6),
                      Text(l10n.referralShare,
                        style: GoogleFonts.inter(color: Colors.white,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                    ]))),
              ]),
            ),
          ),

          const SizedBox(height: 14),

          // ── Friends ───────────────────────────────────────────────────────
         
        ]),

        // ── Confetti layer ─────────────────────────────────────────────────
        if (_showConf)
          Positioned.fill(child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(
                  particles: _confetti,
                  progress: _confCtrl.value)),
            ),
          )),
      ]),
    );
  }

  // ── Scratch card widget ───────────────────────────────────────────────────
  Widget _buildScratchCard(int count, bool dark, Color muted) {
    final i        = _selected;
    final r        = _rewards[i];
    final unlocked = count >= r.need;

    return AspectRatio(
      aspectRatio: 2.2,
      child: LayoutBuilder(builder: (_, c) {
        _cardSize = Size(c.maxWidth, c.maxHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [

            // ── LAYER 1 — Reward revealed (always underneath) ────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: double.infinity,
              color: dark
                  ? r.color.withValues(alpha: 0.15)
                  : r.color.withValues(alpha: 0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: r.color.withValues(alpha: 0.18),
                      shape: BoxShape.circle),
                    child: Icon(r.icon, size: 26, color: r.color)),
                  const SizedBox(width: 18),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Récompense',
                        style: GoogleFonts.inter(fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: r.color, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Text(r.title,
                        style: GoogleFonts.outfit(fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: dark ? Colors.white : const Color(0xFF111110),
                          letterSpacing: -0.4)),
                      const SizedBox(height: 3),
                      Text(r.sub,
                        style: GoogleFonts.inter(fontSize: 11,
                          color: muted)),
                    ])),
                ]),
              ),
            ),

            // ── LAYER 2 — Silver foil (scratched away) ───────────────────
            if (!_done[i])
              GestureDetector(
                onPanUpdate: unlocked ? (d) => _onPanUpdate(d, count) : null,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: _cardSize,
                    painter: _FoilPainter(
                      strokes: List.from(_strokes[i]),
                      locked: !unlocked,
                    ),
                  ),
                ),
              ),

            // ── LAYER 3 — "Scratch here" hint ───────────────────────────
            if (unlocked && !_done[i] && _strokes[i].isEmpty)
              Positioned(bottom: 14, left: 0, right: 0,
                child: IgnorePointer(child: Column(children: [
                  Icon(LucideIcons.fingerprint,
                    color: Colors.white.withValues(alpha: 0.45), size: 20),
                  const SizedBox(height: 3),
                  Text('Gratte pour révéler',
                    style: GoogleFonts.inter(fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.45))),
                ]))),

            // ── LAYER 4 — Lock label when not unlocked ───────────────────
            if (!unlocked && !_done[i])
              Positioned(bottom: 14, left: 0, right: 0,
                child: IgnorePointer(child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.lock,
                      size: 11, color: Colors.white.withValues(alpha: 0.45)),
                    const SizedBox(width: 5),
                    Text(
                      '${r.need} amie${r.need > 1 ? 's' : ''} pour débloquer',
                      style: GoogleFonts.inter(fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.45))),
                  ]))),

            // ── LAYER 5 — "Reward revealed" badge after scratch ──────────
            if (_done[i])
              Positioned(top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: r.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: r.color.withValues(alpha: 0.35),
                      blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('Débloqué !',
                      style: GoogleFonts.inter(fontSize: 10,
                        fontWeight: FontWeight.w800, color: Colors.white)),
                  ]))),
          ]),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SILVER FOIL PAINTER
// ══════════════════════════════════════════════════════════════════════════════
class _FoilPainter extends CustomPainter {
  final List<Offset> strokes;
  final bool         locked;
  const _FoilPainter({required this.strokes, required this.locked});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Silver gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = ui.Gradient.linear(
        Offset.zero, Offset(size.width, size.height),
        const [
          Color(0xFFBBBBBB), Color(0xFFD4D4D4),
          Color(0xFFA8A8A8), Color(0xFFCCCCCC),
          Color(0xFFB8B8B8),
        ], [0.0, 0.25, 0.5, 0.75, 1.0],
      ),
    );

    // Diagonal hatch (lottery texture)
    final hatch = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.2;
    for (double x = -size.height; x < size.width + size.height; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), hatch);
    }

    // Subtle "FitEva" watermark
    final tp = TextPainter(
      text: TextSpan(
        text: 'FitEva',
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.14),
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    for (double y = 12; y < size.height; y += 30) {
      for (double x = 4; x < size.width; x += 58) {
        tp.paint(canvas, Offset(x, y));
      }
    }

    // Scratch erasure with BlendMode.clear
    if (!locked && strokes.length > 1) {
      final clear = Paint()
        ..blendMode = BlendMode.clear
        ..style     = PaintingStyle.stroke
        ..strokeWidth = 38
        ..strokeCap  = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(strokes[0].dx, strokes[0].dy);
      for (int i = 1; i < strokes.length; i++) {
        if (i < strokes.length - 1) {
          final mx = (strokes[i].dx + strokes[i + 1].dx) / 2;
          final my = (strokes[i].dy + strokes[i + 1].dy) / 2;
          path.quadraticBezierTo(strokes[i].dx, strokes[i].dy, mx, my);
        } else {
          path.lineTo(strokes[i].dx, strokes[i].dy);
        }
      }
      canvas.drawPath(path, clear);

      for (final p in strokes) {
        canvas.drawCircle(p, 19, Paint()..blendMode = BlendMode.clear);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_FoilPainter old) =>
      old.strokes.length != strokes.length;
}

// ══════════════════════════════════════════════════════════════════════════════
// CONFETTI
// ══════════════════════════════════════════════════════════════════════════════
class _Confetti {
  final double x, y, size, angle, speed;
  final Color  color;
  const _Confetti({required this.x, required this.y, required this.size,
    required this.angle, required this.speed, required this.color});
}

class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> particles;
  final double          progress;
  const _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (1.0 - progress * 0.85).clamp(0.0, 1.0);
      final dx = p.x * size.width +
          cos(p.angle) * p.speed * progress * size.width * 0.45;
      final dy = p.y * size.height +
          sin(p.angle) * p.speed * progress * size.height * 0.35 +
          progress * progress * size.height * 0.45;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.angle + progress * 7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(1.5)),
        Paint()..color = p.color.withValues(alpha: opacity));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARE SHEET
// ══════════════════════════════════════════════════════════════════════════════
class _ShareSheet extends StatelessWidget {
  final String message;
  final AppL10n l10n;
  final Color surf, ink, muted, div;
  const _ShareSheet({required this.message, required this.l10n,
    required this.surf, required this.ink,
    required this.muted, required this.div});

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF22C55E);
    return Container(
      padding: EdgeInsets.fromLTRB(
        24, 20, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4,
          decoration: BoxDecoration(color: div,
            borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(l10n.referralShareTitle,
          style: GoogleFonts.outfit(fontSize: 17,
            fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: div,
            borderRadius: BorderRadius.circular(12)),
          child: Text(message,
            style: GoogleFonts.inter(fontSize: 13, color: muted, height: 1.6))),
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
              color: green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(
                color: green.withValues(alpha: 0.25),
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
