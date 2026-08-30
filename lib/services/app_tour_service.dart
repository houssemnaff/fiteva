// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const _mascotUrl =
    'https://res.cloudinary.com/dmzvbqocs/image/upload/v1785371674/preview-removebg-preview_i39b7w.png';
const _green = Color(0xFF1B5E3B);

class GuidedTourStep {
  final int tabIndex;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const GuidedTourStep({
    required this.tabIndex,
    required this.title,
    required this.description,
    required this.icon,
    this.color = _green,
  });
}

class AppTourService {
  static const _key = 'guided_tour_completed';

  static Future<bool> shouldShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markTourDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ── Per-section tutorials ──

  static String _sectionKey(String section) => 'section_tour_$section';

  static Future<bool> shouldShowSectionTour(String section) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_sectionKey(section)) ?? false);
  }

  static Future<void> markSectionTourDone(String section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sectionKey(section), true);
  }

  static Future<void> resetSectionTour(String section) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sectionKey(section));
  }

  static Future<void> resetAllSectionTours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('section_tour_'));
    for (final k in keys) { await prefs.remove(k); }
  }

  static void showSectionTutorial(BuildContext context, {
    required String section,
    required List<SpotlightStep> steps,
  }) async {
    if (!await shouldShowSectionTour(section)) return;
    if (!context.mounted) return;

    final targets = <TargetFocus>[];
    for (int i = 0; i < steps.length; i++) {
      final s = steps[i];
      targets.add(TargetFocus(
        identify: '${section}_$i',
        keyTarget: s.key,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        enableTargetTab: true,
        shape: s.shape,
        radius: s.spotlightRadius,
        paddingFocus: s.spotlightPadding,
        contents: [
          TargetContent(
            align: s.contentAlign,
            builder: (ctx, ctrl) => _SpotlightCard(
              title: s.title,
              description: s.description,
              icon: s.icon,
              color: s.color,
              stepIndex: i,
              totalSteps: steps.length,
            ),
          ),
        ],
      ));
    }

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF1A1A1A),
      opacityShadow: 0.75,
      textSkip: '',
      hideSkip: true,
      onFinish: () => markSectionTourDone(section),
      onSkip: () { markSectionTourDone(section); return true; },
    )..show(context: context);
  }
}

class SpotlightStep {
  final GlobalKey key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final ContentAlign contentAlign;
  final ShapeLightFocus shape;
  final double spotlightRadius;
  final double spotlightPadding;

  const SpotlightStep({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    this.color = _green,
    this.contentAlign = ContentAlign.bottom,
    this.shape = ShapeLightFocus.RRect,
    this.spotlightRadius = 16,
    this.spotlightPadding = 8,
  });
}

