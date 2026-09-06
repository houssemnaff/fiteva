import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
import '../../../services/avatar_service.dart';
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

// ─── Design Tokens — WeGLOW-style with Green Palette ─────────────────────
const _kBgDark       = Color(0xFFEFF7F1);
const _kBgMid        = Color(0xFFF2F9F4);
const _kBgMint       = Color(0xFFEFF7F1);
const _kBgLight      = Color(0xFFF5FAF7);
const _kGreenDark    = Color(0xFF1B5E3B);
const _kGreenMid     = Color(0xFF276E4A);
const _kGreenBright  = Color(0xFF1B5E3B);
const _kCardUnsel    = Color(0xFFF5FAF7);
const _kCardSel      = Color(0xFF1B5E3B);
const _kTextDark     = Color(0xFF1A1A1A);
const _kTextMuted    = Color(0xFF8E8E93);
const _kWhite        = Colors.white;
const _kBorderLight  = Color(0xFFDAE8DF);
const _kGlassBorder  = Color(0xFFDAE8DF);
const _kGlassFill    = Color(0xFFF5FAF7);

// ─── Clean white background ──────────────────────────────────────────────────
Widget _stepBackground({required Widget child}) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE6F2EA),
            Color(0xFFEFF7F1),
            Color(0xFFF5FAF7),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: child,
    ),
  );
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar — segmented progress bar (WeGLOW-style) + back chevron
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
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: onBack ?? () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(LucideIcons.chevronLeft, size: 24,
                  color: Color(0xFF1A3C2A)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icône — subtle, no glow (WeGLOW-style clean)
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Titre + sous-titre — WeGLOW bold left-aligned
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
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _kGreenDark,
            height: 1.2,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: _kGreenMid,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// WeGLOW-style card — filled primary when selected, white when not
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: fullWidth ? double.infinity : null,
        padding: sublabel != null
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? _kGreenBright : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _kGreenBright
                : _kGreenBright.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: _kGreenBright.withValues(alpha: 0.2),
                  blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.03),
                  blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: sublabel != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : _kGreenDark)),
                        const SizedBox(height: 4),
                        Text(sublabel!, style: GoogleFonts.inter(
                          fontSize: 13,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.8)
                              : _kTextMuted,
                          height: 1.3)),
                      ],
                    )
                  : Text(label, style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : _kGreenDark)),
            ),
            if (icon != null)
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selected
                      ? Colors.white.withValues(alpha: 0.2)
                      : _kGreenBright.withValues(alpha: 0.08),
                ),
                child: Icon(icon, size: 20,
                    color: selected ? Colors.white.withValues(alpha: 0.9) : _kGreenMid),
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

/// CTA button — WeGLOW solid filled style
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
        padding: const EdgeInsets.fromLTRB(40, 12, 40, 24),
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 56,
            decoration: BoxDecoration(
              color: enabled ? _kGreenBright : _kGreenBright.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
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

class _StepLanguageChoiceState extends State<StepLanguageChoice> {
  String? _selected;

  void _pick(String lang) {
    HapticFeedback.lightImpact();
    setState(() => _selected = lang);
  }

  Widget _langCard(String code, String flag, String label, String sub) {
    final sel = _selected == code;
    final dim = _selected != null && !sel;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pick(code),
        child: AnimatedScale(
          scale: sel ? 1.0 : (dim ? 0.95 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: sel ? _kGreenDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: sel ? _kGreenBright : (dim ? Colors.transparent : _kGreenBright.withValues(alpha: 0.1)),
                width: sel ? 2.5 : 1.5),
              boxShadow: [BoxShadow(
                color: sel
                    ? _kGreenDark.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: dim ? 0.02 : 0.05),
                blurRadius: sel ? 20 : 10,
                offset: const Offset(0, 5))],
            ),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: dim ? 0.45 : 1.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 10),
                  Text(label, style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: sel ? Colors.white : _kGreenDark)),
                  const SizedBox(height: 2),
                  Text(sub, textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: sel ? Colors.white.withValues(alpha: 0.7) : _kGreenMid)),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: sel ? Colors.white : _kGreenMid.withValues(alpha: 0.25),
                        width: 2)),
                    child: AnimatedScale(
                      scale: sel ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: const Icon(Icons.check_rounded, size: 16, color: _kGreenDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 60),
          Icon(LucideIcons.globe, size: 44, color: _kGreenBright),
          const SizedBox(height: 20),
          Text('Choose your language',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800,
              color: _kGreenDark)),
          const SizedBox(height: 4),
          Text('Choisissez votre langue',
            style: GoogleFonts.inter(fontSize: 13, color: _kGreenMid)),
          const SizedBox(height: 36),
          // ── 2-column cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(children: [
              _langCard('fr', '\u{1F1EB}\u{1F1F7}', 'Francais', 'Continuer en francais'),
              const SizedBox(width: 14),
              _langCard('en', '\u{1F1EC}\u{1F1E7}', 'English', 'Continue in English'),
            ]),
          ),
          const Spacer(),
          _CtaButton(
            label: _selected == 'fr' ? 'Continuer' : 'Continue',
            onPressed: _selected != null
                ? () => widget.onNext(Locale(_selected!))
                : null,
          ),
        ]),
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
            color: sel ? _kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? _kGreenBright : _kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Text(widget.flag, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(widget.label, style: GoogleFonts.inter(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : _kGreenDark)),
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
  }

  static const _goalIcons = [
    LucideIcons.flame,
    LucideIcons.scale,
    LucideIcons.dumbbell,
  ];

  static const _goalColors = [
    Color(0xFFE85D3A),
    Color(0xFF2E9E6B),
    Color(0xFF5B6ABF),
  ];

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    final goalLabels = [
      _fr ? 'Perte de poids' : 'Lose weight',
      _fr ? 'Maintien' : 'Maintain weight',
      _fr ? 'Prise de masse' : 'Gain weight',
    ];
    final goalSubs = [
      _fr ? 'Brûle des graisses et sculpte ton corps' : 'Burn fat and sculpt your body',
      _fr ? 'Garde la forme et reste en équilibre' : 'Stay fit and maintain your balance',
      _fr ? 'Construis du muscle et gagne en force' : 'Build muscle and gain strength',
    ];
    final hasSel = widget.selectedGoals.isNotEmpty;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 1, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quel est ton objectif principal ?' : 'What is your main goal?',
                subtitle: _fr
                    ? 'On personnalise ton plan selon ton choix'
                    : 'We\'ll personalize your plan',
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_goals.length, (i) {
                  final key = _goals[i].label;
                  final isSel = widget.selectedGoals.contains(key);
                  final isDim = hasSel && !isSel;
                  final accent = _goalColors[i];
                  return FadeTransition(
                    opacity: _fades[i],
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < _goals.length - 1 ? 14 : 0),
                      child: _GlassCard(
                        selected: isSel,
                        dimmed: isDim,
                        accent: accent,
                        icon: _goalIcons[i],
                        label: goalLabels[i],
                        sublabel: goalSubs[i],
                        onTap: () => _select(key),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
            AnimatedOpacity(
              opacity: hasSel ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: hasSel ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _CtaButton(
                  label: Lang.code == 'fr' ? 'Continuer' : 'Continue',
                  onPressed: hasSel ? widget.onNext : null,
                ),
              ),
            ),
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
  }

  static const _levelIcons = [
    LucideIcons.sprout,
    LucideIcons.zap,
    LucideIcons.trophy,
  ];

  static const _levelColors = [
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    final l10n = AppL10n(Lang.code);
    final levelLabels = [
      l10n.fitnessLevelBeginner,
      l10n.fitnessLevelIntermediate,
      l10n.fitnessLevelAdvanced,
    ];
    final levelSubs = [
      _fr ? 'Commence en douceur, sans pression' : 'Start easy, no pressure',
      _fr ? 'Tu connais les bases, on monte d\'un cran' : 'You know the basics, time to level up',
      _fr ? 'Prête pour des défis intenses' : 'Ready for intense challenges',
    ];
    final hasSel = widget.selectedLevel != null;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 2, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quel est ton niveau de forme actuel ?' : 'What is your current fitness level?',
                subtitle: _fr ? 'On adapte l\'intensité pour toi' : 'We\'ll adapt the intensity for you',
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_levels.length, (i) {
                  final key = _levels[i];
                  final isSel = widget.selectedLevel == key;
                  final isDim = hasSel && !isSel;
                  final accent = _levelColors[i];
                  return FadeTransition(
                    opacity: _fades[i],
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < _levels.length - 1 ? 14 : 0),
                      child: _GlassCard(
                        selected: isSel,
                        dimmed: isDim,
                        accent: accent,
                        icon: _levelIcons[i],
                        label: levelLabels[i],
                        sublabel: levelSubs[i],
                        onTap: () => _select(key),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
            AnimatedOpacity(
              opacity: hasSel ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: hasSel ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _CtaButton(
                  label: Lang.code == 'fr' ? 'Continuer' : 'Continue',
                  onPressed: hasSel ? widget.onNext : null,
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

  static const _equipIcons = [
    LucideIcons.ban,
    LucideIcons.dumbbell,
    LucideIcons.weight,
    LucideIcons.cog,
    LucideIcons.cable,
    LucideIcons.accessibility,
  ];

  static const _equipColors = [
    Color(0xFF78909C),
    Color(0xFFE85D3A),
    Color(0xFF5B6ABF),
    Color(0xFF607D8B),
    Color(0xFF26A69A),
    Color(0xFFAB47BC),
  ];

  @override
  Widget build(BuildContext context) {
    final count = widget.selectedEquipment.length;
    final _fr = Lang.code == 'fr';
    final l10n = AppL10n(Lang.code);
    final equipLabels = [
      l10n.equipmentNone,
      l10n.equipmentDumbbells,
      l10n.equipmentBarbell,
      l10n.equipmentMachines,
      l10n.equipmentBands,
      l10n.equipmentYogaMat,
    ];
    final equipSubs = [
      _fr ? 'Entraînement au poids du corps' : 'Bodyweight training only',
      _fr ? 'Haltères classiques' : 'Classic free weights',
      _fr ? 'Barre olympique et poids' : 'Olympic bar and plates',
      _fr ? 'Équipement de salle' : 'Gym machines',
      _fr ? 'Bandes élastiques' : 'Elastic resistance bands',
      _fr ? 'Tapis et accessoires' : 'Mat and accessories',
    ];

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 3, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quel matériel as-tu ?' : 'What equipment do you have?',
                subtitle: _fr ? 'On adapte tes exercices en fonction' : 'We\'ll tailor exercises to your gear',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _equipments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final key = _equipments[i];
                  final isSel = widget.selectedEquipment.contains(key);
                  final accent = _equipColors[i];
                  return FadeTransition(
                    opacity: _fades[i],
                    child: _GlassCard(
                      selected: isSel,
                      dimmed: false,
                      accent: accent,
                      icon: _equipIcons[i],
                      label: equipLabels[i],
                      sublabel: equipSubs[i],
                      onTap: () => _handleEquipmentTap(key),
                    ),
                  );
                },
              ),
            ),
            AnimatedOpacity(
              opacity: count > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: count > 0 ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _CtaButton(
                  label: count > 0 ? '${l10n.equipmentContinue} ($count)' : l10n.equipmentSelectAtLeastOne,
                  onPressed: count > 0 ? widget.onNext : null,
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

  static const _freqIcons = [
    LucideIcons.calendar,
    LucideIcons.calendarDays,
    LucideIcons.calendarCheck,
    LucideIcons.calendarClock,
    LucideIcons.calendarHeart,
  ];

  static const _freqColors = [
    Color(0xFF4CAF50),
    Color(0xFF2E9E6B),
    Color(0xFF1E88E5),
    Color(0xFFFF9800),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    final freqSubs = [
      _fr ? 'Idéal pour commencer' : 'Great for getting started',
      _fr ? 'Bon rythme régulier' : 'Good steady rhythm',
      _fr ? 'Rythme soutenu et efficace' : 'Consistent and effective',
      _fr ? 'Engagement sérieux' : 'Serious commitment',
      _fr ? 'Athlète confirmée' : 'Dedicated athlete',
    ];
    final hasSel = _hasInteracted;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 5, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Combien de fois par semaine ?' : 'How many times per week?',
                subtitle: _fr ? 'On planifie tes séances idéales' : 'We\'ll plan your ideal schedule',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _labels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final isSel = _index == i && _hasInteracted;
                  final isDim = hasSel && !isSel;
                  final accent = _freqColors[i];
                  return _GlassCard(
                    selected: isSel,
                    dimmed: isDim,
                    accent: accent,
                    icon: _freqIcons[i],
                    label: _labels[i] + (_fr ? ' / semaine' : ' / week'),
                    sublabel: freqSubs[i],
                    onTap: () => _select(i),
                  );
                },
              ),
            ),
            AnimatedOpacity(
              opacity: _hasInteracted ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: _hasInteracted ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _CtaButton(
                  label: AppL10n(Lang.code).frequencyNext,
                  onPressed: _hasInteracted ? widget.onNext : null,
                ),
              ),
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
// STEP — StepHeight (WeGLOW-style ruler picker)
// ══════════════════════════════════════════════════════════════════════════════
class StepHeight extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final int initialHeightCm;
  final ValueChanged<int>? onHeightChanged;

  const StepHeight({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialHeightCm = 165,
    this.onHeightChanged,
  });

  @override
  State<StepHeight> createState() => _StepHeightState();
}

class _StepHeightState extends State<StepHeight> {
  static const int _minCm = 130, _maxCm = 220;
  late final FixedExtentScrollController _ctrl;
  late int _idx;
  bool _useMetric = true;
  bool _isEditing = false;
  late final TextEditingController _textCtrl;
  final FocusNode _focusNode = FocusNode();

  int get _heightCm => _minCm + _idx;

  @override
  void initState() {
    super.initState();
    _useMetric = Lang.code == 'fr';
    _idx = (widget.initialHeightCm - _minCm).clamp(0, _maxCm - _minCm);
    _ctrl = FixedExtentScrollController(initialItem: _idx);
    _textCtrl = TextEditingController();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commitEdit();
    });
    TickSoundService.instance.init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textCtrl.text = _useMetric ? '$_heightCm' : '${(_heightCm / 2.54).round()}';
      _textCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _textCtrl.text.length);
    });
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _commitEdit() {
    final text = _textCtrl.text.trim();
    final parsed = int.tryParse(text);
    if (parsed != null) {
      int targetCm = _useMetric ? parsed : (parsed * 2.54).round();
      targetCm = targetCm.clamp(_minCm, _maxCm);
      final newIdx = targetCm - _minCm;
      setState(() => _idx = newIdx);
      _ctrl.jumpToItem(newIdx);
      widget.onHeightChanged?.call(_heightCm);
    }
    setState(() => _isEditing = false);
  }

  String _displayValue() {
    if (_useMetric) return '$_heightCm';
    final totalInches = (_heightCm / 2.54).round();
    final ft = totalInches ~/ 12;
    final inches = totalInches % 12;
    return '$ft\'$inches"';
  }

  String _displayUnit() => _useMetric ? 'CM' : 'FT, IN';

  String _conversionText() {
    if (_useMetric) {
      final totalIn = (_heightCm / 2.54).round();
      return '= ${totalIn ~/ 12}\'${totalIn % 12}"';
    }
    return '= $_heightCm cm';
  }

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 6, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quelle est ta taille ?' : 'What is your height?',
                subtitle: _fr
                    ? 'On adapte tes exercices a ta morphologie'
                    : 'We\'ll adapt exercises to your body',
              ),
            ),
            const SizedBox(height: 20),

            // ── Glass preview card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FC077).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _kGreenBright.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? null : _startEditing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              _isEditing
                                  ? SizedBox(
                                      width: 100,
                                      child: TextField(
                                        controller: _textCtrl,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 56, fontWeight: FontWeight.w800, color: _kGreenDark),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        onSubmitted: (_) => _commitEdit(),
                                      ),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        _displayValue(),
                                        key: ValueKey('${_displayValue()}_$_useMetric'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 56, fontWeight: FontWeight.w800, color: _kGreenDark),
                                      ),
                                    ),
                              const SizedBox(width: 8),
                              Text(_displayUnit(), style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.w500, color: _kGreenMid)),
                            ],
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 4),
                          Text(
                            _fr ? 'Appuie pour modifier' : 'Tap to edit',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w400, color: _kTextMuted.withValues(alpha: 0.6)),
                          ),
                        ],
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _conversionText(),
                            key: ValueKey('conv_${_heightCm}_$_useMetric'),
                            style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w400, color: _kTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Segmented toggle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _kGreenBright.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    _segmentBtn('ft, in', !_useMetric, () => setState(() => _useMetric = false)),
                    _segmentBtn('cm', _useMetric, () => setState(() => _useMetric = true)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Scroll picker ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _AgePicker(
                  controller: _ctrl,
                  selectedIndex: _idx,
                  itemCount: _maxCm - _minCm + 1,
                  labelFor: (i) {
                    final cm = _minCm + i;
                    if (_useMetric) return '$cm';
                    final totalIn = (cm / 2.54).round();
                    return '${totalIn ~/ 12}\'${totalIn % 12}"';
                  },
                  onChanged: (i) {
                    setState(() => _idx = i);
                    widget.onHeightChanged?.call(_heightCm);
                  },
                ),
              ),
            ),

            const SizedBox(height: 4),
            _PrivacyNotice(isFr: _fr),
            _CtaButton(
              label: _fr ? 'Continuer' : 'Continue',
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(
              fontSize: 15, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _kGreenDark : _kTextMuted,
            )),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepWeight (WeGLOW-style ruler picker)
