import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:fiteva/services/tick_sound_service.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:fiteva/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/lang.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding Data — état centralisé transmis entre les steps
// ─────────────────────────────────────────────────────────────────────────────
class OnboardingData {
  String username       = '';
  String email          = '';
  String password       = '';
  List<String> goals    = [];
  String? fitnessLevel;
  List<String> equipment = [];
  String? frequency;
  int    heightCm       = 165;
  double weightKg       = 60.0;
  int    age            = 25;
  // Santé féminine
  String? healthStatus;     // 'cycle' | 'pregnant' | 'postpartum'
  int?    pregnancyWeekSA;
  String? ppRecovery;       // 'recent' | 'slowly' | 'active'
  String? ppDuration;       // '0-2' | '2-6' | '6-12' | '3-6m' | '6m+'
  String? cycleDuration;
  DateTime? lastPeriod = DateTime.now().subtract(const Duration(days: 14));
  String avatarSeed  = 'fiteva';
  String avatarStyle = 'lorelei';
  String avatarBg    = 'b6e3f4';
  String mascotType  = 'blob';
  String? trainingLocation;

  Map<String, dynamic> toMap() => {
    'username':           username,
    'email':              email,
    'goals':              goals,
    'fitness_level':      fitnessLevel,
    'equipment':          equipment,
    'frequency':          frequency,
    'training_location':  trainingLocation,
    'height_cm':          heightCm,
    'weight_kg':          weightKg,
    'age':                age,
    'health_status':      healthStatus,
    'pregnancy_week':     pregnancyWeekSA,
    'pp_recovery':        ppRecovery,
    'pp_duration':        ppDuration,
    'cycle_duration':     cycleDuration,
    'last_period':        lastPeriod?.toIso8601String(),
    'mascot_type':        mascotType,
    'mascot_mood':        'happy',
    'avatar_seed':        avatarSeed,
    'avatar_style':       avatarStyle,
  };
}

// ─── Responsive helpers ────────────────────────────────────────────────────
// Reference device: 390 × 844 (iPhone 14)
extension _R on BuildContext {
  double get _w => MediaQuery.of(this).size.width;
  double get _h => MediaQuery.of(this).size.height;
  bool get isSmall => _h < 700;   // SE, Fold outer, older Androids
  bool get isLarge => _h > 900;   // Pro Max, tablets
}

// ─── Design Tokens — Premium Dark Palette ─────────────────────────────────
const _kBgDark       = Color(0xFF080E0B);
const _kBgMid        = Color(0xFF0F1A14);
const _kBgMint       = Color(0xFF080E0B); // alias for backward compat
const _kBgLight      = Color(0xFF0F1A14); // alias for backward compat
const _kGreenDark    = Color(0xFF1C4D30);
const _kGreenMid     = Color(0xFF7ABB98);
const _kGreenBright  = Color(0xFF5CD57A);
const _kCardUnsel    = Color(0xFF1A2A20);
const _kCardSel      = Color(0xFF1C4D30);
const _kTextDark     = Color(0xFFF0F0EE);
const _kTextMuted    = Color(0xFF6B8B78);
const _kWhite        = Colors.white;
const _kBorderLight  = Color(0xFF2A3D30);
const _kGlassBorder  = Color(0xFF2A3D30);
const _kGlassFill    = Color(0x18FFFFFF);

// ─── Shared dark premium background with gradient + decorative orbs ─────────
Widget _stepBackground({required Widget child}) {
  return Scaffold(
    backgroundColor: _kBgDark,
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 1.0],
              colors: [Color(0xFF0D1F14), Color(0xFF0A130E), Color(0xFF080E0B)],
            ),
          ),
        ),
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kGreenDark.withValues(alpha: 0.15),
                _kGreenDark.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 100, left: -80,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                _kGreenMid.withValues(alpha: 0.08),
                _kGreenMid.withValues(alpha: 0),
              ]),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar — glass back button + step counter pill
class _OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;
  final String? title;
  final VoidCallback? onBack;

  const _OnboardingTopBar({
    required this.step,
    required this.total,
    this.title,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _kGlassFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kGlassBorder, width: 0.5),
                    ),
                    child: const Icon(LucideIcons.arrowLeft, size: 18, color: _kTextDark),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _kGlassFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kGlassBorder, width: 0.5),
              ),
              child: Text(
                '$step / $total',
                style: GoogleFonts.outfit(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _kGreenMid, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass pill card — selection with green border glow
class _PillCard extends StatelessWidget {
  final String label;
  final String? sublabel;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final bool fullWidth;

  const _PillCard({
    required this.label,
    this.sublabel,
    this.icon,
    required this.selected,
    required this.onTap,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        width: fullWidth ? double.infinity : null,
        padding: sublabel != null
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? _kGreenDark.withValues(alpha: 0.4)
              : _kGlassFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _kGreenMid.withValues(alpha: 0.6)
                : _kGlassBorder,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: _kGreenMid.withValues(alpha: 0.15),
                  blurRadius: 16, offset: const Offset(0, 4))]
              : [],
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: selected ? _kGreenBright : _kGreenMid, size: 22),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: sublabel != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: selected ? _kWhite : _kTextDark)),
                        const SizedBox(height: 2),
                        Text(sublabel!, style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: selected ? Colors.white70 : _kTextMuted)),
                      ],
                    )
                  : Text(label, style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: selected ? _kWhite : _kTextDark)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _kGreenBright : Colors.transparent,
                border: Border.all(
                  color: selected ? _kGreenBright : _kGlassBorder,
                  width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: _kBgDark)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact glass tile (for 2-col grids)
class _CompactPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CompactPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? _kGreenDark.withValues(alpha: 0.4)
              : _kGlassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _kGreenMid.withValues(alpha: 0.6)
                : _kGlassBorder,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: _kGreenMid.withValues(alpha: 0.15),
                  blurRadius: 14, offset: const Offset(0, 5))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? _kGreenBright : _kGreenMid, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? _kWhite : _kTextDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepLanguageChoice  (FR / EN — shown after login)
// ══════════════════════════════════════════════════════════════════════════════
class StepLanguageChoice extends StatefulWidget {
  final void Function(Locale locale) onNext;
  const StepLanguageChoice({super.key, required this.onNext});

  @override
  State<StepLanguageChoice> createState() => _StepLanguageChoiceState();
}

