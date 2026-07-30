// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/storage_service.dart';

const _green = Color(0xFF1B5E3B);
const _mint  = Color(0xFF7ABB98);

class _Step {
  final Alignment spotAlign;
  final double spotW, spotH, spotDx, spotDy;
  final IconData icon;
  final Color color;
  final String title, body;

  const _Step({
    required this.spotAlign,
    this.spotW = 70, this.spotH = 70,
    this.spotDx = 0, this.spotDy = 0,
    required this.icon, required this.color,
    required this.title, required this.body,
  });

  bool get hasSpot => spotW > 0 && spotH > 0;
}

const _steps = <_Step>[
  _Step(
    spotAlign: Alignment.center, spotW: 0, spotH: 0,
    icon: LucideIcons.sparkles, color: _green,
    title: 'Bienvenue sur FitEva !',
    body: 'Laisse-nous te faire un petit tour de l\'app pour que tu puisses profiter de toutes les fonctionnalités.',
  ),
  _Step(
    spotAlign: Alignment.bottomLeft, spotW: 72, spotH: 64,
    spotDx: 10, spotDy: -16,
    icon: Icons.home_rounded, color: _green,
    title: 'Tableau de bord',
    body: 'Ton accueil avec tes stats du jour, tes objectifs et ta progression.',
  ),
  _Step(
    spotAlign: Alignment.bottomLeft, spotW: 72, spotH: 64,
    spotDx: 90, spotDy: -16,
    icon: LucideIcons.heart, color: Color(0xFFD46B8C),
    title: 'Suivi de cycle',
    body: 'Suis ton cycle menstruel et adapte ton entraînement à chaque phase.',
  ),
  _Step(
    spotAlign: Alignment.bottomCenter, spotW: 72, spotH: 64,
    spotDx: -38, spotDy: -16,
    icon: Icons.fitness_center_rounded, color: Color(0xFF4AADE8),
    title: 'Tes workouts',
    body: 'Salle, maison, danse, récupération… trouve le workout parfait pour toi.',
  ),
  _Step(
    spotAlign: Alignment.bottomRight, spotW: 72, spotH: 64,
    spotDx: -90, spotDy: -16,
    icon: Icons.restaurant_rounded, color: Color(0xFFE8A44A),
    title: 'Nutrition',
    body: 'Suis tes repas, scanne tes aliments et découvre des recettes adaptées.',
  ),
  _Step(
    spotAlign: Alignment.bottomRight, spotW: 64, spotH: 64,
    spotDx: -6, spotDy: -16,
    icon: LucideIcons.plus, color: _green,
    title: 'Menu rapide',
    body: 'Accède rapidement à la Boutique, la Communauté et la section Santé.',
  ),
  _Step(
    spotAlign: Alignment.centerRight, spotW: 80, spotH: 80,
    spotDx: -4, spotDy: 40,
    icon: LucideIcons.messageCircle, color: _mint,
    title: 'Coach IA',
    body: 'Ton assistant personnel 24/7 pour toutes tes questions santé et fitness.',
  ),
  _Step(
    spotAlign: Alignment.center, spotW: 0, spotH: 0,
    icon: LucideIcons.rocket, color: _green,
    title: 'C\'est parti !',
    body: 'Tu es prête à commencer ton parcours. FitEva t\'accompagne à chaque étape !',
  ),
];

class AppWalkthroughScreen extends StatefulWidget {
  const AppWalkthroughScreen({super.key});
  @override
  State<AppWalkthroughScreen> createState() => _AppWalkthroughScreenState();
}

