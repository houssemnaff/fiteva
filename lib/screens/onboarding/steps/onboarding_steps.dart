import 'dart:async';
import 'dart:math';

import 'package:fiteva/screens/onboarding/widgets/shared_onboarding_widgets.dart';
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
import '../onboarding_screen.dart' show OnboardingData;

// ─── Responsive helpers ────────────────────────────────────────────────────
// Reference device: 390 × 844 (iPhone 14)
extension _R on BuildContext {
  double get _w => MediaQuery.of(this).size.width;
  double get _h => MediaQuery.of(this).size.height;
  /// Scale a horizontal/font value relative to reference width 390
  double rs(double v) => (v * _w / 390).clamp(v * 0.78, v * 1.28);
  /// Scale a vertical spacing relative to reference height 844
  double rv(double v) => (v * _h / 844).clamp(v * 0.68, v * 1.22);
  bool get isSmall => _h < 700;   // SE, Fold outer, older Androids
  bool get isLarge => _h > 900;   // Pro Max, tablets
}

// ─── Design Tokens — Clean White Palette ─────────────────────────────────
const _kBgDark       = Color(0xFFF8F8F8);
const _kBgMid        = Color(0xFFF2F2F2);
const _kBgMint       = Color(0xFFF8F8F8);
const _kBgLight      = Color(0xFFF2F2F2);
const _kGreenDark    = Color(0xFF1B5E3B);
const _kGreenMid     = Color(0xFF276E4A);
const _kGreenBright  = Color(0xFF1B5E3B);
const _kCardUnsel    = Color(0xFFF2F2F2);
const _kCardSel      = Color(0xFF1B5E3B);
const _kTextDark     = Color(0xFF1A1A1A);
const _kTextMuted    = Color(0xFF8E8E93);
const _kWhite        = Colors.white;
const _kBorderLight  = Color(0xFFE5E5E5);
const _kGlassBorder  = Color(0xFFE5E5E5);
const _kGlassFill    = Color(0xFFF5F5F5);

// ─── Clean white background ──────────────────────────────────────────────────
Widget _stepBackground({required Widget child}) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F5EC),
            Color(0xFFF0FAF3),
            Color(0xFFFCFDFC),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    ),
  );
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar — minimal back arrow + step counter
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
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
                ),
                child: const Icon(LucideIcons.arrowLeft, size: 18,
                    color: Color(0xFF1A3C2A)),
              ),
            ),
            const Spacer(),
            if (title != null) ...[
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3C2A)),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _kGreenBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$step / $total',
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: _kGreenBright),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icône — frosted circle with glow
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kGreenBright.withValues(alpha: 0.12),
          boxShadow: [
            BoxShadow(
              color: _kGreenBright.withValues(alpha: 0.15),
              blurRadius: 20, spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: _kGreenBright, size: 24),
      ),
    );
  }
}

/// Titre + sous-titre — left-aligned editorial type
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A3C2A),
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF5A7A66),
            height: 1.5,
          ),
        ),
      ],
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
              ? _kGreenBright.withValues(alpha: 0.08)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _kGreenBright.withValues(alpha: 0.5)
                : const Color(0xFFE8E8E8),
            width: 1,
          ),
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
                          color: selected ? _kGreenBright : _kTextDark)),
                        const SizedBox(height: 2),
                        Text(sublabel!, style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: selected ? Colors.white70 : _kTextMuted)),
                      ],
                    )
                  : Text(label, style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: selected ? _kGreenBright : _kTextDark)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _kGreenBright : Colors.transparent,
                border: Border.all(
                  color: selected ? _kGreenBright : const Color(0xFFD0D0D0),
                  width: 1.5),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
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
              ? _kGreenBright.withValues(alpha: 0.08)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _kGreenBright.withValues(alpha: 0.5)
                : const Color(0xFFE8E8E8),
            width: 1,
          ),
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

/// CTA button — solid green, no shadow
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _CtaButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF1B5E3B), Color(0xFF276E4A)])
                  : null,
              color: enabled ? null : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: enabled
                  ? null
                  : Border.all(color: const Color(0xFFCCDDD3), width: 1),
              boxShadow: enabled
                  ? [BoxShadow(
                      color: const Color(0xFF1B5E3B).withValues(alpha: 0.3),
                      blurRadius: 16, offset: const Offset(0, 6))]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.white : const Color(0xFF5A7A66),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Scaffold mint de base ─────────────────────────────────────────────────