class _StepLanguageChoiceState extends State<StepLanguageChoice>
    with TickerProviderStateMixin {
  String? _selected;
  late final AnimationController _enterCtrl;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _cardFrFade;
  late final Animation<Offset> _cardFrSlide;
  late final Animation<double> _cardEnFade;
  late final Animation<Offset> _cardEnSlide;
  late final Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100))..forward();

    _titleFade = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)));

    _cardFrFade = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut));
    _cardFrSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic)));

    _cardEnFade = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut));
    _cardEnSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic)));

    _footerFade = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut));
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  void _pick(String lang) {
    if (_selected != null) return;
    HapticFeedback.mediumImpact();
    setState(() => _selected = lang);
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onNext(Locale(lang));
    });
  }

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Title
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose your',
                        style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.w400,
                            color: _kTextMuted, height: 1.15, letterSpacing: -0.8)),
                      Text('Language',
                        style: GoogleFonts.outfit(fontSize: 44, fontWeight: FontWeight.w800,
                            color: _kTextDark, height: 1.05, letterSpacing: -1.5)),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Language cards — staggered entrance
              FadeTransition(
                opacity: _cardFrFade,
                child: SlideTransition(
                  position: _cardFrSlide,
                  child: _LangCard(
                    flag: '🇫🇷',
                    label: 'Français',
                    sublabel: 'French',
                    isSelected: _selected == 'fr',
                    isOtherSelected: _selected == 'en',
                    onTap: () => _pick('fr'),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeTransition(
                opacity: _cardEnFade,
                child: SlideTransition(
                  position: _cardEnSlide,
                  child: _LangCard(
                    flag: '🇬🇧',
                    label: 'English',
                    sublabel: 'Anglais',
                    isSelected: _selected == 'en',
                    isOtherSelected: _selected == 'fr',
                    onTap: () => _pick('en'),
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Footer
              FadeTransition(
                opacity: _footerFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Center(
                    child: Text(
                      'Modifiable à tout moment dans Paramètres',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12,
                          color: _kTextMuted.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangCard extends StatefulWidget {
  final String flag;
  final String label;
  final String sublabel;
  final bool isSelected;
  final bool isOtherSelected;
  final VoidCallback onTap;

  const _LangCard({
    required this.flag,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.isOtherSelected,
    required this.onTap,
  });

  @override
  State<_LangCard> createState() => _LangCardState();
}

class _LangCardState extends State<_LangCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    final dimmed = widget.isOtherSelected && !sel;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) { _scaleCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: dimmed ? 0.35 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: sel
                  ? _kGreenDark.withValues(alpha: 0.4)
                  : _kGlassFill,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: sel
                    ? _kGreenBright.withValues(alpha: 0.5)
                    : _kGlassBorder,
                width: sel ? 1.2 : 0.5),
              boxShadow: sel
                  ? [BoxShadow(
                      color: _kGreenBright.withValues(alpha: 0.1),
                      blurRadius: 28, offset: const Offset(0, 8))]
                  : [],
            ),
            child: Row(
              children: [
                // Flag
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: sel
                        ? _kGreenBright.withValues(alpha: 0.1)
                        : _kWhite.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(widget.flag, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 18),
                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label,
                        style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : _kTextDark,
                          letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Text(widget.sublabel,
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w400,
                          color: sel ? _kGreenMid : _kTextMuted)),
                    ],
                  ),
                ),
                // Check indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: sel ? _kGreenBright : Colors.transparent,
                    border: Border.all(
                      color: sel ? _kGreenBright : _kWhite.withValues(alpha: 0.12),
                      width: sel ? 0 : 1.5),
                  ),
                  child: sel
                      ? const Icon(Icons.check_rounded, size: 15, color: _kBgDark)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 0 — StepIntro  (cinematic hero screen)
// ══════════════════════════════════════════════════════════════════════════════
class StepIntro extends StatefulWidget {
  final VoidCallback onNext;
  const StepIntro({super.key, required this.onNext});

  @override
  State<StepIntro> createState() => _StepIntroState();
}

class _StepIntroState extends State<StepIntro> with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _shimmerCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _headFade;
  late final Animation<Offset> _headSlide;
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _chipsFade;
  late final Animation<double> _proofFade;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;
  late final Animation<double> _orbFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    Animation<double> iv(double s, double e) => CurvedAnimation(
          parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut));

    Animation<Offset> sl(double s, double e, [Offset? from]) =>
        Tween<Offset>(begin: from ?? const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _ctrl,
                curve: Interval(s, e, curve: Curves.easeOutCubic)));

    _orbFade   = iv(0.00, 0.35);
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.05, 0.38, curve: Curves.elasticOut),
    ));
    _logoFade  = iv(0.05, 0.28);
    _headFade  = iv(0.20, 0.45);
    _headSlide = sl(0.20, 0.45);
    _tagFade   = iv(0.30, 0.52);
    _tagSlide  = sl(0.30, 0.52);
    _chipsFade = iv(0.42, 0.62);
    _proofFade = iv(0.52, 0.72);
    _btnFade   = iv(0.62, 0.88);
    _btnSlide  = sl(0.62, 0.88);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF061A0D),
              Color(0xFF0F3D1E),
              Color(0xFF1A5C2E),
              Color(0xFF0F3D1E),
              Color(0xFF061A0D),
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Glowing orbs with blur ──
            FadeTransition(
              opacity: _orbFade,
              child: Stack(children: [
                Positioned(
                  top: -sh * 0.08, left: -sw * 0.18,
                  child: _glowOrb(sw * 0.75, const Color(0xFF2ECC71), 0.14),
                ),
                Positioned(
                  top: sh * 0.25, right: -sw * 0.25,
                  child: _glowOrb(sw * 0.55, const Color(0xFF27AE60), 0.10),
                ),
                Positioned(
                  bottom: sh * 0.18, left: -sw * 0.12,
                  child: _glowOrb(sw * 0.50, const Color(0xFF1ABC9C), 0.10),
                ),
                Positioned(
                  bottom: -sh * 0.06, right: -sw * 0.10,
                  child: _glowOrb(sw * 0.65, const Color(0xFF2ECC71), 0.12),
                ),
              ]),
            ),

            // ── Frosted overlay ──
            Positioned.fill(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),

            // ── Content ──
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sh < 700 ? 22 : 30),
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.04),

                    // Logo — scale + fade
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: _buildLogo(sh),
                      ),
                    ),

                    Spacer(flex: sh < 700 ? 1 : 2),

                    // Headline
                    FadeTransition(
                      opacity: _headFade,
                      child: SlideTransition(
                        position: _headSlide,
                        child: _buildHeadline(sh),
                      ),
                    ),

                    SizedBox(height: sh * 0.012),

                    // Tagline
                    FadeTransition(
                      opacity: _tagFade,
                      child: SlideTransition(
                        position: _tagSlide,
                        child: Text(
                          "Fitness, cycle & nutrition —\ntout ce dont une femme a besoin.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (sh * 0.018).clamp(12.0, 15.0),
                            color: Colors.white.withValues(alpha: 0.50),
                            height: 1.55,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.030),

                    // Feature chips
                    FadeTransition(opacity: _chipsFade, child: _buildChips(sh)),

                    SizedBox(height: sh * 0.024),

                    // Social proof
                    FadeTransition(opacity: _proofFade, child: _buildSocialProof(sh)),

                    Spacer(flex: sh < 700 ? 1 : 3),

                    // CTA with shimmer
                    FadeTransition(
                      opacity: _btnFade,
                      child: SlideTransition(
                        position: _btnSlide,
                        child: _buildCTA(sh),
                      ),
                    ),

                    SizedBox(height: sh * 0.012),

                    FadeTransition(
                      opacity: _btnFade,
                      child: Text(
                        "En continuant, tu acceptes nos Conditions d'utilisation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sh < 700 ? 10 : 11,
                          color: Colors.white.withValues(alpha: 0.25),
                          height: 1.4,
                        ),
                      ),
                    ),

                    SizedBox(height: sh * 0.024),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowOrb(double size, Color color, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      );

  Widget _buildLogo(double sh) {
    final logoSz = sh < 700 ? 50.0 : 60.0;
    return Column(
      children: [
        Container(
          width: logoSz, height: logoSz,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(logoSz * 0.28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSz * 0.28),
            child: Image.asset('assets/images/logfiteva.jpeg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "FITEVA",
          style: TextStyle(
            fontSize: sh < 700 ? 20 : 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 5,
            shadows: [
              Shadow(
                color: const Color(0xFF2ECC71).withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(double sh) {
    final headFs = (sh * 0.050).clamp(28.0, 44.0);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: headFs,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          height: 1.10,
          letterSpacing: -1.0,
        ),
        children: const [
          TextSpan(text: "Transforme\nton corps,\n"),
          TextSpan(
            text: "libère ta force.",
            style: TextStyle(color: Color(0xFF5CD57A)),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(double sh) {
    const features = [
      (Icons.fitness_center_rounded,  "Workouts"),
      (Icons.water_drop_outlined,     "Cycle"),
      (Icons.restaurant_menu_rounded, "Nutrition"),
      (Icons.supervised_user_circle,  "Communauté"),
    ];
    final chipPadV = sh < 700 ? 7.0 : 10.0;
    final chipFs   = sh < 700 ? 12.0 : 13.0;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: features.map((f) => Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: chipPadV),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(f.$1, color: const Color(0xFF5CD57A), size: 14),
          const SizedBox(width: 7),
          Text(f.$2, style: TextStyle(
            fontSize: chipFs, color: Colors.white, fontWeight: FontWeight.w500)),
        ]),
      )).toList(),
    );
  }

  Widget _buildSocialProof(double sh) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 58, height: 26,
              child: Stack(
                children: List.generate(3, (i) => Positioned(
                  left: i * 17.0,
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const [
                        Color(0xFF4CAF7A),
                        Color(0xFF2E7D4F),
                        Color(0xFF81C784),
                      ][i],
                      border: Border.all(
                          color: const Color(0xFF061A0D), width: 1.5),
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 12),
                  ),
                )),
              ),
            ),
            const SizedBox(width: 11),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(fontSize: 13),
                  children: [
                    const TextSpan(
                      text: "★ 4.8  ",
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w700),
                    ),
                    TextSpan(
                      text: "50K+ femmes actives",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCTA(double sh) => GestureDetector(
        onTap: widget.onNext,
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (context, _) {
            return Container(
              width: double.infinity,
              height: sh < 700 ? 52 : 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2ECC71),
                    Color(0xFF27AE60),
                    Color(0xFF1ABC9C),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  // Shimmer sweep
                  Positioned.fill(
                    child: Transform.translate(
                      offset: Offset(
                        (_shimmerCtrl.value * 2 - 0.5) *
                            MediaQuery.of(context).size.width,
                        0,
                      ),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Commencer gratuitement",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 17),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1 — StepWelcome (inchangé visuellement, mais fond mint)
// ══════════════════════════════════════════════════════════════════════════════

// ─── Colors ───────────────────────────────────────────────────────────────────
const _kPrimary     = Color(0xFFFF2D6B);   // SWEAT pink-red
const _kDark        = Color(0xFF0A0A0A);
const _kGrey        = Color(0xFF8A8A8A);
const _kSurface     = Color(0xFFF2F2F2);

// ─── Slide data ───────────────────────────────────────────────────────────────
class _SlideData {
  final String imagePath;
  final String title;
  final String subtitle;
  const _SlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

const _slides = [
  _SlideData(
    imagePath: 'assets/images/slide_gym1.jpg',
    title: 'Welcome to FitEva!',
    subtitle: 'With support from millions, tap into our motivation and find your strength.',
  ),
  _SlideData(
    imagePath: 'assets/images/slide_gym2.jpg',
    title: 'Workouts',
    subtitle: 'Resistance, cardio and recovery workouts. Anytime, anywhere.',
  ),
 _SlideData(
  imagePath: 'assets/images/slide_gym3.jpg',
  title: 'cycle',
  subtitle: 'Track your menstrual cycle, understand your body better, and stay informed about your health and well-being.',
),
  _SlideData(
    imagePath: 'assets/images/slide_gym4.jpg',
    title: 'nutrition',
  subtitle: 'Build healthy habits with personalized nutrition guidance to support your fitness goals.',
  ),
];

// ─── Widget ───────────────────────────────────────────────────────────────────
class StepWelcome extends StatefulWidget {
  /// Crée un nouveau compte. Retourne un message d'erreur, ou null si ok
  /// (l'appelant enchaîne alors sur la suite de l'onboarding).
  final Future<String?> Function(String email, String password) onSignUp;
  /// Connecte un compte existant. Retourne un message d'erreur, ou null si ok
  /// (l'appelant saute alors directement dans l'app).
  final Future<String?> Function(String email, String password) onLogin;
  final Future<void> Function()? onGoogleSignIn;
  final Future<void> Function()? onAppleSignIn;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const StepWelcome({
    super.key,
    required this.onSignUp,
    required this.onLogin,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<StepWelcome>
    with TickerProviderStateMixin {

  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  bool _isLoginMode  = false; // false = inscription, true = connexion
  bool _emailFieldsOpen = false; // les 2 champs n'apparaissent qu'à la demande
  bool _obscure      = true;
  String? _error;
  bool _submitting   = false;
  bool _resetSubmitting = false;
  bool _googleSubmitting = false;
  bool _appleSubmitting  = false;

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _canSubmit =>
      widget.emailController.text.trim().isNotEmpty &&
      widget.passwordController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final email = widget.emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Adresse email invalide.');
      return;
    }
    setState(() { _error = null; _submitting = true; });
    final password = widget.passwordController.text.trim();
    final error = _isLoginMode
        ? await widget.onLogin(email, password)
        : await widget.onSignUp(email, password);
    if (!mounted) return;
    setState(() { _error = error; _submitting = false; });
  }

  /// Envoie l'email de réinitialisation via Supabase, à partir de l'email
  /// déjà saisi dans le champ du formulaire de connexion.
  Future<void> _forgotPassword() async {
    final email = widget.emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Entre ton email ci-dessus pour recevoir le lien de réinitialisation.');
      return;
    }
    setState(() { _resetSubmitting = true; _error = null; });
    final result = await AuthService.resetPassword(email);
    if (!mounted) return;
    setState(() => _resetSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.isSuccess
          ? 'Email de réinitialisation envoyé à $email.'
          : (result.error ?? 'Erreur lors de l\'envoi de l\'email.')),
      backgroundColor: result.isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFB00020),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _handleGoogleSignIn() async {
    if (_googleSubmitting || widget.onGoogleSignIn == null) return;
    setState(() => _googleSubmitting = true);
    try {
      await widget.onGoogleSignIn!();
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    if (_appleSubmitting || widget.onAppleSignIn == null) return;
    setState(() => _appleSubmitting = true);
    try {
      await widget.onAppleSignIn!();
    } finally {
      if (mounted) setState(() => _appleSubmitting = false);
    }
  }

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _slides.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  // Écran scindé en deux : visuel plein cadre en haut (photo + accroche
  // marketing), carte blanche arrondie en bas pour Google/Apple + liens.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [
          // ── Background image carousel ──────────────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageCtrl,
              physics: const PageScrollPhysics(),
              itemCount: _slides.length,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _startAutoSlide(); // reset timer after manual swipe
              },
              itemBuilder: (_, i) => _buildSlideBackground(_slides[i]),
            ),
          ),

          // ── Dark gradient overlay — pour la lisibilité du logo/accroche ────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    _kDark.withValues(alpha:0.55),
                    _kDark.withValues(alpha:0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu : logo + accroche sur la photo, carte en bas ───────────
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 20),
                            _buildLogo(),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSlideText(),
                            const SizedBox(height: 14),
                            _buildDots(),
                            const SizedBox(height: 22),
                            FadeTransition(
                              opacity: _fadeAnim,
                              child: _buildAuthCard(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Carte "verre dépoli" — toggle Inscription/Connexion, Google/Apple,
  // et les 2 champs email/mot de passe qui n'apparaissent qu'à la demande. ──
  Widget _buildAuthCard() {
    final l10n = AppL10n(Lang.code);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: _kDark.withValues(alpha:0.32),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: _kWhite.withValues(alpha:0.22), width: 1)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                24, 22, 24, 20 + MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Toggle Inscription / Connexion ──────────────────────
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _kWhite.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(children: [
                    Expanded(child: _ModeTab(
                      label: l10n.welcomeCreateAccount, active: !_isLoginMode,
                      onTap: () => setState(() { _isLoginMode = false; _error = null; }),
                    )),
                    Expanded(child: _ModeTab(
                      label: l10n.welcomeLogIn, active: _isLoginMode,
                      onTap: () => setState(() { _isLoginMode = true; _error = null; }),
                    )),
                  ]),
                ),
                const SizedBox(height: 18),

                // ── Google / Apple ───────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: _GlassSocialBtn(
                      onTap: _handleGoogleSignIn,
                      loading: _googleSubmitting,
                      child: SvgPicture.asset('assets/images/google-color.svg', width: 20, height: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlassSocialBtn(
                      onTap: _handleAppleSignIn,
                      loading: _appleSubmitting,
                      child: Icon(Icons.apple_rounded, color: _kWhite, size: 22),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(child: Divider(color: _kWhite.withValues(alpha:0.2))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(l10n.welcomeOrContinueWith.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: _kWhite.withValues(alpha:0.5),
                        fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                  Expanded(child: Divider(color: _kWhite.withValues(alpha:0.2))),
                ]),
                const SizedBox(height: 14),

                // ── Email/mot de passe — n'apparaissent qu'à la demande ──
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: _emailFieldsOpen
                      ? Column(children: [
                          _GlassField(
                            controller: widget.emailController,
                            hint: l10n.welcomeEmail,
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => setState(() { _error = null; }),
                          ),
                          const SizedBox(height: 10),
                          _GlassField(
                            controller: widget.passwordController,
                            hint: l10n.welcomePassword,
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffix: GestureDetector(
                              onTap: () => setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: _kWhite.withValues(alpha:0.6), size: 18,
                              ),
                            ),
                            onChanged: (_) => setState(() { _error = null; }),
                          ),
                          if (_isLoginMode) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: _resetSubmitting ? null : _forgotPassword,
                                child: Text(
                                  _resetSubmitting
                                      ? (l10n.isFrench ? 'Envoi en cours...' : 'Sending...')
                                      : (l10n.isFrench ? 'Mot de passe oublié ?' : 'Forgot password?'),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5, fontWeight: FontWeight.w600,
                                    color: _kWhite.withValues(alpha:0.85)),
                                ),
                              ),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(_error!,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFF8A80), fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                          const SizedBox(height: 14),
                          _AuthCtaButton(
                            label: _isLoginMode ? l10n.welcomeLogIn : l10n.welcomeContinue,
                            enabled: _canSubmit && !_submitting,
                            loading: _submitting,
                            onTap: _submit,
                          ),
                        ])
                      : GestureDetector(
                          onTap: () => setState(() => _emailFieldsOpen = true),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _kWhite.withValues(alpha:0.28)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.mail_outline_rounded, size: 16, color: _kWhite.withValues(alpha:0.85)),
                              const SizedBox(width: 8),
                              Text(
                                l10n.isFrench ? 'Continuer par email' : 'Continue with email',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5, fontWeight: FontWeight.w700, color: _kWhite),
                              ),
                            ]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Slide background ──────────────────────────────────────────────────────
  Widget _buildSlideBackground(_SlideData slide) {
    return Image.asset(
      slide.imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1A1A1A),
        child: const Icon(Icons.fitness_center, color: Colors.white12, size: 80),
      ),
    );
  }

  // ─── Logo ──────────────────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: _kWhite.withValues(alpha:0.15),
            shape: BoxShape.circle,
            border: Border.all(color: _kWhite.withValues(alpha:0.4)),
          ),
          child: Icon(Icons.water_drop_rounded, color: _kWhite, size: 15),
        ),
        const SizedBox(width: 9),
        Text(
          'FitEva',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _kWhite,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── Slide text ────────────────────────────────────────────────────────────
  Widget _buildSlideText() {
    final slide = _slides[_currentPage];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        key: ValueKey(_currentPage),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _kWhite,
                height: 1.15,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 12),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: _kWhite.withValues(alpha:0.88),
                height: 1.5,
                shadows: [
                  Shadow(color: Colors.black.withValues(alpha:0.3), blurRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dots ──────────────────────────────────────────────────────────────────
  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final active = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _kWhite : _kWhite.withValues(alpha:0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

}


// ─── Onglet de bascule Inscription/Connexion ────────────────────────────────
class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? _kWhite.withValues(alpha:0.9) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: active ? _kTextDark : _kWhite.withValues(alpha:0.75))),
        ),
      ),
    );
  }
}

