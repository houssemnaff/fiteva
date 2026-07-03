import 'dart:async';
import 'dart:math';

import 'package:fiteva/screens/onboarding/widgets/shared_onboarding_widgets.dart';
import 'package:fiteva/widgets/custom_date_picker.dart';
import 'package:fiteva/widgets/mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../l10n/lang.dart';
import '../../../l10n/app_localizations.dart';

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

// ─── Design Tokens — Mint/Sage Palette ────────────────────────────────────
const _kBgMint       = Color(0xFFB8CFC4); // fond principal mint sauge
const _kBgLight      = Color(0xFFC8DAD0); // fond légèrement plus clair
const _kGreenDark    = Color(0xFF2D4A2D); // vert foncé (texte sélectionné, bouton)
const _kGreenMid     = Color(0xFF4A7A5A); // vert moyen
const _kCardUnsel    = Color(0xFFD4E4DB); // carte non-sélectionnée
const _kCardSel      = Color(0xFF2D4A2D); // carte sélectionnée
const _kTextDark     = Color(0xFF1A2E1A); // texte principal
const _kTextMuted    = Color(0xFF5A7A65); // texte secondaire
const _kWhite        = Colors.white;
const _kBorderLight  = Color(0xFFE2EDE7); // bordures claires

// ─── Shared background widget with mint gradient + decorative orbs ──────────
Widget _stepBackground({required Widget child}) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // Mint gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.40, 1.0],
                  colors: [Color(0xFFA8C4B7), Color(0xFFD2E5DB), Color(0xFFF4FAF6)],
                ),
              ),
            ),
            // Decorative orb top-right
            Positioned(
              top: -h * 0.07, right: -w * 0.12,
              child: Container(
                width: w * 0.56, height: w * 0.56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A7A5A).withOpacity(0.12),
                ),
              ),
            ),
            // Decorative orb bottom-left
            Positioned(
              bottom: h * 0.05, left: -w * 0.17,
              child: Container(
                width: w * 0.66, height: w * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D4A2D).withOpacity(0.07),
                ),
              ),
            ),
            // Content
            child,
          ],
        );
      },
    ),
  );
}

// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar minimaliste avec flèche retour + titre centré
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
        padding: EdgeInsets.symmetric(
            horizontal: context.rs(24), vertical: context.rv(14)),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Icon(Icons.arrow_back,
                  size: context.rs(20), color: _kTextDark),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title?.toUpperCase() ?? '',
                  style: TextStyle(
                    fontSize: context.rs(11),
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                    color: _kTextMuted,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.rs(20)),
          ],
        ),
      ),
    );
  }
}

/// Icône centrale ronde avec fond translucide
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    final sz = context.rs(64);
    return Center(
      child: Container(
        width: sz, height: sz,
        decoration: const BoxDecoration(
          color: Color(0xFFEEF2EE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _kGreenDark, size: context.rs(28)),
      ),
    );
  }
}

/// Titre + sous-titre centré
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.rs(24),
            fontWeight: FontWeight.w700,
            color: _kTextDark,
            height: 1.2,
          ),
        ),
        SizedBox(height: context.rv(8)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.rs(14),
            color: _kTextMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

/// Pill/Ovale card — style de sélection
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
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 18)
            : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? _kCardSel : const Color(0xFFF3F6F3),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? _kCardSel
                : const Color(0xFFD8E5D8),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kGreenDark.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: sublabel != null
            ? Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        color: selected ? _kWhite : _kGreenMid, size: 22),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selected ? _kWhite : _kTextDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sublabel!,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: selected
                                ? Colors.white70
                                : _kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 20),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (icon != null) ...[
                    Icon(icon,
                        color: selected ? _kWhite : _kGreenMid, size: 20),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected ? _kWhite : _kTextDark,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 18),
                ],
              ),
      ),
    );
  }
}

/// Pill compact (sans icône, pour grilles 2-col)
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
          color: selected ? _kCardSel : const Color(0xFFF3F6F3),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? _kCardSel : const Color(0xFFD8E5D8),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: _kGreenDark.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? _kWhite : _kGreenMid, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
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

/// Bouton CTA principal (bas d'écran)
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
        padding: EdgeInsets.fromLTRB(
            context.rs(24), context.rv(10),
            context.rs(24), context.rv(18)),
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: context.rv(54),
            decoration: BoxDecoration(
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    )
                  : null,
              color: enabled ? null : const Color(0xFFE8EDE8),
              borderRadius: BorderRadius.circular(40),
              boxShadow: enabled
                  ? [BoxShadow(color: _kGreenDark.withOpacity(0.30),
                      blurRadius: 14, offset: const Offset(0, 5))]
                  : [],
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: context.rs(13),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: enabled ? _kWhite : _kTextMuted,
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
// STEP — StepLanguageChoice  (FR / EN — shown after login)
// ══════════════════════════════════════════════════════════════════════════════
class StepLanguageChoice extends StatefulWidget {
  final void Function(Locale locale) onNext;
  const StepLanguageChoice({super.key, required this.onNext});

