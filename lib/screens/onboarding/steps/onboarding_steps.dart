import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
          color: Colors.white.withOpacity(0.35),
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
          color: selected ? _kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected
                ? _kCardSel
                : Colors.white.withOpacity(0.8),
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
          color: selected ? _kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: selected ? _kCardSel : Colors.white.withOpacity(0.8),
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
              color: enabled ? _kGreenDark : Colors.white.withOpacity(0.4),
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
    backgroundColor: _kBgMint,
    body: child,
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 0 — StepIntro
// ══════════════════════════════════════════════════════════════════════════════
class StepIntro extends StatelessWidget {
  final VoidCallback onNext;
  const StepIntro({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF244D2A)),
        child: Stack(
          children: [
            Positioned(
              top: -100, left: -80,
              child: _circle(300, const Color(0xFF2E5E35)),
            ),
            Positioned(
              bottom: -120, right: -80,
              child: _circle(280, const Color(0xFF2E5E35)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/logfiteva.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "FITEVA",
                          style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold,
                            letterSpacing: 2, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "fit, c'est moi.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Commencer",
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold,
                                color: Color(0xFF244D2A),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Color(0xFF244D2A)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.4), shape: BoxShape.circle,
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
// STEP 2 — StepGoals  (fond mint + pills)
// ══════════════════════════════════════════════════════════════════════════════
class StepGoals extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final options = [
      _GoalItem('Perdre du poids',    Icons.local_fire_department),
      _GoalItem('Prendre du muscle',  Icons.fitness_center),
      _GoalItem('Endurance',          Icons.directions_run),
      _GoalItem('Réduire le stress',  Icons.self_improvement),
      _GoalItem('Hormones',           Icons.spa),
      _GoalItem('Sommeil',            Icons.nightlight_round),
    ];

    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 2, total: 7, title: 'Goals', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.track_changes_rounded),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Tes objectifs',
                    subtitle: 'Choisis ce qui te correspond',
                  ),
                  const SizedBox(height: 28),
                  // Grille 2 colonnes de pills
                  Expanded(
                    child: GridView.builder(
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected = selectedGoals.contains(item.label);
                        return _CompactPill(
                          label: item.label,
                          icon: item.icon,
                          selected: selected,
                          onTap: () => onToggleGoal(item.label),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Next',
            onPressed: selectedGoals.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _GoalItem {
  final String label;
  final IconData icon;
  _GoalItem(this.label, this.icon);
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 3 — StepFitnessLevel (fond mint + pills liste)
// ══════════════════════════════════════════════════════════════════════════════
class StepFitnessLevel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final levels = [
      _LevelItem('Débutant',      'Moins de 6 mois d\'expérience', Icons.eco_outlined),
      _LevelItem('Intermédiaire', '6 mois à 2 ans d\'expérience',  Icons.local_fire_department),
      _LevelItem('Avancé',        'Plus de 2 ans d\'expérience',   Icons.flash_on),
    ];

    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 3, total: 7, title: 'Level', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.show_chart_rounded),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ton niveau',
                    subtitle: 'On adapte ton programme',
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView.separated(
                      itemCount: levels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = levels[i];
                        return _PillCard(
                          label: item.label,
                          sublabel: item.sub,
                          icon: item.icon,
                          selected: selectedLevel == item.label,
                          onTap: () => onChanged(item.label),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Next',
            onPressed: selectedLevel != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _LevelItem {
  final String label, sub;
  final IconData icon;
  _LevelItem(this.label, this.sub, this.icon);
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 4 — StepEquipment (fond mint + grille pills)
// ══════════════════════════════════════════════════════════════════════════════
class StepEquipment extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final options = [
      _EquipItem('Aucun matériel', Icons.self_improvement),
      _EquipItem('Haltères',       Icons.fitness_center),
      _EquipItem('Barre & poids',  Icons.sports_gymnastics),
      _EquipItem('Machines',       Icons.precision_manufacturing),
      _EquipItem('Résistances',    Icons.timeline),
      _EquipItem('Tapis de yoga',  Icons.spa),
    ];

    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 4, total: 7, title: 'Equipment', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.sports_gymnastics),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ton équipement',
                    subtitle: 'On adapte tes workouts',
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: GridView.builder(
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected = selectedEquipment.contains(item.label);
                        return _CompactPill(
                          label: item.label,
                          icon: item.icon,
                          selected: selected,
                          onTap: () => onToggleEquipment(item.label),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Next',
            onPressed: selectedEquipment.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _EquipItem {
  final String label;
  final IconData icon;
  _EquipItem(this.label, this.icon);
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 5 — StepFrequency (fond mint + pills liste avec dots)
// ══════════════════════════════════════════════════════════════════════════════
class StepFrequency extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final options = [
      _FreqItem('2 jours', 2),
      _FreqItem('3 jours', 3),
      _FreqItem('4 jours', 4),
      _FreqItem('5 jours', 5),
      _FreqItem('6 jours', 6),
    ];

    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 5, total: 7, title: 'Wellbeing', onBack: onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.calendar_today_rounded),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ta fréquence',
                    subtitle: 'On crée ton rythme idéal',
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item   = options[i];
                        final isSel  = selectedFrequency == item.label;
                        return GestureDetector(
                          onTap: () => onChanged(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 18),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? _kCardSel
                                  : Colors.white.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isSel
                                    ? _kCardSel
                                    : Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              boxShadow: isSel
                                  ? [BoxShadow(color: _kGreenDark.withOpacity(0.25),
                                      blurRadius: 16, offset: const Offset(0, 6))]
                                  : [],
                            ),
                            child: Row(children: [
                              // dots
                              Row(children: List.generate(6, (idx) {
                                final active = idx < item.days;
                                return Container(
                                  margin: const EdgeInsets.only(right: 5),
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? (isSel ? Colors.white : _kGreenMid)
                                        : (isSel
                                            ? Colors.white30
                                            : Colors.white.withOpacity(0.5)),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              })),
                              const SizedBox(width: 16),
                              Expanded(child: Text(
                                "${item.label} par semaine",
                                style: TextStyle(fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isSel ? Colors.white : _kTextDark),
                              )),
                              if (isSel)
                                const Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Next',
            onPressed: selectedFrequency != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

class _FreqItem {
  final String label;
  final int days;
  _FreqItem(this.label, this.days);
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 6 — StepHealthProfile (fond mint, sliders conservés)
// ══════════════════════════════════════════════════════════════════════════════
class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepHealthProfile({super.key, required this.onNext, this.onBack});

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  double _heightCm = 165;
  double _weightKg = 60;

  bool get _canContinue =>
      _heightCm >= 140 && _heightCm <= 210 &&
      _weightKg >= 35 && _weightKg <= 150;

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 6, total: 7, title: 'Profil santé', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.monitor_weight_outlined),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Profil santé',
                    subtitle: 'Taille & poids pour personnaliser ton plan',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 310,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _avatarPanel()),
                        const SizedBox(width: 16),
                        SizedBox(width: 84, child: _heightPanel()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _weightPanel(),
                  const SizedBox(height: 16),
                  // IMC pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                    child: Text('IMC : ${_bmi.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 13,
                          fontWeight: FontWeight.w600, color: _kTextDark)),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _avatarPanel() {
    return Center(
      child: Image.asset(
        _weightKg < 55 ? 'assets/images/slim1.png'
            : _weightKg < 75 ? 'assets/images/average1.png'
            : 'assets/images/chubby1.png',
        fit: BoxFit.contain, width: 190, height: 250,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.person, size: 90, color: _kGreenDark),
      ),
    );
  }

  Widget _heightPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(children: [
        const Text('Height', style: TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: _kTextMuted)),
        const SizedBox(height: 8),
        Text('${_heightCm.round()} cm', style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: _kTextDark)),
        const SizedBox(height: 6),
        Expanded(child: RotatedBox(quarterTurns: 3,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _kGreenDark,
              inactiveTrackColor: Colors.white.withOpacity(0.5),
              thumbColor: _kGreenDark,
              overlayColor: _kGreenDark.withOpacity(0.15),
            ),
            child: Slider(value: _heightCm, min: 140, max: 210,
                onChanged: (v) => setState(() => _heightCm = v)),
          ),
        )),
      ]),
    );
  }

  Widget _weightPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weight', style: TextStyle(fontSize: 13,
            color: _kTextMuted, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text('${_weightKg.round()} kg', style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: _kTextDark)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kGreenDark,
            inactiveTrackColor: Colors.white.withOpacity(0.5),
            thumbColor: _kGreenDark,
            overlayColor: _kGreenDark.withOpacity(0.15),
          ),
          child: Slider(value: _weightKg, min: 35, max: 150,
              onChanged: (v) => setState(() => _weightKg = v)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 7 — StepCycle (fond mint)
// ══════════════════════════════════════════════════════════════════════════════
class StepCycle extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  const StepCycle({super.key, required this.onNext, this.onBack});

  @override
  State<StepCycle> createState() => _StepCycleState();
}

class _StepCycleState extends State<StepCycle> {
  String? _selectedDuration = '28 jours';
  DateTime _lastPeriodDate  = DateTime(2026, 4, 5);

  final List<String> _durations = [
    '24 jours', '26 jours', '28 jours', '30 jours', '32 jours',
  ];

  String _formatDate(DateTime d) {
    const months = ['Janvier','Février','Mars','Avril','Mai','Juin',
      'Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _kGreenDark),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 7, total: 7, title: 'Cycle', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(LucideIcons.moon),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ton cycle menstruel',
                    subtitle: 'La clé du cycle syncing',
                  ),
                  const SizedBox(height: 24),
                  // Info card pill large
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Durée de ton cycle',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 15, color: _kTextDark)),
                        SizedBox(height: 6),
                        Text(
                          'La moyenne est de 28 jours mais chaque femme est unique',
                          style: TextStyle(fontSize: 13, color: _kTextMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft,
                    child: const Text('Durée habituelle',
                      style: TextStyle(fontSize: 13, color: _kTextMuted))),
                  const SizedBox(height: 12),
                  // Pills durée
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _kCardSel
                                : Colors.white.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: isSelected
                                  ? _kCardSel
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ),
                          child: Text(d, style: TextStyle(
                            color: isSelected ? Colors.white : _kTextDark,
                            fontWeight: FontWeight.w600, fontSize: 14,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft,
                    child: const Text('Début de tes dernières règles',
                      style: TextStyle(fontSize: 13, color: _kTextMuted))),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Row(children: [
                        const Icon(LucideIcons.calendarDays,
                            size: 20, color: _kTextMuted),
                        const SizedBox(width: 12),
                        Text(_formatDate(_lastPeriodDate),
                          style: const TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: _kTextDark)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Commencer FITEVA',
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 8 — StepPregnancy (fond mint + pills Oui/Non)
// ══════════════════════════════════════════════════════════════════════════════
class StepPregnancy extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final void Function(bool isPregnant, int? weekSA) onChanged;

  const StepPregnancy({
    super.key,
    required this.onNext,
    this.onBack,
    required this.onChanged,
  });

  @override
  State<StepPregnancy> createState() => _StepPregnancyState();
}

class _StepPregnancyState extends State<StepPregnancy> {
  bool? _isPregnant;
  double _week = 12;

  bool get _canContinue => _isPregnant != null;

  int get _trimester {
    if (_week <= 13) return 1;
    if (_week <= 27) return 2;
    return 3;
  }

  String get _trimesterLabel {
    switch (_trimester) {
      case 1: return '1er trimestre (S1–S13)';
      case 2: return '2e trimestre (S14–S27)';
      default: return '3e trimestre (S28–S42)';
    }
  }

  String get _trimesterAdvice {
    switch (_trimester) {
      case 1:
        return 'Privilégie la marche et le yoga prénatal. Évite les abdominaux et les efforts intenses.';
      case 2:
        return 'La natation et le Pilates prénatal sont idéaux. Évite les positions sur le dos après 16 SA.';
      default:
        return 'Privilégie la mobilité douce et la respiration. L\'intensité doit rester très modérée.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mintScaffold(
      child: Column(
        children: [
          _OnboardingTopBar(step: 8, total: 8, title: 'Grossesse', onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: [
                  const _StepIcon(Icons.pregnant_woman),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Grossesse',
                    subtitle: 'On adapte ton programme selon ton état de santé',
                  ),
                  const SizedBox(height: 28),
                  // Oui / Non en pills pleine largeur
                  Row(children: [
                    Expanded(child: _pregnancyPill(false, 'Non',
                        'Je ne suis pas enceinte', Icons.do_not_disturb_alt_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _pregnancyPill(true, 'Oui',
                        'Je suis enceinte', Icons.pregnant_woman)),
                  ]),

                  if (_isPregnant == true) ...[
                    const SizedBox(height: 24),
                    // Semaines
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('À quelle semaine es-tu ?',
                            style: TextStyle(fontSize: 13,
                                fontWeight: FontWeight.w600, color: _kTextMuted)),
                          const SizedBox(height: 10),
                          Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('${_week.round()}', style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.w800,
                                  color: _kGreenDark)),
                              const SizedBox(width: 6),
                              const Text('SA', style: TextStyle(fontSize: 18,
                                  color: _kTextMuted, fontWeight: FontWeight.w500)),
                            ]),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: _kGreenDark,
                              inactiveTrackColor: Colors.white.withOpacity(0.5),
                              thumbColor: _kGreenDark,
                              overlayColor: _kGreenDark.withOpacity(0.15),
                            ),
                            child: Slider(value: _week, min: 1, max: 42,
                                divisions: 41,
                                onChanged: (v) => setState(() => _week = v)),
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('1 SA', style: TextStyle(fontSize: 11, color: _kTextMuted)),
                              Text('42 SA', style: TextStyle(fontSize: 11, color: _kTextMuted)),
                            ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Trimestre pill
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: _kGreenDark,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text(_trimesterLabel, textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700,
                            fontSize: 13.5, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    // Advice
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.8)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: _kGreenDark, size: 18),
                          const SizedBox(width: 10),
                          Expanded(child: Text(_trimesterAdvice,
                            style: const TextStyle(fontSize: 13.5,
                                color: _kTextMuted, height: 1.5))),
                        ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Continuer',
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _pregnancyPill(bool value, String label, String sub, IconData icon) {
    final selected = _isPregnant == value;
    return GestureDetector(
      onTap: () => setState(() => _isPregnant = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? _kCardSel : Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? _kCardSel : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: _kGreenDark.withOpacity(0.25),
                  blurRadius: 16, offset: const Offset(0, 6))]
              : [],
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : _kGreenMid, size: 30),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.w800,
              fontSize: 16, color: selected ? Colors.white : _kTextDark)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(
              fontSize: 11.5,
              color: selected ? Colors.white70 : _kTextMuted)),
        ]),
      ),
    );
  }
}