// ─── Bouton social translucide (verre) ──────────────────────────────────────
class _GlassSocialBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool loading;
  const _GlassSocialBtn({required this.child, required this.onTap, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: _kWhite.withValues(alpha:0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kWhite.withValues(alpha:0.28)),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _kWhite.withValues(alpha:0.85)),
                )
              : child,
        ),
      ),
    );
  }
}

// ─── Champ de formulaire style "verre" (fond translucide, texte clair) ──────
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String> onChanged;

  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Fond nettement plus sombre que la carte pour garantir le contraste
        // du texte blanc (un simple voile blanc translucide le rendait
        // quasi invisible sur des zones claires de la photo).
        color: Colors.black.withValues(alpha:0.28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kWhite.withValues(alpha:0.25), width: 1.1),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        autofillHints: const [],
        style: GoogleFonts.inter(fontSize: 15, color: _kWhite, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: _kWhite.withValues(alpha:0.55), fontSize: 14),
          prefixIcon: Icon(icon, color: _kWhite.withValues(alpha:0.8), size: 19),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          // Le thème global de l'app force `filled: true` + un fond clair sur
          // tous les champs — on neutralise explicitement chaque propriété
          // pour empêcher ce style d'écraser le fond "verre" du champ.
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
        ),
      ),
    );
  }
}

