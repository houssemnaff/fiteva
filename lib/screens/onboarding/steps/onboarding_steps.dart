import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: const Icon(Icons.arrow_back, size: 20, color: _kTextDark),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title?.toUpperCase() ?? '',
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                    color: _kTextMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
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
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2EE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _kGreenDark, size: 28),
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
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _kTextDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        child: GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              color: enabled ? _kGreenDark : const Color(0xFFE8EDE8),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
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
Widget _mintScaffold({required Widget child}) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: child,
  );
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                          position: _logoSlide, child: _buildLogo()),
                    ),
                    const Spacer(flex: 2),
                    FadeTransition(
                      opacity: _headFade,
                      child: SlideTransition(
                          position: _headSlide, child: _buildHeadline()),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(opacity: _chipsFade, child: _buildChips()),
                    const SizedBox(height: 28),
                    FadeTransition(opacity: _proofFade, child: _buildSocialProof()),
                    const Spacer(flex: 3),
                    FadeTransition(
                      opacity: _btnFade,
                      child: SlideTransition(
                          position: _btnSlide, child: _buildCTA()),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _btnFade,
                      child: Text(
                        "En continuant, tu acceptes nos Conditions d'utilisation",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.28),
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
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

  Widget _buildLogo() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset('assets/images/logfiteva.jpeg',
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 13),
          const Text(
            "FITEVA",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 3.5,
            ),
          ),
        ],
      );

  Widget _buildHeadline() => Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.08,
                letterSpacing: -1.2,
              ),
              children: [
                TextSpan(text: "Transforme\nton corps,\n"),
                TextSpan(
                  text: "libère ta force.",
                  style: TextStyle(color: Color(0xFF5CD57A)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Fitness, cycle & nutrition —\ntout ce dont une femme a besoin.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              color: Colors.white.withValues(alpha: 0.50),
              height: 1.55,
            ),
          ),
        ],
      );

  Widget _buildChips() {
    const features = [
      (Icons.fitness_center_rounded,  "Workouts"),
      (Icons.water_drop_outlined,     "Cycle"),
      (Icons.restaurant_menu_rounded, "Nutrition"),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features
          .map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.13)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(f.$1,
                          color: const Color(0xFF5CD57A), size: 15),
                      const SizedBox(width: 7),
                      Text(f.$2,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSocialProof() => Container(
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
            RichText(
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
          ],
        ),
      );

  Widget _buildCTA() => GestureDetector(
        onTap: widget.onNext,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5CD57A), Color(0xFF1A5C26)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5CD57A).withValues(alpha: 0.32),
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
const _kGreenLight  = Color(0xFF2E7D4F);
const _kGreenPale   = Color(0xFFE8F5EE);
const _kGreen       = Color(0xFF2D4A2D);