Widget _mintScaffold({required Widget child}) => _stepBackground(child: child);

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepLanguageChoice  (Welcome + language pick — premium first impression)
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
  late final AnimationController _leafCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _leafCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _leafCtrl.dispose();
    super.dispose();
  }

  void _pick(String lang) {
    HapticFeedback.mediumImpact();
    setState(() => _selected = lang);
  }

  void _onContinue() {
    if (_selected == null) return;
    widget.onNext(Locale(_selected!));
  }

  @override
  Widget build(BuildContext context) {
    final leafGrow = CurvedAnimation(parent: _leafCtrl,
        curve: Curves.elasticOut);
    final logoFade = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut));
    final titleSlide = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut));
    final cards = CurvedAnimation(parent: _enterCtrl,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5EC),   // soft mint top
              Color(0xFFF0FAF3),   // lighter mid
              Color(0xFFFCFDFC),   // almost white bottom
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating blobs
            Positioned(
              top: -40, right: -30,
              child: FadeTransition(
                opacity: logoFade,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B5E3B).withValues(alpha: 0.07),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120, left: -50,
              child: FadeTransition(
                opacity: titleSlide,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6DC88F).withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80, right: -20,
              child: FadeTransition(
                opacity: cards,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B5E3B).withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo — leaf grows in, text fades
                    FadeTransition(
                      opacity: logoFade,
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: leafGrow,
                            child: Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E3B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset('assets/images/logfiteva.jpeg',
                                    fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('FITEVA', style: GoogleFonts.outfit(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A3C2A), letterSpacing: 5)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Greeting — slides up
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(titleSlide),
                      child: FadeTransition(
                        opacity: titleSlide,
                        child: Column(
                          children: [
                            Text('Welcome to FITEVA', style: GoogleFonts.outfit(
                              fontSize: 26, fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A3C2A), letterSpacing: -0.5)),
                            const SizedBox(height: 8),
                            Text(
                              "Set up your personalized fitness\njourney in under 2 minutes.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 15, color: const Color(0xFF5A7A66), height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Section label
                    FadeTransition(
                      opacity: cards,
                      child: Row(
                        children: [
                          Icon(LucideIcons.globe, size: 16,
                              color: const Color(0xFF5A7A66)),
                          const SizedBox(width: 8),
                          Text('Choose your language', style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: const Color(0xFF5A7A66), letterSpacing: 0.3)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Language cards
                    FadeTransition(
                      opacity: cards,
                      child: Column(
                        children: [
                          _LangOption(
                            flag: '🇫🇷', label: 'Français',
                            isSelected: _selected == 'fr',
                            onTap: () => _pick('fr'),
                          ),
                          const SizedBox(height: 10),
                          _LangOption(
                            flag: '🇬🇧', label: 'English',
                            isSelected: _selected == 'en',
                            onTap: () => _pick('en'),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Continue button — fades + slides in when selected
                    AnimatedSlide(
                      offset: _selected != null
                          ? Offset.zero
                          : const Offset(0, 0.3),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _selected != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: _onContinue,
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E3B), Color(0xFF276E4A)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E3B).withValues(alpha: 0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue', style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangOption extends StatefulWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LangOption> createState() => _LangOptionState();
}

class _LangOptionState extends State<_LangOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.isSelected;
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) { _scaleCtrl.reverse(); widget.onTap(); },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: sel
                ? const Color(0xFFE8F5EC)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel
                  ? _kGreenBright.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.6),
              width: sel ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? const Color(0xFF1B5E3B).withValues(alpha: 0.12)
                    : const Color(0xFF000000).withValues(alpha: 0.04),
                blurRadius: sel ? 12 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(widget.label, style: GoogleFonts.inter(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3C2A))),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? _kGreenBright : Colors.white.withValues(alpha: 0.6),
                  border: Border.all(
                    color: sel ? _kGreenBright : const Color(0xFFCCDDD3),
                    width: sel ? 0 : 1.5),
                ),
                child: sel
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 0 — StepIntro  (cinematic dark hero screen — MOTRA-inspired)
// ══════════════════════════════════════════════════════════════════════════════
class StepIntro extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onSignIn;
  const StepIntro({super.key, required this.onNext, this.onSignIn});

  @override
  State<StepIntro> createState() => _StepIntroState();
}

class _StepIntroState extends State<StepIntro>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _bgCtrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _tagFade;
  late final Animation<double> _chipsFade;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  // Background image crossfade
  int _bgIndex = 0;
  Timer? _bgTimer;

  static const _bgImages = [
    'assets/images/slide_gym1.jpg',
    'assets/images/slide_gym2.jpg',
    'assets/images/slide_gym3.jpg',
    'assets/images/slide_gym4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Animation<double> iv(double s, double e) => CurvedAnimation(
          parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut));

    _logoFade  = iv(0.0, 0.35);
    _tagFade   = iv(0.2, 0.5);
    _chipsFade = iv(0.35, 0.6);
    _btnFade   = iv(0.5, 0.8);
    _btnSlide  = Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic)));

    _bgTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _bgIndex = (_bgIndex + 1) % _bgImages.length);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _bgCtrl.dispose();
    _bgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with crossfade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            child: SizedBox.expand(
              key: ValueKey(_bgIndex),
              child: Image.asset(
                _bgImages[_bgIndex],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF0A0A0A)),
              ),
            ),
          ),

          // Dark cinematic overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.55, 0.85, 1.0],
                  colors: [
                    const Color(0xFF0A0A0A).withValues(alpha: 0.7),
                    const Color(0xFF0A0A0A).withValues(alpha: 0.25),
                    Colors.transparent,
                    const Color(0xFF0A0A0A).withValues(alpha: 0.5),
                    const Color(0xFF0A0A0A).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: sh * 0.08),

                  // App name
                  FadeTransition(
                    opacity: _logoFade,
                    child: Text(
                      "FITEVA",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 6,
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Tagline
                  FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      "Train smarter.\nLive stronger.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: (sh * 0.035).clamp(24.0, 32.0),
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.25,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.03),

                  // Feature badges
                  FadeTransition(opacity: _chipsFade, child: _buildBadges()),

                  const Spacer(flex: 2),

                  // Get Started button
                  FadeTransition(
                    opacity: _btnFade,
                    child: SlideTransition(
                      position: _btnSlide,
                      child: _buildGetStartedBtn(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // "Already have an account? Sign in"
                  FadeTransition(
                    opacity: _btnFade,
                    child: _buildLoginLink(),
                  ),

                  SizedBox(height: bottomPad + 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _IntroBadge(icon: LucideIcons.dumbbell, label: 'Workouts'),
        _IntroBadge(icon: LucideIcons.heart, label: 'Cycle'),
        _IntroBadge(icon: LucideIcons.apple, label: 'Nutrition'),
        _IntroBadge(icon: LucideIcons.users, label: 'Community'),
        _IntroBadge(icon: LucideIcons.activity, label: 'Health'),
        _IntroBadge(icon: LucideIcons.shoppingBag, label: 'Shop'),
      ],
    );
  }

  Widget _buildGetStartedBtn() => GestureDetector(
        onTap: widget.onNext,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E3B), Color(0xFF276E4A)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1B5E3B).withValues(alpha: 0.35),
                blurRadius: 20, offset: const Offset(0, 6)),
            ],
          ),
          child: Center(
            child: Text(
              "Get Started",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

  Widget _buildLoginLink() {
    return GestureDetector(
      onTap: widget.onSignIn ?? widget.onNext,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Sign in',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _IntroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1 — StepWelcome (dark cinematic auth — MOTRA-inspired)
// ══════════════════════════════════════════════════════════════════════════════

const _kPrimary     = Color(0xFF1B5E3B);
const _kDark        = Color(0xFF0A0A0A);
const _kGrey        = Color(0xFF8E8E93);
const _kSurface     = Color(0xFFF5F5F5);

class StepWelcome extends StatefulWidget {
  final Future<String?> Function(String email, String password) onSignUp;
  final Future<String?> Function(String email, String password) onLogin;
  final Future<void> Function()? onGoogleSignIn;
  final Future<void> Function()? onAppleSignIn;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? nameController;
  final VoidCallback? onBack;
  final bool initialLoginMode;

  const StepWelcome({
    super.key,
    required this.onSignUp,
    required this.onLogin,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.emailController,
    required this.passwordController,
    this.nameController,
    this.onBack,
    this.initialLoginMode = false,
  });

  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<StepWelcome>
    with TickerProviderStateMixin {

  late bool _isLoginMode;
  bool _emailFormOpen = false;
  bool _obscure      = true;
  String? _error;
  bool _submitting   = false;
  bool _resetSubmitting = false;
  bool _googleSubmitting = false;
  bool _appleSubmitting  = false;

  late final TextEditingController _nameCtrl;
  bool _ownsNameCtrl = false;

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool get _canSubmit =>
      widget.emailController.text.trim().isNotEmpty &&
      widget.passwordController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final email = widget.emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Invalid email address.');
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

  Future<void> _forgotPassword() async {
    final email = widget.emailController.text.trim();
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _error = 'Enter your email above to receive a reset link.');
      return;
    }
    setState(() { _resetSubmitting = true; _error = null; });
    final result = await AuthService.resetPassword(email);
    if (!mounted) return;
    setState(() => _resetSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.isSuccess
          ? 'Reset email sent to $email.'
          : (result.error ?? 'Failed to send email.')),
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
    _isLoginMode = widget.initialLoginMode;
    if (widget.nameController != null) {
      _nameCtrl = widget.nameController!;
    } else {
      _nameCtrl = TextEditingController();
      _ownsNameCtrl = true;
    }
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    if (_ownsNameCtrl) _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (blurred via dark overlay)
          Positioned.fill(
            child: Image.asset(
              'assets/images/slide_gym1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF0A0A0A)),
            ),
          ),

          // Dark frosted overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    _kDark.withValues(alpha: 0.75),
                    _kDark.withValues(alpha: 0.45),
                    _kDark.withValues(alpha: 0.55),
                    _kDark.withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _emailFormOpen
                  ? _buildEmailFormView(bottomPad)
                  : _buildAuthOptionsView(bottomPad),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main auth options view (Apple / Google / Email buttons) ───────────────
  Widget _buildAuthOptionsView(double bottomPad) {
    return Column(
      children: [
        // Close button → back to intro
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: GestureDetector(
              onTap: widget.onBack ?? () => Navigator.maybePop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.close_rounded, size: 20,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ),
        ),

        const Spacer(flex: 2),

        // App name
        Text(
          'FITEVA',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 6,
          ),
        ),

        const SizedBox(height: 16),

        // Headline
        Text(
          _isLoginMode ? 'Welcome Back.' : 'Your fitness,\nyour way.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.3,
          ),
        ),

        const Spacer(flex: 3),

        // Terms
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.4),
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'By continuing, you agree to FitEva\'s\n'),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Auth buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Continue with Apple
              _DarkAuthBtn(
                icon: Icons.apple_rounded,
                label: 'Continue with Apple',
                style: _DarkAuthBtnStyle.white,
                loading: _appleSubmitting,
                onTap: _handleAppleSignIn,
              ),

              const SizedBox(height: 10),

              // Continue with Google
              _DarkAuthBtn(
                svgIcon: 'assets/images/google-color.svg',
                label: 'Continue with Google',
                style: _DarkAuthBtnStyle.frosted,
                loading: _googleSubmitting,
                onTap: _handleGoogleSignIn,
              ),

              const SizedBox(height: 10),

              // Continue with Email
              _DarkAuthBtn(
                icon: Icons.mail_outline_rounded,
                label: 'Continue with Email',
                style: _DarkAuthBtnStyle.frosted,
                onTap: () => setState(() => _emailFormOpen = true),
              ),
            ],
          ),
        ),

        // Toggle login/signup
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() {
            _isLoginMode = !_isLoginMode;
            _error = null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              _isLoginMode
                  ? "Don't have an account? Sign up"
                  : 'Already have an account? Sign in',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),

        SizedBox(height: bottomPad + 16),
      ],
    );
  }

  // ─── Email form view (full-screen dark form) ──────────────────────────────
  Widget _buildEmailFormView(double bottomPad) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomPad + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _emailFormOpen = false;
                _error = null;
              }),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(LucideIcons.arrowLeft, size: 18,
                    color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              _isLoginMode ? 'Welcome back' : 'Sign up with email',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              _isLoginMode
                  ? 'Enter your email and password to continue.'
                  : 'Enter your name, email, and a password to start training.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Form fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                if (!_isLoginMode) ...[
                  _DarkField(
                    controller: _nameCtrl,
                    hint: 'Full name',
                    keyboardType: TextInputType.name,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                ],

                _DarkField(
                  controller: widget.emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() => _error = null),
                ),

                const SizedBox(height: 12),

                _DarkField(
                  controller: widget.passwordController,
                  hint: 'Password',
                  obscure: _obscure,
                  suffix: GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure ? Icons.visibility_off_outlined
                               : Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.3), size: 18),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                ),

                if (_isLoginMode) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _resetSubmitting ? null : _forgotPassword,
                      child: Text(
                        _resetSubmitting ? 'Sending...' : 'Forgot password?',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_error!,
                        style: GoogleFonts.inter(
                            color: const Color(0xFFFF6B6B),
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ],

                const SizedBox(height: 24),

                // Continue button
                GestureDetector(
                  onTap: (_canSubmit && !_submitting) ? _submit : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _canSubmit
                          ? const LinearGradient(
                              colors: [Color(0xFF1B5E3B), Color(0xFF276E4A)])
                          : null,
                      color: _canSubmit
                          ? null
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _canSubmit
                          ? [BoxShadow(
                              color: const Color(0xFF1B5E3B).withValues(alpha: 0.35),
                              blurRadius: 16, offset: const Offset(0, 6))]
                          : null,
                    ),
                    child: Center(
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _canSubmit
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dark auth button (white / frosted variants) ────────────────────────────
enum _DarkAuthBtnStyle { white, frosted }

class _DarkAuthBtn extends StatelessWidget {
  final IconData? icon;
  final String? svgIcon;
  final String label;
  final _DarkAuthBtnStyle style;
  final bool loading;
  final VoidCallback onTap;

  const _DarkAuthBtn({
    this.icon,
    this.svgIcon,
    required this.label,
    required this.style,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWhite = style == _DarkAuthBtnStyle.white;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isWhite
              ? Colors.white
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: isWhite
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.12), width: 0.5),
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isWhite ? _kDark : Colors.white54),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null)
                      Icon(icon, size: 20,
                          color: isWhite ? _kDark : Colors.white.withValues(alpha: 0.8)),
                    if (svgIcon != null)
                      SvgPicture.asset(svgIcon!, width: 18, height: 18),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isWhite
                            ? _kDark
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Dark form field ────────────────────────────────────────────────────────
class _DarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String> onChanged;

  const _DarkField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        autofillHints: const [],
        style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w500),
        cursorColor: Colors.white54,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════════════════════