// ─── Bouton CTA partagé (login/signup) ──────────────────────────────────────
class _AuthCtaButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _AuthCtaButton({
    required this.label,
    required this.enabled,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: enabled ? _kPrimary : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [BoxShadow(
                  color: _kPrimary.withValues(alpha:0.35),
                  blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Center(
          child: loading
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(
                  strokeWidth: 2, color: enabled ? _kWhite : _kGrey))
              : Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: enabled ? _kWhite : _kGrey,
                    letterSpacing: 0.1,
                  ),
                ),
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// Données partagées — objectifs de poids + niveaux de forme, utilisées par
// OnboardingChatFlow (phases "objectif" et "niveau" du fil de chat unique).
// Les clés de stockage ci-dessous sont volontairement distinctes ("poids"
// seulement pour la perte, "masse" pour la prise) pour ne pas se faire
// mal-classer par la détection par mot-clé dans UserProfile.fromOnboardingData
// et NutritionTargets.compute()).
// ══════════════════════════════════════════════════════════════════════════════

class _GoalData {
  final String label;
  const _GoalData(this.label);
}

const _goals = [
  _GoalData('Perte de poids'),
  _GoalData('Maintien'),
  _GoalData('Prise de masse'),
];

const _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

// ── Chat message model ─────────────────────────────────────────────────────
enum _ChatSender { mascot, user }

class _ChatMessage {
  final _ChatSender sender;
  final String? text;
  final WidgetBuilder? inline;
  final bool isTyping;
  final VoidCallback? onEdit;

  const _ChatMessage._({
    required this.sender,
    this.text,
    this.inline,
    this.isTyping = false,
    this.onEdit,
  });

  factory _ChatMessage.mascot(String text) =>
      _ChatMessage._(sender: _ChatSender.mascot, text: text);
  factory _ChatMessage.mascotInline(WidgetBuilder inline) =>
      _ChatMessage._(sender: _ChatSender.mascot, inline: inline);
  factory _ChatMessage.user(String text, {VoidCallback? onEdit}) =>
      _ChatMessage._(sender: _ChatSender.user, text: text, onEdit: onEdit);
  factory _ChatMessage.typing() =>
      const _ChatMessage._(sender: _ChatSender.mascot, isTyping: true);
}

// ── Chat bubble — mascotte (gauche, avatar) ou utilisateur (droite) ────────
// `inline` permet d'intégrer un composant complexe existant (drum picker,
// cadran, cartes de choix) directement dans la bulle mascotte, pour les
// steps où un simple quick-reply ne suffit pas.
// `onTap` (bulles utilisateur uniquement) permet de rouvrir et modifier une
// réponse déjà donnée — un petit crayon signale que la bulle est modifiable.
class _ChatBubble extends StatelessWidget {
  final _ChatSender sender;
  final String? text;
  final WidgetBuilder? inline;
  final MascotType mascotType;
  final VoidCallback? onTap;
  const _ChatBubble({required this.sender, this.text, this.inline, required this.mascotType, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMascot = sender == _ChatSender.mascot;
    final isInline = inline != null;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: context._w * (isInline ? 0.88 : 0.72)),
      padding: EdgeInsets.symmetric(
        horizontal: isInline ? 12 : 16,
        vertical: isInline ? 12 : 12,
      ),
      decoration: BoxDecoration(
        color: isMascot ? _kGlassFill : _kGreenDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMascot ? 4 : 18),
          bottomRight: Radius.circular(isMascot ? 18 : 4),
        ),
        border: Border.all(
          color: isMascot ? _kGlassBorder : _kGreenMid.withValues(alpha: 0.4),
          width: 0.6,
        ),
      ),
      child: isInline
          ? inline!(context)
          : onTap == null
              ? Text(
                  text ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: isMascot ? _kTextDark : _kWhite,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        text ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: isMascot ? _kTextDark : _kWhite,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit_rounded, size: 13,
                        color: (isMascot ? _kTextMuted : _kWhite).withValues(alpha: 0.6)),
                  ],
                ),
    );

    final tappableBubble = onTap != null
        ? GestureDetector(onTap: onTap, child: bubble)
        : bubble;

    if (isMascot) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MascotWidget(type: mascotType, size: 34, mood: MascotMood.happy),
          const SizedBox(width: 8),
          Flexible(child: tappableBubble),
        ],
      );
    }
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: tappableBubble)]);
  }
}

// ── Bulle "en train d'écrire..." — 3 points qui rebondissent ───────────────
class _TypingBubble extends StatefulWidget {
  final MascotType mascotType;
  const _TypingBubble({required this.mascotType});

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MascotWidget(type: widget.mascotType, size: 34, mood: MascotMood.happy),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _kGlassFill,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
            border: Border.all(color: _kGlassBorder, width: 0.6),
          ),
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_ctrl.value + i * 0.2) % 1.0;
                final bounce = sin(t * pi).abs();
                return Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                  child: Transform.translate(
                    offset: Offset(0, -bounce * 4),
                    child: Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _kTextMuted.withValues(alpha: 0.5 + bounce * 0.5),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick-reply — pills affichées sous la dernière bulle mascotte ──────────
class _QuickReplyRow extends StatelessWidget {
  final List<(String key, String label)> options;
  final void Function(String key, String label) onPicked;
  const _QuickReplyRow({required this.options, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) => GestureDetector(
        onTap: () => onPicked(o.$1, o.$2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _kGlassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kGreenMid.withValues(alpha: 0.5), width: 1),
          ),
          child: Text(
            o.$2,
            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: _kTextDark),
          ),
        ),
      )).toList(),
    );
  }
}

// ── Multi quick-reply — chips à toggle (multi-sélection) + bouton confirmer ──
// Pour les steps où plusieurs choix sont possibles (ex: équipement) : chaque
// chip peut être activée/désactivée indépendamment, un bouton "Continuer"
// valide la sélection et fait avancer la conversation.
class _MultiQuickReplyPanel extends StatelessWidget {
  final List<(String key, String label, IconData icon)> options;
  final List<String> selected;
  final void Function(String key) onToggle;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  const _MultiQuickReplyPanel({
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.confirmLabel,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final isSel = selected.contains(o.$1);
            return GestureDetector(
              onTap: () => onToggle(o.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? _kGreenDark.withValues(alpha: 0.45) : _kGlassFill,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSel ? _kGreenBright.withValues(alpha: 0.7) : _kGreenMid.withValues(alpha: 0.5),
                    width: isSel ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(o.$3, size: 14, color: isSel ? _kGreenBright : _kGreenMid),
                    const SizedBox(width: 6),
                    Text(
                      o.$2,
                      style: GoogleFonts.inter(
                        fontSize: 13.5, fontWeight: FontWeight.w600,
                        color: isSel ? _kWhite : _kTextDark),
                    ),
                    if (isSel) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_rounded, size: 14, color: _kGreenBright),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _ChatConfirmButton(label: confirmLabel, onTap: onConfirm),
      ],
    );
  }
}

// ── Bouton "Continuer" — utilisé après une interaction inline (dial, drum
// picker, cartes...) qui ne peut pas s'auto-valider comme un quick-reply. ──
class _ChatConfirmButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _ChatConfirmButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(colors: [_kGreenDark, _kGreenBright])
                : null,
            color: enabled ? null : _kGlassFill,
            borderRadius: BorderRadius.circular(20),
            border: enabled ? null : Border.all(color: _kGlassBorder, width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3,
                  color: enabled ? _kWhite : _kTextMuted),
              ),
              if (enabled) ...[
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 15, color: _kWhite),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// OnboardingChatFlow — tout l'onboarding (mascotte → objectifs → niveau →
// équipement → lieu → fréquence → taille/poids/âge → cycle) dans UN SEUL fil
// de chat continu, un seul scroll — plus de découpage en pages séparées.
// Chaque réponse déjà donnée reste modifiable : taper sur sa bulle (icône
// crayon) rouvre la question correspondante et met simplement à jour la
// donnée, sans rejouer les questions suivantes déjà répondues.
// ══════════════════════════════════════════════════════════════════════════════
class OnboardingChatFlow extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback? onBack;
  final VoidCallback onDataChanged;
  final VoidCallback onFinish;

  const OnboardingChatFlow({
    super.key,
    required this.data,
    this.onBack,
    required this.onDataChanged,
    required this.onFinish,
  });

  @override
  State<OnboardingChatFlow> createState() => _OnboardingChatFlowState();
}

class _OnboardingChatFlowState extends State<OnboardingChatFlow> {
  OnboardingData get _data => widget.data;

  MascotType get _mascotType {
    for (final t in MascotType.values) {
      if (t.name == _data.mascotType) return t;
    }
    return MascotType.blob;
  }

  // ── Chat plumbing ────────────────────────────────────────────────────────
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollCtrl = ScrollController();
  final _rng = Random();
  // Contrôle actif prioritaire — non nul quand l'utilisateur modifie une
  // réponse déjà donnée. Le flux principal (ses propres booléens `_showingX`)
  // n'est jamais touché par une édition : une fois l'édition confirmée, le
  // flux principal réapparaît naturellement tel qu'il était.
  Widget Function(BuildContext)? _editingControl;
  int _completedPhases = 0;
  static const _totalPhases = 10;

  // ── Mascotte ─────────────────────────────────────────────────────────────
  bool _showingMascotOptions = false;
  static const _mascotTypes = [
    (MascotType.blob,  'Blobby',  '🟢'),
    (MascotType.sun,   'Sunny',   '☀️'),
    (MascotType.star,  'Starlet', '⭐'),
    (MascotType.cloud, 'Cloudie', '☁️'),
    (MascotType.leaf,  'Leafy',   '🍃'),
  ];

  // ── Objectif / niveau ────────────────────────────────────────────────────
  bool _showingGoalOptions = false;
  bool _showingFitnessOptions = false;

  // ── Équipement ───────────────────────────────────────────────────────────
  bool _showingEquipmentOptions = false;

  // ── Lieu d'entraînement ──────────────────────────────────────────────────
  bool _showingLocationOptions = false;
  static const _locationValues = ['gym', 'home', 'both'];
  static const _locationEmojis = ['🏋️', '🏠', '💪'];

  // ── Fréquence ────────────────────────────────────────────────────────────
  bool _showingFrequencyOptions = false;
  static const _freqLabels = ['2 jours', '3 jours', '4 jours', '5 jours', '6 jours'];

  // ── Taille / poids / âge ─────────────────────────────────────────────────
  static const int _minH = 140, _maxH = 210;
  static const int _minA = 15,  _maxA = 70;
  static final List<double> _wList = List.generate(231, (i) => 35.0 + i * 0.5);
  late final FixedExtentScrollController _hCtrl;
  late final FixedExtentScrollController _wCtrl;
  late final FixedExtentScrollController _aCtrl;
  late int _hIdx;
  late int _wIdx;
  late int _aIdx;
  bool _showingHeightConfirm = false;
  bool _showingWeightConfirm = false;
  bool _showingAgeConfirm = false;

  int get _heightCm => _minH + _hIdx;
  double get _weightKg => _wList[_wIdx];
  int get _age => _minA + _aIdx;
  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  String get _bmiLabel {
    final l10n = AppL10n(Lang.code);
    if (_bmi < 18.5) return l10n.healthProfileBmiThin;
    if (_bmi < 25.0) return l10n.healthProfileBmiNormal;
    if (_bmi < 30.0) return l10n.healthProfileBmiOver;
    return l10n.healthProfileBmiObese;
  }

  Color get _bmiColor {
    if (_bmi < 18.5) return const Color(0xFF5B9BD9);
    if (_bmi < 25.0) return _kGreenMid;
    if (_bmi < 30.0) return const Color(0xFFE8A040);
    return const Color(0xFFD94A4A);
  }