// ══════════════════════════════════════════════════════════════════════════════
class StepWeight extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final double initialWeightKg;
  final ValueChanged<double>? onWeightChanged;

  const StepWeight({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialWeightKg = 60.0,
    this.onWeightChanged,
  });

  @override
  State<StepWeight> createState() => _StepWeightState();
}

class _StepWeightState extends State<StepWeight> {
  static final List<double> _kgList = List.generate(231, (i) => 35.0 + i * 0.5);
  late final FixedExtentScrollController _ctrl;
  late int _idx;
  bool _useMetric = true;
  bool _isEditing = false;
  late final TextEditingController _textCtrl;
  final FocusNode _focusNode = FocusNode();

  double get _weightKg => _kgList[_idx];

  @override
  void initState() {
    super.initState();
    _useMetric = Lang.code == 'fr';
    final nearest = _kgList.indexWhere((w) => w >= widget.initialWeightKg);
    _idx = nearest < 0 ? 50 : nearest;
    _ctrl = FixedExtentScrollController(initialItem: _idx);
    _textCtrl = TextEditingController();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commitEdit();
    });
    TickSoundService.instance.init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textCtrl.text = _displayValue();
      _textCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _textCtrl.text.length);
    });
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _commitEdit() {
    final text = _textCtrl.text.trim();
    final parsed = double.tryParse(text);
    if (parsed != null) {
      double targetKg = _useMetric ? parsed : parsed / 2.205;
      targetKg = targetKg.clamp(35.0, 150.0);
      int bestIdx = 0;
      double bestDiff = double.infinity;
      for (int i = 0; i < _kgList.length; i++) {
        final diff = (_kgList[i] - targetKg).abs();
        if (diff < bestDiff) { bestDiff = diff; bestIdx = i; }
      }
      setState(() => _idx = bestIdx);
      _ctrl.jumpToItem(bestIdx);
      widget.onWeightChanged?.call(_weightKg);
    }
    setState(() => _isEditing = false);
  }

  String _displayValue() {
    if (_useMetric) {
      return _weightKg % 1 == 0 ? '${_weightKg.toInt()}' : _weightKg.toStringAsFixed(1);
    }
    return (_weightKg * 2.205).round().toString();
  }

  String _displayUnit() => _useMetric ? 'KG' : 'LBS';

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    final lbsValue = (_weightKg * 2.205).round();

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 7, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quel est ton poids ?' : 'What is your weight?',
                subtitle: _fr
                    ? 'On calcule tes besoins caloriques'
                    : 'We\'ll calculate your calorie needs',
              ),
            ),
            const SizedBox(height: 20),

            // ── Glass preview card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FC077).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _kGreenBright.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? null : _startEditing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              _isEditing
                                  ? SizedBox(
                                      width: 120,
                                      child: TextField(
                                        controller: _textCtrl,
                                        focusNode: _focusNode,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 56, fontWeight: FontWeight.w800, color: _kGreenDark),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        onSubmitted: (_) => _commitEdit(),
                                      ),
                                    )
                                  : AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        _displayValue(),
                                        key: ValueKey('${_displayValue()}_$_useMetric'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 56, fontWeight: FontWeight.w800, color: _kGreenDark),
                                      ),
                                    ),
                              const SizedBox(width: 8),
                              Text(_displayUnit(), style: GoogleFonts.inter(
                                fontSize: 20, fontWeight: FontWeight.w500, color: _kGreenMid)),
                            ],
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 4),
                          Text(
                            _fr ? 'Appuie pour modifier' : 'Tap to edit',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w400, color: _kTextMuted.withValues(alpha: 0.6)),
                          ),
                        ],
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _useMetric
                                ? '= $lbsValue lbs'
                                : '= ${_weightKg % 1 == 0 ? '${_weightKg.toInt()}' : _weightKg.toStringAsFixed(1)} kg',
                            key: ValueKey('conv_${_weightKg}_$_useMetric'),
                            style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w400, color: _kTextMuted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Segmented toggle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _kGreenBright.withValues(alpha: 0.08),
                ),
                child: Row(
                  children: [
                    _segmentBtn('lbs', !_useMetric, () => setState(() => _useMetric = false)),
                    _segmentBtn('kg', _useMetric, () => setState(() => _useMetric = true)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Scroll picker ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _AgePicker(
                  controller: _ctrl,
                  selectedIndex: _idx,
                  itemCount: _kgList.length,
                  labelFor: (i) {
                    final w = _kgList[i];
                    if (_useMetric) {
                      return w % 1 == 0 ? '${w.toInt()}' : w.toStringAsFixed(1);
                    }
                    return '${(w * 2.205).round()}';
                  },
                  onChanged: (i) {
                    setState(() => _idx = i);
                    widget.onWeightChanged?.call(_weightKg);
                  },
                ),
              ),
            ),

            const SizedBox(height: 4),
            _PrivacyNotice(isFr: _fr),
            _CtaButton(
              label: _fr ? 'Continuer' : 'Continue',
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(
              fontSize: 15, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _kGreenDark : _kTextMuted,
            )),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepAge (WeGLOW-style ruler picker)
// ══════════════════════════════════════════════════════════════════════════════
class StepAge extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final int initialAge;
  final ValueChanged<int>? onAgeChanged;

  const StepAge({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialAge = 25,
    this.onAgeChanged,
  });

  @override
  State<StepAge> createState() => _StepAgeState();
}