// STEP 2 — StepGoals  (objectif de poids — choix unique, pilote le calcul
// des calories : perte/maintien/prise. Les clés ci-dessous sont volontairement
// distinctes ("poids" seulement pour la perte, "masse" pour la prise) pour ne
// pas se faire mal-classer par la détection par mot-clé dans
// UserProfile.fromOnboardingData et NutritionTargets.compute()).
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

class StepGoals extends StatefulWidget {
  final List<String> selectedGoals;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleGoal;
  final VoidCallback onNext;

  const StepGoals({
    super.key,
    required this.selectedGoals,
    this.onBack,
    required this.onToggleGoal,
    required this.onNext,
  });

  @override
  State<StepGoals> createState() => _StepGoalsState();
}

class _StepGoalsState extends State<StepGoals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fades = List.generate(_goals.length, (i) {
      final s = 0.08 + i * 0.12;
      final e = (s + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(s, e, curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  // Choix unique : on retire l'ancienne sélection avant d'ajouter la nouvelle
  // (le parent n'expose qu'un toggle add/remove générique, partagé avec
  // d'autres steps — on garde donc cette logique côté widget).
  void _select(String label) {
    for (final g in _goals) {
      if (g.label != label && widget.selectedGoals.contains(g.label)) {
        widget.onToggleGoal(g.label);
      }
    }
    if (!widget.selectedGoals.contains(label)) {
      widget.onToggleGoal(label);
    }
    Future.delayed(const Duration(milliseconds: 300), widget.onNext);
  }

  static const _goalIcons = [LucideIcons.flame, LucideIcons.scale, LucideIcons.dumbbell];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    final goalLabels = [l10n.goal1, l10n.goal2, l10n.goal3];
    final goalSubs = [
      'Brûle des graisses et sculpte ton corps',
      'Garde la forme et reste en équilibre',
      'Construis du muscle et gagne en force',
    ];

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 1, total: 8, onBack: widget.onBack),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _StepIcon(Icons.track_changes_rounded),
                const SizedBox(height: 12),
                _StepHeader(
                  title: l10n.goalsTitle,
                  subtitle: l10n.goalsHint,
                ),
              ]),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_goals.length, (i) {
                  final key = _goals[i].label;
                  final isSel = widget.selectedGoals.contains(key);
                  return FadeTransition(
                    opacity: _fades[i],
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuickTapCard(
                        icon: _goalIcons[i],
                        label: goalLabels[i],
                        sublabel: goalSubs[i],
                        selected: isSel,
                        onTap: () => _select(key),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// ── Circle goal button ────────────────────────────────────────────────────────
class _CircleGoal extends StatefulWidget {
  final String label;
  final double diameter;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const _CircleGoal({
    required this.label,
    required this.diameter,
    required this.selected,
    required this.onTap,
    this.accentColor = _kGreenDark,
  });

  @override
  State<_CircleGoal> createState() => _CircleGoalState();
}

class _CircleGoalState extends State<_CircleGoal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d   = widget.diameter;
    final sel = widget.selected;

    return GestureDetector(
      onTapDown:   (_) => _press.forward(),
      onTapUp:     (_) { _press.reverse(); widget.onTap(); },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sel
                ? _kGreenDark.withValues(alpha: 0.5)
                : _kGlassFill,
            border: Border.all(
              color: sel
                  ? _kGreenMid.withValues(alpha: 0.6)
                  : _kGlassBorder,
              width: sel ? 1.5 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(color: _kGreenMid.withValues(alpha: 0.2), blurRadius: 22, offset: const Offset(0, 8))]
                : [],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(context.rs(12)),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.rs(12.5),
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : _kTextDark,
                  height: 1.4,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 3 — StepFitnessLevel  (minimalist B&W circle selector)
// ══════════════════════════════════════════════════════════════════════════════

const _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

class StepFitnessLevel extends StatefulWidget {
  final String? selectedLevel;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFitnessLevel({
    super.key,
    required this.selectedLevel,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<StepFitnessLevel> createState() => _StepFitnessLevelState();
}

class _StepFitnessLevelState extends State<StepFitnessLevel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fades = List.generate(_levels.length, (i) {
      final s = 0.10 + i * 0.18;
      final e = (s + 0.45).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(s, e, curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _select(String label) {
    widget.onChanged(label);
    Future.delayed(const Duration(milliseconds: 300), widget.onNext);
  }

  static const _levelIcons = [LucideIcons.sprout, LucideIcons.zap, LucideIcons.trophy];
  static const _levelSubs = [
    'Commence en douceur, sans pression',
    'Tu connais les bases, on passe au niveau supérieur',
    'Prête pour des défis intenses',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n(Lang.code);
    final levelLabels = [
      l10n.fitnessLevelBeginner,
      l10n.fitnessLevelIntermediate,
      l10n.fitnessLevelAdvanced,
    ];

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 2, total: 8, onBack: widget.onBack),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _StepIcon(Icons.show_chart_rounded),
                const SizedBox(height: 12),
                _StepHeader(
                  title: l10n.fitnessTitle,
                  subtitle: l10n.fitnessHint,
                ),
              ]),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_levels.length, (i) {
                  final key = _levels[i];
                  final isSel = widget.selectedLevel == key;
                  return FadeTransition(
                    opacity: _fades[i],
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuickTapCard(
                        icon: _levelIcons[i],
                        label: levelLabels[i],
                        sublabel: _levelSubs[i],
                        selected: isSel,
                        onTap: () => _select(key),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 4 — StepEquipment  (minimalist B&W circle selector)
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

class StepEquipment extends StatefulWidget {
  final List<String> selectedEquipment;
  final VoidCallback? onBack;
  final ValueChanged<String> onToggleEquipment;
  final VoidCallback onNext;

  const StepEquipment({
    super.key,
    required this.selectedEquipment,
    this.onBack,
    required this.onToggleEquipment,
    required this.onNext,
  });

  @override
  State<StepEquipment> createState() => _StepEquipmentState();
}
class equipmentIcon extends StatelessWidget {
  final String label;
  final IconData icon;
  final double diameter;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const equipmentIcon({
    required this.label,
    required this.icon,
    required this.diameter,
    required this.selected,
    required this.onTap,
    this.accentColor = _kGreenDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? _kGreenDark.withValues(alpha: 0.5)
              : _kGlassFill,
          border: Border.all(
            color: selected
                ? _kGreenMid.withValues(alpha: 0.6)
                : _kGlassBorder,
            width: selected ? 1.5 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _kGreenMid.withValues(alpha: 0.2), blurRadius: 18, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? _kGreenBright : _kGreenMid, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? _kWhite : _kTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _StepEquipmentState extends State<StepEquipment>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fades = List.generate(_equipments.length, (i) {
      final s = 0.05 + i * 0.10;
      final e = (s + 0.40).clamp(0.0, 1.0);

      return CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(s, e, curve: Curves.easeOut),
      );
    });
  }

  void _handleEquipmentTap(String label) {
    final selected = List<String>.from(widget.selectedEquipment);

    if (label == 'Aucun matériel') {
      for (final item in selected) {
        widget.onToggleEquipment(item);
      }

      if (!selected.contains('Aucun matériel')) {
        widget.onToggleEquipment('Aucun matériel');
      }
      return;
    }

    if (selected.contains('Aucun matériel')) {
      widget.onToggleEquipment('Aucun matériel');
    }

    widget.onToggleEquipment(label);
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  static const _equipEmojis = ['🚫', '🏋️', '🔩', '⚙️', '🪢', '🧘'];

  @override
  Widget build(BuildContext context) {
    final count = widget.selectedEquipment.length;
    final l10n = AppL10n(Lang.code);
    final equipLabels = [
      l10n.equipmentNone,
      l10n.equipmentDumbbells,
      l10n.equipmentBarbell,
      l10n.equipmentMachines,
      l10n.equipmentBands,
      l10n.equipmentYogaMat,
    ];

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 3, total: 8, onBack: widget.onBack),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _StepIcon(Icons.sports_gymnastics),
                const SizedBox(height: 12),
                _StepHeader(
                  title: l10n.equipmentTitle,
                  subtitle: l10n.equipmentHint,
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: _equipments.length,
                  itemBuilder: (_, i) {
                    final key = _equipments[i];
                    final isSel = widget.selectedEquipment.contains(key);
                    return FadeTransition(
                      opacity: _fades[i],
                      child: _QuickTapTile(
                        emoji: _equipEmojis[i],
                        label: equipLabels[i],
                        selected: isSel,
                        onTap: () => _handleEquipmentTap(key),
                      ),
                    );
                  },
                ),
              ),
            ),
            _CtaButton(
              label: count > 0 ? '${l10n.equipmentContinue} ($count)' : l10n.equipmentSelectAtLeastOne,
              onPressed: count > 0 ? widget.onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 5 — StepFrequency (fond blanc + cadran circulaire)
// ══════════════════════════════════════════════════════════════════════════════
class StepFrequency extends StatefulWidget {
  final String? selectedFrequency;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFrequency({
    super.key,
    required this.selectedFrequency,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<StepFrequency> createState() => _StepFrequencyState();
}

class _StepFrequencyState extends State<StepFrequency> {
  static const _labels = ['2 jours', '3 jours', '4 jours', '5 jours', '6 jours'];
  late int _index;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    final idx = widget.selectedFrequency != null
        ? _labels.indexOf(widget.selectedFrequency!)
        : -1;
    _index = idx >= 0 ? idx : 0;
    _hasInteracted = idx >= 0;
  }

  void _select(int i) {
    setState(() {
      _index = i;
      _hasInteracted = true;
    });
    widget.onChanged(_labels[i]);
  }

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 5, total: 8, onBack: widget.onBack),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const _StepIcon(Icons.timer_outlined),
                const SizedBox(height: 12),
                _StepHeader(
                  title: AppL10n(Lang.code).frequencyTitle,
                  subtitle: AppL10n(Lang.code).frequencyHint,
                ),
              ]),
            ),

            const Spacer(flex: 1),
            Center(
              child: _FreqDial(
                count: _labels.length,
                index: _index,
                onChanged: _select,
                label: AppL10n(Lang.code).freqLabel(_index),
              ),
            ),
            const Spacer(flex: 1),
            _CtaButton(
              label: AppL10n(Lang.code).frequencyNext,
              onPressed: _hasInteracted ? widget.onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}

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

// ── Circular dial ─────────────────────────────────────────────────────────────

class _FreqDial extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int> onChanged;
final String label;
 const _FreqDial({
  required this.count,
  required this.index,
  required this.onChanged,
  required this.label,
});

  static const double _r     = 105.0;
  static const double _start = -pi / 6;   // -30° → 2 o'clock
  static const double _sweep = pi * 1.5;  // 270°
  static const double _size  = (_r + 44) * 2;

  double _angle(int i) => _start + (i / (count - 1)) * _sweep;

  Offset _pos(int i) {
    final a = _angle(i);
    return Offset(_size / 2 + _r * cos(a), _size / 2 + _r * sin(a));
  }

  int _nearest(Offset local) {
    final dx = local.dx - _size / 2;
    final dy = local.dy - _size / 2;
    double a = atan2(dy, dx);
    while (a < _start) { a += 2 * pi; }
    final diff = a - _start;
    if (diff <= _sweep) {
      return (diff / (_sweep / (count - 1))).round().clamp(0, count - 1);
    }
    return diff < _sweep + (2 * pi - _sweep) / 2 ? count - 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final hp = _pos(index);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => onChanged(_nearest(d.localPosition)),
      onTapDown:   (d) => onChanged(_nearest(d.localPosition)),
      child: SizedBox(
        width: _size, height: _size,
        child: Stack(
          children: [
            // Arc track + dots
            CustomPaint(
              size: const Size(_size, _size),
              painter: _DialPainter(
                count: count, selected: index,
                r: _r, start: _start, sweep: _sweep,
              ),
            ),

            // Play button — center
 Center(
  child: Text(
    label,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: kGreenDark,
    ),
  ),
),

            // Handle at current position
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              left: hp.dx - 18, top: hp.dy - 18,
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _kGreenBright,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kGreenMid.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: _kBgDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final int count;
  final int selected;
  final double r;
  final double start;
  final double sweep;

  const _DialPainter({
    required this.count,
    required this.selected,
    required this.r,
    required this.start,
    required this.sweep,
  });

  double _angle(int i) => start + (i / (count - 1)) * sweep;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      start, sweep, false,
      Paint()
        ..color       = _kGlassBorder
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap   = StrokeCap.round,
    );

    final dot = Paint()..color = _kGlassBorder..style = PaintingStyle.fill;
    for (int i = 0; i < count; i++) {
      if (i == selected) continue;
      final a = _angle(i);
      canvas.drawCircle(
        Offset(center.dx + r * cos(a), center.dy + r * sin(a)), 5, dot,
      );
    }
  }

  @override
  bool shouldRepaint(_DialPainter o) => o.selected != selected || o.count != count;
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 6 — StepHealthProfile — Drum-wheel picker
// ══════════════════════════════════════════════════════════════════════════════
class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final int initialHeightCm;
  final double initialWeightKg;
  final int initialAge;
  final ValueChanged<int>? onHeightChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onAgeChanged;

  const StepHealthProfile({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialHeightCm  = 165,
    this.initialWeightKg  = 60.0,
    this.initialAge       = 25,
    this.onHeightChanged,
    this.onWeightChanged,
    this.onAgeChanged,
  });

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  static const int _minH = 140, _maxH = 210;
  static const int _minA = 15,  _maxA = 70;

  // Weight list: 35.0 → 150.0, step 0.5 → 231 items
  static final List<double> _wList =
      List.generate(231, (i) => 35.0 + i * 0.5);

  late final FixedExtentScrollController _hCtrl;
  late final FixedExtentScrollController _wCtrl;
  late final FixedExtentScrollController _aCtrl;

  late int _hIdx;
  late int _wIdx;
  late int _aIdx;

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

  @override
  void initState() {
    super.initState();
    _hIdx = (widget.initialHeightCm - _minH).clamp(0, _maxH - _minH);
    final wNearest = _wList.indexWhere((w) => w >= widget.initialWeightKg);
    _wIdx = wNearest < 0 ? 50 : wNearest;
    _aIdx = (widget.initialAge - _minA).clamp(0, _maxA - _minA);

    _hCtrl = FixedExtentScrollController(initialItem: _hIdx);
    _wCtrl = FixedExtentScrollController(initialItem: _wIdx);
    _aCtrl = FixedExtentScrollController(initialItem: _aIdx);

    TickSoundService.instance.init();
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _wCtrl.dispose();
    _aCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(
              step: 2, total: 3, title: AppL10n(Lang.code).healthProfileTopBarTitle, onBack: widget.onBack),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        const _StepIcon(Icons.straighten_rounded),
                        const SizedBox(height: 16),
                        _StepHeader(
                          title: AppL10n(Lang.code).healthProfileTitle,
                          subtitle: AppL10n(Lang.code).healthProfileSubtitle,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: _DrumPicker(
                                label: AppL10n(Lang.code).healthProfileHeight,
                                unit: 'cm',
                                selectedIndex: _hIdx,
                                controller: _hCtrl,
                                itemCount: _maxH - _minH + 1,
                                labelFor: (i) => '${_minH + i}',
                                onChanged: (i) {
                                  setState(() => _hIdx = i);
                                  widget.onHeightChanged?.call(_heightCm);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DrumPicker(
                                label: AppL10n(Lang.code).healthProfileWeight,
                                unit: 'kg',
                                selectedIndex: _wIdx,
                                controller: _wCtrl,
                                itemCount: _wList.length,
                                labelFor: (i) {
                                  final w = _wList[i];
                                  return w % 1 == 0
                                      ? '${w.toInt()}'
                                      : w.toStringAsFixed(1);
                                },
                                onChanged: (i) {
                                  setState(() => _wIdx = i);
                                  widget.onWeightChanged?.call(_weightKg);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DrumPicker(
                                label: AppL10n(Lang.code).healthProfileAge,
                                unit: AppL10n(Lang.code).healthProfileAgeUnit,
                                selectedIndex: _aIdx,
                                controller: _aCtrl,
                                itemCount: _maxA - _minA + 1,
                                labelFor: (i) => '${_minA + i}',
                                onChanged: (i) {
                                  setState(() => _aIdx = i);
                                  widget.onAgeChanged?.call(_age);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _BmiCard(bmi: _bmi, label: _bmiLabel, color: _bmiColor),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _CtaButton(label: AppL10n(Lang.code).healthProfileContinue, onPressed: widget.onNext),
        ],
      ),
    );
  }
}

// ─── Drum-wheel picker ────────────────────────────────────────────────────────
class _DrumPicker extends StatelessWidget {
  final String label;
  final String unit;
  final int selectedIndex;
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) labelFor;
  final ValueChanged<int> onChanged;

  const _DrumPicker({
    required this.label,
    required this.unit,
    required this.selectedIndex,
    required this.controller,
    required this.itemCount,
    required this.labelFor,
    required this.onChanged,
  });

  static const double _kItemH = 52.0;
  static const int _kVisible = 5;
  static const Color _kFadeBg = Color(0xFFEFF7F1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E3B).withValues(alpha: 0.06),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A7A66),
              )),
          const SizedBox(height: 10),
          SizedBox(
            height: _kItemH * _kVisible,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    height: _kItemH,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _kGreenBright.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _kGreenBright.withValues(alpha: 0.25), width: 1),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: _kItemH,
                  perspective: 0.002,
                  diameterRatio: 1.8,
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
                            fontSize: sel ? 24 : 16,
                            fontWeight:
                                sel ? FontWeight.w800 : FontWeight.w400,
                            color: sel
                                ? const Color(0xFF1A3C2A)
                                : const Color(0xFF5A7A66).withValues(alpha: 0.5),
                          ),
                          child: Text(labelFor(i)),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_kFadeBg, _kFadeBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_kFadeBg, _kFadeBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(unit,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5A7A66))),
          const SizedBox(height: 14),
        ],
      ),
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
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.04),
            blurRadius: 12, offset: const Offset(0, 3),
          ),
        ],
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
                      color: Color(0xFF5A7A66))),
              const SizedBox(height: 4),
              Text(bmi.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A3C2A))),
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

