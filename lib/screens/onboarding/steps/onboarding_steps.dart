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
            
                        const Text(
                          "J'ai déjà un compte",
                          style: TextStyle(color: Colors.white70),
                        ),
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
class StepWelcome extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final TextEditingController nameController;
  final TextEditingController ageController;
 
  const StepWelcome({
    super.key,
    required this.onNext,
    this.onBack,
    required this.nameController,
    required this.ageController,
  });
 
  @override
  State<StepWelcome> createState() => _StepWelcomeState();
}
  
class _StepWelcomeState extends State<StepWelcome>
    with TickerProviderStateMixin {

  late final AnimationController _entranceCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _orbCtrl;
  late final AnimationController _petalCtrl;
  late final AnimationController _btnPulseCtrl;
 
  // ── Staggered entrance animations ─────────────────────────────────────────
  late final Animation<double> _badgeFade;
  late final Animation<Offset> _badgeSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _avatarFade;
  late final Animation<double> _avatarScale;
  late final Animation<double> _fieldsFade;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<double> _socialFade;
  late final Animation<double> _btnFade;
  late final Animation<Offset> _btnSlide;
 
  // ── Petal particles ────────────────────────────────────────────────────────
  final List<_Petal> _petals = [];
  final Random _rng = Random();
 
  bool get _canContinue =>
      widget.nameController.text.trim().isNotEmpty &&
      widget.ageController.text.trim().isNotEmpty;
 
  String get _initial =>
      widget.nameController.text.trim().isNotEmpty
          ? widget.nameController.text.trim()[0].toUpperCase()
          : 'S';
 
  @override
  void initState() {
    super.initState();
 
    // ── Entrance (2 s total, staggered) ─────────────────────────────────────
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
 
    _badgeFade  = _curve(_entranceCtrl, 0.00, 0.20);
    _badgeSlide = _slideY(_entranceCtrl, 0.00, 0.20);
    _titleFade  = _curve(_entranceCtrl, 0.12, 0.35);
    _titleSlide = _slideY(_entranceCtrl, 0.12, 0.35);
    _avatarFade = _curve(_entranceCtrl, 0.28, 0.55);
    _avatarScale = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.28, 0.60, curve: Curves.elasticOut),
    );
    _fieldsFade  = _curve(_entranceCtrl, 0.48, 0.72);
    _fieldsSlide = _slideY(_entranceCtrl, 0.48, 0.72);
    _socialFade  = _curve(_entranceCtrl, 0.62, 0.82);
    _btnFade     = _curve(_entranceCtrl, 0.72, 0.95);
    _btnSlide    = _slideY(_entranceCtrl, 0.72, 0.95);
 
    // ── Infinite ring rotation ───────────────────────────────────────────────
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
 
    // ── Orb float ────────────────────────────────────────────────────────────
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
 
    // ── Petal loop ───────────────────────────────────────────────────────────
    _petalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _spawnPetals();
 
    // ── Button pulse ─────────────────────────────────────────────────────────
    _btnPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }
 
  // ── Helpers ─────────────────────────────────────────────────────────────────
  Animation<double> _curve(AnimationController c, double s, double e) =>
      CurvedAnimation(parent: c, curve: Interval(s, e, curve: Curves.easeOut));
 
  Animation<Offset> _slideY(AnimationController c, double s, double e) =>
      Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
        CurvedAnimation(parent: c, curve: Interval(s, e, curve: Curves.easeOut)),
      );
 
  void _spawnPetals() {
    for (int i = 0; i < 18; i++) {
      _petals.add(_Petal(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 6,
        duration: 4 + _rng.nextDouble() * 5,
        size: 5 + _rng.nextDouble() * 8,
        angle: _rng.nextDouble() * pi * 2,
        colorIndex: _rng.nextInt(4),
      ));
    }
  }
 
  @override
  void dispose() {
    _entranceCtrl.dispose();
    _ringCtrl.dispose();
    _orbCtrl.dispose();
    _petalCtrl.dispose();
    _btnPulseCtrl.dispose();
    super.dispose();
  }
 
  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 149, 239, 47),
      body: Stack(
        children: [
          // ── Background gradient ─────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                     Color(0xFF1C4D30),
                                    Color(0xFF1C4D30),
                 Color(0xFF1C4D30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
 
          // ── Animated orbs ───────────────────────────────────────────────
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) {
              final t = _orbCtrl.value;
              return Stack(children: [
                Positioned(
                  top: -80 + t * 30,
                  left: -60 + t * 20,
                  child: _orb(280, _kPink.withOpacity(0.18)),
                ),
                Positioned(
                  bottom: 60 + t * 40,
                  right: -70 + t * 15,
                  child: _orb(220, _kPinkLight.withOpacity(0.12)),
                ),
                Positioned(
                  top: 280 + t * 20,
                  left: 10 + t * 10,
                  child: _orb(140, _kPinkPale.withOpacity(0.06)),
                ),
              ]);
            },
          ),
 
          // ── Floating petals ─────────────────────────────────────────────
      
 
          // ── Main content ────────────────────────────────────────────────
          Column(
            children: [
              // TOP BAR
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: widget.onBack ?? () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white70, size: 16),
                        ),
                      ),
                      Row(
                        children: List.generate(7, (i) => _stepDot(i == 0)),
                      ),
                    ],
                  ),
                ),
              ),
 
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
 
                        // ── BADGE ──────────────────────────────────────────
                        FadeTransition(
                          opacity: _badgeFade,
                          child: SlideTransition(
                            position: _badgeSlide,
                            child: _buildBadge(),
                          ),
                        ),
 
                        const SizedBox(height: 16),
 
                        // ── HEADLINE ───────────────────────────────────────
                        FadeTransition(
                          opacity: _titleFade,
                          child: SlideTransition(
                            position: _titleSlide,
                            child: _buildHeadline(),
                          ),
                        ),
 
                        const SizedBox(height: 32),
 
                        // ── AVATAR ─────────────────────────────────────────
                        FadeTransition(
                          opacity: _avatarFade,
                          child: ScaleTransition(
                            scale: _avatarScale,
                            child: _buildAvatar(),
                          ),
                        ),
 
                        const SizedBox(height: 32),
 
                        // ── FIELDS ─────────────────────────────────────────
                        FadeTransition(
                          opacity: _fieldsFade,
                          child: SlideTransition(
                            position: _fieldsSlide,
                            child: Column(children: [
                              _premiumField(
                                controller: widget.nameController,
                                hint: "Ton prénom",
                                icon: Icons.auto_awesome,
                              ),
                              const SizedBox(height: 12),
                              _premiumField(
                                controller: widget.ageController,
                                hint: "Ton âge",
                                isNumber: true,
                                icon: Icons.cake_outlined,
                              ),
                            ]),
                          ),
                        ),
 
                        const SizedBox(height: 24),
 
                        // ── SOCIAL ─────────────────────────────────────────
                        FadeTransition(
                          opacity: _socialFade,
                          child: _buildSocial(),
                        ),
 
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
 
              // ── BUTTON ──────────────────────────────────────────────────
              FadeTransition(
                opacity: _btnFade,
                child: SlideTransition(
                  position: _btnSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                    child: _buildButton(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
 
  // ══════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ══════════════════════════════════════════════════════════════════════════
 
  Widget _orb(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, Colors.transparent]),
        ),
      );
 
  Widget _stepDot(bool active) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(left: 5),
        width: active ? 20 : 6,
        height: 6,
        decoration: BoxDecoration(
          color: active ? _kPinkLight : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(3),
        ),
      );
 
  Widget _buildBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _kPink.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _kPink.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(),
            const SizedBox(width: 7),
            const Text(
              "FITNESS · FÉMININ",
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _kPinkLight,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      );
 
  Widget _buildHeadline() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.05,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: "Ton corps,\nta "),
                TextSpan(
                  text: "force.",
                  style: TextStyle(
                    color: _kPinkLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Conçu par des femmes, pour des femmes.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
        ],
      );
 
  Widget _buildAvatar() => Center(
        child: AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, child) => Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring (slow clockwise)
              Transform.rotate(
                angle: _ringCtrl.value * 2 * pi,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kPinkLight.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Middle ring (medium counter-clockwise)
              Transform.rotate(
                angle: -_ringCtrl.value * 2 * pi * 1.5,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kPink.withOpacity(0.30),
                      width: 1,
                      // dashed via custom paint below
                    ),
                  ),
                ),
              ),
              // Inner ring (fast clockwise)
              Transform.rotate(
                angle: _ringCtrl.value * 2 * pi * 3,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _kPinkLight.withOpacity(0.10),
                      width: 0.8,
                    ),
                  ),
                ),
              ),
              // Avatar core
              child!,
            ],
          ),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kPink, _kPinkDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kPink.withOpacity(0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  _initial,
                  key: ValueKey(_initial),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
 
  Widget _premiumField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kPinkLight.withOpacity(0.12)),
      ),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color.fromARGB(255, 9, 9, 9).withOpacity(0.28), fontWeight: FontWeight.w300),
          prefixIcon: Icon(icon, color: _kPinkLight.withOpacity(0.6), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
 
  Widget _buildSocial() => Column(
        children: [
          Row(children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text("ou continuer avec",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.25),
                      fontSize: 12,
                      fontWeight: FontWeight.w300)),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
          ]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialBtn(Icons.g_mobiledata, "G"),
              const SizedBox(width: 14),
              _socialBtn(Icons.apple, ""),
              const SizedBox(width: 14),
          
            ],
          ),
        ],
      );
 
  Widget _socialBtn(IconData icon, String _) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      );
 
  Widget _buildButton() => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _canContinue ? 1.0 : 0.4,
        child: GestureDetector(
          onTap: _canContinue ? widget.onNext : null,
          child: AnimatedBuilder(
            animation: _btnPulseCtrl,
            builder: (_, child) => Container(
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [_kPink, Color.fromARGB(255, 171, 251, 203)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _canContinue
                    ? [
                        BoxShadow(
                          color: _kPink.withOpacity(
                              0.35 + _btnPulseCtrl.value * 0.15),
                          blurRadius: 20 + _btnPulseCtrl.value * 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Continuer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward,
                      color: Colors.white, size: 14),
                ),
              ],
            ),
          ),
        ),
      );
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
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (_, i) {
                        final item = options[i];
                        final selected = selectedGoals.contains(item.label);

                        return GestureDetector(
                          onTap: () => onToggleGoal(item.label),
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
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  bool get _canContinue =>
      _heightCtrl.text.trim().isNotEmpty &&
      _weightCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // EXACT same base
      body: Column(
        children: [
          _OnboardingTopBar(step: 6, total: 7, onBack: widget.onBack),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepHeader(
                    title: 'Profil santé',
                    subtitle: 'Taille & poids pour personnaliser ton plan',
                  ),

                  const SizedBox(height: 30),

                  // ───── INPUT CARD (same style as StepFrequency card) ─────
                  _inputCard(
                    label: "Taille (cm)",
                    controller: _heightCtrl,
                    hint: "165",
                  ),

                  const SizedBox(height: 14),

                  _inputCard(
                    label: "Poids (kg)",
                    controller: _weightCtrl,
                    hint: "60",
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

  // 💎 SAME CARD STYLE AS FREQUENCY ITEM
  Widget _inputCard({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // SAME
        border: Border.all(color: Colors.grey.shade200), // SAME
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
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: controller,
            onChanged: (_) => setState(() {}),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
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