class _StepAgeState extends State<StepAge> {
  static const int _minAge = 15, _maxAge = 70;
  late final FixedExtentScrollController _ctrl;
  late int _idx;
  bool _isEditing = false;
  late final TextEditingController _textCtrl;
  final FocusNode _focusNode = FocusNode();

  int get _age => _minAge + _idx;

  @override
  void initState() {
    super.initState();
    _idx = (widget.initialAge - _minAge).clamp(0, _maxAge - _minAge);
    _ctrl = FixedExtentScrollController(initialItem: _idx);
    _textCtrl = TextEditingController();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commitEdit();
    });
    TickSoundService.instance.init();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _textCtrl.text = '$_age';
      _textCtrl.selection = TextSelection(baseOffset: 0, extentOffset: _textCtrl.text.length);
    });
    Future.microtask(() => _focusNode.requestFocus());
  }

  void _commitEdit() {
    final text = _textCtrl.text.trim();
    final parsed = int.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(_minAge, _maxAge);
      final newIdx = clamped - _minAge;
      setState(() => _idx = newIdx);
      _ctrl.jumpToItem(newIdx);
      widget.onAgeChanged?.call(_age);
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 8, total: 10, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Quel est ton âge ?' : 'How old are you?',
                subtitle: _fr
                    ? 'On adapte l\'intensité selon ton profil'
                    : 'We\'ll adapt intensity to your profile',
              ),
            ),
            const SizedBox(height: 24),

            // ── Big preview card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7FC077).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _kGreenBright.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _isEditing ? null : _startEditing,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              _isEditing
                                  ? SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: _textCtrl,
                                        focusNode: _focusNode,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 64, fontWeight: FontWeight.w800, color: _kGreenDark),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                        onSubmitted: (_) => _commitEdit(),
                                      ),
                                    )
                                  : Text('$_age', style: GoogleFonts.outfit(
                                      fontSize: 64, fontWeight: FontWeight.w800, color: _kGreenDark)),
                              const SizedBox(width: 8),
                              Text(_fr ? 'ans' : 'yrs', style: GoogleFonts.inter(
                                fontSize: 22, fontWeight: FontWeight.w500, color: _kGreenMid)),
                            ],
                          ),
                        ),
                        if (!_isEditing) ...[
                          const SizedBox(height: 4),
                          Text(
                            _fr ? 'Appuie pour modifier' : 'Tap to edit',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w400, color: _kTextMuted.withValues(alpha: 0.6)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Scroll wheel ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _AgePicker(
                  controller: _ctrl,
                  selectedIndex: _idx,
                  itemCount: _maxAge - _minAge + 1,
                  labelFor: (i) => '${_minAge + i}',
                  onChanged: (i) {
                    setState(() => _idx = i);
                    widget.onAgeChanged?.call(_age);
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),
            _PrivacyNotice(isFr: _fr),
            _CtaButton(
              label: _fr ? 'Continuer' : 'Continue',
              onPressed: widget.onNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Age Picker (glassmorphic center indicator, horizontal scroll feel) ───────
class _AgePicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int selectedIndex;
  final int itemCount;
  final String Function(int) labelFor;
  final ValueChanged<int> onChanged;

  const _AgePicker({
    required this.controller,
    required this.selectedIndex,
    required this.itemCount,
    required this.labelFor,
    required this.onChanged,
  });

  static const double _kItemH = 60.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Glassmorphic selection strip ──
        Positioned(
          left: 0, right: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: _kItemH + 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF7FC077).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _kGreenBright.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
        // ── Scroll list ──
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: _kItemH,
          perspective: 0.003,
          diameterRatio: 1.8,
          squeeze: 1.0,
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
                  duration: const Duration(milliseconds: 150),
                  style: GoogleFonts.outfit(
                    fontSize: sel ? 32 : 20,
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                    color: sel ? _kGreenDark : _kTextMuted.withValues(alpha: 0.6),
                  ),
                  child: Text(labelFor(i)),
                ),
              );
            },
          ),
        ),
        // Top fade
        Positioned(
          top: 0, left: 0, right: 0, height: 70,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE6F2EA),
                    const Color(0xFFE6F2EA).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom fade
        Positioned(
          bottom: 0, left: 0, right: 0, height: 70,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [
                    const Color(0xFFF5FAF7),
                    const Color(0xFFF5FAF7).withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Ruler Picker (shared by Height/Weight steps) ────────────────────────────
class _RulerPicker extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int selectedIndex;
  final int itemCount;
  final String Function(int) labelFor;
  final ValueChanged<int> onChanged;

  const _RulerPicker({
    required this.controller,
    required this.selectedIndex,
    required this.itemCount,
    required this.labelFor,
    required this.onChanged,
  });

  static const double _kItemH = 56.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0, right: 0,
            child: Container(height: 2, color: _kGreenDark),
          ),
          Positioned(
            right: 12, top: 0, bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(9, (i) {
                final isMajor = i % 2 == 0;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: isMajor ? 14 : 16),
                  child: Container(
                    width: isMajor ? 16 : 10,
                    height: 1.5,
                    color: _kGreenDark.withValues(alpha: isMajor ? 0.25 : 0.12),
                  ),
                );
              }),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _kItemH,
            perspective: 0.002,
            diameterRatio: 2.0,
            squeeze: 1.0,
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
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: GoogleFonts.outfit(
                        fontSize: sel ? 20 : 15,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                        color: sel ? _kGreenDark : _kGreenMid.withValues(alpha: 0.4),
                      ),
                      child: Text(labelFor(i)),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0, height: 60,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: 60,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.white, Colors.white.withValues(alpha: 0)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Unit toggle (lbs/kg, ft/cm) ──────────────────────────────────────────────
class _UnitToggle extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isRight;
  final ValueChanged<bool> onToggle;

  const _UnitToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isRight,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kGreenBright.withValues(alpha: 0.15)),
        color: _kGreenBright.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleBtn(leftLabel, !isRight, () => onToggle(false))),
          Expanded(child: _toggleBtn(rightLabel, isRight, () => onToggle(true))),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: active ? Border.all(color: _kGreenBright.withValues(alpha: 0.2)) : null,
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
              : null,
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.inter(
            fontSize: 15, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? _kGreenDark : _kGreenMid.withValues(alpha: 0.5),
          )),
        ),
      ),
    );
  }
}

// ── Privacy notice card ──────────────────────────────────────────────────────
class _PrivacyNotice extends StatelessWidget {
  final bool isFr;
  const _PrivacyNotice({required this.isFr});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGreenBright.withValues(alpha: 0.12)),
          color: _kGreenBright.withValues(alpha: 0.04),
        ),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: isFr ? 'Ta vie privée compte. ' : 'Your privacy matters. ',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w700, color: _kGreenDark),
            ),
            TextSpan(
              text: isFr
                  ? 'Nous utilisons ces informations uniquement pour calculer ton métabolisme, recommander des calories et personnaliser ton expérience.'
                  : 'We only use this information to calculate your BMR, recommend calories and to personalise your experience.',
              style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w400, color: _kGreenMid, height: 1.4),
            ),
          ]),
        ),
      ),
    );
  }
}