// ══════════════════════════════════════════════════════════════════════════════
// STEP 7 — StepCycleAndPregnancy  (santé féminine — cycle + grossesse mergés)
// ══════════════════════════════════════════════════════════════════════════════
class StepCycleAndPregnancy extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final ValueChanged<DateTime>? onLastPeriodChanged;
  final ValueChanged<String>? onCycleDurationChanged;
  final ValueChanged<String>? onHealthStatusChanged;
  final ValueChanged<int>? onPregnancyWeekChanged;
  final ValueChanged<String>? onPpRecoveryChanged;
  final ValueChanged<String>? onPpDurationChanged;

  const StepCycleAndPregnancy({
    super.key,
    required this.onNext,
    this.onBack,
    this.onLastPeriodChanged,
    this.onCycleDurationChanged,
    this.onHealthStatusChanged,
    this.onPregnancyWeekChanged,
    this.onPpRecoveryChanged,
    this.onPpDurationChanged,
  });

  @override
  State<StepCycleAndPregnancy> createState() => _StepCycleAndPregnancyState();
}

class _StepCycleAndPregnancyState extends State<StepCycleAndPregnancy> {
  // 'cycle' | 'pregnant' | 'postpartum' | null
  String? _status;

  // ── Cycle ──────────────────────────────────────────────────────────────────
  String _cycleDuration = '28 jours';
  DateTime _lastPeriod = DateTime.now().subtract(const Duration(days: 14));