  // ── Cycle / grossesse / post-partum ──────────────────────────────────────
  // 'cycle' | 'pregnant' | 'postpartum' | null
  String? _status;
  String _cycleDuration = '28 jours';
  DateTime _lastPeriod = DateTime.now().subtract(const Duration(days: 14));
  static const List<String> _cycleDurations = [
    '24 jours', '26 jours', '28 jours', '30 jours', '32 jours',
  ];
  String? _ppDuration;   // '0-2', '2-6', '6-12', '3-6m', '6m+'
  DateTime? _birthDate;
  int _weekIdx = 11; // default SA 12 (index 0-based)
  late final FixedExtentScrollController _weekCtrl;
  bool _showingCycleStatusOptions = false;
  bool _showingCycleConfirm = false;

  String get _ppProgram {
    switch (_ppDuration) {
      case '0-2':  return 'Reborn';
      case '2-6':  return 'Rise';
      case '6-12': return 'Rise+';
      case '3-6m': return 'Reclaim';
      case '6m+':  return 'Reclaim+';
      default: return '';
    }
  }

  String get _ppProgramDesc {
    final l10n = AppL10n(Lang.code);
    switch (_ppDuration) {
      case '0-2':  return l10n.ppPpProgDesc0_2;
      case '2-6':  return l10n.ppPpProgDesc2_6;
      case '6-12': return l10n.ppPpProgDesc6_12;
      case '3-6m': return l10n.ppPpProgDesc3_6m;
      case '6m+':  return l10n.ppPpProgDesc6mPlus;
      default: return '';
    }
  }

  Color get _ppProgramColor {
    switch (_ppDuration) {
      case '0-2':  return const Color(0xFFE53935);
      case '2-6':  return const Color(0xFFFB8C00);
      case '6-12': return const Color(0xFFFB8C00);
      case '3-6m': return const Color(0xFF2E7D32);
      case '6m+':  return const Color(0xFF2E7D32);
      default: return _kGreenDark;
    }
  }