// Keep StepHealthProfile as a wrapper for backwards compatibility
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
  int _subStep = 0;

  @override
  Widget build(BuildContext context) {
    switch (_subStep) {
      case 0:
        return StepHeight(
          onBack: widget.onBack,
          initialHeightCm: widget.initialHeightCm,
          onHeightChanged: widget.onHeightChanged,
          onNext: () => setState(() => _subStep = 1),
        );
      case 1:
        return StepWeight(
          onBack: () => setState(() => _subStep = 0),
          initialWeightKg: widget.initialWeightKg,
          onWeightChanged: widget.onWeightChanged,
          onNext: () => setState(() => _subStep = 2),
        );
      default:
        return StepAge(
          onBack: () => setState(() => _subStep = 1),
          initialAge: widget.initialAge,
          onAgeChanged: widget.onAgeChanged,
          onNext: widget.onNext,
        );
    }
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

  static final _pathData = [
    {'key': 'cycle',      'icon': LucideIcons.moon,     'color': Color(0xFF7ABB98),
     'fr': 'Cycle regulier',       'en': 'Regular cycle',
     'frSub': 'Sync ton entrainement\navec ton cycle menstruel',
     'enSub': 'Sync your training\nwith your menstrual cycle',
     'frTag': 'Le plus populaire', 'enTag': 'Most popular'},
    {'key': 'pregnant',   'icon': LucideIcons.heart,    'color': Color(0xFFE8A0B4),
     'fr': 'Enceinte',             'en': 'Pregnant',
     'frSub': 'Programme prenatal adapte\na chaque trimestre',
     'enSub': 'Prenatal program adapted\nto each trimester',
     'frTag': 'Prenatal',          'enTag': 'Prenatal'},
    {'key': 'postpartum', 'icon': LucideIcons.baby,     'color': Color(0xFFA7B8CD),
     'fr': 'Post-partum',          'en': 'Postpartum',
     'frSub': 'Recuperation douce\net progressive',
     'enSub': 'Gentle and\nprogressive recovery',
     'frTag': 'Recuperation',      'enTag': 'Recovery'},
  ];

  @override
  Widget build(BuildContext context) {
    final fr = Lang.code == 'fr';
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 7, total: 7, onBack: widget.onBack),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                Text(fr ? 'Ton parcours' : 'Your journey',
                  style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w700,
                    color: _kGreenDark)),
                const SizedBox(height: 6),
                Text(fr ? 'Choisis ce qui te correspond' : 'Choose what fits you',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 14, color: _kGreenMid)),
              ]),
            ),
            const SizedBox(height: 16),

            // ── Vertical accordion options ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(_pathData.length, (i) {
                    final d = _pathData[i];
                    final key = d['key'] as String;
                    final sel = _status == key;
                    final otherSel = _status != null && !sel;
                    final color = d['color'] as Color;
                    final icon = d['icon'] as IconData;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _status = _status == key ? null : key);
                          if (_status == key) widget.onHealthStatusChanged?.call(key);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: sel ? color : Colors.transparent,
                              width: 2),
                            boxShadow: [BoxShadow(
                              color: sel
                                  ? color.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: otherSel ? 0.02 : 0.04),
                              blurRadius: sel ? 16 : 8,
                              offset: const Offset(0, 4))],
                          ),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: otherSel ? 0.5 : 1.0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ── Header row ──
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(children: [
                                    Container(
                                      width: 44, height: 44,
                                      decoration: BoxDecoration(
                                        gradient: sel
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [color, color.withValues(alpha: 0.7)])
                                            : null,
                                        color: sel ? null : color.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14)),
                                      child: Icon(icon, size: 20,
                                        color: sel ? Colors.white : color),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fr ? d['fr'] as String : d['en'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16, fontWeight: FontWeight.w700,
                                            color: _kGreenDark)),
                                        const SizedBox(height: 2),
                                        Text(
                                          (fr ? d['frSub'] as String : d['enSub'] as String)
                                              .replaceAll('\n', ' '),
                                          style: GoogleFonts.inter(
                                            fontSize: 12, color: _kGreenMid,
                                            height: 1.3)),
                                      ],
                                    )),
                                    const SizedBox(width: 8),
                                    // Checkmark when selected, chevron otherwise
                                    sel
                                        ? Container(
                                            width: 26, height: 26,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color),
                                            child: const Icon(Icons.check_rounded,
                                              size: 16, color: Colors.white),
                                          )
                                        : AnimatedRotation(
                                            turns: 0,
                                            duration: const Duration(milliseconds: 300),
                                            child: Icon(LucideIcons.chevronDown,
                                              size: 20,
                                              color: otherSel
                                                  ? _kGreenMid.withValues(alpha: 0.4)
                                                  : _kGreenMid),
                                          ),
                                  ]),
                                ),

                                // ── Expanded content ──
                                AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Divider(height: 1,
                                          color: color.withValues(alpha: 0.15)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                                        child: key == 'cycle'
                                            ? _cycleWidget()
                                            : key == 'pregnant'
                                                ? _pregnancyWidget()
                                                : _postpartumWidget(),
                                      ),
                                    ],
                                  ),
                                  crossFadeState: sel
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 350),
                                  sizeCurve: Curves.easeOutCubic,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            _CtaButton(
              label: fr ? 'Continuer' : 'Continue',
              onPressed: _status != null
                  ? (_status == 'cycle'
                      ? widget.onNext
                      : _status == 'pregnant'
                          ? widget.onNext
                          : (_ppDuration != null ? widget.onNext : null))
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── CYCLE content ──────────────────────────────────────────────────────────
  Widget _cycleWidget() {
    final fr = Lang.code == 'fr';
    final cycleDays = int.tryParse(_cycleDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 28;
    final diff = _nextPeriod.difference(DateTime.now()).inDays;

    return Column(
      key: const ValueKey('cycle'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Duration — horizontal scroll selector ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.timer, size: 18, color: _kGreenBright),
              ),
              const SizedBox(width: 12),
              Text(fr ? 'Duree du cycle' : 'Cycle duration',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700,
                  color: _kGreenDark)),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: Row(
                children: _durations.map((d) {
                  final sel = _cycleDuration == d;
                  final num = d.replaceAll(RegExp(r'[^0-9]'), '');
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _cycleDuration = d);
                        widget.onCycleDurationChanged?.call(d);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          gradient: sel ? const LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [Color(0xFF1B5E3B), Color(0xFF2E8B57)]) : null,
                          color: sel ? null : const Color(0xFFF5F8F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(num, style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : _kGreenDark)),
                            Text(fr ? 'j' : 'd', style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: sel ? Colors.white.withValues(alpha: 0.7) : _kGreenMid)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 14),

        // ── Last period — date card ──
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${_lastPeriod.day}',
                      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800,
                        color: const Color(0xFFD94F6B))),
                    Text(_fmtMonth(_lastPeriod),
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700,
                        color: const Color(0xFFD94F6B).withValues(alpha: 0.7))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fr ? 'Dernieres regles' : 'Last period',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                      color: _kGreenDark)),
                  const SizedBox(height: 2),
                  Text(_fmt(_lastPeriod),
                    style: GoogleFonts.inter(fontSize: 13, color: _kGreenMid)),
                ],
              )),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F6),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.calendarDays, size: 16, color: _kGreenMid),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 14),

        // ── Next period + phase overview ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.moon, size: 16, color: _kGreenBright),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fr ? 'Prochaines regles' : 'Next period',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700,
                      color: _kGreenDark)),
                  Text(diff > 0
                      ? '${fr ? 'dans' : 'in'} $diff ${fr ? 'jours' : 'days'} · ${_fmt(_nextPeriod)}'
                      : _fmt(_nextPeriod),
                    style: GoogleFonts.inter(fontSize: 12, color: _kGreenMid)),
                ],
              )),
            ]),
            const SizedBox(height: 16),
            _buildPhaseBar(cycleDays),
          ]),
        ),

        const SizedBox(height: 10),

        // ── Context note ──
        Row(children: [
          Icon(LucideIcons.info, size: 13,
            color: _kGreenMid.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Text(fr ? 'Base sur tes donnees' : 'Based on your data',
            style: GoogleFonts.inter(fontSize: 11,
              color: _kGreenMid.withValues(alpha: 0.5))),
        ]),
      ],
    );
  }

  String _fmtMonth(DateTime d) {
    const m = ['JAN','FEV','MAR','AVR','MAI','JUN','JUL','AOU','SEP','OCT','NOV','DEC'];
    return m[d.month - 1];
  }

  Widget _buildPhaseBar(int days) {
    final follDays = max(1, (days * 0.32).round() - 2);
    final lutDays = max(1, days - 5 - follDays - 2);
    final fr = Lang.code == 'fr';
    final phases = [
      (fr ? 'Regles' : 'Period', 5, const Color(0xFFE8A0A0)),
      (fr ? 'Folliculaire' : 'Follicular', follDays, const Color(0xFFEDD07A)),
      (fr ? 'Ovulation' : 'Ovulation', 2, const Color(0xFF7AC998)),
      (fr ? 'Luteale' : 'Luteal', lutDays, const Color(0xFFB8A8D4)),
    ];
    return Column(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: phases.map((p) => Expanded(
            flex: p.$2,
            child: Container(height: 8, color: p.$3),
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
              decoration: BoxDecoration(color: p.$3, shape: BoxShape.circle)),
            const SizedBox(width: 3),
            Text(p.$1, style: GoogleFonts.inter(fontSize: 9, color: _kGreenMid,
              fontWeight: FontWeight.w500)),
          ],
        )).toList(),
      ),
    ]);
  }

  // ── PREGNANCY content ──────────────────────────────────────────────────────
  Widget _pregnancyWidget() {
    final fr = Lang.code == 'fr';
    final l10n = AppL10n(Lang.code);
    final trimColors = [const Color(0xFF7AC998), const Color(0xFFEDD07A), const Color(0xFFE8A0A0)];
    final trimLabels = [
      l10n.cycleTrimester1Label,
      l10n.cycleTrimester2Label,
      l10n.cycleTrimester3Label,
    ];

    return Column(
      key: const ValueKey('pregnancy'),
      children: [
        // ── Week selector card ──
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(LucideIcons.heart, size: 20, color: Color(0xFFE8A0B4)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fr ? 'Semaine de grossesse' : 'Pregnancy week',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                      color: _kGreenDark)),
                  Text(fr ? 'Trimestre $_trimester' : 'Trimester $_trimester',
                    style: GoogleFonts.inter(fontSize: 12, color: _kGreenMid)),
                ],
              )),
              Text('$_weekSA', style: GoogleFonts.outfit(
                fontSize: 36, fontWeight: FontWeight.w800, color: _kGreenDark)),
              const SizedBox(width: 4),
              Text(fr ? 'SA' : 'W', style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w600, color: _kGreenMid)),
            ]),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: trimColors[_trimester - 1],
                inactiveTrackColor: trimColors[_trimester - 1].withValues(alpha: 0.15),
                thumbColor: trimColors[_trimester - 1],
                overlayColor: trimColors[_trimester - 1].withValues(alpha: 0.1),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              ),
              child: Slider(
                value: _weekIdx.toDouble(),
                min: 0, max: 41,
                divisions: 41,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _weekIdx = v.round());
                  widget.onPregnancyWeekChanged?.call(_weekIdx + 1);
                },
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(fr ? '1 SA' : 'W 1', style: GoogleFonts.inter(
                fontSize: 11, color: _kGreenMid)),
              Text(fr ? '42 SA' : 'W 42', style: GoogleFonts.inter(
                fontSize: 11, color: _kGreenMid)),
            ]),
          ]),
        ),

        const SizedBox(height: 12),

        // ── Trimester tabs ──
        Row(children: List.generate(3, (i) {
          final t = i + 1;
          final active = _trimester == t;
          return Expanded(child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? trimColors[i] : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(children: [
                Text('T$t', style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: active ? Colors.white : _kGreenDark)),
                const SizedBox(height: 2),
                Text(t == 1 ? 'S1-13' : t == 2 ? 'S14-27' : 'S28-42',
                  style: GoogleFonts.inter(fontSize: 10,
                    color: active ? Colors.white.withValues(alpha: 0.8) : _kGreenMid)),
              ]),
            ),
          ));
        })),

        const SizedBox(height: 12),

        // ── Advice card ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: trimColors[_trimester - 1].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
              child: Icon(LucideIcons.sparkles, size: 16,
                color: trimColors[_trimester - 1]),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trimLabels[_trimester - 1], style: GoogleFonts.outfit(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _kGreenDark)),
                const SizedBox(height: 4),
                Text(_trimesterAdvice, style: GoogleFonts.inter(
                  fontSize: 12, color: _kGreenMid, height: 1.5)),
              ],
            )),
          ]),
        ),

        const SizedBox(height: 10),

        // ── Due date estimate ──
        Row(children: [
          Icon(LucideIcons.calendar, size: 13,
            color: _kGreenMid.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          Builder(builder: (_) {
            final dueDate = DateTime.now().add(Duration(days: (40 - _weekSA) * 7));
            return Text(
              fr
                  ? 'Date prevue : ${_fmt(dueDate)}'
                  : 'Due date: ${_fmt(dueDate)}',
              style: GoogleFonts.inter(fontSize: 11,
                color: _kGreenMid.withValues(alpha: 0.5)));
          }),
        ]),
      ],
    );
  }

  // ── POST-PARTUM content ────────────────────────────────────────────────────
  Widget _postpartumWidget() {
    final fr = Lang.code == 'fr';
    final weeks = _birthDate != null
        ? DateTime.now().difference(_birthDate!).inDays ~/ 7
        : null;

    return Column(
      key: const ValueKey('postpartum'),
      children: [
        // ── Birth date card ──
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
              accentColor: const Color(0xFFA7B8CD),
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
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EDF3),
                  borderRadius: BorderRadius.circular(16)),
                child: _birthDate != null
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${_birthDate!.day}', style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: const Color(0xFF6B89A8))),
                        Text(_fmtMonth(_birthDate!), style: GoogleFonts.inter(
                          fontSize: 9, fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B89A8).withValues(alpha: 0.7))),
                      ])
                    : const Icon(LucideIcons.baby, size: 22, color: Color(0xFF6B89A8)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fr ? 'Date de naissance' : 'Birth date',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700,
                      color: _kGreenDark)),
                  const SizedBox(height: 2),
                  Text(_birthDate != null
                      ? (weeks == 0
                          ? AppL10n(Lang.code).ppLessThanOneWeek
                          : '$weeks ${weeks == 1 ? (fr ? 'semaine' : 'week') : (fr ? 'semaines' : 'weeks')} ${AppL10n(Lang.code).ppWeeksSince}')
                      : (fr ? 'Quand bebe est-il ne ?' : 'When was baby born?'),
                    style: GoogleFonts.inter(fontSize: 12, color: _kGreenMid)),
                ],
              )),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8F6),
                  borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.calendarDays, size: 16, color: _kGreenMid),
              ),
            ]),
          ),
        ),

        // ── Recovery progress ──
        if (_birthDate != null && weeks != null) ...[
          const SizedBox(height: 12),
          _BirthWeekBar(weeks: weeks),
        ],

        // ── Program card ──
        if (_ppProgram.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _ppProgramColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.heartPulse, size: 18, color: _ppProgramColor),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_ppProgram, style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w700, color: _kGreenDark)),
                  const SizedBox(height: 2),
                  Text(_ppProgramDesc, style: GoogleFonts.inter(
                    fontSize: 11, color: _kGreenMid, height: 1.4)),
                ],
              )),
            ]),
          ),
        ],
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
// Step — Profile Photo (selfie / gallery)
// ─────────────────────────────────────────────────────────────────────────────
class StepProfilePhoto extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<String?> onPhotoSelected;

  const StepProfilePhoto({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onPhotoSelected,
  });

  @override
  State<StepProfilePhoto> createState() => _StepProfilePhotoState();
}

