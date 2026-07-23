// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../services/storage_service.dart';

const _main = Color(0xFF1C4D30);
const _sage = Color(0xFF7ABB98);

class _GuideStep {
  final Alignment spotlightAlign;
  final double spotW;
  final double spotH;
  final double spotDx;
  final double spotDy;
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final bool tooltipAbove;

  const _GuideStep({
    required this.spotlightAlign,
    this.spotW = 70,
    this.spotH = 70,
    this.spotDx = 0,
    this.spotDy = 0,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    this.tooltipAbove = true,
  });
}

final _steps = <_GuideStep>[
  // Step 0: Welcome overlay (no spotlight)
  const _GuideStep(
    spotlightAlign: Alignment.center,
    spotW: 0, spotH: 0,
    icon: LucideIcons.sparkles,
    accent: _sage,
    title: 'Bienvenue sur FitEva !',
    body: 'Laisse-nous te faire un petit tour de l\'app pour que tu puisses profiter de toutes les fonctionnalités.',
    tooltipAbove: true,
  ),
  // Step 1: Home tab (bottom-left)
  const _GuideStep(
    spotlightAlign: Alignment.bottomLeft,
    spotW: 72, spotH: 64,
    spotDx: 10, spotDy: -16,
    icon: Icons.home_rounded,
    accent: _main,
    title: 'Tableau de bord',
    body: 'Ton accueil avec tes stats du jour, tes objectifs et ta progression en un coup d\'œil.',
    tooltipAbove: true,
  ),
  // Step 2: Cycle tab
  const _GuideStep(
    spotlightAlign: Alignment.bottomLeft,
    spotW: 72, spotH: 64,
    spotDx: 90, spotDy: -16,
    icon: LucideIcons.heart,
    accent: Color(0xFFD46B8C),
    title: 'Suivi de cycle',
    body: 'Suis ton cycle menstruel et adapte ton entraînement et ta nutrition à chaque phase.',
    tooltipAbove: true,
  ),
  // Step 3: Workout tab
  const _GuideStep(
    spotlightAlign: Alignment.bottomCenter,
    spotW: 72, spotH: 64,
    spotDx: -38, spotDy: -16,
    icon: Icons.fitness_center_rounded,
    accent: Color(0xFF4AADE8),
    title: 'Entraînement',
    body: 'Des séances personnalisées selon ton niveau, tes objectifs et ta phase de cycle.',
    tooltipAbove: true,
  ),
  // Step 4: Nutrition tab
  const _GuideStep(
    spotlightAlign: Alignment.bottomRight,
    spotW: 72, spotH: 64,
    spotDx: -90, spotDy: -16,
    icon: Icons.restaurant_rounded,
    accent: Color(0xFFE8A44A),
    title: 'Nutrition',
    body: 'Suis tes repas, scanne tes aliments avec la caméra et découvre des recettes adaptées à tes objectifs.',
    tooltipAbove: true,
  ),
  // Step 5: Plus button
  const _GuideStep(
    spotlightAlign: Alignment.bottomRight,
    spotW: 64, spotH: 64,
    spotDx: -6, spotDy: -16,
    icon: LucideIcons.plus,
    accent: _main,
    title: 'Menu rapide',
    body: 'Appuie sur + pour accéder rapidement à la Boutique, la Communauté et la section Santé.',
    tooltipAbove: true,
  ),
  // Step 6: Chatbot
  const _GuideStep(
    spotlightAlign: Alignment.centerRight,
    spotW: 80, spotH: 80,
    spotDx: -4, spotDy: 40,
    icon: LucideIcons.messageCircle,
    accent: _sage,
    title: 'Coach IA',
    body: 'Ton assistant personnel disponible 24/7 pour répondre à toutes tes questions santé et fitness.',
    tooltipAbove: false,
  ),
  // Step 7: Final
  const _GuideStep(
    spotlightAlign: Alignment.center,
    spotW: 0, spotH: 0,
    icon: LucideIcons.rocket,
    accent: _main,
    title: 'C\'est parti !',
    body: 'Tu es prête à commencer ton parcours. FitEva t\'accompagne à chaque étape !',
    tooltipAbove: true,
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
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

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

  void _finish() async {
    HapticFeedback.mediumImpact();
    await StorageService.setBool('walkthrough_completed', true);
    if (mounted) Navigator.of(context).pop();
  }

  Offset _spotCenter(Size screenSize, _GuideStep step) {
    double x, y;
    switch (step.spotlightAlign) {
      case Alignment.bottomLeft:
        x = step.spotW / 2 + step.spotDx;
        y = screenSize.height - step.spotH / 2 + step.spotDy;
        break;
      case Alignment.bottomCenter:
        x = screenSize.width / 2 + step.spotDx;
        y = screenSize.height - step.spotH / 2 + step.spotDy;
        break;
      case Alignment.bottomRight:
        x = screenSize.width - step.spotW / 2 + step.spotDx;
        y = screenSize.height - step.spotH / 2 + step.spotDy;
        break;
      case Alignment.centerRight:
        x = screenSize.width - step.spotW / 2 + step.spotDx;
        y = screenSize.height / 2 + step.spotDy;
        break;
      case Alignment.center:
      default:
        x = screenSize.width / 2 + step.spotDx;
        y = screenSize.height / 2 + step.spotDy;
        break;
    }
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = _steps[_page];
    final center = _spotCenter(size, step);
    final hasSpotlight = step.spotW > 0 && step.spotH > 0;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final opacity = _anim.value;
          return Stack(
            children: [
              // Dark overlay with spotlight cutout
              Positioned.fill(
                child: CustomPaint(
                  painter: _SpotlightPainter(
                    center: center,
                    radiusX: hasSpotlight ? step.spotW / 2 + 12 : 0,
                    radiusY: hasSpotlight ? step.spotH / 2 + 12 : 0,
                    opacity: opacity * 0.82,
                  ),
                ),
              ),

              // Tap entire screen to advance
              Positioned.fill(
                child: GestureDetector(
                  onTap: _next,
                  behavior: HitTestBehavior.translucent,
                ),
              ),

              // Spotlight pulse ring
              if (hasSpotlight)
                Positioned(
                  left: center.dx - step.spotW / 2 - 16,
                  top: center.dy - step.spotH / 2 - 16,
                  child: Opacity(
                    opacity: opacity,
                    child: _PulseRing(
                      width: step.spotW + 32,
                      height: step.spotH + 32,
                      color: step.accent,
                    ),
                  ),
                ),

              // Tooltip card
              Positioned(
                left: 24,
                right: 24,
                top: hasSpotlight
                    ? (step.tooltipAbove
                        ? center.dy - step.spotH / 2 - 200
                        : center.dy + step.spotH / 2 + 24)
                    : size.height / 2 - 100,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.translate(
                    offset: Offset(0, (1 - opacity) * 20),
                    child: _TooltipCard(
                      step: step,
                      page: _page,
                      total: _steps.length,
                      onNext: _next,
                      onSkip: _finish,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radiusX;
  final double radiusY;
  final double opacity;

  _SpotlightPainter({
    required this.center,
    required this.radiusX,
    required this.radiusY,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (radiusX > 0 && radiusY > 0) {
      final cutout = Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: radiusX * 2, height: radiusY * 2),
          Radius.circular(radiusX.clamp(16, 40)),
        ));
      final combined = Path.combine(PathOperation.difference, overlay, cutout);
      canvas.drawPath(
        combined,
        Paint()..color = const Color(0xFF0A0F0D).withOpacity(opacity),
      );
    } else {
      canvas.drawPath(
        overlay,
        Paint()..color = const Color(0xFF0A0F0D).withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.center != center || old.radiusX != radiusX || old.opacity != opacity;
}

class _PulseRing extends StatefulWidget {
  final double width, height;
  final Color color;
  const _PulseRing({required this.width, required this.height, required this.color});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = 1.0 + _ctrl.value * 0.25;
        final opacity = (1 - _ctrl.value) * 0.4;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.width.clamp(16, 40)),
              border: Border.all(
                color: widget.color.withOpacity(opacity),
                width: 2.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TooltipCard extends StatelessWidget {
  final _GuideStep step;
  final int page;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TooltipCard({
    required this.step,
    required this.page,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  step.accent.withOpacity(0.15),
                  step.accent.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(step.icon, size: 26, color: step.accent),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Body
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7B73),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final active = i == page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? step.accent : const Color(0xFFE0E5E2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Buttons
          Row(
            children: [
              // Skip
              Expanded(
                child: GestureDetector(
                  onTap: onSkip,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Passer',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7B73),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onNext,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [step.accent, step.accent.withOpacity(0.85)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: step.accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        page == total - 1 ? 'Commencer !' : 'Suivant',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