  DateTime get _nextPeriod {
    final d = int.tryParse(_cycleDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 28;
    return _lastPeriod.add(Duration(days: d));
  }

  int get _weekSA => _weekIdx + 1;

  int get _trimester {
    if (_weekSA <= 13) return 1;
    if (_weekSA <= 27) return 2;
    return 3;
  }

  String get _trimesterAdvice {
    final l10n = AppL10n(Lang.code);
    switch (_trimester) {
      case 1: return l10n.cycleAdviceT1;
      case 2: return l10n.cycleAdviceT2;
      default: return l10n.cycleAdviceT3;
    }
  }

  bool get _canConfirmCycle =>
      _status == 'postpartum' ? _ppDuration != null : _status != null;

  String _fmt(DateTime d) {
    const m = [
      'Janv.', 'Févr.', 'Mars', 'Avr.', 'Mai', 'Juin',
      'Juil.', 'Août', 'Sept.', 'Oct.', 'Nov.', 'Déc.',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }

  Future<void> _pickLastPeriodDate() async {
    final p = await showCustomDatePicker(
      context: context,
      initialDate: _lastPeriod,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      title: AppL10n(Lang.code).datePickerLastPeriodTitle,
      subtitle: AppL10n(Lang.code).datePickerLastPeriodSub,
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFFD94F6B),
    );
    if (p != null) {
      setState(() => _lastPeriod = p);
      _data.lastPeriod = p;
      widget.onDataChanged();
    }
  }

  // ── Init / Dispose ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _hIdx = (_data.heightCm - _minH).clamp(0, _maxH - _minH);
    final wNearest = _wList.indexWhere((w) => w >= _data.weightKg);
    _wIdx = wNearest < 0 ? 50 : wNearest;
    _aIdx = (_data.age - _minA).clamp(0, _maxA - _minA);
    _hCtrl = FixedExtentScrollController(initialItem: _hIdx);
    _wCtrl = FixedExtentScrollController(initialItem: _wIdx);
    _aCtrl = FixedExtentScrollController(initialItem: _aIdx);
    _weekCtrl = FixedExtentScrollController(initialItem: _weekIdx);
    TickSoundService.instance.init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askMascot());
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _wCtrl.dispose();
    _aCtrl.dispose();
    _weekCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Chat plumbing helpers ───────────────────────────────────────────────
  Future<void> _sayMascot(String text) async {
    setState(() => _messages.add(_ChatMessage.typing()));
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: 400 + _rng.nextInt(200)));
    if (!mounted) return;
    setState(() {
      _messages.removeLast();
      _messages.add(_ChatMessage.mascot(text));
    });
    _scrollToBottom();
  }

  void _sayUser(String text, {VoidCallback? onEdit}) {
    setState(() => _messages.add(_ChatMessage.user(text, onEdit: onEdit)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 140,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _ackEdit() async {
    await _sayMascot(AppL10n(Lang.code).chatAnswerUpdated);
    if (!mounted) return;
    setState(() => _editingControl = null);
  }

  // ══ PHASE 1 — Mascotte ══════════════════════════════════════════════════
  Future<void> _askMascot() async {
    await _sayMascot(AppL10n(Lang.code).avatarChooseTitle);
    if (!mounted) return;
    setState(() => _showingMascotOptions = true);
  }

  Widget _mascotControl({required bool editing}) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mascotTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (type, name, emoji) = _mascotTypes[i];
          final selected = _mascotType == type;
          return GestureDetector(
            onTap: () => _commitMascot(type, name, emoji, editing: editing),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _kGreenDark.withValues(alpha: 0.4) : _kGlassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _kGreenMid.withValues(alpha: 0.6) : _kGlassBorder,
                  width: selected ? 1.4 : 0.6),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                MascotWidget(type: type, mood: MascotMood.happy, size: 40),
                const SizedBox(height: 4),
                Text(name, style: GoogleFonts.inter(
                  fontSize: 9.5, fontWeight: FontWeight.w700,
                  color: selected ? _kWhite : _kTextMuted)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _commitMascot(MascotType type, String name, String emoji, {required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingMascotOptions = false);
    }
    _data.mascotType = type.name;
    widget.onDataChanged();

    _sayUser('$emoji $name', onEdit: () => _reopenMascot());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 1;
    await _sayMascot(AppL10n(Lang.code).avatarChatConfirm);
    if (!mounted) return;
    await _askGoal();
  }

  void _reopenMascot() {
    setState(() => _editingControl = (ctx) => _mascotControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 2 — Objectif ══════════════════════════════════════════════════
  Future<void> _askGoal() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.goalsTitle.replaceAll('\n', ' '));
    if (!mounted) return;
    setState(() => _showingGoalOptions = true);
  }

  Widget _goalControl({required bool editing}) {
    final l10n = AppL10n(Lang.code);
    return _QuickReplyRow(
      options: [
        (_goals[0].label, l10n.goal1.replaceAll('\n', ' ')),
        (_goals[1].label, l10n.goal2.replaceAll('\n', ' ')),
        (_goals[2].label, l10n.goal3.replaceAll('\n', ' ')),
      ],
      onPicked: (key, label) => _commitGoal(key, label, editing: editing),
    );
  }

  // Choix unique : on retire l'ancienne sélection avant d'ajouter la nouvelle.
  Future<void> _commitGoal(String key, String label, {required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingGoalOptions = false);
    }
    for (final g in _goals) {
      if (g.label != key) _data.goals.remove(g.label);
    }
    if (!_data.goals.contains(key)) _data.goals.add(key);
    widget.onDataChanged();

    _sayUser(label, onEdit: () => _reopenGoal());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 2;
    await _sayMascot(AppL10n(Lang.code).goalsChatConfirm);
    if (!mounted) return;
    await _askFitness();
  }

  void _reopenGoal() {
    setState(() => _editingControl = (ctx) => _goalControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 3 — Niveau fitness ════════════════════════════════════════════
  Future<void> _askFitness() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.fitnessTitle.replaceAll('\n', ' '));
    if (!mounted) return;
    setState(() => _showingFitnessOptions = true);
  }

  Widget _fitnessControl({required bool editing}) {
    final l10n = AppL10n(Lang.code);
    return _QuickReplyRow(
      options: [
        (_levels[0], l10n.fitnessLevelBeginner),
        (_levels[1], l10n.fitnessLevelIntermediate),
        (_levels[2], l10n.fitnessLevelAdvanced),
      ],
      onPicked: (key, label) => _commitFitness(key, label, editing: editing),
    );
  }

  Future<void> _commitFitness(String key, String label, {required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingFitnessOptions = false);
    }
    _data.fitnessLevel = key;
    widget.onDataChanged();

    _sayUser(label, onEdit: () => _reopenFitness());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 3;
    await _sayMascot(AppL10n(Lang.code).fitnessChatConfirm);
    if (!mounted) return;
    await _askEquipment();
  }

  void _reopenFitness() {
    setState(() => _editingControl = (ctx) => _fitnessControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 4 — Équipement (multi-sélection) ══════════════════════════════
  Future<void> _askEquipment() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.equipmentTitle.replaceAll('\n', ' '));
    if (!mounted) return;
    setState(() => _showingEquipmentOptions = true);
  }

  Map<String, String> _equipmentLabels(AppL10n l10n) => {
    'Aucun matériel': l10n.equipmentNone,
    'Haltères': l10n.equipmentDumbbells,
    'Barre & poids': l10n.equipmentBarbell,
    'Machines': l10n.equipmentMachines,
    'Résistances': l10n.equipmentBands,
    'Tapis de yoga': l10n.equipmentYogaMat,
  };

  // Logique métier inchangée — gère l'exclusivité de "Aucun matériel" via un
  // toggle générique add/remove (comme l'ancien callback partagé du parent).
  void _toggleEquipmentRaw(String item) {
    if (_data.equipment.contains(item)) {
      _data.equipment.remove(item);
    } else {
      _data.equipment.add(item);
    }
  }

  void _handleEquipmentTap(String label) {
    final selected = List<String>.from(_data.equipment);
    if (label == 'Aucun matériel') {
      for (final item in selected) {
        _toggleEquipmentRaw(item);
      }
      if (!selected.contains('Aucun matériel')) _toggleEquipmentRaw('Aucun matériel');
    } else {
      if (selected.contains('Aucun matériel')) _toggleEquipmentRaw('Aucun matériel');
      _toggleEquipmentRaw(label);
    }
    widget.onDataChanged();
    setState(() {});
  }

  Widget _equipmentControl({required bool editing}) {
    final l10n = AppL10n(Lang.code);
    final labels = _equipmentLabels(l10n);
    return _MultiQuickReplyPanel(
      options: _equipments.map((k) => (k, labels[k]!, equipmentIcons[k]!)).toList(),
      selected: _data.equipment,
      onToggle: _handleEquipmentTap,
      confirmLabel: _data.equipment.isNotEmpty
          ? '${l10n.equipmentContinue} (${_data.equipment.length})'
          : l10n.equipmentSelectAtLeastOne,
      onConfirm: _data.equipment.isNotEmpty ? () => _confirmEquipment(editing: editing) : null,
    );
  }

  Future<void> _confirmEquipment({required bool editing}) async {
    if (_data.equipment.isEmpty) return;
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingEquipmentOptions = false);
    }

    final l10n = AppL10n(Lang.code);
    final labels = _equipmentLabels(l10n);
    _sayUser(_data.equipment.map((k) => labels[k] ?? k).join(', '), onEdit: () => _reopenEquipment());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 4;
    await _sayMascot(l10n.equipmentChatConfirm);
    if (!mounted) return;
    await _askLocation();
  }

  void _reopenEquipment() {
    setState(() => _editingControl = (ctx) => _equipmentControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 5 — Lieu d'entraînement ═══════════════════════════════════════
  Future<void> _askLocation() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.locationTitle);
    if (!mounted) return;
    setState(() => _showingLocationOptions = true);
  }

  Widget _locationControl({required bool editing}) {
    final l10n = AppL10n(Lang.code);
    final labels = [l10n.locationGym, l10n.locationHome, l10n.locationBoth];
    return _QuickReplyRow(
      options: List.generate(_locationValues.length,
          (i) => (_locationValues[i], '${_locationEmojis[i]} ${labels[i]}')),
      onPicked: (key, label) => _commitLocation(key, label, editing: editing),
    );
  }

  Future<void> _commitLocation(String key, String label, {required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingLocationOptions = false);
    }
    _data.trainingLocation = key;
    widget.onDataChanged();

    _sayUser(label, onEdit: () => _reopenLocation());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 5;
    await _sayMascot(AppL10n(Lang.code).locationChatConfirm);
    if (!mounted) return;
    await _askFrequency();
  }

  void _reopenLocation() {
    setState(() => _editingControl = (ctx) => _locationControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 6 — Fréquence ═════════════════════════════════════════════════
  Future<void> _askFrequency() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.frequencyTitle.replaceAll('\n', ' '));
    if (!mounted) return;
    setState(() => _showingFrequencyOptions = true);
  }

  Widget _frequencyControl({required bool editing}) {
    return _QuickReplyRow(
      options: List.generate(_freqLabels.length, (i) => (_freqLabels[i], '${i + 2}')),
      onPicked: (key, label) => _commitFrequency(key, label, editing: editing),
    );
  }

  Future<void> _commitFrequency(String key, String label, {required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingFrequencyOptions = false);
    }
    _data.frequency = key;
    widget.onDataChanged();

    _sayUser(label, onEdit: () => _reopenFrequency());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 6;
    await _sayMascot(AppL10n(Lang.code).frequencyChatConfirm);
    if (!mounted) return;
    await _askHeight();
  }

  void _reopenFrequency() {
    setState(() => _editingControl = (ctx) => _frequencyControl(editing: true));
    _scrollToBottom();
  }

  // ══ PHASE 7-9 — Taille / poids / âge (question par question) ═══════════
  Widget _heightPicker() {
    return Center(
      child: _ChatDrumPicker(
        label: AppL10n(Lang.code).healthProfileHeight,
        unit: 'cm',
        selectedIndex: _hIdx,
        controller: _hCtrl,
        itemCount: _maxH - _minH + 1,
        labelFor: (i) => '${_minH + i}',
        onChanged: (i) {
          setState(() => _hIdx = i);
          _data.heightCm = _heightCm;
          widget.onDataChanged();
        },
      ),
    );
  }

  Future<void> _askHeight() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.healthProfileHeightQuestion);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _heightPicker()));
      _showingHeightConfirm = true;
    });
    _scrollToBottom();
  }

  Future<void> _confirmHeight({required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingHeightConfirm = false);
    }
    _sayUser('$_heightCm cm', onEdit: () => _reopenHeight());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 7;
    await _askWeight();
  }

  void _reopenHeight() {
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _heightPicker()));
      _editingControl = (ctx) => _ChatConfirmButton(
        label: AppL10n(Lang.code).frequencyNext,
        onTap: () => _confirmHeight(editing: true));
    });
    _scrollToBottom();
  }

  Widget _weightPicker() {
    return Center(
      child: _ChatDrumPicker(
        label: AppL10n(Lang.code).healthProfileWeight,
        unit: 'kg',
        selectedIndex: _wIdx,
        controller: _wCtrl,
        itemCount: _wList.length,
        labelFor: (i) {
          final w = _wList[i];
          return w % 1 == 0 ? '${w.toInt()}' : w.toStringAsFixed(1);
        },
        onChanged: (i) {
          setState(() => _wIdx = i);
          _data.weightKg = _weightKg;
          widget.onDataChanged();
        },
      ),
    );
  }

  Future<void> _askWeight() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.healthProfileWeightQuestion);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _weightPicker()));
      _showingWeightConfirm = true;
    });
    _scrollToBottom();
  }

  Future<void> _confirmWeight({required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingWeightConfirm = false);
    }
    final weightLabel = _weightKg % 1 == 0 ? '${_weightKg.toInt()}' : _weightKg.toStringAsFixed(1);
    _sayUser('$weightLabel kg', onEdit: () => _reopenWeight());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 8;
    await _askAge();
  }

  void _reopenWeight() {
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _weightPicker()));
      _editingControl = (ctx) => _ChatConfirmButton(
        label: AppL10n(Lang.code).frequencyNext,
        onTap: () => _confirmWeight(editing: true));
    });
    _scrollToBottom();
  }

  Widget _agePicker() {
    return Center(
      child: _ChatDrumPicker(
        label: AppL10n(Lang.code).healthProfileAge,
        unit: AppL10n(Lang.code).healthProfileAgeUnit,
        selectedIndex: _aIdx,
        controller: _aCtrl,
        itemCount: _maxA - _minA + 1,
        labelFor: (i) => '${_minA + i}',
        onChanged: (i) {
          setState(() => _aIdx = i);
          _data.age = _age;
          widget.onDataChanged();
        },
      ),
    );
  }

  Future<void> _askAge() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.healthProfileAgeQuestion);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _agePicker()));
      _showingAgeConfirm = true;
    });
    _scrollToBottom();
  }

  Future<void> _confirmAge({required bool editing}) async {
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingAgeConfirm = false);
    }
    final l10n = AppL10n(Lang.code);
    _sayUser('$_age ${l10n.healthProfileAgeUnit}', onEdit: () => _reopenAge());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 9;
    await _sayMascot(l10n.healthProfileChatConfirm);
    if (!mounted) return;
    setState(() => _messages.add(
        _ChatMessage.mascotInline((ctx) => _BmiCard(bmi: _bmi, label: _bmiLabel, color: _bmiColor))));
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await _askCycleStatus();
  }

  void _reopenAge() {
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => _agePicker()));
      _editingControl = (ctx) => _ChatConfirmButton(
        label: AppL10n(Lang.code).healthProfileContinue,
        onTap: () => _confirmAge(editing: true));
    });
    _scrollToBottom();
  }

  // ══ PHASE 10 — Cycle / grossesse / post-partum ══════════════════════════
  Future<void> _askCycleStatus() async {
    final l10n = AppL10n(Lang.code);
    await _sayMascot(l10n.cycleStepTitle);
    if (!mounted) return;
    setState(() => _showingCycleStatusOptions = true);
  }

  Widget _cycleStatusControl({required bool editing}) {
    final l10n = AppL10n(Lang.code);
    return _QuickReplyRow(
      options: [
        ('cycle', l10n.cycleStatusRegular.replaceAll('\n', ' ')),
        ('pregnant', l10n.cycleStatusPregnant.replaceAll('\n', ' ')),
        ('postpartum', l10n.cycleStatusPostpartum.replaceAll('\n', ' ')),
      ],
      onPicked: (key, label) => _pickCycleStatus(key, label, editing: editing),
    );
  }

  void _pickCycleStatus(String value, String displayLabel, {required bool editing}) {
    HapticFeedback.selectionClick();
    if (!editing) setState(() => _showingCycleStatusOptions = false);
    setState(() => _status = value);
    _data.healthStatus = value;
    widget.onDataChanged();

    _sayUser(displayLabel, onEdit: () => _reopenCycleStatus());
    final inlineBuilder = value == 'cycle'
        ? _cycleWidget
        : value == 'pregnant'
            ? _pregnancyWidget
            : _postpartumWidget;
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => inlineBuilder()));
      _editingControl = (ctx) => _ChatConfirmButton(
        label: _status == 'cycle' ? AppL10n(Lang.code).cycleCtaStart : AppL10n(Lang.code).continueBtn,
        onTap: _canConfirmCycle ? () => _confirmCycleDetails(editing: true) : null,
      );
      if (!editing) _showingCycleConfirm = true;
    });
    _scrollToBottom();
  }

  void _reopenCycleStatus() {
    setState(() => _editingControl = (ctx) => _cycleStatusControl(editing: true));
    _scrollToBottom();
  }

  void _reopenCycleDetails() {
    if (_status == null) return;
    final inlineBuilder = _status == 'cycle'
        ? _cycleWidget
        : _status == 'pregnant'
            ? _pregnancyWidget
            : _postpartumWidget;
    setState(() {
      _messages.add(_ChatMessage.mascotInline((ctx) => inlineBuilder()));
      _editingControl = (ctx) => _ChatConfirmButton(
        label: _status == 'cycle' ? AppL10n(Lang.code).cycleCtaStart : AppL10n(Lang.code).continueBtn,
        onTap: _canConfirmCycle ? () => _confirmCycleDetails(editing: true) : null,
      );
    });
    _scrollToBottom();
  }

  Future<void> _confirmCycleDetails({required bool editing}) async {
    if (!_canConfirmCycle) return;
    HapticFeedback.selectionClick();
    if (editing) {
      setState(() => _editingControl = null);
    } else {
      setState(() => _showingCycleConfirm = false);
    }

    final l10n = AppL10n(Lang.code);
    final summary = _status == 'cycle'
        ? '${l10n.cycleStatusRegular.replaceAll('\n', ' ')} · $_cycleDuration · ${_fmt(_lastPeriod)}'
        : _status == 'pregnant'
            ? '${l10n.cycleStatusPregnant.replaceAll('\n', ' ')} · SA $_weekSA'
            : '${l10n.cycleStatusPostpartum.replaceAll('\n', ' ')} · ${_fmt(_birthDate!)}';
    _sayUser(summary, onEdit: () => _reopenCycleDetails());
    if (editing) {
      await _ackEdit();
      return;
    }
    _completedPhases = 10;
    await _sayMascot(l10n.cycleChatConfirm);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    widget.onFinish();
  }

  // ── CYCLE content ──────────────────────────────────────────────────────────
  Widget _cycleWidget() {
    return Column(
      key: const ValueKey('cycle'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _phaseStrip(),
        const SizedBox(height: 20),
        Text(AppL10n(Lang.code).cycleDurationLabel,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: _kTextDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _cycleDurations.map((d) {
            final sel = _cycleDuration == d;
            return GestureDetector(
              onTap: () {
                setState(() => _cycleDuration = d);
                _data.cycleDuration = d;
                widget.onDataChanged();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                  color: sel ? _kGreenDark : _kGlassFill,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: sel ? _kGreenDark : _kGlassBorder,
                  ),
                ),
                child: Text(d, style: TextStyle(
                    color: sel ? Colors.white : _kTextDark,
                    fontWeight: FontWeight.w600, fontSize: 13.5)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text(AppL10n(Lang.code).cycleLastPeriod,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: _kTextDark)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickLastPeriodDate,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _kGlassFill,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: _kGlassBorder),
            ),
            child: Row(children: [
              const Icon(LucideIcons.calendarDays,
                  size: 18, color: _kTextMuted),
              const SizedBox(width: 12),
              Text(_fmt(_lastPeriod),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16, color: _kTextDark)),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  color: _kTextMuted, size: 18),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        _nextPeriodPill(),
      ],
    );
  }

  Widget _phaseStrip() {
    final days =
        int.tryParse(_cycleDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 28;
    final follDays = max(1, (days * 0.32).round() - 2);
    final lutDays = max(1, days - 5 - follDays - 2);
    final l10n = AppL10n(Lang.code);
    final phases = [
      _CyclePhase(l10n.cyclePhaseMenstruation, 5, const Color(0xFFE8A0A0)),
      _CyclePhase(l10n.cyclePhaseFollicular, follDays, const Color(0xFFEDD07A)),
      _CyclePhase(l10n.cyclePhaseOvulation, 2, const Color(0xFF7AC998)),
      _CyclePhase(l10n.cyclePhaseLuteal, lutDays, const Color(0xFFB8A8D4)),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(AppL10n(Lang.code).cycleAtAGlance,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
              color: _kTextMuted, letterSpacing: 0.4)),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: phases.map((p) => Expanded(
            flex: p.days,
            child: Container(height: 10, color: p.color),
          )).toList(),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: phases.map((p) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6,
                decoration: BoxDecoration(
                    color: p.color, shape: BoxShape.circle)),
            const SizedBox(width: 3),
            Text(p.name, style: const TextStyle(
                fontSize: 9.5, color: _kTextMuted,
                fontWeight: FontWeight.w500)),
          ],
        )).toList(),
      ),
    ]);
  }

  Widget _nextPeriodPill() {
    final diff = _nextPeriod.difference(DateTime.now()).inDays;
    final l10n = AppL10n(Lang.code);
    final label = diff > 0
        ? '${l10n.cycleNextPeriodIn} $diff ${l10n.cycleNextPeriodDays} · ${_fmt(_nextPeriod)}'
        : diff == 0
            ? '${l10n.cycleNextPeriodToday} · ${_fmt(_nextPeriod)}'
            : '${l10n.cycleNextPeriodExpected} · ${_fmt(_nextPeriod)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _kGlassBorder),
      ),
      child: Row(children: [
        const Icon(LucideIcons.moon, size: 13, color: _kGreenMid),
        const SizedBox(width: 8),
        Flexible(
          child: Text(label, style: const TextStyle(
              fontSize: 12, color: _kTextMuted,
              fontWeight: FontWeight.w500)),
        ),
      ]),
    );
  }

  // ── PREGNANCY content ──────────────────────────────────────────────────────
  Widget _pregnancyWidget() {
    return Column(
      key: const ValueKey('pregnancy'),
      children: [
        Center(
          child: _ChatDrumPicker(
            label: AppL10n(Lang.code).cyclePregnancyWeeksLabel,
            unit: 'SA',
            selectedIndex: _weekIdx,
            controller: _weekCtrl,
            itemCount: 42,
            labelFor: (i) => '${i + 1}',
            onChanged: (i) {
              setState(() => _weekIdx = i);
              _data.pregnancyWeekSA = i + 1;
              widget.onDataChanged();
            },
          ),
        ),
        const SizedBox(height: 16),
        _trimesterBar(),
        const SizedBox(height: 12),
        _adviceCard(),
      ],
    );
  }

  Widget _trimesterBar() {
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: List.generate(3, (i) {
            final t = i + 1;
            final active = _trimester == t;
            final passed = _trimester > t;
            return Expanded(child: Container(
              height: 8,
              color: active
                  ? _kGreenDark
                  : passed
                      ? _kGreenMid.withValues(alpha: 0.45)
                      : _kGlassBorder,
            ));
          }),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: List.generate(3, (i) {
        final t = i + 1;
        final active = _trimester == t;
        return Expanded(child: Column(children: [
          Text(
            t == 1 ? 'S1–S13' : t == 2 ? 'S14–S27' : 'S28–S42',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: active ? _kGreenDark : _kTextMuted,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text('T$t', textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: active ? _kTextDark : _kTextMuted,
              fontWeight: active ? FontWeight.w800 : FontWeight.w400,
            )),
        ]));
      })),
    ]);
  }

  Widget _adviceCard() {
    final l10n = AppL10n(Lang.code);
    final label = _trimester == 1
        ? l10n.cycleTrimester1Label
        : _trimester == 2
            ? l10n.cycleTrimester2Label
            : l10n.cycleTrimester3Label;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: _kGreenDark.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.favorite_outline,
            size: 14, color: _kGreenBright),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: _kTextDark)),
          const SizedBox(height: 4),
          Text(_trimesterAdvice, style: const TextStyle(
              fontSize: 12.5, color: _kTextMuted, height: 1.5)),
        ],
      )),
    ]);
  }

  // ── POST-PARTUM content ────────────────────────────────────────────────────
  Widget _postpartumWidget() {
    final weeks = _birthDate != null
        ? DateTime.now().difference(_birthDate!).inDays ~/ 7
        : null;

    return Column(
      key: const ValueKey('postpartum'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 4),

        // ── Titre + sous-titre ────────────────────────────────────────────
        Text(AppL10n(Lang.code).ppWhenDidYouGiveBirth,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextDark)),
        const SizedBox(height: 4),
        Text(AppL10n(Lang.code).ppAutoCalculate,
          style: const TextStyle(fontSize: 12, color: _kTextMuted)),
        const SizedBox(height: 14),

        // ── Date picker card ──────────────────────────────────────────────
        GestureDetector(
          onTap: () async {
            final picked = await showCustomDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
              lastDate: DateTime.now(),
              title: AppL10n(Lang.code).datePickerBirthTitle,
              subtitle: AppL10n(Lang.code).datePickerBirthSub,
              icon: Icons.child_care_rounded,
              accentColor: const Color(0xFF2D4A2D),
            );
            if (picked != null && mounted) {
              final w = DateTime.now().difference(picked).inDays ~/ 7;
              final String dur;
              if (w < 2)       dur = '0-2';
              else if (w < 6)  dur = '2-6';
              else if (w < 12) dur = '6-12';
              else if (w < 26) dur = '3-6m';
              else             dur = '6m+';
              setState(() { _birthDate = picked; _ppDuration = dur; });
              _data.ppDuration = dur;
              widget.onDataChanged();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _birthDate != null
                    ? _kGreenMid.withValues(alpha: 0.6)
                    : _kGlassBorder,
                width: _birthDate != null ? 1.2 : 0.8),
            ),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _birthDate != null
                      ? _kGreenDark.withValues(alpha: 0.15)
                      : _kGlassFill,
                  shape: BoxShape.circle),
                child: Icon(Icons.calendar_today_rounded,
                  size: 15,
                  color: _birthDate != null ? _kGreenBright : _kTextMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _birthDate == null
                  ? Text(AppL10n(Lang.code).ppSelectBirthDate,
                      style: const TextStyle(fontSize: 13.5, color: _kTextMuted))
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        '${_birthDate!.day.toString().padLeft(2,'0')} / '
                        '${_birthDate!.month.toString().padLeft(2,'0')} / '
                        '${_birthDate!.year}',
                        style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: _kTextDark)),
                      const SizedBox(height: 2),
                      Text(
                        weeks == 0
                          ? AppL10n(Lang.code).ppLessThanOneWeek
                          : '$weeks ${weeks == 1 ? (AppL10n(Lang.code).isFrench ? 'semaine' : 'week') : (AppL10n(Lang.code).isFrench ? 'semaines' : 'weeks')} ${AppL10n(Lang.code).ppWeeksSince}',
                        style: TextStyle(fontSize: 12, color: _kGreenDark.withValues(alpha: 0.75))),
                    ]),
              ),
              if (_birthDate != null)
                const Icon(Icons.edit_calendar_rounded, color: _kGreenDark, size: 18)
              else
                Icon(Icons.chevron_right_rounded, color: _kTextMuted, size: 22),
            ]),
          ),
        ),

        // ── Barre de progression semaines ─────────────────────────────────
        if (_birthDate != null && weeks != null) ...[
          const SizedBox(height: 18),
          _BirthWeekBar(weeks: weeks),
        ],

        // ── Programme assigné ─────────────────────────────────────────────
        if (_ppProgram.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _ppProgramColor.withValues(alpha: 0.15),
                shape: BoxShape.circle),
              child: Icon(LucideIcons.heartPulse, size: 15, color: _ppProgramColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('${AppL10n(Lang.code).ppProgramLabel} ', style: TextStyle(
                    fontSize: 11.5, color: _ppProgramColor, fontWeight: FontWeight.w500)),
                  Text(_ppProgram, style: TextStyle(
                    fontSize: 15, color: _ppProgramColor, fontWeight: FontWeight.w800,
                    letterSpacing: 0.3)),
                ]),
                const SizedBox(height: 3),
                Text(_ppProgramDesc, style: const TextStyle(
                  fontSize: 11.5, color: _kTextMuted, height: 1.4)),
              ],
            )),
          ]),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────
  Widget? _mainTrailing() {
    if (_showingMascotOptions) return _mascotControl(editing: false);
    if (_showingGoalOptions) return _goalControl(editing: false);
    if (_showingFitnessOptions) return _fitnessControl(editing: false);
    if (_showingEquipmentOptions) return _equipmentControl(editing: false);
    if (_showingLocationOptions) return _locationControl(editing: false);
    if (_showingFrequencyOptions) return _frequencyControl(editing: false);
    if (_showingHeightConfirm) {
      return _ChatConfirmButton(
        label: AppL10n(Lang.code).frequencyNext,
        onTap: () => _confirmHeight(editing: false));
    }
    if (_showingWeightConfirm) {
      return _ChatConfirmButton(
        label: AppL10n(Lang.code).frequencyNext,
        onTap: () => _confirmWeight(editing: false));
    }
    if (_showingAgeConfirm) {
      return _ChatConfirmButton(
        label: AppL10n(Lang.code).healthProfileContinue,
        onTap: () => _confirmAge(editing: false));
    }
    if (_showingCycleStatusOptions) return _cycleStatusControl(editing: false);
    if (_showingCycleConfirm) {
      final l10n = AppL10n(Lang.code);
      return _ChatConfirmButton(
        label: _status == 'cycle' ? l10n.cycleCtaStart : l10n.continueBtn,
        onTap: _canConfirmCycle ? () => _confirmCycleDetails(editing: false) : null,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rawTrailing = _editingControl != null ? _editingControl!(context) : _mainTrailing();
    final trailing = rawTrailing == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(left: 42, top: 4, bottom: 8),
            child: rawTrailing,
          );

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: _completedPhases, total: _totalPhases, onBack: widget.onBack),
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                itemCount: _messages.length + (trailing != null ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i < _messages.length) {
                    final m = _messages[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: m.isTyping
                          ? _TypingBubble(mascotType: _mascotType)
                          : _ChatBubble(sender: m.sender, text: m.text, inline: m.inline,
                              mascotType: _mascotType, onTap: m.onEdit),
                    );
                  }
                  return trailing!;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Données partagées — équipement disponible, utilisées par la phase
// "équipement" du fil de chat unique (OnboardingChatFlow).
final Map<String, IconData> equipmentIcons = {
  'Aucun matériel': LucideIcons.circleOff,
  'Haltères': LucideIcons.dumbbell,
  'Barre & poids': LucideIcons.activity,
  'Machines': LucideIcons.cog,
  'Résistances': LucideIcons.gitBranch,
  'Tapis de yoga': LucideIcons.flower,
};

// ⚠️ assure-toi que cette liste existe
final List<String> _equipments = [
  'Aucun matériel',
  'Haltères',
  'Barre & poids',
  'Machines',
  'Résistances',
  'Tapis de yoga',
];


// ── Callout bubble (fixed, full-width, arrow at bottom-center) ───────────────

class _FreqCallout extends StatelessWidget {
  final String text;
  const _FreqCallout({required this.text});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CalloutPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _kTextDark,
          ),
        ),
      ),
    );
  }
}