class _StepProfilePhotoState extends State<StepProfilePhoto>
    with SingleTickerProviderStateMixin {
  String? _photoUrl;
  bool _uploading = false;
  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      setState(() => _uploading = true);
      final url = await AvatarService.uploadAvatar(picked);
      if (!mounted) return;
      setState(() => _uploading = false);

      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_fr
              ? 'Impossible de charger la photo. Reessaie.'
              : 'Could not load the photo. Please try again.'),
        ));
        return;
      }

      setState(() => _photoUrl = url);
      widget.onPhotoSelected(url);
    } catch (e) {
      debugPrint('[ProfilePhoto] pick error: $e');
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_fr
              ? 'Impossible de charger la photo. Reessaie.'
              : 'Could not load the photo. Please try again.'),
        ));
      }
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(Lang.code == 'fr' ? 'Choisir une source' : 'Choose source',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                color: _kGreenDark)),
            const SizedBox(height: 20),
            _PhotoSourceOption(
              icon: LucideIcons.camera,
              label: Lang.code == 'fr' ? 'Prendre un selfie' : 'Take a selfie',
              onTap: () { Navigator.pop(ctx); _pickPhoto(ImageSource.camera); },
            ),
            const SizedBox(height: 10),
            _PhotoSourceOption(
              icon: LucideIcons.image,
              label: Lang.code == 'fr' ? 'Choisir de la galerie' : 'Choose from gallery',
              onTap: () { Navigator.pop(ctx); _pickPhoto(ImageSource.gallery); },
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  static bool get _fr => Lang.code == 'fr';

  @override
  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    return _stepBackground(
      child: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: Column(children: [
            _OnboardingTopBar(step: 1, total: 1, onBack: widget.onBack),
            const SizedBox(height: 12),

            Text(_fr ? 'Ta photo de profil' : 'Your profile photo',
              style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w800,
                color: _kGreenDark)),
            const SizedBox(height: 4),
            Text(_fr ? 'Elle sera visible sur ton profil' : 'Visible on your profile',
              style: GoogleFonts.inter(fontSize: 13, color: _kGreenMid)),

            const SizedBox(height: 28),

            // ── Avatar area ──
            GestureDetector(
              onTap: _showSourcePicker,
              child: SizedBox(
                width: 160, height: 160,
                child: Stack(
                  children: [
                    Positioned.fill(child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _kGreenBright.withValues(alpha: 0.12), width: 3)),
                    )),
                    Center(child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _photoUrl != null ? Colors.transparent : Colors.white,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20, offset: const Offset(0, 6))],
                        image: _photoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_photoUrl!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: _uploading
                          ? const CircularProgressIndicator(strokeWidth: 2.5)
                          : (_photoUrl == null
                              ? Icon(LucideIcons.user, size: 40,
                                  color: _kGreenBright.withValues(alpha: 0.2))
                              : null),
                    )),
                    Positioned(bottom: 2, right: 2, child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Color(0xFF2E7D4F), Color(0xFF1B5E3B)]),
                        boxShadow: [BoxShadow(
                          color: _kGreenDark.withValues(alpha: 0.3),
                          blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Icon(
                        _photoUrl != null ? LucideIcons.refreshCw : LucideIcons.plus,
                        size: 18, color: Colors.white),
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Primary: Selfie ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => _pickPhoto(ImageSource.camera),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1B5E3B), Color(0xFF2E8B57)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: _kGreenDark.withValues(alpha: 0.25),
                      blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14)),
                      child: const Icon(LucideIcons.camera, size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fr ? 'Prendre un selfie' : 'Take a selfie',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700,
                            color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(_fr ? 'Face bien visible, bonne lumiere' : 'Face visible, good lighting',
                          style: GoogleFonts.inter(fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.7))),
                      ],
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(_fr ? 'Recommande' : 'Best',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                            color: Colors.white)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Secondary: Gallery ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () => _pickPhoto(ImageSource.gallery),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _kGreenBright.withValues(alpha: 0.1))),
                  child: Row(children: [
                    Icon(LucideIcons.image, size: 18, color: _kGreenMid),
                    const SizedBox(width: 12),
                    Text(_fr ? 'Ou choisir de la galerie' : 'Or choose from gallery',
                      style: GoogleFonts.inter(fontSize: 14, color: _kGreenMid)),
                    const Spacer(),
                    Icon(LucideIcons.chevronRight, size: 16, color: _kGreenMid.withValues(alpha: 0.5)),
                  ]),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(children: [
                _CtaButton(
                  label: _fr ? 'Continuer' : 'Continue',
                  onPressed: widget.onNext,
                ),
                if (_photoUrl == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        widget.onPhotoSelected(null);
                        widget.onNext();
                      },
                      child: Text(
                        _fr ? 'Passer cette etape' : 'Skip this step',
                        style: GoogleFonts.inter(fontSize: 13,
                          color: _kGreenMid.withValues(alpha: 0.4))),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PhotoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kGreenBright.withValues(alpha: 0.12))),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _kGreenBright.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: _kGreenBright)),
          const SizedBox(width: 14),
          Expanded(child: Text(label,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
              color: _kGreenDark))),
          Icon(LucideIcons.chevronRight, size: 18,
            color: _kGreenMid.withValues(alpha: 0.4)),
        ]),
      ),
    );
  }
}

class _PhotoSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _kGreenBright.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kGreenBright.withValues(alpha: 0.12))),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kGreenBright.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 20, color: _kGreenBright)),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600,
                color: _kGreenDark))),
            Icon(LucideIcons.chevronRight, size: 18,
              color: _kGreenMid.withValues(alpha: 0.4)),
          ]),
        ),
      ),
    );
  }
}

// ─── Health Status Card (cycle / pregnant / postpartum) ──────────────────────

class _HealthStatusCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _HealthStatusCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? _kGreenDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _kGreenDark : _kGreenBright.withValues(alpha: 0.12),
            width: selected ? 2 : 1),
          boxShadow: [BoxShadow(
            color: selected
                ? _kGreenDark.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: selected ? 16 : 8,
            offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 24,
              color: selected ? Colors.white : color),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _kGreenDark)),
              const SizedBox(height: 3),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 13,
                color: selected ? Colors.white.withValues(alpha: 0.7) : _kGreenMid)),
            ],
          )),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              border: Border.all(
                color: selected ? Colors.white : const Color(0xFFCDD5CF), width: 2),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 16, color: _kGreenDark)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step — Body Photos (front, left, right, back)
// ─────────────────────────────────────────────────────────────────────────────

class StepBodyPhotos extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final ValueChanged<String?> onPhotoFront;
  final ValueChanged<String?> onPhotoLeft;
  final ValueChanged<String?> onPhotoRight;
  final ValueChanged<String?> onPhotoBack;

  const StepBodyPhotos({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.onPhotoFront,
    required this.onPhotoLeft,
    required this.onPhotoRight,
    required this.onPhotoBack,
  });

  @override
  State<StepBodyPhotos> createState() => _StepBodyPhotosState();
}

class _StepBodyPhotosState extends State<StepBodyPhotos>
    with SingleTickerProviderStateMixin {
  final Map<String, String?> _photos = {
    'front': null,
    'left': null,
    'right': null,
    'back': null,
  };
  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  static bool get _fr => Lang.code == 'fr';

  ValueChanged<String?> _callbackFor(String key) {
    switch (key) {
      case 'front': return widget.onPhotoFront;
      case 'left':  return widget.onPhotoLeft;
      case 'right': return widget.onPhotoRight;
      case 'back':  return widget.onPhotoBack;
      default:      return (_) {};
    }
  }

  String _labelFor(String key) {
    if (_fr) {
      switch (key) {
        case 'front': return 'Face';
        case 'left':  return 'Gauche';
        case 'right': return 'Droite';
        case 'back':  return 'Dos';
      }
    } else {
      switch (key) {
        case 'front': return 'Front';
        case 'left':  return 'Left';
        case 'right': return 'Right';
        case 'back':  return 'Back';
      }
    }
    return key;
  }

  String _tipFor(String key) {
    if (_fr) {
      switch (key) {
        case 'front': return 'Debout, bras le long du corps';
        case 'left':  return 'Profil gauche complet';
        case 'right': return 'Profil droit complet';
        case 'back':  return 'Montrer la silhouette';
      }
    } else {
      switch (key) {
        case 'front': return 'Stand straight, arms relaxed';
        case 'left':  return 'Full left profile';
        case 'right': return 'Full right profile';
        case 'back':  return 'Show your silhouette';
      }
    }
    return '';
  }

  bool _isRequired(String key) => key == 'front' || key == 'back';

  IconData _iconFor(String key) {
    switch (key) {
      case 'front': return LucideIcons.user;
      case 'left':  return LucideIcons.arrowLeft;
      case 'right': return LucideIcons.arrowRight;
      case 'back':  return LucideIcons.userX;
      default:      return LucideIcons.camera;
    }
  }

  Future<void> _pickPhoto(String key, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
      if (picked == null || !mounted) return;

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'body_${key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

      setState(() => _photos[key] = savedFile.path);
      _callbackFor(key)(savedFile.path);
    } catch (e) {
      debugPrint('[BodyPhotos] pick error: $e');
    }
  }

  void _showSourcePicker(String key) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20)),
        child: SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('${_labelFor(key)} — ${_fr ? 'Choisir une source' : 'Choose source'}',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700,
                color: _kGreenDark)),
            const SizedBox(height: 20),
            _PhotoSourceOption(
              icon: LucideIcons.camera,
              label: _fr ? 'Prendre une photo' : 'Take a photo',
              onTap: () { Navigator.pop(ctx); _pickPhoto(key, ImageSource.camera); },
            ),
            const SizedBox(height: 10),
            _PhotoSourceOption(
              icon: LucideIcons.image,
              label: _fr ? 'Choisir de la galerie' : 'Choose from gallery',
              onTap: () { Navigator.pop(ctx); _pickPhoto(key, ImageSource.gallery); },
            ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    final hasAny = _photos.values.any((p) => p != null);
    final count = _photos.values.where((p) => p != null).length;
    final keys = ['front', 'left', 'right', 'back'];

    return _stepBackground(
      child: SafeArea(
        child: FadeTransition(
          opacity: fade,
          child: Column(children: [
            _OnboardingTopBar(step: 1, total: 1, onBack: widget.onBack),
            const SizedBox(height: 8),

            Text(
              _fr ? 'Photos de progression' : 'Progress photos',
              style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800,
                color: _kGreenDark)),
            const SizedBox(height: 4),
            Text(
              _fr ? 'Suis ton evolution mois apres mois' : 'Track your transformation month by month',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: _kGreenMid)),

            const SizedBox(height: 6),

            // ── Progress dots ──
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final done = _photos[keys[i]] != null;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: done ? 28 : 8, height: 8,
                    decoration: BoxDecoration(
                      color: done ? _kGreenBright : _kGreenBright.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4)),
                  ),
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── 2x2 grid ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Expanded(child: Row(children: [
                    _photoCell(keys[0], 1),
                    const SizedBox(width: 10),
                    _photoCell(keys[1], 2),
                  ])),
                  const SizedBox(height: 10),
                  Expanded(child: Row(children: [
                    _photoCell(keys[2], 3),
                    const SizedBox(width: 10),
                    _photoCell(keys[3], 4),
                  ])),
                ]),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(children: [
                _CtaButton(
                  label: _fr ? 'Continuer' : 'Continue',
                  onPressed: hasAny ? widget.onNext : null,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: widget.onNext,
                    child: Text(
                      _fr ? 'Passer cette etape' : 'Skip this step',
                      style: GoogleFonts.inter(fontSize: 13,
                        color: _kGreenMid.withValues(alpha: 0.4))),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _photoCell(String key, int index) {
    final path = _photos[key];
    final required_ = _isRequired(key);
    return Expanded(
      child: GestureDetector(
        onTap: () => _showSourcePicker(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: path != null ? Colors.transparent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: path != null
                  ? _kGreenBright
                  : (required_ ? _kGreenBright.withValues(alpha: 0.2) : _kGreenBright.withValues(alpha: 0.08)),
              width: path != null ? 2.5 : 1.5),
            boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10, offset: const Offset(0, 3))],
            image: path != null
                ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
                : null,
          ),
          child: path == null
              ? Stack(children: [
                  // Step number
                  Positioned(top: 10, left: 10, child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _kGreenBright.withValues(alpha: 0.08)),
                    child: Center(child: Text('$index',
                      style: GoogleFonts.inter(fontSize: 11,
                        fontWeight: FontWeight.w700, color: _kGreenBright))),
                  )),
                  // Required / Optional badge
                  Positioned(top: 10, right: 10, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: required_
                          ? _kGreenDark.withValues(alpha: 0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      required_
                          ? (_fr ? 'Requis' : 'Required')
                          : (_fr ? 'Optionnel' : 'Optional'),
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600,
                        color: required_ ? _kGreenDark : _kGreenMid.withValues(alpha: 0.5))),
                  )),
                  // Center content
                  Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _kGreenBright.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14)),
                        child: Icon(_iconFor(key), size: 20, color: _kGreenBright),
                      ),
                      const SizedBox(height: 8),
                      Text(_labelFor(key), style: GoogleFonts.outfit(
                        fontSize: 15, fontWeight: FontWeight.w700, color: _kGreenDark)),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(_tipFor(key), textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 10, color: _kGreenMid, height: 1.3)),
                      ),
                    ],
                  )),
                  // Add button at bottom
                  Positioned(left: 0, right: 0, bottom: 10, child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: _kGreenBright.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(LucideIcons.plus, size: 12, color: _kGreenBright),
                          const SizedBox(width: 4),
                          Text(_fr ? 'Ajouter' : 'Add', style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600, color: _kGreenBright)),
                        ]),
                      ),
                    ],
                  )),
                ])
              : Stack(children: [
                  // Checkmark
                  Positioned(top: 8, right: 8, child: Container(
                    width: 26, height: 26,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _kGreenBright),
                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  )),
                  // Step number on photo
                  Positioned(top: 8, left: 8, child: Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4)),
                    child: Center(child: Text('$index',
                      style: GoogleFonts.inter(fontSize: 11,
                        fontWeight: FontWeight.w700, color: Colors.white))),
                  )),
                  // Label at bottom
                  Positioned(left: 0, right: 0, bottom: 0, child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent]),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(_fr ? 'Ajoutee' : 'Added', textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 12,
                          fontWeight: FontWeight.w700, color: Colors.white)),
                    ]),
                  )),
                ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step — Body Composition (body fat %)
