import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ─── Shared Design Constants ───────────────────────────────────────────────
const _kGreen = Color(0xFF2D4A2D);
const _kBg = Color(0xFFF0F0EC);
const Color _kPink       = Color(0xFF1C4D30);
const Color _kPinkLight  = Color(0xFF7ABB98);
const Color _kPinkDeep   = Color(0xFF7ABB98);
const Color _kPinkPale   = Color(0xFFFCE4EC); 
// ─── Shared Widgets ────────────────────────────────────────────────────────

/// Top bar: back arrow + "X / 7" counter + green progress line
class _OnboardingTopBar extends StatelessWidget {
  final int step;
  final int total;
  final VoidCallback? onBack;

  const _OnboardingTopBar({
    required this.step,
    required this.total,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack ?? () => Navigator.maybePop(context),
                  child: const Icon(Icons.arrow_back, size: 22, color: Colors.black87),
                ),
                Text(
                  '$step / $total',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Thin progress line
        LinearProgressIndicator(
          value: step / total,
          minHeight: 2,
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(_kGreen),
        ),
      ],
    );
  }
}

/// Icon badge (grey rounded square with dark green icon)
class _StepIcon extends StatelessWidget {
  final IconData icon;
  const _StepIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: _kGreen, size: 28),
    );
  }
}

/// Step title + subtitle
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
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }
}

/// Bottom CTA button (dark green, full width)
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  const _CtaButton({
    required this.label,
    this.onPressed,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed != null ? _kGreen : Colors.grey.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 10),
                  Icon(trailingIcon, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared text field style
InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _kGreen, width: 1.5),
      ),
    );


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
        decoration: const BoxDecoration(
          color: Color(0xFF244D2A), // vert principal
        ),
        child: Stack(
          children: [
            // 🔵 Background circles (design moderne)
            Positioned(
              top: -100,
              left: -80,
              child: _circle(300, const Color(0xFF2E5E35)),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _circle(280, const Color(0xFF2E5E35)),
            ),

            // 🔥 CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  // 🔷 Logo + brand centered in page
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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "fit, c'est moi.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 🚀 BUTTON
                  SafeArea(
                    child: Column(
                      children: [
                        GestureDetector(
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF244D2A),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward, color: Color(0xFF244D2A)),
                              ],
                            ),
                          ),
                        ),
            
                        const SizedBox(height: 16),
            
                      ],
                    ),
                  ),
            
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔵 Background circle
  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Bienvenue (Prénom + Âge)
// ══════════════════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════════════════
// STEP 1 — Bienvenue (Prénom + Âge)
// ══════════════════════════════════════════════════════════════════════════════


// ── Brand colors ───────────────────────────────────────────────────────────
const _kGreenLight = Color(0xFF2E7D4F);
const _kGreenPale  = Color(0xFFE8F5EE);
const _kGreenAccent= Color(0xFF5CD57A);