  static const List<String> _durations = [
    '24 jours', '26 jours', '28 jours', '30 jours', '32 jours',
  ];

  // ── Post-partum ────────────────────────────────────────────────────────────
  String? _ppRecovery;   // 'recent' | 'slowly' | 'active'
  String? _ppDuration;   // '0-2', '2-6', '6-12', '3-6m', '6m+'
  DateTime? _birthDate;

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
    final d =
        int.tryParse(_cycleDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 28;
    return _lastPeriod.add(Duration(days: d));
  }

  // ── Pregnancy ──────────────────────────────────────────────────────────────
  int _weekIdx = 11; // default SA 12 (index 0-based)
  late final FixedExtentScrollController _weekCtrl;

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

  // ── Helpers ────────────────────────────────────────────────────────────────
  String _fmt(DateTime d) {
    const m = [
      'Janv.', 'Févr.', 'Mars', 'Avr.', 'Mai', 'Juin',
      'Juil.', 'Août', 'Sept.', 'Oct.', 'Nov.', 'Déc.',
    ];
    return '${d.day} ${m[d.month - 1]}';
  }

  Future<void> _pickDate() async {
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
      widget.onLastPeriodChanged?.call(p);
    }
  }

  @override
  void initState() {
    super.initState();
    _weekCtrl = FixedExtentScrollController(initialItem: _weekIdx);
  }

  @override
  void dispose() {
    _weekCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(
              step: 3, total: 3, title: AppL10n(Lang.code).cycleStepTopBarTitle,
              onBack: widget.onBack),
          const SizedBox(height: 20),
          const _StepIcon(Icons.favorite_border_rounded),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _StepHeader(
              title: AppL10n(Lang.code).cycleStepTitle,
              subtitle: AppL10n(Lang.code).cycleStepSubtitle,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Toggle cards — 3 options ──
                  Row(children: [
                    Expanded(child: _statusCard(
                      'cycle', LucideIcons.droplet,
                      AppL10n(Lang.code).cycleStatusRegular,
                      AppL10n(Lang.code).cycleStatusRegularSub,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _statusCard(
                      'pregnant', Icons.pregnant_woman,
                      AppL10n(Lang.code).cycleStatusPregnant,
                      AppL10n(Lang.code).cycleStatusPregnantSub,
                      iconSize: 30,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _statusCard(
                      'postpartum', LucideIcons.baby,
                      AppL10n(Lang.code).cycleStatusPostpartum,
                      AppL10n(Lang.code).cycleStatusPostpartumSub,
                    )),
                  ]),
                  const SizedBox(height: 24),
                  // ── Conditional content ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _status == null
                        ? _hintWidget()
                        : _status == 'cycle'
                            ? _cycleWidget()
                            : _status == 'pregnant'
                                ? _pregnancyWidget()
                                : _postpartumWidget(),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: _status == 'cycle' ? AppL10n(Lang.code).cycleCtaStart : AppL10n(Lang.code).continueBtn,
            onPressed: _status != null
                ? (_status == 'postpartum'
                    ? (_ppDuration != null ? widget.onNext : null)
                    : widget.onNext)
                : null,
          ),
        ],
      ),
    );
  }

  // ── Status toggle cards ────────────────────────────────────────────────────
  Widget _statusCard(String value, IconData icon, String label, String sub, {double iconSize = 22}) {
    final sel = _status == value;
    return GestureDetector(
      onTap: () {
        setState(() => _status = value);
        widget.onHealthStatusChanged?.call(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
        decoration: BoxDecoration(
          color: sel ? _kGreenDark : _kGlassFill,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sel ? _kGreenDark : _kGlassBorder,
            width: 1.5,
          ),
          boxShadow: sel
              ? [BoxShadow(
                  color: _kGreenDark.withValues(alpha: 0.25),
                  blurRadius: 18, offset: const Offset(0, 7))]
              : [],
        ),
        child: Column(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: sel
                  ? Colors.white.withValues(alpha: 0.15)
                  : _kGlassFill,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize,
                color: sel ? Colors.white : _kGreenMid),
          ),
          const SizedBox(height: 12),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15,
                  color: sel ? Colors.white : _kTextDark,
                  height: 1.3)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10.5,
                  color: sel
                      ? Colors.white.withValues(alpha: 0.72)
                      : _kTextMuted)),
        ]),
      ),
    );
  }

  // ── Nothing selected hint ──────────────────────────────────────────────────
  Widget _hintWidget() {
    return Container(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGlassBorder),
      ),
      child: Row(children: [
        const Icon(Icons.touch_app_outlined, color: _kTextMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(AppL10n(Lang.code).cycleSelectSituation,
              style: const TextStyle(
                  fontSize: 13, color: _kTextMuted, height: 1.4)),
        ),
      ]),
    );
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
          children: _durations.map((d) {
            final sel = _cycleDuration == d;
            return GestureDetector(
              onTap: () {
                setState(() => _cycleDuration = d);
                widget.onCycleDurationChanged?.call(d);
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
          onTap: _pickDate,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGlassBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
      ]),
    );
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
        _DrumPicker(
          label: AppL10n(Lang.code).cyclePregnancyWeeksLabel,
          unit: 'SA',
          selectedIndex: _weekIdx,
          controller: _weekCtrl,
          itemCount: 42,
          labelFor: (i) => '${i + 1}',
          onChanged: (i) {
            setState(() => _weekIdx = i);
            widget.onPregnancyWeekChanged?.call(i + 1);
          },
        ),
        const SizedBox(height: 16),
        _trimesterBar(),
        const SizedBox(height: 12),
        _adviceCard(),
      ],
    );
  }

  Widget _trimesterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGlassBorder),
      ),
      child: Column(children: [
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
      ]),
    );
  }

  Widget _adviceCard() {
    final l10n = AppL10n(Lang.code);
    final label = _trimester == 1
        ? l10n.cycleTrimester1Label
        : _trimester == 2
            ? l10n.cycleTrimester2Label
            : l10n.cycleTrimester3Label;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kGlassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGlassBorder),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: _kGreenDark.withValues(alpha: 0.09),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_outline,
              size: 16, color: _kGreenDark),
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
      ]),
    );
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
              widget.onPpDurationChanged?.call(dur);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _birthDate != null
                  ? _kGlassFill
                  : _kGlassFill,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _birthDate != null ? _kGreenDark : _kGlassBorder,
                width: 1.5),
              boxShadow: _birthDate != null
                  ? [BoxShadow(color: _kGreenDark.withValues(alpha: 0.12),
                      blurRadius: 14, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _birthDate != null
                      ? _kGreenDark.withValues(alpha: 0.12)
                      : _kGlassFill,
                  shape: BoxShape.circle),
                child: Icon(Icons.calendar_today_rounded,
                  size: 19,
                  color: _birthDate != null ? _kGreenDark : _kTextMuted),
              ),
              const SizedBox(width: 14),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _ppProgramColor.withValues(alpha: 0.08),
                  _ppProgramColor.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _ppProgramColor.withValues(alpha: 0.30)),
            ),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _ppProgramColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle),
                child: Icon(LucideIcons.heartPulse, size: 20, color: _ppProgramColor),
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
          ),
        ],
        const SizedBox(height: 8),
      ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Step 8 — Mascotte