// ─────────────────────────────────────────────────────────────────────────────

class StepBodyComposition extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final double? initialBodyFat;
  final ValueChanged<double>? onBodyFatChanged;

  const StepBodyComposition({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialBodyFat,
    this.onBodyFatChanged,
  });

  @override
  State<StepBodyComposition> createState() => _StepBodyCompositionState();
}

class _StepBodyCompositionState extends State<StepBodyComposition> {
  late double _bodyFat;
  int? _selectedVisual;

  static const _ranges = [
    (label: '10-14%', value: 12.0, desc: 'Tres sec', descEn: 'Very lean', fill: 0.15, color: Color(0xFF2E7D4F)),
    (label: '15-20%', value: 17.5, desc: 'Fitness / Sec', descEn: 'Fitness / Lean', fill: 0.30, color: Color(0xFF4CAF50)),
    (label: '21-25%', value: 23.0, desc: 'Fitness', descEn: 'Fitness', fill: 0.50, color: Color(0xFF8BC34A)),
    (label: '26-31%', value: 28.5, desc: 'Normal', descEn: 'Average', fill: 0.70, color: Color(0xFFFFA726)),
    (label: '32%+',   value: 35.0, desc: 'Au-dessus', descEn: 'Above avg', fill: 0.90, color: Color(0xFFEF5350)),
  ];

