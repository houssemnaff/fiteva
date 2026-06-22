import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

// ── Providers ─────────────────────────────────────────────────────────────────
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
    final suffix =
        List.generate(4, (_) => chars[rng.nextInt(chars.length)]).join();
    final code = 'FITEVA-$suffix';
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

// ── Reward tiers ──────────────────────────────────────────────────────────────
class _Reward {
  final int threshold;
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  const _Reward({
    required this.threshold,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

const _rewards = [
  _Reward(
    threshold: 1,
    emoji: '⭐',
    title: '+50 Points',
    subtitle: 'Bonus immédiat sur ton compte',
    gradient: [Color(0xFF2E7D52), Color(0xFF4CAF50)],
  ),
  _Reward(
    threshold: 3,
    emoji: '🔥',
    title: 'Premium Day',
    subtitle: 'Accès illimité pendant 24h',
    gradient: [Color(0xFFE65100), Color(0xFFFF6B35)],
  ),
  _Reward(
    threshold: 5,
    emoji: '🏆',
    title: 'Badge Exclusif',
    subtitle: 'Visible sur ton profil',
    gradient: [Color(0xFF8B6914), Color(0xFFD4A853)],
  ),
];

// Mock friends
const _mockFriends = [
  (name: 'Sara B.', avatar: '👩', joined: true),
  (name: 'Ahmed K.', avatar: '🧑', joined: true),
  (name: 'Nour M.', avatar: '👩‍🦱', joined: false),
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
  // Which tiles have been fully revealed (confetti shown)
  final Set<int> _revealed = {};
  // Confetti
  List<_Particle> _particles = [];
  bool _showConfetti = false;
  late AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _confettiCtrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        setState(() => _showConfetti = false);
      }
    });
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _onScratchComplete(int index) {
    if (_revealed.contains(index)) return;
    setState(() => _revealed.add(index));
    HapticFeedback.heavyImpact();
    _launchConfetti();
  }

  void _launchConfetti() {
    final rng = Random();
    setState(() {
      _showConfetti = true;
      _particles = List.generate(50, (_) => _Particle(
        x: 0.2 + rng.nextDouble() * 0.6,
        y: 0.1 + rng.nextDouble() * 0.4,
        color: [
          const Color(0xFFD4A853), const Color(0xFF4CAF50),
          const Color(0xFFFF6B35), Colors.white, const Color(0xFF64B5F6),
          const Color(0xFFE040FB),
        ][rng.nextInt(6)],
        size: 5 + rng.nextDouble() * 7,
        angle: rng.nextDouble() * 2 * pi,
        speed: 0.5 + rng.nextDouble() * 0.5,
      ));
    });
    _confettiCtrl
      ..reset()
      ..forward();
  }