  @override
  State<StepLanguageChoice> createState() => _StepLanguageChoiceState();
}

class _StepLanguageChoiceState extends State<StepLanguageChoice>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late final AnimationController _enterCtrl;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _cardsFade;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _titleFade  = CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _cardsFade  = CurvedAnimation(parent: _enterCtrl, curve: const Interval(0.30, 0.85, curve: Curves.easeOut));
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  void _pick(String lang) {
    if (_selected != null) return;
    setState(() => _selected = lang);
    Future.delayed(const Duration(milliseconds: 420), () {
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
              const SizedBox(height: 48),

              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Language',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _kTextDark, height: 1.0, letterSpacing: -1.2)),
                      const Text('Langue',
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: _kGreenMid, height: 1.1, letterSpacing: -1.2)),
                      const SizedBox(height: 14),
                      Container(width: 32, height: 3,
                          decoration: BoxDecoration(color: _kGreenDark, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 10),
                      const Text('Choose the language for your experience',
                        style: TextStyle(fontSize: 13, color: _kTextMuted, height: 1.4)),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              FadeTransition(
                opacity: _cardsFade,
                child: Column(
                  children: [
                    _CleanLangOption(label: 'Français', sublabel: 'French',  isSelected: _selected == 'fr', onTap: () => _pick('fr')),
                    const SizedBox(height: 14),
                    _CleanLangOption(label: 'English',  sublabel: 'Anglais', isSelected: _selected == 'en', onTap: () => _pick('en')),
                  ],
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Center(
                  child: Text(
                    'Changeable anytime in Settings · Modifiable dans Paramètres',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10.5, color: _kTextMuted.withOpacity(0.6), height: 1.5),
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

class _CleanLangOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _CleanLangOption({required this.label, required this.sublabel, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [Color(0xFF3D6B40), _kGreenDark], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFB8D4C0), width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: _kGreenDark.withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : _kTextDark, letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(sublabel, style: TextStyle(fontSize: 12,
                      color: isSelected ? Colors.white.withOpacity(0.55) : _kTextMuted)),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: isSelected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 26, height: 26,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 15, color: _kGreenDark),
              ),
            ),
          ],
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

  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _headFade;
  late final Animation<Offset> _headSlide;
  late final Animation<double> _chipsFade;
  late final Animation<double> _proofFade;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..forward();

    Animation<double> iv(double s, double e) => CurvedAnimation(
          parent: _ctrl, curve: Interval(s, e, curve: Curves.easeOut));

    Animation<Offset> sl(double s, double e, [Offset? from]) =>
        Tween<Offset>(begin: from ?? const Offset(0, 0.22), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _ctrl,
                curve: Interval(s, e, curve: Curves.easeOutCubic)));

    _logoFade  = iv(0.00, 0.28);
    _logoSlide = sl(0.00, 0.35, const Offset(0, -0.25));
    _headFade  = iv(0.18, 0.50);
    _headSlide = sl(0.18, 0.52);
    _chipsFade = iv(0.40, 0.65);
    _proofFade = iv(0.55, 0.78);
    _btnFade   = iv(0.65, 0.92);
    _btnSlide  = sl(0.65, 0.92);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: const Color(0xFF0B1A0E),
        child: Stack(
          children: [
            // Ambient glow orbs
            Positioned(
              top: -sh * 0.12, left: -sw * 0.28,
              child: _orb(sw * 0.88, const Color(0xFF1A5C26), 0.55),
            ),
            Positioned(
              bottom: sh * 0.08, right: -sw * 0.22,
              child: _orb(sw * 0.72, const Color(0xFF0E3A15), 0.65),
            ),
            Positioned(
              top: sh * 0.38, left: sw * 0.15,
              child: _orb(sw * 0.55, const Color(0xFF5CD57A), 0.06),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sh < 700 ? 22 : 28),
                child: Column(
                  children: [
                    SizedBox(height: sh * 0.032),
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                          position: _logoSlide, child: _buildLogo(sh)),
                    ),
                    Spacer(flex: sh < 700 ? 1 : 2),
                    FadeTransition(
                      opacity: _headFade,
                      child: SlideTransition(
                          position: _headSlide, child: _buildHeadline(sh)),
                    ),
                    SizedBox(height: sh * 0.030),
                    FadeTransition(opacity: _chipsFade, child: _buildChips(sh)),
                    SizedBox(height: sh * 0.024),
                    FadeTransition(opacity: _proofFade, child: _buildSocialProof(sh)),
                    Spacer(flex: sh < 700 ? 1 : 3),
                    FadeTransition(
                      opacity: _btnFade,
                      child: SlideTransition(
                          position: _btnSlide, child: _buildCTA(sh)),
                    ),
                    SizedBox(height: sh * 0.014),
                    FadeTransition(
                      opacity: _btnFade,
                      child: Text(
                        "En continuant, tu acceptes nos Conditions d'utilisation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sh < 700 ? 10 : 11,
                          color: Colors.white.withValues(alpha: 0.28),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: sh * 0.028),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      );

  Widget _buildLogo(double sh) {
    final logoSz = sh < 700 ? 36.0 : 44.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: logoSz, height: logoSz,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(logoSz * 0.27),
            border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(logoSz * 0.25),
            child: Image.asset('assets/images/logfiteva.jpeg', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 13),
        Text(
          "FITEVA",
          style: TextStyle(
            fontSize: sh < 700 ? 18 : 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline(double sh) {
    final headFs = (sh * 0.051).clamp(28.0, 46.0);
    final subFs  = (sh * 0.018).clamp(12.0, 16.0);
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: headFs,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.08,
              letterSpacing: -1.2,
            ),
            children: const [
              TextSpan(text: "Transforme\nton corps,\n"),
              TextSpan(text: "libère ta force.",
                style: TextStyle(color: Color(0xFF5CD57A))),
            ],
          ),
        ),
        SizedBox(height: sh * 0.018),
        Text(
          "Fitness, cycle & nutrition —\ntout ce dont une femme a besoin.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: subFs,
            color: Colors.white.withValues(alpha: 0.50),
            height: 1.55,
          ),
        ),
      ],
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
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
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
              width: 58,
              height: 26,
              child: Stack(
                children: List.generate(
                  3,
                  (i) => Positioned(
                    left: i * 17.0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const [
                          Color(0xFF4CAF7A),
                          Color(0xFF2E7D4F),
                          Color(0xFF81C784),
                        ][i],
                        border: Border.all(
                            color: const Color(0xFF0B1A0E), width: 1.5),
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 12),
                    ),
                  ),
                ),
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
        child: Container(
          width: double.infinity,
          height: sh < 700 ? 50 : 58,
          decoration: BoxDecoration(
           color: Color.fromARGB(255, 21, 80, 44),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color:    const Color.fromARGB(255, 21, 80, 44),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Commencer gratuitement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 20),
            ],
          ),
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
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback? onLogin;
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const StepWelcome({
    super.key,
    required this.onNext,
    this.onBack,
    this.onLogin,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.nameController,
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

  bool _isLoginMode = false; // true = formulaire de connexion, false = inscription
  bool _obscure     = true;

  String? _emailError;
  String? _passwordError;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  // Au moins 8 caractères et au moins un chiffre.
  bool _isValidPassword(String password) =>
      password.length >= 8 && RegExp(r'\d').hasMatch(password);

  bool get _canContinue {
    if (_isLoginMode) {
      return widget.emailController.text.trim().isNotEmpty &&
             widget.passwordController.text.trim().isNotEmpty;
    }
    return widget.nameController.text.trim().isNotEmpty &&
           widget.emailController.text.trim().isNotEmpty &&
           widget.passwordController.text.trim().isNotEmpty;
  }

  /// Valide le format de l'email (et la force du mot de passe en inscription)
  /// et met à jour les messages d'erreur affichés sous les champs.
  bool _validateEmailForm() {
    final email    = widget.emailController.text.trim();
    final password = widget.passwordController.text.trim();

    String? emailErr;
    String? passwordErr;

    if (!_isValidEmail(email)) {
      emailErr = 'Adresse email invalide.';
    }
    if (!_isLoginMode && !_isValidPassword(password)) {
      passwordErr = 'Le mot de passe doit contenir au moins 8 caractères et un chiffre.';
    }

    setState(() {
      _emailError    = emailErr;
      _passwordError = passwordErr;
    });
    return emailErr == null && passwordErr == null;
  }

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

          // ── Dark gradient overlay ──────────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.60, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    _kDark.withOpacity(0.55),
                    _kDark.withOpacity(0.98),
                  ],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildLogo(),
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        _buildSlideText(),
                        const SizedBox(height: 16),
                        _buildDots(),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildAuthSection(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
        Text(
          'FitEva',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: _kWhite,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 6),
        Icon(Icons.water_drop, color: _kWhite, size: 26),
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
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            Text(
              slide.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _kWhite,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              slide.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _kWhite,
                height: 1.5,
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
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _kWhite : _kWhite.withOpacity(0.35),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ─── Auth section — social icons (always visible) + email path ────────────
  Widget _buildAuthSection() {
    return Column(
      children: [
        _buildSocialIcons(),
        const SizedBox(height: 18),
        _buildOrDivider(),
        const SizedBox(height: 18),
        _buildEmailForm(),
        _buildLoginRow(),
      ],
    );
  }

  // ─── Social icon buttons — Google + Apple, icon-only, always visible ──────
  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIconBtn(
          semanticLabel: AppL10n(Lang.code).welcomeSignUpGoogle,
          onTap: widget.onGoogleSignIn ?? () {},
          child: _googleIcon(),
        ),
        const SizedBox(width: 18),
        _socialIconBtn(
          semanticLabel: AppL10n(Lang.code).welcomeSignUpApple,
          onTap: widget.onAppleSignIn ?? () {},
          child: Icon(Icons.apple_rounded, color: _kWhite, size: 26),
        ),
      ],
    );
  }

  Widget _socialIconBtn({
    required Widget child,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: _kWhite.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: _kWhite.withOpacity(0.18)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(children: [
      Expanded(child: Divider(color: _kWhite.withOpacity(0.15))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          AppL10n(Lang.code).welcomeOrContinueWith.toUpperCase(),
          style: TextStyle(
            color: _kWhite.withOpacity(0.4),
            fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1,
          ),
        ),
      ),
      Expanded(child: Divider(color: _kWhite.withOpacity(0.15))),
    ]);
  }

  // ─── Email form ────────────────────────────────────────────────────────────
  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre (pas de flèche retour — le formulaire est toujours affiché)
        Text(
          _isLoginMode
              ? AppL10n(Lang.code).welcomeLogIn
              : AppL10n(Lang.code).welcomeCreateAccount,
          style: const TextStyle(
              color: _kWhite, fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 20),

        // Champ nom — uniquement pour la création de compte
        if (!_isLoginMode) ...[
          _formField(
            controller: widget.nameController,
            hint: AppL10n(Lang.code).welcomeUsername,
            icon: Icons.badge_outlined,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
        ],

        _formField(
          controller: widget.emailController,
          hint: 'your@email.com',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          onChanged: (_) => setState(() { _emailError = null; }),
        ),
        const SizedBox(height: 12),
        _formField(
          controller: widget.passwordController,
          hint: '••••••••',
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          errorText: _passwordError,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: _kGrey, size: 18,
            ),
          ),
          onChanged: (_) => setState(() { _passwordError = null; }),
        ),
        const SizedBox(height: 20),

        // CTA — login direct (sans steps) ou inscription (avec steps)
        GestureDetector(
          onTap: _canContinue
              ? () {
                  if (!_validateEmailForm()) return;
                  (_isLoginMode ? (widget.onLogin ?? widget.onNext) : widget.onNext)();
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 54,
            decoration: BoxDecoration(
              color: _canContinue ? _kPrimary : _kGrey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Center(
              child: Text(
                _isLoginMode
                    ? AppL10n(Lang.code).welcomeLogIn
                    : AppL10n(Lang.code).welcomeContinue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _canContinue ? _kWhite : _kGrey,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    String? errorText,
    required ValueChanged<String> onChanged,
  }) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _kWhite.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? const Color(0xFFE53935) : _kBorderLight,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            onChanged: onChanged,
            autofillHints: const [],
            style: const TextStyle(fontSize: 15, color: Color.fromARGB(255, 1, 1, 1),
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.45), fontSize: 14),
              prefixIcon: Icon(icon, color: _kWhite.withOpacity(0.7), size: 20),
              suffixIcon: suffix != null
                  ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText,
                style: const TextStyle(
                    color: Color(0xFFFF6B6B), fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ],
    );
  }

  // ─── Toggle between sign up and log in — swaps the whole section in place ──
  Widget _buildLoginRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => _isLoginMode = !_isLoginMode),
          child: _isLoginMode
              ? Text(
                  AppL10n(Lang.code).welcomeNoAccount,
                  style: const TextStyle(
                    color: _kWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: _kWhite,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppL10n(Lang.code).welcomeAlreadyAccount,
                        style: TextStyle(color: _kWhite.withOpacity(0.6), fontSize: 13)),
                    Text(
                      AppL10n(Lang.code).welcomeLogIn,
                      style: const TextStyle(
                        color: _kWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: _kWhite,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Google icon ───────────────────────────────────────────────────────────
  Widget _googleIcon() => SvgPicture.asset(
    'assets/images/google-color.svg',
    width: 22,
    height: 22,
  );
}


// ══════════════════════════════════════════════════════════════════════════════
// STEP 2 — StepGoals  (minimalist B&W circle selector)
// ══════════════════════════════════════════════════════════════════════════════

class _GoalData {
  final String label;
  const _GoalData(this.label);
}

const _goals = [
  _GoalData('Prendre de la force\net me sentir plus forte'),
  _GoalData('Tonifier et sculpter\ntout mon corps'),
  _GoalData('Améliorer\nma souplesse\net mobilité'),
  _GoalData('Réduire le stress\net me sentir plus\néquilibrée'),
  _GoalData('Reprendre\nune routine'),
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

  void _select(String label) {
    widget.onToggleGoal(label);
    Future.delayed(const Duration(milliseconds: 300), widget.onNext);
  }

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: context.rs(24), vertical: context.rv(14)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.maybePop(context),
                    child: Container(
                      width: context.rs(36), height: context.rs(36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back,
                          size: context.rs(18), color: _kGreenDark),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppL10n(Lang.code).goalsTopBarTitle,
                        style: TextStyle(
                          fontSize: context.rs(11),
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w700,
                          color: _kGreenDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rs(36)),
                ],
              ),
            ),

            SizedBox(height: context.rv(8)),

            // ── Icon + title block ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
              child: Column(children: [
                Container(
                  width: context.rs(56), height: context.rs(56),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A7A5A), Color(0xFF2D4A2D)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Icon(Icons.track_changes_rounded,
                      size: context.rs(26), color: Colors.white),
                ),
                SizedBox(height: context.rv(12)),
                Text(
                  AppL10n(Lang.code).goalsTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.rs(20),
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: context.rv(5)),
                Text(
                  AppL10n(Lang.code).goalsHint,
                  style: TextStyle(
                      fontSize: context.rs(12.5), color: _kTextMuted),
                ),
              ]),
            ),

            SizedBox(height: context.rv(24)),

            // ── Circle cluster ────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.rs(20)),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final double d     = context.rs(138);
                  final double vStep = context.rv(108);
                  final double w     = constraints.maxWidth;
                  final double lx    = d / 2 + context.rs(10);
                  final double rx    = w - d / 2 - context.rs(10);
                  final double cx    = w / 2;

                  final offsets = [
                    Offset(lx, 0),
                    Offset(rx, 0),
                    Offset(cx, vStep),
                    Offset(lx, vStep * 2),
                    Offset(rx, vStep * 2),
                  ];

                  final l10n = AppL10n(Lang.code);
                  final _goalDisplayLabels = [
                    l10n.goal1, l10n.goal2, l10n.goal3, l10n.goal4, l10n.goal5,
                  ];
                  return SizedBox(
                    height: vStep * 2 + d,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(_goals.length, (i) {
                        final key = _goals[i].label; // French key for selection
                        final displayLabel = _goalDisplayLabels[i];
                        final isSel = widget.selectedGoals.contains(key);
                        return Positioned(
                          left: offsets[i].dx - d / 2,
                          top: offsets[i].dy,
                          child: FadeTransition(
                            opacity: _fades[i],
                            child: _CircleGoal(
                              label: displayLabel,
                              diameter: d,
                              selected: isSel,
                              onTap: () => _select(key),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

            const Spacer(flex: 1),
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
            gradient: sel
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                  )
                : null,
            color: sel ? null : const Color(0xFFE8F2EC),
            border: Border.all(
              color: sel ? Colors.transparent : const Color(0xFFB8D4C0),
              width: 1.5,
            ),
            boxShadow: sel
                ? [BoxShadow(color: const Color(0xFF2D4A2D).withOpacity(0.38), blurRadius: 22, offset: const Offset(0, 8))]
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
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

  @override
  Widget build(BuildContext context) {
    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rs(24), vertical: context.rv(14)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.maybePop(context),
                    child: Container(
                      width: context.rs(36), height: context.rs(36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back,
                        size: context.rs(18), color: _kGreenDark),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppL10n(Lang.code).fitnessTopBarTitle,
                        style: TextStyle(
                          fontSize: context.rs(11),
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w700,
                          color: _kGreenDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rs(36)),
                ],
              ),
            ),

            SizedBox(height: context.rv(12)),

            // ── Icon + title block ───────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
              child: Column(children: [
                Container(
                  width: context.rs(56), height: context.rs(56),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A7A5A), Color(0xFF2D4A2D)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Icon(Icons.show_chart_rounded,
                    size: context.rs(26), color: Colors.white),
                ),
                SizedBox(height: context.rv(12)),
                Text(
                  AppL10n(Lang.code).fitnessTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.rs(20),
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: context.rv(5)),
                Text(
                  AppL10n(Lang.code).fitnessHint,
                  style: TextStyle(fontSize: context.rs(12.5), color: _kTextMuted),
                ),
              ]),
            ),

            SizedBox(height: context.rv(24)),

            // ── Triangle circle layout ────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.rs(20)),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final double d     = context.rs(138);
                  final double vStep = context.rv(110);
                  final double w     = constraints.maxWidth;
                  final double lx    = d / 2 + context.rs(10);
                  final double rx    = w - d / 2 - context.rs(10);
                  final double cx    = w / 2;

                  final offsets = [
                    Offset(lx, 0),
                    Offset(rx, 0),
                    Offset(cx, vStep),
                  ];

                  final l10n = AppL10n(Lang.code);
                  final _levelDisplayLabels = [
                    l10n.fitnessLevelBeginner,
                    l10n.fitnessLevelIntermediate,
                    l10n.fitnessLevelAdvanced,
                  ];
                  return SizedBox(
                    height: vStep + d,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(_levels.length, (i) {
                        final key = _levels[i]; // French key for selection
                        final displayLabel = _levelDisplayLabels[i];
                        final isSel = widget.selectedLevel == key;
                        return Positioned(
                          left: offsets[i].dx - d / 2,
                          top: offsets[i].dy,
                          child: FadeTransition(
                            opacity: _fades[i],
                            child: _CircleGoal(
                              label: displayLabel,
                              diameter: d,
                              selected: isSel,
                              onTap: () => _select(key),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

            const Spacer(flex: 1),
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
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                )
              : null,
          color: selected ? null : const Color(0xFFE8F2EC),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFB8D4C0),
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _kGreenDark.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : _kGreenDark, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _kTextDark,
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

  @override
  Widget build(BuildContext context) {
    final count = widget.selectedEquipment.length;

    return _stepBackground(
      child: SafeArea(
        child: Column(
          children: [
              // ── Top bar ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rs(24), vertical: context.rv(14)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.maybePop(context),
                      child: Container(
                        width: context.rs(36), height: context.rs(36),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back,
                          size: context.rs(18), color: _kGreenDark),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppL10n(Lang.code).equipmentTopBarTitle,
                          style: TextStyle(
                            fontSize: context.rs(11),
                            letterSpacing: 3.5,
                            fontWeight: FontWeight.w700,
                            color: _kGreenDark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.rs(36)),
                  ],
                ),
              ),

              SizedBox(height: context.rv(10)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
                child: Column(children: [
                  Container(
                    width: context.rs(56), height: context.rs(56),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A7A5A), Color(0xFF2D4A2D)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Icon(Icons.sports_gymnastics,
                      size: context.rs(26), color: Colors.white),
                  ),
                  SizedBox(height: context.rv(12)),
                  Text(
                    AppL10n(Lang.code).equipmentTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.rs(20),
                      fontWeight: FontWeight.w800,
                      color: _kTextDark,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: context.rv(5)),
                  Text(
                    AppL10n(Lang.code).equipmentHint,
                    style: TextStyle(fontSize: context.rs(12.5), color: _kTextMuted),
                  ),
                ]),
              ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.rs(20)),
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      final double d    = context.rs(126);
                      final double vStep = context.rv(98);

                      final w = constraints.maxWidth;
                      final lx = d / 2 + context.rs(8);
                      final rx = w - d / 2 - context.rs(8);
                      final cx = w / 2;

                      final offsets = [
                        Offset(lx, 0),
                        Offset(rx, 0),
                        Offset(cx, vStep),
                        Offset(lx, vStep * 2),
                        Offset(rx, vStep * 2),
                        Offset(cx, vStep * 3),
                      ];

                      final l10n = AppL10n(Lang.code);
                      final _equipDisplayLabels = [
                        l10n.equipmentNone,
                        l10n.equipmentDumbbells,
                        l10n.equipmentBarbell,
                        l10n.equipmentMachines,
                        l10n.equipmentBands,
                        l10n.equipmentYogaMat,
                      ];
                      return SizedBox(
                        height: vStep * 3 + d,
                        child: Stack(
                          children: List.generate(_equipments.length, (i) {
                            final key = _equipments[i]; // French key
                            final displayLabel = _equipDisplayLabels[i];
                            final isSel = widget.selectedEquipment.contains(key);

                            return Positioned(
                              left: offsets[i].dx - d / 2,
                              top: offsets[i].dy,
                              child: FadeTransition(
                                opacity: _fades[i],
                                child: equipmentIcon(
                                  label: displayLabel,
                                  icon: equipmentIcons[key]!,
                                  diameter: d,
                                  selected: isSel,
                                  onTap: () => _handleEquipmentTap(key),
                                  accentColor: _kGreenDark,
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: GestureDetector(
                onTap: count > 0 ? widget.onNext : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: count > 0
                        ? const LinearGradient(colors: [Color(0xFF3D6B40), Color(0xFF1A3318)])
                        : null,
                    color: count > 0 ? null : const Color(0xFFE8EDE8),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: count > 0
                        ? [BoxShadow(color: _kGreenDark.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      count > 0 ? '${AppL10n(Lang.code).equipmentContinue} ($count)' : AppL10n(Lang.code).equipmentSelectAtLeastOne,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: count > 0 ? Colors.white : _kTextMuted,
                      ),
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
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rs(24), vertical: context.rv(14)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ?? () => Navigator.maybePop(context),
                    child: Container(
                      width: context.rs(36), height: context.rs(36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back,
                        size: context.rs(18), color: _kGreenDark),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppL10n(Lang.code).frequencyTopBarTitle,
                        style: TextStyle(
                          fontSize: context.rs(11),
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w700,
                          color: _kGreenDark,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.rs(36)),
                ],
              ),
            ),

            SizedBox(height: context.rv(10)),

            // ── Header card ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
              child: Column(children: [
                Container(
                  width: context.rs(56), height: context.rs(56),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A7A5A), Color(0xFF2D4A2D)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.3),
                      blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Icon(Icons.timer_outlined,
                    size: context.rs(26), color: Colors.white),
                ),
                SizedBox(height: context.rv(12)),
                Text(
                  AppL10n(Lang.code).frequencyTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.rs(20),
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: context.rv(5)),
                Text(
                  AppL10n(Lang.code).frequencyHint,
                  style: TextStyle(fontSize: context.rs(12.5), color: _kTextMuted),
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
      ..color = const Color(0xFFE4E8E6)
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kGreenDark.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: _kGreenDark,
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
        ..color       = const Color(0xFFCCCCCC)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap   = StrokeCap.round,
    );

    final dot = Paint()..color = const Color(0xFFBBBBBB)..style = PaintingStyle.fill;
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
              step: 6, total: 7, title: AppL10n(Lang.code).healthProfileTopBarTitle, onBack: widget.onBack),
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
  static const Color _kBg = Color(0xFFF3F6F3);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFD8E5D8), width: 1.5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(label,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: _kTextMuted,
              )),
          const SizedBox(height: 10),
          SizedBox(
            height: _kItemH * _kVisible,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight band
                Center(
                  child: Container(
                    height: _kItemH,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _kGreenDark.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: _kGreenDark.withValues(alpha: 0.22), width: 1),
                    ),
                  ),
                ),
                // Scroll wheel
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: _kItemH,
                  perspective: 0.002,
                  diameterRatio: 1.8,
                  squeeze: 1.1,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: onChanged,
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
                            color: sel ? _kGreenDark : _kTextMuted,
                          ),
                          child: Text(labelFor(i)),
                        ),
                      );
                    },
                  ),
                ),
                // Top fade overlay
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_kBg, _kBg.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom fade overlay
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  height: _kItemH * 1.6,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_kBg, _kBg.withValues(alpha: 0)],
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
                  color: _kTextMuted)),
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
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD8E5D8)),
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
              step: 7, total: 7, title: AppL10n(Lang.code).cycleStepTopBarTitle,
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
                      'cycle', LucideIcons.moon,
                      AppL10n(Lang.code).cycleStatusRegular,
                      AppL10n(Lang.code).cycleStatusRegularSub,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _statusCard(
                      'pregnant', LucideIcons.sparkles,
                      AppL10n(Lang.code).cycleStatusPregnant,
                      AppL10n(Lang.code).cycleStatusPregnantSub,
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
  Widget _statusCard(String value, IconData icon, String label, String sub) {
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
          color: sel ? _kGreenDark : const Color(0xFFF3F6F3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: sel ? _kGreenDark : const Color(0xFFD8E5D8),
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
                  : const Color(0xFFE4EEE4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22,
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
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5D8)),
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
                  color: sel ? _kGreenDark : const Color(0xFFF3F6F3),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: sel ? _kGreenDark : const Color(0xFFD8E5D8),
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
              color: const Color(0xFFF3F6F3),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFFD8E5D8)),
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
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5D8)),
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
        color: const Color(0xFFEEF3EE),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFD4E4D4)),
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
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5D8)),
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
                        : const Color(0xFFD8E5D8),
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
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5D8)),
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
                  ? const Color(0xFFE8F2EC)
                  : const Color(0xFFF3F6F3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _birthDate != null ? _kGreenDark : const Color(0xFFD8E5D8),
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
                      : const Color(0xFFE8EDE8),
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
                            ? Colors.white.withOpacity(0.60)
                            : const Color(0xFFEEF5EE),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.transparent
                          : isNext
                              ? const Color(0xFFB8D4C0)
                              : const Color(0xFFD4E6D6),
                      width: 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [BoxShadow(color: _kGreenDark.withOpacity(0.30), blurRadius: 16, offset: const Offset(0, 5))]
                        : isNext
                            ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]
                            : [],
                  ),
                  child: Row(
                    children: [
                      // Emoji circle
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Colors.white.withOpacity(0.18)
                              : const Color(0xFFD6EBE0),
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
                                    ? Colors.white.withOpacity(0.70)
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
                            color: Colors.white.withOpacity(0.22),
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
                            color: const Color(0xFFD6EBE0),
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
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(children: [
                GestureDetector(
                  onTap: widget.onBack,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back, size: 18, color: _kGreenDark),
                  ),
                ),
                Expanded(child: Center(child: Text(AppL10n(Lang.code).avatarTopBarTitle,
                  style: const TextStyle(fontSize: 11, letterSpacing: 3.0,
                    fontWeight: FontWeight.w700, color: _kGreenDark)))),
                const SizedBox(width: 36),
              ]),
            ),

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
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                          boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: Column(children: [
                          // Mascot with glow ring
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFD6EBE0), Color(0xFFB8CFC4)],
                              ),
                              boxShadow: [
                                BoxShadow(color: _kGreenDark.withOpacity(0.20), blurRadius: 24, spreadRadius: 2),
                              ],
                            ),
                            child: Center(child: MascotWidget(type: _type, mood: _mood, size: 110)),
                          ),
                          const SizedBox(height: 16),
                          Text(AppL10n(Lang.code).avatarChooseTitle,
                            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800,
                              color: _kTextDark, letterSpacing: -0.3)),
                          const SizedBox(height: 4),
                          Text(
                            AppL10n(Lang.code).avatarSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12.5, color: _kTextMuted, height: 1.5),
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
                          color: _kGreenMid, letterSpacing: 2.5)),
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
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                                    : null,
                                color: selected ? null : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected ? Colors.transparent : const Color(0xFFB8D4C0),
                                  width: 1.5,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: _kGreenDark.withOpacity(0.32), blurRadius: 14, offset: const Offset(0, 5))]
                                    : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                MascotWidget(type: type, mood: MascotMood.happy, size: 48),
                                const SizedBox(height: 4),
                                Text(name, style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: selected ? Colors.white : _kTextMuted)),
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
                          color: _kGreenMid, letterSpacing: 2.5)),
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
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                                        begin: Alignment.topLeft, end: Alignment.bottomRight)
                                    : null,
                                color: selected ? null : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: selected ? Colors.transparent : const Color(0xFFB8D4C0),
                                  width: 1.2,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: _kGreenDark.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 3))]
                                    : [],
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Text(emoji, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(label, style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : _kTextDark)),
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

            // ── CTA ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: GestureDetector(
                onTap: widget.onNext,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppL10n(Lang.code).avatarCta,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: 1.5)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
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
  static const _optionEmojis = ['🏋️', '🏠', '💪'];

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
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.rs(24), vertical: context.rv(14)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack ?? () => Navigator.maybePop(context),
                      child: Container(
                        width: context.rs(36), height: context.rs(36),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.arrow_back,
                          size: context.rs(18), color: _kGreenDark),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppL10n(Lang.code).locationTopBarTitle,
                          style: TextStyle(
                            fontSize: context.rs(11),
                            letterSpacing: 3.0,
                            fontWeight: FontWeight.w700,
                            color: _kGreenDark,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.rs(36)),
                  ],
                ),
              ),

              SizedBox(height: context.rv(10)),

              // ── Header card ─────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.rs(24)),
                child: Column(children: [
                  Container(
                    width: context.rs(56), height: context.rs(56),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A7A5A), Color(0xFF2D4A2D)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: _kGreenDark.withOpacity(0.3),
                        blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Icon(Icons.location_on_outlined,
                      size: context.rs(26), color: Colors.white),
                  ),
                  SizedBox(height: context.rv(12)),
                  Text(
                    AppL10n(Lang.code).locationTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.rs(20),
                      fontWeight: FontWeight.w800,
                      color: _kTextDark,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: context.rv(5)),
                  Text(
                    AppL10n(Lang.code).locationSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: context.rs(12.5), color: _kTextMuted),
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
                    final emoji = _optionEmojis[i];
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
                            gradient: sel
                                ? const LinearGradient(
                                    colors: [Color(0xFF3D6B40), Color(0xFF1A3318)],
                                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  )
                                : null,
                            color: sel ? null : Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: sel ? Colors.transparent : const Color(0xFFB8D4C0),
                              width: 1.8,
                            ),
                            boxShadow: sel
                                ? [BoxShadow(color: _kGreenDark.withOpacity(0.32), blurRadius: 18, offset: const Offset(0, 6))]
                                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: context.rs(48), height: context.rs(48),
                                decoration: BoxDecoration(
                                  color: sel ? Colors.white.withOpacity(0.2) : const Color(0xFFD6EBE0),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(emoji,
                                    style: TextStyle(fontSize: context.rs(24))),
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
                                        color: sel ? Colors.white.withOpacity(0.75) : _kTextMuted,
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