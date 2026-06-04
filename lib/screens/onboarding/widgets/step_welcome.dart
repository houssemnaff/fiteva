import 'package:flutter/material.dart';
import 'shared_onboarding_widgets.dart';

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

  bool get canContinue {
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
    child: CustomPaint(painter: GoogleGPainter()),
  );

  Widget _buildCTA() {
    final enabled = canContinue;
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