class StepWelcome extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const StepWelcome({
    super.key,
    required this.onNext,
    this.onBack,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}

class _StepWelcomeState extends State<StepWelcome>
    with TickerProviderStateMixin {

  late final AnimationController _entranceCtrl;

  Animation<double> _titleFade  = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _titleSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _fieldsFade  = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _fieldsSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _dividerFade = const AlwaysStoppedAnimation<double>(1);
  Animation<double> _socialFade  = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _socialSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _btnFade    = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _btnSlide   = const AlwaysStoppedAnimation<Offset>(Offset.zero);

  bool _obscure    = true;
  bool _emailMode  = false;

  bool get _canContinue {
    if (_emailMode) {
      return widget.nameController.text.trim().isNotEmpty &&
             widget.emailController.text.trim().isNotEmpty &&
             widget.passwordController.text.trim().isNotEmpty;
    }
    return widget.nameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400),
    )..forward();

    _titleFade  = _c(0.15, 0.38);
    _titleSlide = _s(0.15, 0.38);
    _fieldsFade  = _c(0.30, 0.55);
    _fieldsSlide = _s(0.30, 0.55);
    _dividerFade = _c(0.45, 0.65);
    _socialFade  = _c(0.55, 0.78);
    _socialSlide = _s(0.55, 0.78);
    _btnFade    = _c(0.68, 0.92);
    _btnSlide   = _s(0.68, 0.92);
  }

  Animation<double> _c(double s, double e) => CurvedAnimation(
    parent: _entranceCtrl, curve: Interval(s, e, curve: Curves.easeOut),
  );

  Animation<Offset> _s(double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.28), end: Offset.zero).animate(
        CurvedAnimation(parent: _entranceCtrl,
            curve: Interval(s, e, curve: Curves.easeOut)),
      );

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _emailMode
                        ? () => setState(() => _emailMode = false)
                        : (widget.onBack ?? () => Navigator.pop(context)),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _kGreenPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: _kGreen, size: 15),
                    ),
                  ),
                  Row(
                    children: List.generate(7, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == 0 ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == 0 ? _kGreen : const Color(0xFFD8E8DF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    FadeTransition(opacity: _titleFade,
                      child: SlideTransition(position: _titleSlide,
                        child: _buildHeadline())),
                    const SizedBox(height: 32),
                    FadeTransition(opacity: _fieldsFade,
                      child: SlideTransition(position: _fieldsSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _label("Comment FitEva t'appelle ?"),
                            const SizedBox(height: 8),
                            _inputField(
                              controller: widget.nameController,
                              hint: "Ton pseudo dans l'app",
                              icon: Icons.badge_outlined,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 6),
                            Text("Ce nom sera visible dans la communauté.",
                              style: TextStyle(fontSize: 11.5,
                                  color: Colors.grey.shade400, height: 1.4)),
                            if (_emailMode) ...[
                              const SizedBox(height: 20),
                              _label("Email"),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: widget.emailController,
                                hint: "ton@email.com",
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 16),
                              _label("Mot de passe"),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: widget.passwordController,
                                hint: "••••••••",
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscure = !_obscure),
                                  child: Icon(
                                    _obscure ? Icons.visibility_off_outlined
                                             : Icons.visibility_outlined,
                                    size: 18, color: Colors.grey.shade400,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(opacity: _dividerFade, child: _buildDivider()),
                    const SizedBox(height: 24),
                    FadeTransition(opacity: _socialFade,
                      child: SlideTransition(position: _socialSlide,
                        child: _buildSocialButtons())),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            FadeTransition(opacity: _btnFade,
              child: SlideTransition(position: _btnSlide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
                  child: _buildCTA(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _emailMode ? "Crée ton compte" : "Bienvenue ",
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800,
            color: Color(0xFF0F1A14), height: 1.15, letterSpacing: -0.8),
      ),
      const SizedBox(height: 6),
      Text(
        _emailMode ? "Remplis les infos pour commencer."
                   : "Comment veux-tu rejoindre FitEva ?",
        style: TextStyle(fontSize: 14.5, color: Colors.grey.shade500, height: 1.5),
      ),
    ],
  );

  Widget _label(String text) => Text(text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
        color: Colors.grey.shade700, letterSpacing: 0.1));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2EDE7), width: 1.2),
      ),
      child: TextField(
        controller: controller, obscureText: obscure,
        keyboardType: keyboardType, onChanged: onChanged,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
            color: Color(0xFF0F1A14)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400,
              fontWeight: FontWeight.w400, fontSize: 14.5),
          prefixIcon: Icon(icon, color: _kGreenLight, size: 19),
          suffixIcon: suffix != null
              ? Padding(padding: const EdgeInsets.only(right: 12), child: suffix)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(children: [
    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text("ou continuer avec",
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade400,
              fontWeight: FontWeight.w500)),
    ),
    Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
  ]);

  Widget _buildSocialButtons() => Column(children: [
    _socialBtn(label: "Continuer avec Email", icon: Icons.mail_outline_rounded,
        iconColor: _kGreen, bgColor: _kGreenPale, textColor: _kGreen,
        borderColor: const Color(0xFFB8D9C5),
        onTap: () => setState(() => _emailMode = true)),
    const SizedBox(height: 12),
    _socialBtn(label: "Continuer avec Google", customIcon: _googleIcon(),
        bgColor: Colors.white, textColor: const Color(0xFF1A1A1A),
        borderColor: const Color(0xFFE0E0E0), onTap: () {}),
    const SizedBox(height: 12),
    _socialBtn(label: "Continuer avec Apple", icon: Icons.apple_rounded,
        iconColor: Colors.white, bgColor: const Color(0xFF1A1A1A),
        textColor: Colors.white, borderColor: Colors.transparent, onTap: () {}),
  ]);

  Widget _socialBtn({
    required String label,
    IconData? icon, Widget? customIcon,
    Color iconColor = Colors.black,
    required Color bgColor, required Color textColor,
    required Color borderColor, required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          customIcon ?? Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: textColor, letterSpacing: -0.1)),
        ]),
      ),
    );
  }

  Widget _googleIcon() => SizedBox(
    width: 20, height: 20,
    child: CustomPaint(painter: _GoogleGPainter()),
  );

  Widget _buildCTA() {
    final enabled = _canContinue;
    return GestureDetector(
      onTap: enabled ? widget.onNext : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled ? const LinearGradient(
            colors: [_kGreenLight, _kGreen],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          color: enabled ? null : const Color(0xFFE8EDE9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? [BoxShadow(color: _kGreen.withOpacity(0.30),
              blurRadius: 18, offset: const Offset(0, 6))] : [],
        ),
        child: Center(
          child: Text("Continuer →", style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700,
            color: enabled ? Colors.white : Colors.grey.shade400,
            letterSpacing: 0.2,
          )),
        ),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segments = [
      (0.0, 90.0, const Color(0xFF4285F4)),
      (90.0, 180.0, const Color(0xFF34A853)),
      (180.0, 270.0, const Color(0xFFFBBC05)),
      (270.0, 360.0, const Color(0xFFEA4335)),
    ];
    for (final (s, e, color) in segments) {
      final paint = Paint()..color = color
        ..strokeWidth = size.width * 0.22..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 0.72),
          s * pi / 180, (e - s) * pi / 180, false, paint);
    }
    canvas.drawRect(Rect.fromLTWH(size.width * 0.5, size.height * 0.38,
        size.width * 0.5, size.height * 0.24), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.62, size.height * 0.44,
        size.width * 0.38, size.height * 0.12),
        Paint()..color = const Color(0xFF4285F4));
  }
  @override bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 2 — StepGoals  (minimalist B&W circle selector)