class _CalloutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _kGlassFill
      ..style = PaintingStyle.fill;

    const r      = 20.0;
    const arrowH = 10.0;
    const arrowW = 18.0;
    final bodyH  = size.height - arrowH;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, bodyH),
        const Radius.circular(r),
      ))
      ..moveTo(size.width / 2 - arrowW / 2, bodyH)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + arrowW / 2, bodyH)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}


// ─── Compact drum-wheel picker — habillage natif pour bulle de chat ───────────
// Pas de carte/bordure propre (on est déjà dans une _ChatBubble), pas de fondu
// de bord (sa couleur fixe jurait avec le fond translucide de la bulle) : juste
// le libellé, la roue et l'unité, posés directement sur le fond de la bulle.
class _ChatDrumPicker extends StatelessWidget {
  final String label;
  final String unit;
  final int selectedIndex;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelFor;
  final ValueChanged<int> onChanged;

  const _ChatDrumPicker({
    required this.label,
    required this.unit,
    required this.selectedIndex,
    required this.controller,
    required this.itemCount,
    required this.labelFor,
    required this.onChanged,
  });

  static const double _kItemH = 38.0;
  static const int _kVisible = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: _kGreenMid,
            )),
        const SizedBox(height: 6),
        SizedBox(
          width: 120,
          height: _kItemH * _kVisible,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection highlight band
              Container(
                height: _kItemH,
                decoration: BoxDecoration(
                  color: _kGreenDark.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kGreenMid.withValues(alpha: 0.4), width: 1),
                ),
              ),
              // Scroll wheel
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: _kItemH,
                perspective: 0.003,
                diameterRatio: 1.4,
                squeeze: 1.1,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  HapticFeedback.selectionClick();
                  TickSoundService.instance.tick();
                  onChanged(i);
                },
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (_, i) {
                    final sel = i == selectedIndex;
                    return Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          fontSize: sel ? 19 : 14,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w400,
                          color: sel ? _kGreenBright : _kTextMuted.withValues(alpha: 0.65),
                        ),
                        child: Text(labelFor(i)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(unit,
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: _kTextMuted)),
      ],
    );
  }
}