// ══════════════════════════════════════════════════════════════════════════════
// StepWelcome
// ══════════════════════════════════════════════════════════════════════════════
class StepWelcome extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final TextEditingController nameController;      // pseudo / display name
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

  Animation<double> _logoFade = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _logoSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _titleFade = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _titleSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _fieldsFade = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _fieldsSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _dividerFade = const AlwaysStoppedAnimation<double>(1);
  Animation<double> _socialFade = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _socialSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);
  Animation<double> _btnFade = const AlwaysStoppedAnimation<double>(1);
  Animation<Offset> _btnSlide = const AlwaysStoppedAnimation<Offset>(Offset.zero);

  bool _obscure = true;
  bool _emailMode = false; // toggle email/password form

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
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _logoFade   = _c(0.00, 0.22);
    _logoSlide  = _s(0.00, 0.22);
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
    parent: _entranceCtrl,
    curve: Interval(s, e, curve: Curves.easeOut),
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

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _kGreenPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: _kGreen, size: 15),
                    ),
                  ),
                  // Step dots
                  Row(
                    children: List.generate(
                      7,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == 0 ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == 0 ? _kGreen : const Color(0xFFD8E8DF),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
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
                    const SizedBox(height: 12),

                  

                    const SizedBox(height: 28),

                    // ── Headline ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: _buildHeadline(),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Pseudo field (always visible) ──────────────────────
                    FadeTransition(
                      opacity: _fieldsFade,
                      child: SlideTransition(
                        position: _fieldsSlide,
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
                            Text(
                              "Ce nom sera visible dans la communauté.",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade400,
                                height: 1.4,
                              ),
                            ),

                            // ── Email/password fields (conditional) ─────────
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
                                  onTap: () =>
                                      setState(() => _obscure = !_obscure),
                                  child: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: Colors.grey.shade400,
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

                    // ── Divider ────────────────────────────────────────────
                    FadeTransition(
                      opacity: _dividerFade,
                      child: _buildDivider(),
                    ),

                    const SizedBox(height: 24),

                    // ── Social login buttons ───────────────────────────────
                    FadeTransition(
                      opacity: _socialFade,
                      child: SlideTransition(
                        position: _socialSlide,
                        child: _buildSocialButtons(),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── CTA button ───────────────────────────────────────────────
            FadeTransition(
              opacity: _btnFade,
              child: SlideTransition(
                position: _btnSlide,
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

  // ── Logo ─────────────────────────────────────────────────────────────────
 
  // ── Headline ──────────────────────────────────────────────────────────────
  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _emailMode ? "Crée ton compte" : "Bienvenue ",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F1A14),
            height: 1.15,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _emailMode
              ? "Remplis les infos pour commencer."
              : "Comment veux-tu rejoindre FitEva ?",
          style: TextStyle(
            fontSize: 14.5,
            color: Colors.grey.shade500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Label ─────────────────────────────────────────────────────────────────
  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
      letterSpacing: 0.1,
    ),
  );

  // ── Input field ───────────────────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isNumber = false,
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
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType ??
            (isNumber ? TextInputType.number : TextInputType.text),
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F1A14),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
            fontSize: 14.5,
          ),
          prefixIcon: Icon(icon, color: _kGreenLight, size: 19),
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: suffix,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "ou continuer avec",
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }

  // ── Social buttons ────────────────────────────────────────────────────────
  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Email button
        _socialBtn(
          label: "Continuer avec Email",
          icon: Icons.mail_outline_rounded,
          iconColor: _kGreen,
          bgColor: _kGreenPale,
          textColor: _kGreen,
          borderColor: const Color(0xFFB8D9C5),
          onTap: () => setState(() => _emailMode = true),
        ),
        const SizedBox(height: 12),
        // Google button
        _socialBtn(
          label: "Continuer avec Google",
          customIcon: _googleIcon(),
          bgColor: Colors.white,
          textColor: const Color(0xFF1A1A1A),
          borderColor: const Color(0xFFE0E0E0),
          onTap: () {/* TODO: Google Sign-In */},
        ),
        const SizedBox(height: 12),
        // Apple button
        _socialBtn(
          label: "Continuer avec Apple",
          icon: Icons.apple_rounded,
          iconColor: Colors.white,
          bgColor: const Color(0xFF1A1A1A),
          textColor: Colors.white,
          borderColor: Colors.transparent,
          onTap: () {/* TODO: Apple Sign-In */},
        ),
      ],
    );
  }

  Widget _socialBtn({
    required String label,
    IconData? icon,
    Widget? customIcon,
    Color iconColor = Colors.black,
    required Color bgColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            customIcon ??
                Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google "G" icon
  Widget _googleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }

  // ── CTA Button ────────────────────────────────────────────────────────────
  Widget _buildCTA() {
    final enabled = _canContinue;
    return GestureDetector(
      onTap: enabled ? widget.onNext : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 56,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [_kGreenLight, _kGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : const Color(0xFFE8EDE9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: _kGreen.withOpacity(0.30),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            "Continuer →",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: enabled ? Colors.white : Colors.grey.shade400,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Google G painter ─────────────────────────────────────────────────────────
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ring segments
    final segments = [
      (0.0,  90.0, const Color(0xFF4285F4)),
      (90.0, 180.0, const Color(0xFF34A853)),
      (180.0,270.0, const Color(0xFFFBBC05)),
      (270.0,360.0, const Color(0xFFEA4335)),
    ];

    for (final (s, e, color) in segments) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = size.width * 0.22
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        s * pi / 180,
        (e - s) * pi / 180,
        false,
        paint,
      );
    }

    // White cut for the "G" bar
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.38,
          size.width * 0.5, size.height * 0.24),
      whitePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.62, size.height * 0.44,
          size.width * 0.38, size.height * 0.12),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
 
// ══════════════════════════════════════════════════════════════════════════════
// PULSING DOT widget
// ══════════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}
 
class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
 
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.3, end: 1.0).animate(_c),
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: _kPinkLight,
            shape: BoxShape.circle,
          ),
        ),
      );
}
 