class _SpotlightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int stepIndex;
  final int totalSteps;

  const _SpotlightCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.stepIndex,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = stepIndex == totalSteps - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A1A), height: 1.2)),
                    const SizedBox(height: 2),
                    Text('${stepIndex + 1} / $totalSteps',
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(description, style: GoogleFonts.inter(
              fontSize: 13.5, color: const Color(0xFF5A6B62),
              height: 1.5, fontWeight: FontWeight.w400)),
            const SizedBox(height: 14),
            Row(children: [
              // Progress dots
              ...List.generate(totalSteps, (i) => Container(
                width: i == stepIndex ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i == stepIndex ? color : color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
              const Spacer(),
              Text(
                isLast ? 'Compris !' : 'Appuie pour continuer',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: const Color(0xFF8B9990)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class GuidedTourOverlay extends StatefulWidget {
  final List<GuidedTourStep> steps;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onFinish;

  const GuidedTourOverlay({
    super.key,
    required this.steps,
    required this.onNavigateToTab,
    required this.onFinish,
  });

  @override
  State<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends State<GuidedTourOverlay>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  void _next() async {
    HapticFeedback.lightImpact();
    if (_current >= widget.steps.length - 1) {
      await AppTourService.markTourDone();
      widget.onFinish();
      return;
    }
    await _anim.reverse();
    setState(() => _current++);
    widget.onNavigateToTab(widget.steps[_current].tabIndex);
    await Future.delayed(const Duration(milliseconds: 350));
    _anim.forward();
  }

  void _prev() async {
    if (_current <= 0) return;
    HapticFeedback.lightImpact();
    await _anim.reverse();
    setState(() => _current--);
    widget.onNavigateToTab(widget.steps[_current].tabIndex);
    await Future.delayed(const Duration(milliseconds: 350));
    _anim.forward();
  }

  void _skip() async {
    HapticFeedback.mediumImpact();
    await AppTourService.markTourDone();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];
    final bot = MediaQuery.of(context).padding.bottom;
    final isFirst = _current == 0;
    final isLast = _current == widget.steps.length - 1;
    final accent = step.color;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final t = CurvedAnimation(
            parent: _anim, curve: Curves.easeOutCubic).value;

          return Stack(children: [
            // Dark overlay
            GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.black.withOpacity(0.75 * t),
              ),
            ),

            // Mascot — floating above card
            Positioned(
              left: 0, right: 0,
              bottom: bot + 300,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 40),
                  child: CachedNetworkImage(
                    imageUrl: _mascotUrl,
                    width: 150, height: 150,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox(width: 150, height: 150),
                    errorWidget: (_, __, ___) => Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        shape: BoxShape.circle),
                      child: Icon(step.icon, size: 32, color: accent),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom glass card
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(0, (1 - t) * 80),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(24, 20, 24, bot + 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.93),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(32)),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withOpacity(0.5), width: 1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 40,
                              offset: const Offset(0, -8)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Handle
                            Container(
                              width: 36, height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0D8D3),
                                borderRadius: BorderRadius.circular(2)),
                            ),
                            const SizedBox(height: 20),

                            // Icon + title row
                            Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      accent.withOpacity(0.15),
                                      accent.withOpacity(0.06),
                                    ]),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: accent.withOpacity(0.12)),
                                ),
                                child: Icon(step.icon, size: 22, color: accent),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(step.title, style: GoogleFonts.outfit(
                                    fontSize: 20, fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1A1A1A),
                                    letterSpacing: -0.3, height: 1.2)),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Étape ${_current + 1} sur ${widget.steps.length}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12, fontWeight: FontWeight.w500,
                                      color: accent)),
                                ],
                              )),
                              // Skip X
                              if (!isLast)
                                GestureDetector(
                                  onTap: _skip,
                                  child: Container(
                                    width: 34, height: 34,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFF0F2F1)),
                                    child: const Icon(LucideIcons.x, size: 16,
                                      color: Color(0xFF8B9990)),
                                  ),
                                ),
                            ]),
                            const SizedBox(height: 14),

                            // Description
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(step.description,
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  color: const Color(0xFF5A6B62),
                                  height: 1.55,
                                  fontWeight: FontWeight.w400)),
                            ),
                            const SizedBox(height: 20),

                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: SizedBox(
                                height: 5,
                                child: Stack(children: [
                                  Container(color: const Color(0xFFE8EDE9)),
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    widthFactor:
                                        (_current + 1) / widget.steps.length,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          accent,
                                          accent.withOpacity(0.7),
                                        ]),
                                        borderRadius: BorderRadius.circular(3)),
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Buttons
                            Row(children: [
                              if (!isFirst)
                                GestureDetector(
                                  onTap: _prev,
                                  child: Container(
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: const Color(0xFFF0F2F1),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8E4))),
                                    child: const Icon(LucideIcons.chevronLeft,
                                      size: 18, color: Color(0xFF5A6B62)),
                                  ),
                                ),
                              if (!isFirst) const SizedBox(width: 10),

                              Expanded(
                                child: GestureDetector(
                                  onTap: _next,
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          accent,
                                          accent.withOpacity(0.8),
                                        ]),
                                      borderRadius: BorderRadius.circular(25),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6)),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isLast
                                              ? 'C\'est parti !'
                                              : (isFirst
                                                  ? 'Commencer'
                                                  : 'Suivant'),
                                          style: GoogleFonts.outfit(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          isLast
                                              ? LucideIcons.rocket
                                              : LucideIcons.arrowRight,
                                          size: 16,
                                          color: Colors.white.withOpacity(0.9)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
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