// ─────────────────────────────────────────────────────────────────────────────
class StepAvatar extends StatefulWidget {
  final String   userName;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final void Function(String seed, String style, String bg) onAvatarChanged;

  const StepAvatar({
    super.key,
    required this.userName,
    required this.onNext,
    required this.onBack,
    required this.onAvatarChanged,
  });

  @override
  State<StepAvatar> createState() => _StepAvatarState();
}

class _StepAvatarState extends State<StepAvatar> {
  MascotType _type = MascotType.blob;
  MascotMood _mood = MascotMood.happy;

  static const _accent = Color(0xFF2D4A2D);

  static const _types = [
    (MascotType.blob,  'Blobby',  '🟢'),
    (MascotType.sun,   'Sunny',   '☀️'),
    (MascotType.star,  'Starlet', '⭐'),
    (MascotType.cloud, 'Cloudie', '☁️'),
    (MascotType.leaf,  'Leafy',   '🍃'),
  ];

  static const _moodTypes = [
    (MascotMood.happy,       '😊'),
    (MascotMood.excited,     '🤩'),
    (MascotMood.proud,       '💪'),
    (MascotMood.celebrating, '🎉'),
    (MascotMood.sleepy,      '😴'),
  ];

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
              _OnboardingTopBar(step: 9, total: 11, onBack: widget.onBack),