// ══════════════════════════════════════════════════════════════════════════════
// PETAL DATA MODEL
// ══════════════════════════════════════════════════════════════════════════════
class _Petal {
  final double x;         // 0..1 horizontal position
  final double delay;     // seconds before starting
  final double duration;  // seconds for full cycle
  final double size;
  final double angle;
  final int colorIndex;
 
  const _Petal({
    required this.x,
    required this.delay,
    required this.duration,
    required this.size,
    required this.angle,
    required this.colorIndex,
  });
}
 
// ══════════════════════════════════════════════════════════════════════════════
// PETAL PAINTER
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
      _GoalItem('Perdre du poids', Icons.local_fire_department),
      _GoalItem('Prendre du muscle', Icons.fitness_center),
      _GoalItem('Endurance', Icons.directions_run),
      _GoalItem('Réduire le stress', Icons.self_improvement),
      _GoalItem('Hormones', Icons.spa),
      _GoalItem('Sommeil', Icons.nightlight_round),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _OnboardingTopBar(step: 2, total: 7, onBack: onBack),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Tes objectifs',
                    subtitle: 'Choisis ce qui te correspond',
                  ),

                  const SizedBox(height: 30),

                  // 💎 GRID PREMIUM
                  Expanded(
                    child: GridView.builder(
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.0,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected = selectedGoals.contains(item.label);

                        return GestureDetector(
                          onTap: () => onToggleGoal(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selected ? _kGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? _kGreen
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: _kGreen.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ICON
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withOpacity(0.2)
                                        : _kGreen.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: selected
                                        ? Colors.white
                                        : _kGreen,
                                    size: 22,
                                  ),
                                ),

                                const Spacer(),

                                // TEXT
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // MINI CHECK
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: selected ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
            ),
          ),

          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedGoals.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// 🔹 MODEL
class _GoalItem {
  final String label;
  final IconData icon;