// ─── BMI result card ──────────────────────────────────────────────────────────
class _BmiCard extends StatelessWidget {
  final double bmi;
  final String label;
  final Color color;

  const _BmiCard(
      {required this.bmi, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kGlassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IMC',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                      color: _kTextMuted)),
              const SizedBox(height: 4),
              Text(bmi.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: _kTextDark)),
            ],
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ── Barre de progression de récupération post-partum ─────────────────────────
class _BirthWeekBar extends StatelessWidget {
  final int weeks;
  const _BirthWeekBar({required this.weeks});

  @override
  Widget build(BuildContext context) {
    // Phases : 0-2 / 2-6 / 6-12 / 12-26 / 26+
    const phases = [
      (label: '0–2 sem.', maxW: 2,  color: Color(0xFFE53935)),
      (label: '2–6 sem.', maxW: 6,  color: Color(0xFFFB8C00)),
      (label: '6–12 sem.',maxW: 12, color: Color(0xFFFFA726)),
      (label: '3–6 mois', maxW: 26, color: Color(0xFF66BB6A)),
      (label: '6+ mois',  maxW: 99, color: Color(0xFF2E7D32)),
    ];

    int activeIdx = 0;
    for (int i = 0; i < phases.length; i++) {
      if (weeks < phases[i].maxW) { activeIdx = i; break; }
      if (i == phases.length - 1)  activeIdx = i;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segments colorés
        Row(
          children: List.generate(phases.length, (i) {
            final isActive = i == activeIdx;
            final isPast   = i < activeIdx;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                height: isActive ? 7 : 5,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isPast || isActive
                      ? phases[i].color
                      : phases[i].color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isActive
                      ? [BoxShadow(color: phases[i].color.withValues(alpha: 0.40),
                          blurRadius: 6, offset: const Offset(0, 2))]
                      : [],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 7),
        // Label de la phase active
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: phases[activeIdx].color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: phases[activeIdx].color.withValues(alpha: 0.30)),
            ),
            child: Text(
              '${AppL10n(Lang.code).ppPhaseLabel} : ${phases[activeIdx].label}',
              style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600,
                color: phases[activeIdx].color),
            ),
          ),
        ),
      ],
    );
  }
}

// Data holder for cycle phase strip
class _CyclePhase {
  final String name;
  final int days;
  final Color color;
  const _CyclePhase(this.name, this.days, this.color);
}

// ── Post-partum progressive phase card ────────────────────────────────────────
enum _PpStatus { unselected, current, next }

class _PpPhaseCard extends StatelessWidget {
  final bool show;
  final String value;
  final String emoji;
  final String label;
  final String desc;
  final _PpStatus status;
  final VoidCallback onTap;

  const _PpPhaseCard({
    required this.show,
    required this.value,
    required this.emoji,
    required this.label,
    required this.desc,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = status == _PpStatus.current;
    final isNext    = status == _PpStatus.next;

    return AnimatedSize(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
      child: show
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isCurrent
                        ? const LinearGradient(
                            colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCurrent
                        ? null
                        : isNext
                            ? Colors.white.withValues(alpha:0.60)
                            : _kGlassFill,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.transparent
                          : isNext
                              ? _kGlassBorder
                              : _kGlassBorder,
                      width: 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [BoxShadow(color: _kGreenDark.withValues(alpha:0.30), blurRadius: 16, offset: const Offset(0, 5))]
                        : isNext
                            ? [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 8)]
                            : [],
                  ),
                  child: Row(
                    children: [
                      // Emoji circle
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.white.withValues(alpha:0.18)
                              : _kGlassFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Label + description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isCurrent ? Colors.white : _kTextDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.4,
                                color: isCurrent
                                    ? Colors.white.withValues(alpha:0.70)
                                    : _kTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Status badge
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.22),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('🟢', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text('ACTUELLE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: 0.5)),
                          ]),
                        )
                      else if (isNext)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _kGlassFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('🔜', style: TextStyle(fontSize: 11)),
                            SizedBox(width: 4),
                            Text('PROCHAINE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                color: _kGreenDark, letterSpacing: 0.5)),
                          ]),
                        )
                      else
                        const Icon(Icons.chevron_right, color: _kTextMuted, size: 20),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

