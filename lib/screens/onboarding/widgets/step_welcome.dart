import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shared_onboarding_widgets.dart';

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
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _ctaFade;

  bool _obscure    = true;
  bool _emailMode  = false;

  void _showComingSoon() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion sociale bientôt disponible',
          style: GoogleFonts.inter(color: kTextDark)),
        backgroundColor: const Color(0xFF1A2A20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static final _emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');

  bool get canContinue {
    if (_emailMode) {
      final email = widget.emailController.text.trim();
      final password = widget.passwordController.text;
      return widget.nameController.text.trim().isNotEmpty &&
             _emailRegex.hasMatch(email) &&
             password.length >= 8;
    }
    return widget.nameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200),
    )..forward();

    _headerFade = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic)));
    _contentFade = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut));
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceCtrl,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)));
    _ctaFade = CurvedAnimation(parent: _entranceCtrl,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return mintScaffold(
      child: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_emailMode) {
                        setState(() => _emailMode = false);
                      } else {
                        (widget.onBack ?? () => Navigator.pop(context))();
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: kGlassFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kGlassBorder, width: 0.5),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: kTextDark, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    FadeTransition(opacity: _headerFade,
                      child: SlideTransition(position: _headerSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _emailMode ? 'Crée ton\ncompte' : 'Bienvenue',
                              style: GoogleFonts.outfit(fontSize: 36,
                                  fontWeight: FontWeight.w800, color: kTextDark,
                                  height: 1.1, letterSpacing: -1),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _emailMode
                                  ? 'Remplis les infos pour commencer.'
                                  : 'Comment veux-tu rejoindre FitEva ?',
                              style: GoogleFonts.inter(fontSize: 15,
                                  color: kTextMuted, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    FadeTransition(opacity: _contentFade,
                      child: SlideTransition(position: _contentSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('Ton pseudo'),
                            const SizedBox(height: 8),
                            _GlassInput(
                              controller: widget.nameController,
                              hint: 'Comment on t\'appelle ?',
                              icon: Icons.badge_outlined,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 6),
                            Text('Visible dans la communauté.',
                              style: GoogleFonts.inter(fontSize: 11.5,
                                  color: kTextMuted.withValues(alpha: 0.6))),
                            if (_emailMode) ...[
                              const SizedBox(height: 24),
                              _fieldLabel('Email'),
                              const SizedBox(height: 8),
                              _GlassInput(
                                controller: widget.emailController,
                                hint: 'ton@email.com',
                                icon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),
                              _fieldLabel('Mot de passe'),
                              const SizedBox(height: 8),
                              _GlassInput(
                                controller: widget.passwordController,
                                hint: '8 caractères minimum',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscure,
                                suffix: GestureDetector(
                                  onTap: () => setState(() => _obscure = !_obscure),
                                  child: Icon(
                                    _obscure ? Icons.visibility_off_outlined
                                             : Icons.visibility_outlined,
                                    size: 18, color: kTextMuted,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ],
                            const SizedBox(height: 32),
                            _buildDivider(),
                            const SizedBox(height: 24),
                            _buildSocialButtons(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // CTA
            FadeTransition(opacity: _ctaFade,
              child: CtaButton(
                label: 'Continuer',
                onPressed: canContinue ? widget.onNext : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(text,
    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
        color: kTextMuted, letterSpacing: 0.2));

  Widget _buildDivider() => Row(children: [
    Expanded(child: Container(height: 0.5, color: kGlassBorder)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('ou continuer avec',
          style: GoogleFonts.inter(fontSize: 12.5, color: kTextMuted,
              fontWeight: FontWeight.w400)),
    ),
    Expanded(child: Container(height: 0.5, color: kGlassBorder)),
  ]);

  Widget _buildSocialButtons() => Column(children: [
    _SocialButton(
      label: 'Continuer avec Email',
      icon: Icons.mail_outline_rounded,
      iconColor: kGreenBright,
      filled: true,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _emailMode = true);
      },
    ),
    const SizedBox(height: 10),
    _SocialButton(
      label: 'Continuer avec Google',
      customIcon: SizedBox(width: 18, height: 18,
          child: CustomPaint(painter: GoogleGPainter())),
      onTap: _showComingSoon,
    ),
    const SizedBox(height: 10),
    _SocialButton(
      label: 'Continuer avec Apple',
      icon: Icons.apple_rounded,
      iconColor: kTextDark,
      onTap: _showComingSoon,
    ),
  ]);
}

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final Color iconColor;
  final bool filled;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    this.icon,
    this.customIcon,
    this.iconColor = kTextDark,
    this.filled = false,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
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
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: widget.filled
                ? kGreenDark.withValues(alpha: 0.4)
                : kGlassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.filled
                  ? kGreenBright.withValues(alpha: 0.3)
                  : kGlassBorder,
              width: 0.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            widget.customIcon ?? Icon(widget.icon,
                color: widget.iconColor, size: 20),
            const SizedBox(width: 10),
            Text(widget.label, style: GoogleFonts.inter(fontSize: 15,
                fontWeight: FontWeight.w600,
                color: widget.filled ? kGreenBright : kTextDark)),
          ]),
        ),
      ),
    );
  }
}

class _GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final ValueChanged<String> onChanged;

  const _GlassInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    required this.onChanged,
  });

  @override
  State<_GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<_GlassInput> {
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _focused
            ? const LinearGradient(
                colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              )
            : null,
        color: _focused ? null : kGlassBorder,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1A14),
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: GoogleFonts.inter(fontSize: 15,
              fontWeight: FontWeight.w500, color: kTextDark),
          cursorColor: kGreenBright,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.inter(color: kTextMuted,
                fontWeight: FontWeight.w400, fontSize: 14.5),
            prefixIcon: Icon(widget.icon, size: 19,
              color: _focused ? kGreenBright : kTextMuted),
            suffixIcon: widget.suffix != null
                ? Padding(padding: const EdgeInsets.only(right: 12),
                    child: widget.suffix)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 4),
          ),
        ),
      ),
    );
  }
}