class _AppWalkthroughScreenState extends State<AppWalkthroughScreen>
    with SingleTickerProviderStateMixin {
  int _page = 0;
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _next() {
    HapticFeedback.lightImpact();
    if (_page < _steps.length - 1) {
      _anim.reset();
      setState(() => _page++);
      _anim.forward();
    } else {
      _finish();
    }
  }

  void _prev() {
    if (_page > 0) {
      HapticFeedback.lightImpact();
      _anim.reset();
      setState(() => _page--);
      _anim.forward();
    }
  }

  void _finish() async {
    HapticFeedback.mediumImpact();
    await StorageService.setBool('walkthrough_completed', true);
    if (mounted) Navigator.of(context).pop();
  }

  Offset _spot(Size s, _Step st) {
    double x, y;
    switch (st.spotAlign) {
      case Alignment.bottomLeft:
        x = st.spotW / 2 + st.spotDx; y = s.height - st.spotH / 2 + st.spotDy;
      case Alignment.bottomCenter:
        x = s.width / 2 + st.spotDx; y = s.height - st.spotH / 2 + st.spotDy;
      case Alignment.bottomRight:
        x = s.width - st.spotW / 2 + st.spotDx; y = s.height - st.spotH / 2 + st.spotDy;
      case Alignment.centerRight:
        x = s.width - st.spotW / 2 + st.spotDx; y = s.height / 2 + st.spotDy;
      default:
        x = s.width / 2 + st.spotDx; y = s.height / 2 + st.spotDy;
    }
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final bot = MediaQuery.of(context).padding.bottom;
    final step = _steps[_page];
    final center = _spot(sz, step);
    final isLast = _page == _steps.length - 1;
    final isFirst = _page == 0;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final t = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic).value;

          return Stack(children: [
            // Overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(
                  center: center,
                  rx: step.hasSpot ? step.spotW / 2 + 14 : 0,
                  ry: step.hasSpot ? step.spotH / 2 + 14 : 0,
                  opacity: t * 0.9,
                ),
              ),
            ),

            // Tap to advance
            Positioned.fill(
              child: GestureDetector(onTap: _next, behavior: HitTestBehavior.translucent),
            ),

            // Pulse ring
            if (step.hasSpot)
              Positioned(
                left: center.dx - step.spotW / 2 - 18,
                top: center.dy - step.spotH / 2 - 18,
                child: Opacity(
                  opacity: t,
                  child: _Pulse(w: step.spotW + 36, h: step.spotH + 36, color: step.color),
                ),
              ),

            // Bottom glass card
            Positioned(
              left: 0, right: 0,
              bottom: 0,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 60),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, bot + 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                          border: Border(
                            top: BorderSide(color: Colors.white.withOpacity(0.6), width: 1),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 40, offset: const Offset(0, -10)),
                          ],
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          // Handle bar
                          Container(
                            width: 36, height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD0D8D3),
                              borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(height: 20),

                          // Icon + step label row
                          Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: step.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: step.color.withOpacity(0.15)),
                                ),
                                child: Icon(step.icon, size: 22, color: step.color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(step.title, style: GoogleFonts.outfit(
                                      fontSize: 20, fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                      letterSpacing: -0.3, height: 1.2)),
                                    const SizedBox(height: 2),
                                    Text('Étape ${_page + 1} sur ${_steps.length}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w500,
                                        color: step.color)),
                                  ],
                                ),
                              ),
                              // Skip X button
                              if (!isLast)
                                GestureDetector(
                                  onTap: _finish,
                                  child: Container(
                                    width: 34, height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFF0F2F1),
                                    ),
                                    child: const Icon(LucideIcons.x, size: 16,
                                      color: Color(0xFF8B9990)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Body
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(step.body, style: GoogleFonts.inter(
                              fontSize: 14.5, color: const Color(0xFF5A6B62),
                              height: 1.55, fontWeight: FontWeight.w400)),
                          ),
                          const SizedBox(height: 20),

                          // Progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: SizedBox(
                              height: 5,
                              child: Stack(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EDE9),
                                    borderRadius: BorderRadius.circular(3)),
                                ),
                                AnimatedFractionallySizedBox(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                  widthFactor: (_page + 1) / _steps.length,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [step.color, step.color.withOpacity(0.7)]),
                                      borderRadius: BorderRadius.circular(3)),
                                  ),
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Buttons
                          Row(children: [
                            // Back button
                            if (!isFirst)
                              GestureDetector(
                                onTap: _prev,
                                child: Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: const Color(0xFFF0F2F1),
                                    border: Border.all(color: const Color(0xFFE2E8E4)),
                                  ),
                                  child: const Icon(LucideIcons.chevronLeft, size: 18,
                                    color: Color(0xFF5A6B62)),
                                ),
                              ),
                            if (!isFirst) const SizedBox(width: 10),

                            // Next / Start button
                            Expanded(
                              child: GestureDetector(
                                onTap: _next,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [step.color, step.color.withOpacity(0.8)],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: step.color.withOpacity(0.3),
                                        blurRadius: 16, offset: const Offset(0, 6)),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isLast ? 'Commencer' : (isFirst ? 'C\'est parti' : 'Suivant'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 15, fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isLast ? LucideIcons.rocket : LucideIcons.arrowRight,
                                        size: 16, color: Colors.white.withOpacity(0.9)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ── Overlay painter ──────────────────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  final Offset center;
  final double rx, ry, opacity;
  _OverlayPainter({required this.center, required this.rx, required this.ry, required this.opacity});

  @override
  void paint(Canvas c, Size s) {
    final bg = Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height));
    if (rx > 0 && ry > 0) {
      final cut = Path()..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
        Radius.circular(rx.clamp(16, 40))));
      c.drawPath(Path.combine(PathOperation.difference, bg, cut),
        Paint()..color = const Color(0xFF0A0F0D).withOpacity(opacity));
    } else {
      c.drawPath(bg, Paint()..color = const Color(0xFF0A0F0D).withOpacity(opacity));
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter o) =>
    o.center != center || o.rx != rx || o.opacity != opacity;
}

// ── Pulse ring ───────────────────────────────────────────────────────────────

class _Pulse extends StatefulWidget {
  final double w, h;
  final Color color;
  const _Pulse({required this.w, required this.h, required this.color});
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final scale = 1.0 + _c.value * 0.28;
        final op = (1 - _c.value) * 0.4;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.w, height: widget.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.w.clamp(16, 40)),
              border: Border.all(color: widget.color.withOpacity(op), width: 2.5),
            ),
          ),
        );
      },
    );
  }
}