  _GoalItem(this.label, this.icon);
}
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
      _LevelItem(
        'Débutant',
        'Moins de 6 mois d\'expérience',
        Icons.eco_outlined,
      ),
      _LevelItem(
        'Intermédiaire',
        '6 mois à 2 ans d\'expérience',
        Icons.local_fire_department,
      ),
      _LevelItem(
        'Avancé',
        'Plus de 2 ans d\'expérience',
        Icons.flash_on,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _OnboardingTopBar(step: 3, total: 7, onBack: onBack),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Ton niveau',
                    subtitle: 'On adapte ton programme',
                  ),

                  const SizedBox(height: 30),

                  // 💎 LIST PREMIUM
                  Expanded(
                    child: ListView.builder(
                      itemCount: levels.length,
                      itemBuilder: (_, i) {
                        final item = levels[i];
                        final isSelected = selectedLevel == item.label;

                        return GestureDetector(
                          onTap: () => onChanged(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected ? _kGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? _kGreen
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _kGreen.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),

                            child: Row(
                              children: [
                                // ICON BOX
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : _kGreen.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : _kGreen,
                                    size: 24,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // TEXT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.sub,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSelected
                                              ? Colors.white70
                                              : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // CHECK ICON
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isSelected ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 22,
                                  ),
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
            ),
          ),

          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedLevel != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// 🔹 MODEL
class _LevelItem {
  final String label;
  final String sub;
  final IconData icon;

  _LevelItem(this.label, this.sub, this.icon);
}
// ══════════════════════════════════════════════════════════════════════════════
// STEP 4 — Équipement
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
      _EquipItem('Haltères', Icons.fitness_center),
      _EquipItem('Barre & poids', Icons.sports_gymnastics),
      _EquipItem('Machines', Icons.precision_manufacturing),
      _EquipItem('Résistances', Icons.timeline),
      _EquipItem('Tapis de yoga', Icons.spa),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _OnboardingTopBar(step: 4, total: 7, onBack: onBack),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Ton équipement',
                    subtitle: 'On adapte tes workouts',
                  ),

                  const SizedBox(height: 30),

                  // 💎 GRID PREMIUM
                  Expanded(
                    child: GridView.builder(
                      itemCount: options.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected =
                            selectedEquipment.contains(item.label);

                        return GestureDetector(
                          onTap: () => onToggleEquipment(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: selected ? _kGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? _kGreen
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: _kGreen.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ICON
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white.withOpacity(0.2)
                                        : _kGreen.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item.icon,
                                    color: selected
                                        ? Colors.white
                                        : _kGreen,
                                    size: 22,
                                  ),
                                ),

                                const Spacer(),

                                // TEXT
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // CHECK
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: selected ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
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
            ),
          ),

          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed:
                selectedEquipment.isNotEmpty ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// 🔹 MODEL
class _EquipItem {
  final String label;
  final IconData icon;

  _EquipItem(this.label, this.icon);
}class StepFrequency extends StatelessWidget {
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _OnboardingTopBar(step: 5, total: 7, onBack: onBack),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Ta fréquence',
                    subtitle: 'On crée ton rythme idéal',
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final isSelected =
                            selectedFrequency == item.label;

                        return GestureDetector(
                          onTap: () => onChanged(item.label),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: isSelected ? _kGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? _kGreen
                                    : Colors.grey.shade200,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: _kGreen.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),

                            child: Row(
                              children: [
                                // 🔵 VISUAL DAYS
                                Row(
                                  children: List.generate(6, (index) {
                                    final active = index < item.days;
                                    return Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? (isSelected
                                                ? Colors.white
                                                : _kGreen)
                                            : Colors.grey.shade300,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),

                                const SizedBox(width: 16),

                                // TEXT
                                Expanded(
                                  child: Text(
                                    "${item.label} par semaine",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),

                                // CHECK
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isSelected ? 1 : 0,
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 20,
                                  ),
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
            ),
          ),

          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: selectedFrequency != null ? onNext : null,
          ),
        ],
      ),
    );
  }
}

// 🔹 MODEL
class _FreqItem {
  final String label;
  final int days;

  _FreqItem(this.label, this.days);
}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 6 — Profil santé (Taille + Poids)
// ══════════════════════════════════════════════════════════════════════════════
class StepHealthProfile extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const StepHealthProfile({
    super.key,
    required this.onNext,
    this.onBack,
  });

  @override
  State<StepHealthProfile> createState() => _StepHealthProfileState();
}

class _StepHealthProfileState extends State<StepHealthProfile> {
  double _heightCm = 165;
  double _weightKg = 60;

  bool get _canContinue => _heightCm >= 140 && _heightCm <= 210 && _weightKg >= 35 && _weightKg <= 150;

  double get _bmi => _weightKg / pow(_heightCm / 100, 2);

  int get _zoneIndex {
    if (_bmi < 18.5) return 0;
    if (_bmi < 25) return 1;
    return 2;
  }

  String get _zoneTitle {
    switch (_zoneIndex) {
      case 0:
        return 'Zone 1: Poids leger';
      case 1:
        return 'Zone 2: Poids equilibre';
      default:
        return 'Zone 3: Surpoids';
    }
  }