            const SizedBox(height: 16),

            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Mascot preview card ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
                          boxShadow: [BoxShadow(color: const Color(0xFF1B5E3B).withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: Column(children: [
                          // Mascot with glow ring
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _kGreenBright.withValues(alpha: 0.15),
                                  _kGreenBright.withValues(alpha: 0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(color: _kGreenBright.withValues(alpha: 0.15), blurRadius: 24, spreadRadius: 2),
                              ],
                            ),
                            child: Center(child: MascotWidget(type: _type, mood: _mood, size: 110)),
                          ),
                          const SizedBox(height: 16),
                          Text(AppL10n(Lang.code).avatarChooseTitle,
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A3C2A), letterSpacing: -0.3)),
                          const SizedBox(height: 4),
                          Text(
                            AppL10n(Lang.code).avatarSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF5A7A66), height: 1.5),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Choix mascotte (horizontal scroll) ─────────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppL10n(Lang.code).avatarShapeLabel, style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E3B), letterSpacing: 2.5)),
                      ),
                    ),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final (type, name, _) = _types[i];
                          final selected = _type == type;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _type = type);
                              HapticFeedback.selectionClick();
                              widget.onAvatarChanged(type.name, type.name, '');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 82,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFE8F5EC)
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected
                                      ? _kGreenBright.withValues(alpha: 0.5)
                                      : const Color(0xFFCCDDD3),
                                  width: selected ? 1.5 : 1,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: _kGreenBright.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 5))]
                                    : [],
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                MascotWidget(type: type, mood: MascotMood.happy, size: 48),
                                const SizedBox(height: 4),
                                Text(name, style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: selected
                                      ? const Color(0xFF1A3C2A)
                                      : const Color(0xFF5A7A66))),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ── Humeur ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppL10n(Lang.code).avatarMoodLabel, style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800,
                          color: Color(0xFF1B5E3B), letterSpacing: 2.5)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8, runSpacing: 8,
                        children: (() {
                          final l10n = AppL10n(Lang.code);
                          final _moodLabels = [
                            l10n.avatarMoodHappy, l10n.avatarMoodExcited,
                            l10n.avatarMoodProud, l10n.avatarMoodCelebrating, l10n.avatarMoodSleepy,
                          ];
                          return _moodTypes.asMap().entries.map((entry) {
                          final i = entry.key;
                          final m = entry.value;
                          final (mood, emoji) = m;
                          final label = _moodLabels[i];
                          final selected = _mood == mood;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _mood = mood);
                              HapticFeedback.selectionClick();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFFE8F5EC)
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: selected
                                      ? _kGreenBright.withValues(alpha: 0.5)
                                      : const Color(0xFFCCDDD3),
                                  width: selected ? 1.5 : 1,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: _kGreenBright.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))]
                                    : [],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(label, style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: selected
                                      ? const Color(0xFF1A3C2A)
                                      : const Color(0xFF5A7A66))),
                              ]),
                            ),
                          );
                        }).toList();
                        })(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _CtaButton(
              label: AppL10n(Lang.code).avatarCta,
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepTrainingLocation  (Salle / Maison / Les deux)
// ══════════════════════════════════════════════════════════════════════════════
class StepTrainingLocation extends StatefulWidget {
  final String? selectedLocation;
  final VoidCallback? onBack;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepTrainingLocation({
    super.key,
    required this.selectedLocation,
    this.onBack,
    required this.onChanged,
    required this.onNext,
  });

  @override
  State<StepTrainingLocation> createState() => _StepTrainingLocationState();
}

class _StepTrainingLocationState extends State<StepTrainingLocation>
    with SingleTickerProviderStateMixin {
  static const _accent = _kGreenDark;
  String? _selected;

  late final AnimationController _ctrl;
  late final List<Animation<double>> _fades;

  static const _optionValues = ['gym', 'home', 'both'];
  static const _optionIcons = [LucideIcons.dumbbell, LucideIcons.home, LucideIcons.shuffle];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedLocation;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..forward();
    _fades = List.generate(_optionValues.length, (i) {
      final s = 0.10 + i * 0.22;
      final e = (s + 0.50).clamp(0.0, 1.0);
      return CurvedAnimation(parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _select(String value) {
    setState(() => _selected = value);
    widget.onChanged(value);
    Future.delayed(const Duration(milliseconds: 320), widget.onNext);
  }

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
              _OnboardingTopBar(step: 4, total: 8, onBack: widget.onBack),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const _StepIcon(Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _StepHeader(
                    title: AppL10n(Lang.code).locationTitle,
                    subtitle: AppL10n(Lang.code).locationSubtitle,
                  ),
                ]),
              ),

              const Spacer(flex: 1),

              // ── Cards ─────────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
                child: Column(
                  children: List.generate(_optionValues.length, (i) {
                    final l10n = AppL10n(Lang.code);
                    final _locLabels = [l10n.locationGym, l10n.locationHome, l10n.locationBoth];
                    final _locSubs = [l10n.locationGymDetail, l10n.locationHomeDetail, l10n.locationBothDetail];
                    final value = _optionValues[i];
                    final icon = _optionIcons[i];
                    final label = _locLabels[i];
                    final sub = _locSubs[i];
                    final sel = _selected == value;
                    return FadeTransition(
                      opacity: _fades[i],
                      child: GestureDetector(
                        onTap: () => _select(value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          margin: EdgeInsets.only(bottom: context.rv(12)),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.rs(18),
                            vertical: context.rv(14)),
                          decoration: BoxDecoration(
                            color: sel
                                ? _kGreenDark.withValues(alpha: 0.4)
                                : _kGlassFill,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: sel
                                  ? _kGreenMid.withValues(alpha: 0.6)
                                  : _kGlassBorder,
                              width: sel ? 1.5 : 0.5,
                            ),
                            boxShadow: sel
                                ? [BoxShadow(color: _kGreenMid.withValues(alpha: 0.15), blurRadius: 18, offset: const Offset(0, 6))]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: context.rs(48), height: context.rs(48),
                                decoration: BoxDecoration(
                                  color: sel ? Colors.white.withValues(alpha:0.2) : _kGlassFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(icon,
                                    size: context.rs(24),
                                    color: sel ? Colors.white : _kGreenDark),
                                ),
                              ),
                              SizedBox(width: context.rs(14)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: context.rs(15),
                                        fontWeight: FontWeight.w700,
                                        color: sel ? Colors.white : _kTextDark,
                                      ),
                                    ),
                                    SizedBox(height: context.rv(3)),
                                    Text(
                                      sub,
                                      style: TextStyle(
                                        fontSize: context.rs(12),
                                        height: 1.4,
                                        color: sel ? Colors.white.withValues(alpha: 0.75) : _kTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedOpacity(
                                opacity: sel ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.check_circle, color: Colors.white, size: 22),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepCoachChat (conversation-style onboarding)
// ══════════════════════════════════════════════════════════════════════════════

enum _ChatPhase { goal, fitness, equipment, location, frequency, done }

class _Msg {
  final bool isCoach;
  final String text;
  const _Msg.coach(this.text) : isCoach = true;
  const _Msg.user(this.text) : isCoach = false;
}

class StepCoachChat extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback? onBack;
  final VoidCallback onDone;
  final ValueChanged<String> onGoalSelected;
  final ValueChanged<String> onFitnessChanged;
  final ValueChanged<String> onEquipmentToggled;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onFrequencyChanged;

  const StepCoachChat({
    super.key,
    required this.data,
    this.onBack,
    required this.onDone,
    required this.onGoalSelected,
    required this.onFitnessChanged,
    required this.onEquipmentToggled,
    required this.onLocationChanged,
    required this.onFrequencyChanged,
  });

  @override
  State<StepCoachChat> createState() => _StepCoachChatState();
}

class _StepCoachChatState extends State<StepCoachChat>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  final List<_Msg> _messages = [];
  _ChatPhase _phase = _ChatPhase.goal;
  bool _typing = false;
  bool _showReplies = false;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    await _coachSays('Salut ! 👋 Je suis ton coach FitEva.');
    await _coachSays('On va créer ton programme en quelques taps. C\'est parti !');
    await _coachSays('Quel est ton objectif principal ?');
    _showQuickReplies();
  }
   Future<void> _coachSays(String text) async {
    setState(() { _typing = true; _showReplies = false; });
    _scrollToBottom();
    await Future.delayed(Duration(milliseconds: 500 + text.length * 8));
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_Msg.coach(text));
    });
    _scrollToBottom();
  }

  void _userSays(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      _showReplies = false;
      _messages.add(_Msg.user(text));
    });
    _scrollToBottom();
  }

  void _showQuickReplies() {
    setState(() => _showReplies = true);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Goal ──────────────────────────────────────────────────────────────────
  Future<void> _onGoal(String key, String label) async {
    widget.onGoalSelected(key);
    _userSays(label);
    await _coachSays('Super choix ! 💪');
    await _coachSays('Et ton niveau actuel ?');
    setState(() => _phase = _ChatPhase.fitness);
    _showQuickReplies();
  }

  // ── Fitness ───────────────────────────────────────────────────────────────
  Future<void> _onFitness(String key, String label) async {
    widget.onFitnessChanged(key);
    _userSays(label);
    await _coachSays('Noté ! 📝');
    await _coachSays('Quel matériel as-tu ? (tu peux en choisir plusieurs)');
    setState(() => _phase = _ChatPhase.equipment);
    _showQuickReplies();
  }

  // ── Equipment (multi-select) ──────────────────────────────────────────────
  void _onEquipmentTap(String key, String label) {
    widget.onEquipmentToggled(key);
    setState(() {});
  }

  Future<void> _onEquipmentDone() async {
    final items = widget.data.equipment;
    _userSays(items.join(', '));
    await _coachSays('Parfait ! 🏠');
    await _coachSays('Où préfères-tu t\'entraîner ?');
    setState(() => _phase = _ChatPhase.location);
    _showQuickReplies();
  }

  // ── Location ──────────────────────────────────────────────────────────────
  Future<void> _onLocation(String key, String label) async {
    widget.onLocationChanged(key);
    _userSays(label);
    await _coachSays('Top ! ⏱️');
    await _coachSays('Combien de fois par semaine veux-tu t\'entraîner ?');
    setState(() => _phase = _ChatPhase.frequency);
    _showQuickReplies();
  }

  // ── Frequency ─────────────────────────────────────────────────────────────
  Future<void> _onFrequency(String key, String label) async {
    widget.onFrequencyChanged(key);
    _userSays(label);
    await _coachSays('Excellent ! On a tout ce qu\'il faut 🎉');
    await _coachSays('Encore quelques détails et on lance ton programme !');
    setState(() => _phase = _ChatPhase.done);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) widget.onDone();
  }

  // ── Build — full-screen question/answer flow ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5EC),
              Color(0xFFF0FAF3),
              Color(0xFFFCFDFC),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    if (widget.onBack != null)
                      GestureDetector(
                        onTap: widget.onBack,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.7),
                            border: Border.all(color: const Color(0xFFCCDDD3), width: 1),
                          ),
                          child: const Icon(LucideIcons.arrowLeft, size: 18,
                              color: Color(0xFF1A3C2A)),
                        ),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kGreenBright.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _phaseLabel(),
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700, color: _kGreenBright),
                      ),
                    ),
                  ],
                ),
              ),

              // Question + replies
              Expanded(
                child: _typing
                    ? Center(child: _BouncingDots())
                    : _buildQuestionView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _phaseLabel() {
    switch (_phase) {
      case _ChatPhase.goal: return '1 of 5';
      case _ChatPhase.fitness: return '2 of 5';
      case _ChatPhase.equipment: return '3 of 5';
      case _ChatPhase.location: return '4 of 5';
      case _ChatPhase.frequency: return '5 of 5';
      case _ChatPhase.done: return 'Done';
    }
  }

  Widget _buildQuestionView() {
    final lastCoachMsg = _messages.lastWhere(
      (m) => m.isCoach, orElse: () => _Msg.coach(''));

    return TweenAnimationBuilder<double>(
      key: ValueKey(_phase),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),

            Text(
              lastCoachMsg.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A3C2A),
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 40),

            if (_showReplies) _buildReplyOptions(),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyOptions() {
    switch (_phase) {
      case _ChatPhase.goal:
        return _replyWrap([
          _ReplyPill('Perte de poids', () => _onGoal('Perte de poids', 'Perte de poids'),
              icon: LucideIcons.flame, iconColor: const Color(0xFFFF6B4A)),
          _ReplyPill('Maintien', () => _onGoal('Maintien', 'Maintien'),
              icon: LucideIcons.scale, iconColor: const Color(0xFF4A90D9)),
          _ReplyPill('Prise de masse', () => _onGoal('Prise de masse', 'Prise de masse'),
              icon: LucideIcons.dumbbell, iconColor: const Color(0xFF7B61FF)),
        ]);

      case _ChatPhase.fitness:
        final l10n = AppL10n(Lang.code);
        return _replyWrap([
          _ReplyPill(l10n.fitnessLevelBeginner, () => _onFitness('Débutant', l10n.fitnessLevelBeginner),
              icon: LucideIcons.footprints, iconColor: const Color(0xFF4CAF7A)),
          _ReplyPill(l10n.fitnessLevelIntermediate, () => _onFitness('Intermédiaire', l10n.fitnessLevelIntermediate),
              icon: LucideIcons.zap, iconColor: const Color(0xFFF5A623)),
          _ReplyPill(l10n.fitnessLevelAdvanced, () => _onFitness('Avancé', l10n.fitnessLevelAdvanced),
              icon: LucideIcons.trophy, iconColor: const Color(0xFFD4A017)),
        ]);

      case _ChatPhase.equipment:
        final l10n = AppL10n(Lang.code);
        final labels = [
          l10n.equipmentNone, l10n.equipmentDumbbells, l10n.equipmentBarbell,
          l10n.equipmentMachines, l10n.equipmentBands, l10n.equipmentYogaMat,
        ];
        const icons = [
          LucideIcons.ban, LucideIcons.dumbbell, LucideIcons.disc,
          LucideIcons.settings, LucideIcons.link, Icons.self_improvement,
        ];
        const iconColors = [
          Color(0xFF9CA3AF), Color(0xFF4A90D9), Color(0xFF7B61FF),
          Color(0xFFF5A623), Color(0xFF4CAF7A), Color(0xFFE85A9B),
        ];
        const keys = ['Aucun matériel', 'Haltères', 'Barre & poids', 'Machines', 'Résistances', 'Tapis de yoga'];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8, runSpacing: 8,
              children: List.generate(keys.length, (i) {
                final sel = widget.data.equipment.contains(keys[i]);
                return _ReplyChip(
                  label: labels[i],
                  icon: icons[i],
                  iconColor: iconColors[i],
                  selected: sel,
                  onTap: () => _onEquipmentTap(keys[i], labels[i]),
                );
              }),
            ),
            if (widget.data.equipment.isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _onEquipmentDone,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E3B), Color(0xFF276E4A)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B5E3B).withValues(alpha: 0.3),
                        blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text('Continuer', style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ],
        );

      case _ChatPhase.location:
        final l10n = AppL10n(Lang.code);
        return _replyWrap([
          _ReplyPill(l10n.locationGym, () => _onLocation('gym', l10n.locationGym),
              icon: LucideIcons.dumbbell, iconColor: const Color(0xFF4A90D9)),
          _ReplyPill(l10n.locationHome, () => _onLocation('home', l10n.locationHome),
              icon: LucideIcons.home, iconColor: const Color(0xFF4CAF7A)),
          _ReplyPill(l10n.locationBoth, () => _onLocation('both', l10n.locationBoth),
              icon: LucideIcons.shuffle, iconColor: const Color(0xFF7B61FF)),
        ]);

      case _ChatPhase.frequency:
        return _replyWrap([
          _ReplyPill('2x', () => _onFrequency('2 jours', '2 jours par semaine')),
          _ReplyPill('3x', () => _onFrequency('3 jours', '3 jours par semaine')),
          _ReplyPill('4x', () => _onFrequency('4 jours', '4 jours par semaine')),
          _ReplyPill('5x', () => _onFrequency('5 jours', '5 jours par semaine')),
          _ReplyPill('6x', () => _onFrequency('6 jours', '6 jours par semaine')),
        ]);

      case _ChatPhase.done:
        return const SizedBox.shrink();
    }
  }

  Widget _replyWrap(List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: c,
      )).toList(),
    );
  }
}