  @override
  void initState() {
    super.initState();
    _bodyFat = widget.initialBodyFat ?? 23.0;
    for (int i = 0; i < _ranges.length; i++) {
      if ((_bodyFat - _ranges[i].value).abs() < 3) {
        _selectedVisual = i;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fr = Lang.code == 'fr';
    final hasSel = _selectedVisual != null;

    return _stepBackground(
      child: SafeArea(
        child: Column(children: [
          _OnboardingTopBar(step: 8, total: 10, onBack: widget.onBack),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _StepHeader(
              title: fr ? 'Estime ta masse grasse' : 'Estimate your body fat',
              subtitle: fr ? 'On adapte ton plan nutritionnel' : 'We\'ll tailor your nutrition plan',
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _ranges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = _ranges[i];
                final sel = _selectedVisual == i;
                final isDim = hasSel && !sel;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() { _selectedVisual = i; _bodyFat = r.value; });
                    widget.onBodyFatChanged?.call(r.value);
                  },
                  child: AnimatedOpacity(
                    opacity: isDim ? 0.45 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedScale(
                      scale: isDim ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: sel
                              ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: sel
                                  ? const Color(0xFF7FC077).withValues(alpha: 0.15)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: sel
                                    ? r.color.withValues(alpha: 0.4)
                                    : _kGlassBorder,
                                width: sel ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                if (sel)
                                  BoxShadow(
                                    color: r.color.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )
                                else
                                  BoxShadow(
                                    color: const Color(0xFF000000).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Row(children: [
                              SizedBox(
                                width: 50, height: 50,
                                child: Stack(alignment: Alignment.center, children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 50, height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: sel
                                          ? r.color.withValues(alpha: 0.18)
                                          : r.color.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40, height: 40,
                                    child: CircularProgressIndicator(
                                      value: r.fill,
                                      strokeWidth: 4,
                                      backgroundColor: r.color.withValues(alpha: 0.12),
                                      valueColor: AlwaysStoppedAnimation(r.color),
                                    ),
                                  ),
                                  Text('${r.value.round()}',
                                    style: GoogleFonts.outfit(fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: r.color)),
                                ]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.label, style: GoogleFonts.outfit(
                                    fontSize: 17, fontWeight: FontWeight.w700,
                                    color: sel ? _kGreenDark : _kTextDark)),
                                  const SizedBox(height: 3),
                                  Text(fr ? r.desc : r.descEn, style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: _kTextMuted,
                                    height: 1.3)),
                                ],
                              )),
                              const SizedBox(width: 12),
                              AnimatedScale(
                                scale: sel ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: r.color,
                                  ),
                                  child: const Icon(LucideIcons.check,
                                    size: 16, color: Colors.white),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          AnimatedOpacity(
            opacity: hasSel ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedSlide(
              offset: hasSel ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(children: [
                  _CtaButton(
                    label: fr ? 'Continuer' : 'Continue',
                    onPressed: hasSel ? widget.onNext : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: widget.onNext,
                      child: Text(fr ? 'Passer cette etape' : 'Skip this step',
                        style: GoogleFonts.inter(fontSize: 13,
                          color: _kGreenMid.withValues(alpha: 0.4))),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step — Body Measurements (waist, hips, chest, thighs, arms)
// ─────────────────────────────────────────────────────────────────────────────

class StepBodyMeasurements extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final double? initialWaist, initialHips, initialChest, initialThighs, initialArms;
  final ValueChanged<double>? onWaistChanged, onHipsChanged, onChestChanged,
      onThighsChanged, onArmsChanged;

  const StepBodyMeasurements({
    super.key,
    required this.onNext,
    this.onBack,
    this.initialWaist, this.initialHips, this.initialChest,
    this.initialThighs, this.initialArms,
    this.onWaistChanged, this.onHipsChanged, this.onChestChanged,
    this.onThighsChanged, this.onArmsChanged,
  });

  @override
  State<StepBodyMeasurements> createState() => _StepBodyMeasurementsState();
}

class _StepBodyMeasurementsState extends State<StepBodyMeasurements> {
  late final TextEditingController _waistCtrl;
  late final TextEditingController _hipsCtrl;
  late final TextEditingController _chestCtrl;
  late final TextEditingController _thighsCtrl;
  late final TextEditingController _armsCtrl;
  bool _useMetric = true;

  static const _measureColors = [
    Color(0xFF1E88E5), // waist — blue
    Color(0xFFE91E63), // hips — pink
    Color(0xFFFF9800), // chest — orange
    Color(0xFF2E9E6B), // thighs — green
    Color(0xFF7C4DFF), // arms — purple
  ];

  static const _measureIcons = [
    LucideIcons.circleDot,
    LucideIcons.diamond,
    LucideIcons.heart,
    LucideIcons.arrowDown,
    LucideIcons.zap,
  ];

  @override
  void initState() {
    super.initState();
    _useMetric = Lang.code == 'fr';
    _waistCtrl  = TextEditingController(text: widget.initialWaist?.toStringAsFixed(0)  ?? '');
    _hipsCtrl   = TextEditingController(text: widget.initialHips?.toStringAsFixed(0)   ?? '');
    _chestCtrl  = TextEditingController(text: widget.initialChest?.toStringAsFixed(0)  ?? '');
    _thighsCtrl = TextEditingController(text: widget.initialThighs?.toStringAsFixed(0) ?? '');
    _armsCtrl   = TextEditingController(text: widget.initialArms?.toStringAsFixed(0)   ?? '');
  }

  @override
  void dispose() {
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _chestCtrl.dispose();
    _thighsCtrl.dispose();
    _armsCtrl.dispose();
    super.dispose();
  }

  void _syncValues() {
    final factor = _useMetric ? 1.0 : 2.54;
    final w = double.tryParse(_waistCtrl.text);
    final h = double.tryParse(_hipsCtrl.text);
    final c = double.tryParse(_chestCtrl.text);
    final t = double.tryParse(_thighsCtrl.text);
    final a = double.tryParse(_armsCtrl.text);
    if (w != null) widget.onWaistChanged?.call(w * factor);
    if (h != null) widget.onHipsChanged?.call(h * factor);
    if (c != null) widget.onChestChanged?.call(c * factor);
    if (t != null) widget.onThighsChanged?.call(t * factor);
    if (a != null) widget.onArmsChanged?.call(a * factor);
  }

  void _convertFields(bool toMetric) {
    for (final ctrl in [_waistCtrl, _hipsCtrl, _chestCtrl, _thighsCtrl, _armsCtrl]) {
      final val = double.tryParse(ctrl.text);
      if (val != null && val > 0) {
        if (toMetric) {
          ctrl.text = (val * 2.54).round().toString();
        } else {
          ctrl.text = (val / 2.54).round().toString();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFr = Lang.code == 'fr';
    final unit = _useMetric ? 'cm' : 'in';

    final labels = isFr
        ? ['Tour de taille', 'Hanches', 'Poitrine', 'Cuisses', 'Bras']
        : ['Waist', 'Hips', 'Chest', 'Thighs', 'Arms'];

    final ctrls = [_waistCtrl, _hipsCtrl, _chestCtrl, _thighsCtrl, _armsCtrl];

    return _stepBackground(
      child: SafeArea(
        child: Column(children: [
          _OnboardingTopBar(step: 9, total: 10, onBack: widget.onBack),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _StepHeader(
              title: isFr ? 'Tes mensurations' : 'Your measurements',
              subtitle: isFr
                  ? 'Pour suivre ton evolution. Tu pourras les modifier plus tard.'
                  : 'To track your progress. You can update them later.',
            ),
          ),
          const SizedBox(height: 16),

          // ── Segmented toggle cm/in ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _kGreenBright.withValues(alpha: 0.08),
              ),
              child: Row(
                children: [
                  _segmentBtn('in', !_useMetric, () {
                    if (_useMetric) {
                      _convertFields(false);
                      setState(() => _useMetric = false);
                    }
                  }),
                  _segmentBtn('cm', _useMetric, () {
                    if (!_useMetric) {
                      _convertFields(true);
                      setState(() => _useMetric = true);
                    }
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Measurement fields ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) {
                final ctrl = ctrls[i];
                final hasValue = ctrl.text.trim().isNotEmpty;
                final color = _measureColors[i];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: hasValue
                        ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: hasValue
                            ? const Color(0xFF7FC077).withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasValue ? color.withValues(alpha: 0.4) : _kBorderLight,
                          width: hasValue ? 1.5 : 1.0,
                        ),
                        boxShadow: hasValue
                            ? [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))]
                            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: hasValue ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_measureIcons[i], size: 22, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w600, color: _kTextDark),
                            decoration: InputDecoration(
                              labelText: '${labels[i]} ($unit)',
                              labelStyle: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w400, color: _kTextMuted),
                              floatingLabelStyle: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w500, color: color),
                              suffixText: unit,
                              suffixStyle: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.w500, color: _kTextMuted),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onChanged: (_) {
                              setState(() {});
                              _syncValues();
                            },
                          ),
                        ),
                        if (hasValue)
                          AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            child: Container(
                              width: 26, height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                            ),
                          ),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Skip + Continue ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Column(children: [
              _CtaButton(
                label: isFr ? 'Continuer' : 'Continue',
                onPressed: () {
                  _syncValues();
                  widget.onNext();
                },
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onNext,
                child: Text(isFr ? 'Mesurer plus tard' : 'Measure later',
                  style: GoogleFonts.inter(fontSize: 13,
                    fontWeight: FontWeight.w500, color: _kTextMuted)),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _segmentBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Center(
            child: Text(label, style: GoogleFonts.inter(
              fontSize: 15, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              color: active ? _kGreenDark : _kTextMuted,
            )),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 8 — Mascotte (kept but no longer in flow)
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

  static bool get _fr => Lang.code == 'fr';

  static const _types = [
    (MascotType.blob,  'Blobby'),
    (MascotType.sun,   'Sunny'),
    (MascotType.star,  'Starlet'),
    (MascotType.cloud, 'Cloudie'),
    (MascotType.leaf,  'Leafy'),
  ];

  static const _moodIcons = [
    LucideIcons.smile,
    LucideIcons.partyPopper,
    LucideIcons.trophy,
    LucideIcons.sparkles,
    LucideIcons.moonStar,
  ];

  static const _moods = [
    MascotMood.happy,
    MascotMood.excited,
    MascotMood.proud,
    MascotMood.celebrating,
    MascotMood.sleepy,
  ];

  @override
  Widget build(BuildContext context) {
    final moodLabels = [
      _fr ? 'Heureuse' : 'Happy',
      _fr ? 'Excitée' : 'Excited',
      _fr ? 'Fière' : 'Proud',
      _fr ? 'En fête' : 'Celebrating',
      _fr ? 'Fatiguée' : 'Sleepy',
    ];

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 1, total: 1, onBack: widget.onBack),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Mascot preview ────────────────────────────────────
                    Center(
                      child: Container(
                        width: 130, height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGreenBright.withValues(alpha: 0.06),
                        ),
                        child: Center(
                          child: MascotWidget(type: _type, mood: _mood, size: 100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        _fr ? 'Choisis ta mascotte' : 'Choose your mascot',
                        style: GoogleFonts.outfit(
                          fontSize: 22, fontWeight: FontWeight.w700, color: _kGreenDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        _fr
                            ? 'Elle t\'accompagnera tout au long de ton aventure'
                            : 'It will accompany you throughout your journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14, color: _kGreenMid, height: 1.4),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Mascot type — horizontal scroll ───────────────────
                    Text(
                      _fr ? 'Forme' : 'Shape',
                      style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700, color: _kGreenDark),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final (type, name) = _types[i];
                          final selected = _type == type;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _type = type);
                              HapticFeedback.lightImpact();
                              widget.onAvatarChanged(type.name, type.name, '');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              decoration: BoxDecoration(
                                color: selected ? _kGreenBright : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected
                                      ? _kGreenBright
                                      : _kGreenBright.withValues(alpha: 0.12),
                                  width: selected ? 2 : 1,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(
                                        color: _kGreenBright.withValues(alpha: 0.2),
                                        blurRadius: 10, offset: const Offset(0, 4))]
                                    : [BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MascotWidget(type: type, mood: MascotMood.happy, size: 44),
                                  const SizedBox(height: 6),
                                  Text(name, style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : _kGreenDark)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Mood — full-width cards ──────────────────────────
                    Text(
                      _fr ? 'Humeur' : 'Mood',
                      style: GoogleFonts.outfit(
                        fontSize: 16, fontWeight: FontWeight.w700, color: _kGreenDark),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_moods.length, (i) {
                      final selected = _mood == _moods[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _mood = _moods[i]);
                            HapticFeedback.lightImpact();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected ? _kGreenBright : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? _kGreenBright
                                    : _kGreenBright.withValues(alpha: 0.12),
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [BoxShadow(
                                      color: _kGreenBright.withValues(alpha: 0.2),
                                      blurRadius: 10, offset: const Offset(0, 4))]
                                  : [BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Text(moodLabels[i], style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : _kGreenDark)),
                                const Spacer(),
                                Icon(_moodIcons[i], size: 22,
                                  color: selected
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : _kGreenBright.withValues(alpha: 0.35)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            _CtaButton(
              label: _fr ? 'Commencer' : 'Get started',
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
  static const _optionIcons = [LucideIcons.building2, LucideIcons.home, LucideIcons.repeat2];
  static const _optionColors = [Color(0xFF5B6ABF), Color(0xFF2E9E6B), Color(0xFFFF9800)];

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
    final _fr = Lang.code == 'fr';
    final l10n = AppL10n(Lang.code);
    final _locLabels = [l10n.locationGym, l10n.locationHome, l10n.locationBoth];
    final _locSubs = [l10n.locationGymDetail, l10n.locationHomeDetail, l10n.locationBothDetail];
    final hasSel = _selected != null;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 4, total: 8, onBack: widget.onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: AppL10n(Lang.code).locationTitle,
                subtitle: _fr
                    ? 'On adapte tes séances à ton lieu'
                    : 'We\'ll adapt workouts to your space',
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(_optionValues.length, (i) {
                  final value = _optionValues[i];
                  final sel = _selected == value;
                  final isDim = hasSel && !sel;
                  final accent = _optionColors[i];
                  return FadeTransition(
                    opacity: _fades[i],
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i < _optionValues.length - 1 ? 14 : 0),
                      child: GestureDetector(
                        onTap: () => _select(value),
                        child: AnimatedOpacity(
                          opacity: isDim ? 0.45 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          child: AnimatedScale(
                            scale: isDim ? 0.96 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: sel ? _kGreenDark : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: sel ? accent : _kGlassBorder,
                                  width: sel ? 2.0 : 1.0,
                                ),
                                boxShadow: [
                                  if (sel)
                                    BoxShadow(
                                      color: accent.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    )
                                  else
                                    BoxShadow(
                                      color: const Color(0xFF000000).withValues(alpha: 0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _optionIcons[i],
                                      size: 26,
                                      color: sel ? Colors.white : accent,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_locLabels[i], style: GoogleFonts.outfit(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: sel ? Colors.white : _kTextDark,
                                        )),
                                        const SizedBox(height: 3),
                                        Text(_locSubs[i], style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: sel
                                              ? Colors.white.withValues(alpha: 0.75)
                                              : _kTextMuted,
                                          height: 1.3,
                                        )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  AnimatedScale(
                                    scale: sel ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutBack,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: accent,
                                      ),
                                      child: const Icon(
                                        LucideIcons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepLocation
// ══════════════════════════════════════════════════════════════════════════════
class StepLocation extends StatelessWidget {
  final String? selected;
  final VoidCallback? onBack;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const StepLocation({
    super.key,
    this.selected,
    this.onBack,
    required this.onSelected,
    this.onNext,
  });

  static const _locIcons = [
    LucideIcons.building2,
    LucideIcons.home,
    LucideIcons.repeat2,
  ];

  static const _locColors = [
    Color(0xFF5B6ABF),
    Color(0xFF2E9E6B),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final _fr = Lang.code == 'fr';
    final l10n = AppL10n(Lang.code);
    final locations = [
      ('gym', l10n.locationGym, _fr ? 'Accès à une salle de sport' : 'Access to a gym'),
      ('home', l10n.locationHome, _fr ? 'Entraînement chez toi' : 'Train at home'),
      ('both', l10n.locationBoth, _fr ? 'Un mix des deux' : 'A mix of both'),
    ];
    final hasSel = selected != null;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            _OnboardingTopBar(step: 4, total: 8, onBack: onBack),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _StepHeader(
                title: _fr ? 'Où préfères-tu t\'entraîner ?' : 'Where do you prefer to train?',
                subtitle: _fr
                    ? 'On adapte tes séances à ton lieu'
                    : 'We\'ll adapt workouts to your space',
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: List.generate(locations.length, (i) {
                  final loc = locations[i];
                  final isSel = selected == loc.$1;
                  final isDim = hasSel && !isSel;
                  final accent = _locColors[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < locations.length - 1 ? 14 : 0),
                    child: _GlassCard(
                      selected: isSel,
                      dimmed: isDim,
                      accent: accent,
                      icon: _locIcons[i],
                      label: loc.$2,
                      sublabel: loc.$3,
                      onTap: () => onSelected(loc.$1),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
            AnimatedOpacity(
              opacity: hasSel ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedSlide(
                offset: hasSel ? Offset.zero : const Offset(0, 0.3),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _CtaButton(
                  label: _fr ? 'Continuer' : 'Continue',
                  onPressed: hasSel ? onNext : null,
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
// STEP — StepFrequency
// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// STEP — StepResults (motivational chart — "With FitEva" vs "Without")
// ══════════════════════════════════════════════════════════════════════════════
class StepResults extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const StepResults({super.key, this.onBack, required this.onNext});

  static bool get _fr => Lang.code == 'fr';

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(LucideIcons.chevronLeft, size: 24,
                        color: Color(0xFF1A3C2A)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      _fr
                          ? 'FitEva va t\'aider à devenir plus forte, confiante et atteindre tes objectifs.'
                          : 'FitEva will help you get strong, feel confident & achieve results that last.',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kGreenDark,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(child: _ResultsChart()),
                    const SizedBox(height: 20),
                    Text(
                      _fr
                          ? 'Des entraînements fun et dynamiques, des fonctionnalités faciles et une communauté bienveillante pour t\'aider à atteindre tes objectifs.'
                          : 'Fun & dynamic workouts, easy-to-use features and a supportive community will challenge you to achieve your goals.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF5A7A66),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _CtaButton(
              label: _fr ? 'Continuer' : 'Continue',
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results comparison chart (with FitEva vs without) ───────────────────────
class _ResultsChart extends StatefulWidget {
  @override
  State<_ResultsChart> createState() => _ResultsChartState();
}

class _ResultsChartState extends State<_ResultsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _ResultsChartPainter(
          progress: Curves.easeOutCubic.transform(_anim.value),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ResultsChartPainter extends CustomPainter {
  final double progress;
  const _ResultsChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final chartTop = h * 0.08;
    final chartBottom = h * 0.75;
    final chartH = chartBottom - chartTop;
    final chartLeft = 0.0;
    final chartRight = w;

    // "WITH FITEVA" curve — rises steeply
    final withPath = Path();
    withPath.moveTo(chartLeft, chartBottom);
    final cp1x = chartRight * 0.35 * progress;
    final cp1y = chartBottom - chartH * 0.15 * progress;
    final cp2x = chartRight * 0.55 * progress;
    final cp2y = chartTop + chartH * 0.1;
    final endX = chartRight * progress;
    final endY = chartTop + chartH * 0.05;
    withPath.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, endY);

    final withPaint = Paint()
      ..color = _kGreenBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(withPath, withPaint);

    // "WITHOUT" curve — rises slowly, plateaus lower
    final withoutPath = Path();
    withoutPath.moveTo(chartLeft, chartBottom);
    final wo_cp1x = chartRight * 0.4 * progress;
    final wo_cp1y = chartBottom - chartH * 0.05 * progress;
    final wo_cp2x = chartRight * 0.7 * progress;
    final wo_cp2y = chartBottom - chartH * 0.35;
    final wo_endX = chartRight * progress;
    final wo_endY = chartBottom - chartH * 0.30;
    withoutPath.cubicTo(wo_cp1x, wo_cp1y, wo_cp2x, wo_cp2y, wo_endX, wo_endY);

    final withoutPaint = Paint()
      ..color = const Color(0xFFB0C4B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(withoutPath, withoutPaint);

    if (progress > 0.7) {
      final labelOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);

      // "WITH FITEVA" label
      _drawLabel(canvas, _fr ? 'AVEC FITEVA' : 'WITH FITEVA', _kGreenBright,
          Offset(endX - 20, endY - 28), labelOpacity);

      // "WITHOUT FITEVA" label
      _drawLabel(canvas, _fr ? 'SANS FITEVA' : 'WITHOUT FITEVA', const Color(0xFFB0C4B8),
          Offset(wo_endX - 30, wo_endY + 12), labelOpacity);

      // Side labels
      final sideLabels = [
        (_fr ? 'FORME' : 'FITNESS LEVEL', chartTop + chartH * 0.20),
        (_fr ? 'CONFIANCE' : 'CONFIDENCE', chartTop + chartH * 0.35),
        (_fr ? 'ÉNERGIE' : 'ENERGY', chartTop + chartH * 0.50),
      ];

      for (final entry in sideLabels) {
        _drawPill(canvas, entry.$1, Offset(0, entry.$2), labelOpacity);
      }
    }
  }

  static bool get _fr => Lang.code == 'fr';

  void _drawLabel(Canvas canvas, String text, Color color, Offset pos, double opacity) {
    final bg = Paint()
      ..color = color.withValues(alpha: 0.9 * opacity)
      ..style = PaintingStyle.fill;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withValues(alpha: opacity),
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx, pos.dy, tp.width + 16, tp.height + 10),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, bg);
    tp.paint(canvas, Offset(pos.dx + 8, pos.dy + 5));
  }

  void _drawPill(Canvas canvas, String text, Offset pos, double opacity) {
    final bg = Paint()
      ..color = _kGreenBright.withValues(alpha: 0.12 * opacity)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = _kGreenBright.withValues(alpha: 0.3 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _kGreenDark.withValues(alpha: opacity),
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx, pos.dy, tp.width + 18, tp.height + 12),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, bg);
    canvas.drawRRect(rect, border);
    tp.paint(canvas, Offset(pos.dx + 9, pos.dy + 6));
  }

  @override
  bool shouldRepaint(_ResultsChartPainter old) => old.progress != progress;
}

// ── Selection card — WeGLOW style: fills green, emoji right ─────────────────
class _SelectionCard extends StatefulWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SelectionCard> createState() => _SelectionCardState();
}

class _SelectionCardState extends State<_SelectionCard>
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
            color: sel ? _kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? _kGreenBright : _kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(widget.label, style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : _kGreenDark)),
              ),
              const SizedBox(width: 12),
              Text(widget.emoji, style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selection chip — for multi-select (equipment) ───────────────────────────
class _SelectionChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _kGreenBright : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? _kGreenBright
                : _kGreenBright.withValues(alpha: 0.12),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(
                  color: _kGreenBright.withValues(alpha: 0.2),
                  blurRadius: 8, offset: const Offset(0, 3))]
              : [BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.03),
                  blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _kGreenDark)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED — Glass Card (glassmorphic selection card with backdrop blur)
// ══════════════════════════════════════════════════════════════════════════════
class _GlassCard extends StatelessWidget {
  final bool selected;
  final bool dimmed;
  final Color accent;
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _GlassCard({
    required this.selected,
    required this.dimmed,
    required this.accent,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedScale(
          scale: dimmed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: selected
                  ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF7FC077).withValues(alpha: 0.15)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? accent.withValues(alpha: 0.4)
                        : _kGlassBorder,
                    width: selected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (selected)
                      BoxShadow(
                        color: accent.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      )
                    else
                      BoxShadow(
                        color: const Color(0xFF000000).withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selected
                            ? accent.withValues(alpha: 0.18)
                            : accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 26, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: selected ? _kGreenDark : _kTextDark,
                          )),
                          const SizedBox(height: 3),
                          Text(sublabel, style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _kTextMuted,
                            height: 1.3,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedScale(
                      scale: selected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                        ),
                        child: const Icon(
                          LucideIcons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
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
// SHARED — Quick Tap Card (full-width, emoji + label + sublabel, auto-advance)
// ══════════════════════════════════════════════════════════════════════════════
class _QuickTapCard extends StatefulWidget {
  final String emoji;
  final IconData? icon;
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _QuickTapCard({
    this.emoji = '',
    this.icon,
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
            color: sel ? _kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? _kGreenBright : _kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: GoogleFonts.outfit(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : _kGreenDark)),
                    if (widget.sublabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(widget.sublabel, style: GoogleFonts.inter(
                        fontSize: 13,
                        color: sel ? Colors.white.withValues(alpha: 0.8) : _kTextMuted,
                        fontWeight: FontWeight.w400, height: 1.3)),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (widget.icon != null)
                Icon(widget.icon, size: 32,
                  color: sel
                      ? Colors.white.withValues(alpha: 0.7)
                      : _kGreenBright.withValues(alpha: 0.35))
              else if (widget.emoji.isNotEmpty)
                Text(widget.emoji, style: const TextStyle(fontSize: 28)),
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
            color: sel ? _kGreenBright : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: sel ? _kGreenBright : _kGreenBright.withValues(alpha: 0.12),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                    color: _kGreenBright.withValues(alpha: 0.2),
                    blurRadius: 12, offset: const Offset(0, 4))]
                : [BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.03),
                    blurRadius: 6, offset: const Offset(0, 2))],
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
                  color: sel ? Colors.white : _kGreenDark, height: 1.2),
              ),
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
  late final AnimationController _ringCtrl;
  late final AnimationController _pulseCtrl;

  int _currentStep = 0;
  bool _showSummary = false;

  static bool get _fr => Lang.code == 'fr';

  static const _stepIcons = [
    LucideIcons.target,
    LucideIcons.chartBar,
    LucideIcons.dumbbell,
    LucideIcons.calendarCheck,
    LucideIcons.sparkles,
  ];

  List<(String, String)> get _buildSteps => [
    (_fr ? 'Analyse de tes objectifs' : 'Analyzing your goals', ''),
    (_fr ? 'Calcul de ton profil nutritionnel' : 'Calculating your nutrition profile', ''),
    (_fr ? 'Création de ton programme' : 'Creating your program', ''),
    (_fr ? 'Planification de tes séances' : 'Planning your sessions', ''),
    (_fr ? 'Ton plan est prêt !' : 'Your plan is ready!', ''),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < _buildSteps.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 500 : 800));
      if (!mounted) return;
      setState(() => _currentStep = i);
    }
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _showSummary = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    widget.onDone();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _buildSteps.length;

    return _stepBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Animated progress ring
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) {
                  final scale = 1.0 + _pulseCtrl.value * 0.05;
                  return Transform.scale(scale: scale, child: child);
                },
                child: SizedBox(
                  width: 88, height: 88,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 88, height: 88,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 4,
                          backgroundColor: _kGreenBright.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation(_kGreenBright),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _kGreenBright.withValues(alpha: 0.08),
                        ),
                        child: Center(
                          child: Icon(
                            _showSummary ? LucideIcons.check : _stepIcons[_currentStep],
                            size: 28,
                            color: _kGreenBright,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                _showSummary
                    ? (_fr ? 'C\'est parti !' : 'Let\'s go!')
                    : (_fr ? 'On prépare ton plan...' : 'Building your plan...'),
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _kGreenDark,
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _showSummary
                    ? (_fr ? 'Ton programme personnalisé est prêt' : 'Your personalized program is ready')
                    : (_fr ? 'Quelques secondes...' : 'Just a moment...'),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _kGreenMid,
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
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: done
                                  ? _kGreenBright
                                  : _kGreenBright.withValues(alpha: 0.08),
                              boxShadow: done ? [
                                BoxShadow(
                                  color: _kGreenBright.withValues(alpha: 0.25),
                                  blurRadius: 10, offset: const Offset(0, 3)),
                              ] : null,
                            ),
                            child: Center(
                              child: Icon(
                                done ? LucideIcons.check : _stepIcons[i],
                                size: 18,
                                color: done ? Colors.white : _kGreenMid,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _buildSteps[i].$1,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                                color: done ? _kGreenDark : _kGreenMid,
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

              // Summary cards
              if (_showSummary)
                AnimatedOpacity(
                  opacity: _showSummary ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _kGreenBright.withValues(alpha: 0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _SummaryItem(
                          value: widget.data.frequency ?? '3x',
                          label: _fr ? 'par semaine' : 'per week',
                        ),
                        Container(width: 1, height: 36,
                            color: _kGreenBright.withValues(alpha: 0.12)),
                        _SummaryItem(
                          value: widget.data.goals.isNotEmpty
                              ? widget.data.goals.first.split(' ').first
                              : 'Fitness',
                          label: _fr ? 'objectif' : 'goal',
                        ),
                        Container(width: 1, height: 36,
                            color: _kGreenBright.withValues(alpha: 0.12)),
                        _SummaryItem(
                          value: widget.data.fitnessLevel ?? (_fr ? 'Débutant' : 'Beginner'),
                          label: _fr ? 'niveau' : 'level',
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
          fontSize: 11, color: _kGreenMid,
          fontWeight: FontWeight.w400)),
      ],
    );
  }
}