  void _copyCode(BuildContext context, String code, AppL10n l10n) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(LucideIcons.checkCircle, color: Colors.white, size: 15),
        const SizedBox(width: 8),
        Text(l10n.referralCodeCopied(code),
            style: GoogleFonts.inter(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: const Color(0xFF1C4D30),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _shareCode(BuildContext context, String code, AppL10n l10n) {
    final msg = 'Rejoins-moi sur FitEva ! 🏋️‍♀️\n'
        'Utilise mon code $code à l\'inscription '
        'et on gagne toutes les deux des points 💪\n'
        'fiteva.app/invite/$code';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(code: code, message: msg, l10n: l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final codeAsync  = ref.watch(referralCodeProvider);
    final countAsync = ref.watch(referralCountProvider);
    final count = countAsync.asData?.value ?? 0;
    final dark  = Theme.of(context).brightness == Brightness.dark;

    // Next milestone
    final nextReward = _rewards.firstWhere(
      (r) => count < r.threshold,
      orElse: () => _rewards.last,
    );
    final nextPct = (count / nextReward.threshold).clamp(0.0, 1.0);
    final isMaxed = count >= _rewards.last.threshold;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header ───────────────────────────────────────────────────
            _SectionHeader(l10n: l10n),
            const SizedBox(height: 16),

            // ── Scratch cards row ─────────────────────────────────────────
            Row(
              children: List.generate(_rewards.length, (i) {
                final r = _rewards[i];
                final unlocked = count >= r.threshold;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i < _rewards.length - 1 ? 10 : 0),
                    child: ScratchCardTile(
                      reward: r,
                      unlocked: unlocked,
                      onComplete: () => _onScratchComplete(i),
                      l10n: l10n,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ── Progress ──────────────────────────────────────────────────
            _ProgressBlock(
              count: count,
              dark: dark,
              pct: nextPct,
              isMaxed: isMaxed,
              nextThreshold: nextReward.threshold,
              l10n: l10n,
            ),

            const SizedBox(height: 20),

            // ── Code block ────────────────────────────────────────────────
            codeAsync.when(
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox(),
              data: (code) => _CodeBlock(
                code: code,
                dark: dark,
                onCopy: () => _copyCode(context, code, l10n),
                onShare: () => _shareCode(context, code, l10n),
                l10n: l10n,
              ),
            ),

            const SizedBox(height: 20),

            // ── Friends ───────────────────────────────────────────────────
            _FriendsList(count: count, dark: dark, l10n: l10n),
          ]),

          // ── Confetti ──────────────────────────────────────────────────────
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _ConfettiPainter(
                        particles: _particles,
                        progress: _confettiCtrl.value),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// REAL SCRATCH CARD TILE
// ══════════════════════════════════════════════════════════════════════════════
class ScratchCardTile extends StatefulWidget {
  final _Reward reward;
  final bool unlocked;
  final VoidCallback onComplete;
  final AppL10n l10n;

  const ScratchCardTile({
    super.key,
    required this.reward,
    required this.unlocked,
    required this.onComplete,
    required this.l10n,
  });

  @override
  State<ScratchCardTile> createState() => _ScratchCardTileState();
}

class _ScratchCardTileState extends State<ScratchCardTile> {
  // Grid-based scratch tracking: 12×16 cells
  static const _cols = 12;
  static const _rows = 16;
  static const _totalCells = _cols * _rows;
  static const _completeThreshold = 0.60;

  final Set<int> _scratchedCells = {};
  final List<Offset> _points = [];
  bool _completed = false;
  Size _cardSize = Size.zero;

  bool get _scratchPercent =>
      _scratchedCells.length / _totalCells >= _completeThreshold;

  void _onPanUpdate(DragUpdateDetails d) {
    if (!widget.unlocked || _completed) return;
    final pos = d.localPosition;
    if (pos.dx < 0 || pos.dy < 0 ||
        pos.dx > _cardSize.width || pos.dy > _cardSize.height) return;

    // Track visual points
    setState(() => _points.add(pos));

    // Track grid cells
    final col = (pos.dx / _cardSize.width * _cols).floor().clamp(0, _cols - 1);
    final row = (pos.dy / _cardSize.height * _rows).floor().clamp(0, _rows - 1);
    final cell = row * _cols + col;
    // Also scratch neighbouring cells for smoother feel
    for (int dc = -1; dc <= 1; dc++) {
      for (int dr = -1; dr <= 1; dr++) {
        final nc = (col + dc).clamp(0, _cols - 1);
        final nr = (row + dr).clamp(0, _rows - 1);
        _scratchedCells.add(nr * _cols + nc);
      }
    }

    HapticFeedback.selectionClick();

    if (!_completed && _scratchPercent) {
      setState(() => _completed = true);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.62,
      child: LayoutBuilder(builder: (_, constraints) {
        _cardSize = Size(constraints.maxWidth, constraints.maxHeight);
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(children: [
            // ── Revealed layer (reward) ─────────────────────────────────
            _RewardLayer(reward: widget.reward, unlocked: widget.unlocked),

            // ── Scratch overlay ─────────────────────────────────────────
            if (!_completed)
              GestureDetector(
                onPanUpdate: _onPanUpdate,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: _cardSize,
                    painter: _ScratchPainter(
                      points: List.from(_points),
                      unlocked: widget.unlocked,
                    ),
                  ),
                ),
              ),

            // ── "Gratte ici" hint when not started ─────────────────────
            if (_points.isEmpty && !_completed && widget.unlocked)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(children: [
                          const Icon(LucideIcons.fingerprint,
                              color: Colors.white54, size: 22),
                          const SizedBox(height: 4),
                          Text(widget.l10n.referralScratch,
                              style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Lock overlay when not unlocked ──────────────────────────
            if (!widget.unlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                  ),
                  child: const Center(
                    child: Icon(LucideIcons.lock,
                        color: Colors.white54, size: 22),
                  ),
                ),
              ),
          ]),
        );
      }),
    );
  }
}

// ── Reward layer (behind the scratch) ────────────────────────────────────────
class _RewardLayer extends StatelessWidget {
  final _Reward reward;
  final bool unlocked;
  const _RewardLayer({required this.reward, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reward.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(reward.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(reward.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(reward.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    height: 1.4)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${reward.threshold} amie${reward.threshold > 1 ? 's' : ''}',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scratch painter ───────────────────────────────────────────────────────────
class _ScratchPainter extends CustomPainter {
  final List<Offset> points;
  final bool unlocked;
  _ScratchPainter({required this.points, required this.unlocked});

  @override
  void paint(Canvas canvas, Size size) {
    // Save layer so BlendMode.clear works
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // ── Silver lottery card background ───────────────────────────────────
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        const [
          Color(0xFF9E9E9E),
          Color(0xFFBDBDBD),
          Color(0xFF757575),
          Color(0xFFBDBDBD),
          Color(0xFF9E9E9E),
        ],
        [0.0, 0.25, 0.5, 0.75, 1.0],
      );
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ── Diagonal hatch pattern (lottery feel) ──────────────────────────
    final hatchPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const spacing = 10.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
          Offset(i, 0), Offset(i + size.height, size.height), hatchPaint);
    }

    // ── FitEva branding text ──────────────────────────────────────────
    final tp = TextPainter(
      text: TextSpan(
        text: 'FitEva',
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.18),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    // Tile the branding
    for (double y = 14; y < size.height; y += 32) {
      for (double x = 4; x < size.width; x += 52) {
        tp.paint(canvas, Offset(x, y));
      }
    }

    // ── Star pattern ─────────────────────────────────────────────────
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final rng = Random(42); // fixed seed for consistent pattern
    for (int i = 0; i < 12; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        1.5 + rng.nextDouble() * 2,
        starPaint,
      );
    }

    // ── Scratch holes (BlendMode.clear) ──────────────────────────────
    if (points.isNotEmpty) {
      final clearPaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final clearFill = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;

      // Draw connected path for smooth scratch
      if (points.length > 1) {
        final path = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i < points.length; i++) {
          // Smooth quadratic bezier
          if (i < points.length - 1) {
            final midX = (points[i].dx + points[i + 1].dx) / 2;
            final midY = (points[i].dy + points[i + 1].dy) / 2;
            path.quadraticBezierTo(
                points[i].dx, points[i].dy, midX, midY);
          } else {
            path.lineTo(points[i].dx, points[i].dy);
          }
        }
        canvas.drawPath(path, clearPaint);
      }

      // Dots at each point for precise reveal
      for (final pt in points) {
        canvas.drawCircle(pt, 14, clearFill);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScratchPainter old) =>
      old.points.length != points.length;
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final AppL10n l10n;
  const _SectionHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C4D30), Color(0xFF2E7D52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1C4D30).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A853),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l10n.referralTitle,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3)),
            ),
            const SizedBox(height: 8),
            Text(l10n.referralHeadline,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.2)),
            const SizedBox(height: 6),
            Text(l10n.referralHint,
                style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12)),
          ]),
        ),
        const SizedBox(width: 12),
        const Text('🎴', style: TextStyle(fontSize: 44)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PROGRESS BLOCK
// ══════════════════════════════════════════════════════════════════════════════
class _ProgressBlock extends StatelessWidget {
  final int count;
  final bool dark;
  final double pct;
  final bool isMaxed;
  final int nextThreshold;
  final AppL10n l10n;
  const _ProgressBlock({
    required this.count,
    required this.dark,
    required this.pct,
    required this.isMaxed,
    required this.nextThreshold,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final needed = (nextThreshold - count).clamp(0, 99);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF1C4D30).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Row(children: [
          const Icon(LucideIcons.flame, size: 15, color: Color(0xFF1C4D30)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              isMaxed
                  ? l10n.referralAllUnlocked
                  : l10n.referralNeedMore(needed),
              style: GoogleFonts.inter(
                  color: const Color(0xFF1C4D30),
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Text('$count / $nextThreshold',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF1C4D30),
                  fontSize: 13,
                  fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 10),
        _GlowBar(pct: pct),
      ]),
    );
  }
}

class _GlowBar extends StatefulWidget {
  final double pct;
  const _GlowBar({required this.pct});

  @override
  State<_GlowBar> createState() => _GlowBarState();
}

class _GlowBarState extends State<_GlowBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final glow = 0.20 + _anim.value * 0.50;
        return Container(
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1C4D30).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(builder: (_, c) => Stack(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: c.maxWidth * widget.pct,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1C4D30), Color(0xFF4CAF50)]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: glow),
                      blurRadius: 8,
                      spreadRadius: 1)
                ],
              ),
            ),
          ])),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CODE BLOCK