// ── Reply pill button ────────────────────────────────────────────────────────
class _ReplyPill extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  const _ReplyPill(this.label, this.onTap, {this.icon, this.iconColor});

  @override
  State<_ReplyPill> createState() => _ReplyPillState();
}

class _ReplyPillState extends State<_ReplyPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withValues(alpha: 0.04),
                blurRadius: 10, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: widget.iconColor ?? _kGreenBright),
                const SizedBox(width: 8),
              ],
              Text(widget.label, textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3C2A))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reply chip (toggleable for multi-select) ─────────────────────────────────
class _ReplyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  const _ReplyChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8F5EC)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? _kGreenBright.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? const Color(0xFF1B5E3B).withValues(alpha: 0.1)
                  : const Color(0xFF000000).withValues(alpha: 0.03),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 16, color: _kGreenBright),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor ?? _kGreenBright),
              const SizedBox(width: 6),
            ],
            Text(label, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: selected
                  ? _kGreenBright
                  : const Color(0xFF1A3C2A))),
          ],
        ),
      ),
    );
  }
}

// ── Bouncing dots typing indicator ───────────────────────────────────────────
class _BouncingDots extends StatefulWidget {
  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
      return ctrl;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            child: Transform.translate(
              offset: Offset(0, -4 * _ctrls[i].value),
              child: Container(
                width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kGreenMid.withValues(alpha: 0.5 + 0.5 * _ctrls[i].value),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED — Quick Tap Card (full-width, emoji + label + sublabel, auto-advance)
// ══════════════════════════════════════════════════════════════════════════════
class _QuickTapCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _QuickTapCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_QuickTapCard> createState() => _QuickTapCardState();
}

class _QuickTapCardState extends State<_QuickTapCard>
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
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) { _scaleCtrl.reverse(); HapticFeedback.lightImpact(); widget.onTap(); },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: sel
                ? _kGreenDark.withValues(alpha: 0.4)
                : _kGlassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: sel
                  ? _kGreenBright.withValues(alpha: 0.5)
                  : _kGlassBorder,
              width: sel ? 1.5 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.12),
                    blurRadius: 20, offset: const Offset(0, 6))]
                : [],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: sel
                      ? _kGreenBright.withValues(alpha: 0.12)
                      : _kWhite.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(widget.icon, size: 24,
                      color: sel ? _kWhite : _kGreenBright),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: sel ? _kWhite : _kTextDark)),
                    const SizedBox(height: 3),
                    Text(widget.sublabel, style: GoogleFonts.inter(
                      fontSize: 13, color: sel ? _kGreenMid : _kTextMuted,
                      fontWeight: FontWeight.w400, height: 1.3)),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: sel ? _kGreenBright : Colors.transparent,
                  border: Border.all(
                    color: sel ? _kGreenBright : _kWhite.withValues(alpha: 0.15),
                    width: sel ? 0 : 1.5),
                ),
                child: sel
                    ? const Icon(Icons.check_rounded, size: 14, color: _kBgDark)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED — Quick Tap Tile (compact square for grids)
// ══════════════════════════════════════════════════════════════════════════════
class _QuickTapTile extends StatefulWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickTapTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_QuickTapTile> createState() => _QuickTapTileState();
}

class _QuickTapTileState extends State<_QuickTapTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selected;
    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) { _scaleCtrl.reverse(); HapticFeedback.selectionClick(); widget.onTap(); },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: sel
                ? _kGreenDark.withValues(alpha: 0.4)
                : _kGlassFill,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel
                  ? _kGreenBright.withValues(alpha: 0.5)
                  : _kGlassBorder,
              width: sel ? 1.5 : 0.5,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.1),
                    blurRadius: 16, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: sel ? _kWhite : _kTextDark, height: 1.2),
              ),
              if (sel) ...[
                const SizedBox(height: 6),
                Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGreenBright,
                  ),
                  child: const Icon(Icons.check_rounded, size: 12, color: _kBgDark),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepBuildingPlan (animated "building your plan" screen)
// ══════════════════════════════════════════════════════════════════════════════
class StepBuildingPlan extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onDone;

  const StepBuildingPlan({
    super.key,
    required this.data,
    required this.onDone,
  });

  @override
  State<StepBuildingPlan> createState() => _StepBuildingPlanState();
}

class _StepBuildingPlanState extends State<StepBuildingPlan>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;

  int _currentStep = 0;
  bool _showSummary = false;

  static const _buildSteps = [
    ('🎯', 'Analyse de tes objectifs...'),
    ('📊', 'Calcul de ton profil nutritionnel...'),
    ('🏋️', 'Création de ton programme...'),
    ('📅', 'Planification de tes séances...'),
    ('✨', 'Ton plan est prêt !'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..forward();

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _buildSteps.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 400 : 700));
      if (!mounted) return;
      setState(() => _currentStep = i);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _showSummary = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    widget.onDone();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Pulsing logo
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final scale = 1.0 + _pulseCtrl.value * 0.08;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGreenBright.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: _kGreenBright.withValues(alpha: 0.2),
                        blurRadius: 24, spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('✦', style: TextStyle(fontSize: 32, color: _kGreenBright)),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                _showSummary ? 'C\'est parti !' : 'On prépare ton plan...',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A3C2A),
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _showSummary
                    ? 'Ton programme personnalisé est prêt'
                    : 'Quelques secondes...',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF5A7A66),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 40),

              // Build steps checklist
              ...List.generate(_buildSteps.length, (i) {
                final visible = i <= _currentStep;
                final done = i < _currentStep || (i == _currentStep && i == _buildSteps.length - 1);
                return AnimatedOpacity(
                  opacity: visible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: AnimatedSlide(
                    offset: visible ? Offset.zero : const Offset(0, 0.3),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? _kGreenBright.withValues(alpha: 0.12)
                                  : Colors.white.withValues(alpha: 0.6),
                              boxShadow: done ? [
                                BoxShadow(
                                  color: _kGreenBright.withValues(alpha: 0.15),
                                  blurRadius: 8),
                              ] : null,
                            ),
                            child: Center(
                              child: done
                                  ? const Icon(Icons.check_rounded, size: 16, color: _kGreenBright)
                                  : Text(_buildSteps[i].$1, style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _buildSteps[i].$2,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                                color: done
                                    ? const Color(0xFF1A3C2A)
                                    : const Color(0xFF5A7A66),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(flex: 1),

              // Summary cards (appear after build)
              if (_showSummary)
                AnimatedOpacity(
                  opacity: _showSummary ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFCCDDD3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withValues(alpha: 0.04),
                          blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          value: widget.data.frequency ?? '3x',
                          label: 'par semaine',
                        ),
                        Container(width: 1, height: 36, color: const Color(0xFFCCDDD3)),
                        _SummaryItem(
                          value: widget.data.goals.isNotEmpty
                              ? widget.data.goals.first.split(' ').first
                              : 'Fitness',
                          label: 'objectif',
                        ),
                        Container(width: 1, height: 36, color: const Color(0xFFCCDDD3)),
                        _SummaryItem(
                          value: widget.data.fitnessLevel ?? 'Débutant',
                          label: 'niveau',
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  const _SummaryItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w700,
          color: _kGreenBright)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, color: const Color(0xFF5A7A66),
          fontWeight: FontWeight.w400)),
      ],
    );
  }
}