  String get _zoneAdvice {
    switch (_zoneIndex) {
      case 0:
        return 'Objectif: renforcement musculaire et energie.';
      case 1:
        return 'Objectif: maintien et progression reguliere.';
      default:
        return 'Objectif: perdre du poids progressivement.';
    }
  }

  String get _avatarAsset {
    if (_weightKg < 55) {
      return 'assets/images/slim1.png';
    }
    if (_weightKg < 75) {
      return 'assets/images/average1.png';
    }
    return 'assets/images/chubby1.png';
  }

  double get _avatarScale {
    switch (_zoneIndex) {
      case 0:
        return 0.92;
      case 1:
        return 1.0;
      default:
        return 0.98;
    }
  }

  Color? get _avatarTint {
    switch (_zoneIndex) {
      case 0:
        return const Color(0x337ABB98);
      case 1:
        return null;
      default:
        return const Color(0x33D68C6C);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _OnboardingTopBar(step: 6, total: 7, onBack: widget.onBack),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Profil santé',
                    subtitle: 'Taille & poids pour personnaliser ton plan',
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 330,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _avatarPanel(),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 84,
                          child: _heightPanel(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  _weightPanel(),

                 

                

                  const SizedBox(height: 18),

                  Text(
                    'IMC: ${_bmi.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          _CtaButton(
            label: 'Continuer',
            trailingIcon: Icons.arrow_forward,
            onPressed: _canContinue ? widget.onNext : null,
          ),
        ],
      ),
    );
  }

  Widget _avatarPanel() {
    return Center(
      child: Transform.scale(
        scale: _avatarScale,
        child: _avatarTint == null
            ? Image.asset(
                _avatarAsset,
                fit: BoxFit.contain,
                width: 190,
                height: 250,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.person,
                    size: 90,
                    color: _kGreen,
                  );
                },
              )
            : ColorFiltered(
                colorFilter: ColorFilter.mode(_avatarTint!, BlendMode.srcATop),
                child: Image.asset(
                  _avatarAsset,
                  fit: BoxFit.contain,
                  width: 190,
                  height: 250,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.person,
                      size: 90,
                      color: _kGreen,
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _heightPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE7E0)),
      ),
      child: Column(
        children: [
          const Text(
            'Height',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_heightCm.round()} cm',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _kGreen,
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: _kGreen,
                  overlayColor: _kGreen.withOpacity(0.15),
                ),
                child: Slider(
                  value: _heightCm,
                  min: 140,
                  max: 210,
                  onChanged: (v) => setState(() => _heightCm = v),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weightPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_weightKg.round()} kg',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _kGreen,
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: _kGreen,
              overlayColor: _kGreen.withOpacity(0.15),
            ),
            child: Slider(
              value: _weightKg,
              min: 35,
              max: 150,
              onChanged: (v) => setState(() => _weightKg = v),
            ),
          ),
        ],
      ),
    );
  }

 


}

// ══════════════════════════════════════════════════════════════════════════════
// STEP 7 — Cycle menstruel
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
  DateTime _lastPeriodDate = DateTime(2026, 4, 5);

  final List<String> _durations = [
    '24 jours',
    '26 jours',
    '28 jours',
    '30 jours',
    '32 jours',
  ];

  String _formatDate(DateTime d) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
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
          colorScheme: const ColorScheme.light(primary: _kGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _OnboardingTopBar(step: 7, total: 7, onBack: widget.onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIcon(LucideIcons.moon),
                  const SizedBox(height: 20),
                  const _StepHeader(
                    title: 'Ton cycle menstruel',
                    subtitle: 'La clé du cycle syncing',
                  ),
                  const SizedBox(height: 20),
                  // Info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EDE8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Durée de ton cycle',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _kGreen,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'La moyenne est de 28 jours mais chaque femme est unique',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Durée habituelle',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _durations.map((d) {
                      final isSelected = _selectedDuration == d;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = d),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? _kGreen : Colors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Text(
                            d,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Début de tes dernières règles',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendarDays,
                              size: 20, color: Colors.black45),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(_lastPeriodDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _CtaButton(
            label: 'Commencer FITEVA',
            trailingIcon: Icons.check,
            onPressed: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}