// ══════════════════════════════════════════════════════════════════════════════

class _GoalData {
  final String label;
  const _GoalData(this.label);
}

const _goals = [
  _GoalData('Build strength\nand feel stronger'),
  _GoalData('Tone and sculpt\nmy whole body'),
  _GoalData('Improve\nflexibility\nand mobility'),
  _GoalData('Reduce stress\nand feel more\nbalanced'),
  _GoalData('Get back into\na routine'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ??
                        () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: Colors.black),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'GOALS',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Icon ────────────────────────────────────────────
            const Icon(Icons.track_changes_rounded,
                size: 38, color: Color(0xFF888888)),

            const SizedBox(height: 20),

            // ── Question ─────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'What is your primary\nfocus right now?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),
            ),

            const Spacer(),

            // ── Circle cluster ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  const double d     = 148.0;
                  const double vStep = 120.0;
                  final double w     = constraints.maxWidth;
                  final double lx    = d / 2 + 10;
                  final double rx    = w - d / 2 - 10;
                  final double cx    = w / 2;

                  final offsets = [
                    Offset(lx, 0),
                    Offset(rx, 0),
                    Offset(cx, vStep),
                    Offset(lx, vStep * 2),
                    Offset(rx, vStep * 2),
                  ];

                  return SizedBox(
                    height: vStep * 2 + d,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(_goals.length, (i) {
                        final label = _goals[i].label;
                        final isSel =
                            widget.selectedGoals.contains(label);
                        return Positioned(
                          left: offsets[i].dx - d / 2,
                          top: offsets[i].dy,
                          child: FadeTransition(
                            opacity: _fades[i],
                            child: _CircleGoal(
                              label: label,
                              diameter: d,
                              selected: isSel,
                              onTap: () => _select(label),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),
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

  const _CircleGoal({
    required this.label,
    required this.diameter,
    required this.selected,
    required this.onTap,
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
            color: sel ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: sel ? Colors.white : Colors.black,
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack ??
                        () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: Colors.black),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'LEVEL',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 3.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Icon ────────────────────────────────────────────
            const Icon(Icons.show_chart_rounded,
                size: 38, color: Color(0xFF888888)),

            const SizedBox(height: 20),

            // ── Question ─────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'What is your current\nfitness level?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),
            ),

            const Spacer(),

            // ── Triangle circle layout ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (_, constraints) {
                  const double d     = 148.0;
                  const double vStep = 120.0;
                  final double w     = constraints.maxWidth;
                  final double lx    = d / 2 + 10;
                  final double rx    = w - d / 2 - 10;
                  final double cx    = w / 2;

                  // Triangle: top-left, top-right, bottom-center
                  final offsets = [
                    Offset(lx, 0),
                    Offset(rx, 0),
                    Offset(cx, vStep),
                  ];

                  return SizedBox(
                    height: vStep + d,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: List.generate(_levels.length, (i) {
                        final label = _levels[i];
                        final isSel = widget.selectedLevel == label;
                        return Positioned(
                          left: offsets[i].dx - d / 2,
                          top: offsets[i].dy,
                          child: FadeTransition(
                            opacity: _fades[i],
                            child: _CircleGoal(
                              label: label,
                              diameter: d,
                              selected: isSel,
                              onTap: () => _select(label),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
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

  const equipmentIcon({
    required this.label,
    required this.icon,
    required this.diameter,
    required this.selected,
    required this.onTap,
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
          color: selected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : Colors.black, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : Colors.black,
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            const Icon(Icons.sports_gymnastics,
                size: 38, color: Color(0xFF888888)),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'What equipment\ndo you have access to?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),

            Expanded(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  const double d = 136.0;
                  const double vStep = 106.0;

                  final w = constraints.maxWidth;
                  final lx = d / 2 + 8;
                  final rx = w - d / 2 - 8;
                  final cx = w / 2;

                  final offsets = [
                    Offset(lx, 0),
                    Offset(rx, 0),
                    Offset(cx, vStep),
                    Offset(lx, vStep * 2),
                    Offset(rx, vStep * 2),
                    Offset(cx, vStep * 3),
                  ];

                  return SizedBox(
                    height: vStep * 3 + d,
                    child: Stack(
                      children: List.generate(_equipments.length, (i) {
                        final label = _equipments[i];
                        final isSel = widget.selectedEquipment.contains(label);

                        return Positioned(
                          left: offsets[i].dx - d / 2,
                          top: offsets[i].dy,
                          child: FadeTransition(
                            opacity: _fades[i],
                            child: equipmentIcon(
                              label: label,
                              icon: equipmentIcons[label]!,
                              diameter: d,
                              selected: isSel,
                              onTap: () => _handleEquipmentTap(label),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: GestureDetector(
                onTap: count > 0 ? widget.onNext : null,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: count > 0 ? Colors.black : const Color(0xFFE8E8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      count > 0
                          ? 'CONTINUE ($count)'
                          : 'SELECT AT LEAST ONE',
                      style: TextStyle(
                        color:
                            count > 0 ? Colors.white : const Color(0xFF999999),
                        fontWeight: FontWeight.w700,
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
      child: Column(
        children: [
          _OnboardingTopBar(step: 5, total: 7, title: 'Wellbeing', onBack: widget.onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 48, color: _kTextMuted),
                  const SizedBox(height: 24),
                  const Text(
                    'Combien de jours par\nsemaine veux-tu t\'entraîner ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: _kTextDark,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _FreqCallout(text: _labels[_index]),
                  const SizedBox(height: 20),
                  Center(
                    child: _FreqDial(
                      count: _labels.length,
                      index: _index,
                      onChanged: _select,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Suivant',
            onPressed: _hasInteracted ? widget.onNext : null,
          ),
        ],
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

  const _FreqDial({
    required this.count,
    required this.index,
    required this.onChanged,
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
            Positioned(
              left: _size / 2 - 36, top: _size / 2 - 36,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded, color: _kTextDark, size: 38),
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
                      color: Colors.black.withValues(alpha: 0.12),
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
  const StepHealthProfile({super.key, required this.onNext, this.onBack});

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  static const int _minH = 140, _maxH = 210;

  // Weight list: 35.0 → 150.0, step 0.5 → 231 items
  static final List<double> _wList =
      List.generate(231, (i) => 35.0 + i * 0.5);

  late final FixedExtentScrollController _hCtrl;
  late final FixedExtentScrollController _wCtrl;

  int _hIdx = 25; // default 165 cm
  int _wIdx = 50; // default 60.0 kg

  int get _heightCm => _minH + _hIdx;
  double get _weightKg => _wList[_wIdx];

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  String get _bmiLabel {
    if (_bmi < 18.5) return 'Mince';
    if (_bmi < 25.0) return 'Normale';
    if (_bmi < 30.0) return 'Surpoids';
    return 'Obésité';
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
    _hCtrl = FixedExtentScrollController(initialItem: _hIdx);
    _wCtrl = FixedExtentScrollController(initialItem: _wIdx);
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _wCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(
              step: 6, total: 7, title: 'Profil santé', onBack: widget.onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const _StepIcon(Icons.straighten_rounded),
                  const SizedBox(height: 16),
                  const _StepHeader(
                    title: 'Taille & Poids',
                    subtitle: 'Fais défiler pour entrer tes mesures',
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: _DrumPicker(
                          label: 'TAILLE',
                          unit: 'cm',
                          selectedIndex: _hIdx,
                          controller: _hCtrl,
                          itemCount: _maxH - _minH + 1,
                          labelFor: (i) => '${_minH + i}',
                          onChanged: (i) => setState(() => _hIdx = i),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DrumPicker(
                          label: 'POIDS',
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
                          onChanged: (i) => setState(() => _wIdx = i),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _BmiCard(bmi: _bmi, label: _bmiLabel, color: _bmiColor),
                ],
              ),
            ),
          ),
          _CtaButton(label: 'Continuer', onPressed: widget.onNext),
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

  const StepCycleAndPregnancy({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<StepCycleAndPregnancy> createState() => _StepCycleAndPregnancyState();
}

class _StepCycleAndPregnancyState extends State<StepCycleAndPregnancy> {
  bool? _isPregnant;

  // ── Cycle ──────────────────────────────────────────────────────────────────
  String _cycleDuration = '28 jours';
  DateTime _lastPeriod = DateTime(2026, 4, 5);

  static const List<String> _durations = [
    '24 jours', '26 jours', '28 jours', '30 jours', '32 jours',
  ];

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
    switch (_trimester) {
      case 1:
        return 'Marche douce & yoga prénatal. Évite les abdominaux et les efforts intenses.';
      case 2:
        return 'Natation & Pilates prénatal. Évite d\'être allongée sur le dos après 16 SA.';
      default:
        return 'Mobilité douce & respiration consciente. Intensité très modérée recommandée.';
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
    final p = await showDatePicker(
      context: context,
      initialDate: _lastPeriod,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreenDark),
        ),
        child: child!,
      ),
    );
    if (p != null) setState(() => _lastPeriod = p);
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
              step: 7, total: 7, title: 'Santé féminine',
              onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Santé féminine',
                    subtitle: 'Pour adapter ton plan à ta réalité du moment',
                  ),
                  const SizedBox(height: 24),
                  // ── Toggle cards ──
                  Row(children: [
                    Expanded(child: _statusCard(
                      false, LucideIcons.moon,
                      'Cycle\nrégulier', 'Sync entraînement',
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _statusCard(
                      true, LucideIcons.sparkles,
                      'Je suis\nenceinte', 'Programme prénatal',
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
                    child: _isPregnant == null
                        ? _hintWidget()
                        : _isPregnant == false
                            ? _cycleWidget()
                            : _pregnancyWidget(),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: _isPregnant == false ? 'Commencer FITEVA' : 'Continuer',
            onPressed: _isPregnant != null ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  // ── Status toggle cards ────────────────────────────────────────────────────
  Widget _statusCard(bool value, IconData icon, String label, String sub) {
    final sel = _isPregnant == value;
    return GestureDetector(
      onTap: () => setState(() => _isPregnant = value),
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
      child: const Row(children: [
        Icon(Icons.touch_app_outlined, color: _kTextMuted, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text('Sélectionne ta situation ci-dessus',
              style: TextStyle(
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
        const Text('Durée habituelle de ton cycle',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: _kTextDark)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _durations.map((d) {
            final sel = _cycleDuration == d;
            return GestureDetector(
              onTap: () => setState(() => _cycleDuration = d),
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
        const Text('Dernières règles',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
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
    final phases = [
      _CyclePhase('Menstruation', 5, const Color(0xFFE8A0A0)),
      _CyclePhase('Folliculaire', follDays, const Color(0xFFEDD07A)),
      _CyclePhase('Ovulation', 2, const Color(0xFF7AC998)),
      _CyclePhase('Lutéale', lutDays, const Color(0xFFB8A8D4)),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5D8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ton cycle en un coup d\'œil',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
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
    final label = diff > 0
        ? 'Prochaines règles dans $diff jours · ${_fmt(_nextPeriod)}'
        : diff == 0
            ? 'Prochaines règles aujourd\'hui · ${_fmt(_nextPeriod)}'
            : 'Période attendue · ${_fmt(_nextPeriod)}';
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
          label: 'SEMAINES D\'AMÉNORRHÉE',
          unit: 'SA',
          selectedIndex: _weekIdx,
          controller: _weekCtrl,
          itemCount: 42,
          labelFor: (i) => '${i + 1}',
          onChanged: (i) => setState(() => _weekIdx = i),
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
    final label = _trimester == 1
        ? '1er trimestre'
        : _trimester == 2
            ? '2ème trimestre'
            : '3ème trimestre';
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
}

// Data holder for cycle phase strip
class _CyclePhase {
  final String name;
  final int days;
  final Color color;
  const _CyclePhase(this.name, this.days, this.color);
}