// ══════════════════════════════════════════════════════════════════════════════
class _CodeBlock extends StatelessWidget {
  final String code;
  final bool dark;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final AppL10n l10n;
  const _CodeBlock(
      {required this.code,
      required this.dark,
      required this.onCopy,
      required this.onShare,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF1C4D30).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.referralCodeLabel,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF1C4D30),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5)),
              const SizedBox(height: 5),
              Text(code,
                  style: GoogleFonts.outfit(
                      color: dark ? Colors.white : const Color(0xFF111111),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0)),
            ]),
          ),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C4D30).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.copy,
                  color: Color(0xFF1C4D30), size: 18),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onShare,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1C4D30), Color(0xFF2E7D52)]),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1C4D30).withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(LucideIcons.share2, color: Colors.white, size: 15),
              const SizedBox(width: 8),
              Text(l10n.referralShare,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FRIENDS LIST
// ══════════════════════════════════════════════════════════════════════════════
class _FriendsList extends StatelessWidget {
  final int count;
  final bool dark;
  final AppL10n l10n;
  const _FriendsList({required this.count, required this.dark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final friends = _mockFriends.take(count + 1).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: const Color(0xFF1C4D30).withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(children: [
        Row(children: [
          const Icon(LucideIcons.users, size: 14, color: Color(0xFF1C4D30)),
          const SizedBox(width: 7),
          Text(l10n.referralFriends,
              style: GoogleFonts.inter(
                  color: const Color(0xFF1C4D30),
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('$count inscrite${count > 1 ? 's' : ''}',
              style: GoogleFonts.outfit(
                  color: const Color(0xFF1C4D30),
                  fontSize: 12,
                  fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 14),
        ...friends.asMap().entries.map((e) {
          final f = e.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: e.key < friends.length - 1 ? 10 : 0),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: f.joined
                      ? const Color(0xFF1C4D30).withValues(alpha: 0.10)
                      : (dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFEEEEEE)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child:
                        Text(f.avatar, style: const TextStyle(fontSize: 18))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(f.name,
                      style: GoogleFonts.inter(
                          color: dark ? Colors.white : const Color(0xFF111111),
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  Text(f.joined ? l10n.referralRegistered : l10n.referralPending,
                      style: GoogleFonts.inter(
                          color: f.joined
                              ? const Color(0xFF4CAF50)
                              : (dark ? Colors.white38 : Colors.black38),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
              if (f.joined)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('+50 pts',
                      style: GoogleFonts.inter(
                          color: const Color(0xFF4CAF50),
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(l10n.referralPending,
                      style: GoogleFonts.inter(
                          color: dark ? Colors.white38 : Colors.black38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONFETTI
// ══════════════════════════════════════════════════════════════════════════════
class _Particle {
  final double x, y, size, angle, speed;
  final Color color;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
    required this.speed,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final opacity = (1.0 - progress * 0.9).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      final dx = p.x * size.width +
          cos(p.angle) * p.speed * progress * size.width * 0.5;
      final dy = p.y * size.height +
          sin(p.angle) * p.speed * progress * size.height * 0.5 +
          progress * progress * size.height * 0.35;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.angle + progress * 5);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: Offset.zero, width: p.size, height: p.size * 0.55),
              const Radius.circular(2)),
          paint);
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
  final String code;
  final String message;
  final AppL10n l10n;
  const _ShareSheet({required this.code, required this.message, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF1A1A1A) : Colors.white;
    final t1 = dark ? Colors.white : const Color(0xFF111111);
    final t2 = dark ? Colors.white54 : const Color(0xFF666666);

    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        Text(l10n.referralShareTitle,
            style: GoogleFonts.outfit(
                fontSize: 18, fontWeight: FontWeight.w800, color: t1)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF242424)
                  : const Color(0xFFF5F5F3),
              borderRadius: BorderRadius.circular(16)),
          child: Text(message,
              style:
                  GoogleFonts.inter(fontSize: 13, color: t2, height: 1.65)),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: message));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                const Icon(LucideIcons.checkCircle,
                    color: Colors.white, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      l10n.referralCopied,
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              backgroundColor: const Color(0xFF1C4D30),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1C4D30), Color(0xFF2E7D52)]),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1C4D30).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Icon(LucideIcons.copy, color: Colors.white, size: 15),
              const SizedBox(width: 8),
              Text(l10n.referralCopyMsg,
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ]),
    );
  }
}
