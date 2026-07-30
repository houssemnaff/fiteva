import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/stripe_config.dart';
import '../../providers/subscription_provider.dart';

const _slides = [
  'assets/images/slide_gym1.jpg',
  'assets/images/slide_gym2.jpg',
  'assets/images/slide_gym3.jpg',
  'assets/images/slide_gym4.jpg',
];

const _accent = Color(0xFF5CD57A);

class _Feature {
  final String label;
  final bool free;
  final bool pro;
  const _Feature(this.label, {this.free = false, this.pro = true});
}

const _features = [
  _Feature('Suivi des workouts', free: true),
  _Feature('Suivi nutrition de base', free: true),
  _Feature('Communauté', free: true),
  _Feature('Scanner repas & recettes'),
  _Feature('Suivi cycle & santé'),
  _Feature('Statistiques avancées'),
];

class PaywallScreen extends ConsumerStatefulWidget {
  final bool showSkip;
  const PaywallScreen({super.key, this.showSkip = true});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlan = 0;
  int _currentSlide = 0;
  Timer? _slideTimer;
  SubscriptionPlan? _processing;

  @override
  void initState() {
    super.initState();
    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _currentSlide = (_currentSlide + 1) % _slides.length);
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final plan = _selectedPlan == 0
        ? SubscriptionPlan.proAnnual
        : SubscriptionPlan.proMonthly;

    setState(() => _processing = plan);
    final result = await StripeService.subscribe(plan);
    ref.invalidate(subscriptionProvider);
    if (!mounted) return;
    setState(() => _processing = null);

    if (result.success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bienvenue dans FITEVA Pro !')));
    } else if (!result.canceledByUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Le paiement a échoué.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Sliding background (top portion) ──────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1200),
              child: Image.asset(
                _slides[_currentSlide],
                key: ValueKey(_currentSlide),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),

          // ── Gradient over photo ───────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.38,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Color(0x00000000),
                    Color(0x40000000),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable content ────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Headline ──────────────────────────────
                      Text.rich(
                        TextSpan(children: [
                          const TextSpan(text: 'Progresse '),
                          TextSpan(
                            text: '2x',
                            style: TextStyle(color: _accent)),
                          const TextSpan(text: ' plus vite\navec '),
                          TextSpan(
                            text: 'Pro',
                            style: TextStyle(
                              color: _accent,
                              fontStyle: FontStyle.italic)),
                          const TextSpan(text: ' !'),
                        ]),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Comparison table ──────────────────────
                      _buildComparisonTable(),
                      const SizedBox(height: 28),

                      // ── Plans ─────────────────────────────────
                      _GlassPlanCard(
                        selected: _selectedPlan == 0,
                        badge: 'MEILLEURE OFFRE  -33%',
                        title: 'Annuel',
                        price: '79,99€',
                        period: '/an',
                        subtitle: '6,67€/mois · au lieu de 119,88€',
                        onTap: () => setState(() => _selectedPlan = 0),
                      ),
                      const SizedBox(height: 10),
                      _GlassPlanCard(
                        selected: _selectedPlan == 1,
                        badge: null,
                        title: '1 mois',
                        price: '9,99€',
                        period: '/mois',
                        subtitle: 'Sans engagement',
                        onTap: () => setState(() => _selectedPlan = 1),
                      ),

                      const SizedBox(height: 24),

                      // ── CTA ───────────────────────────────────
                      GestureDetector(
                        onTap: _processing != null ? null : _subscribe,
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Center(
                            child: _processing != null
                                ? const SizedBox(
                                    width: 22, height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white))
                                : const Text('S\'abonner',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Footer ────────────────────────────────
                      GestureDetector(
                        onTap: () {
                          ref.invalidate(subscriptionProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vérification en cours…')));
                        },
                        child: Text('Restaurer mes achats',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.5),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.3))),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paiement sécurisé · Annulable à tout moment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.3),
                          letterSpacing: -0.1)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Skip ──────────────────────────────────────────────
          if (widget.showSkip)
            Positioned(
              top: top + 12,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  child: Icon(Icons.close_rounded,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 56,
                  child: Text('Free',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.45))),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('PRO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _accent,
                      letterSpacing: 1.5)),
                ),
              ],
            ),
          ),

          // Feature rows
          ...List.generate(_features.length, (i) {
            final f = _features[i];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(f.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: -0.2)),
                  ),
                  SizedBox(
                    width: 56,
                    child: Center(
                      child: f.free
                          ? Icon(Icons.check_rounded,
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.4))
                          : Icon(Icons.remove_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SizedBox(
                    width: 56,
                    child: Center(
                      child: Icon(Icons.check_rounded,
                        size: 20, color: _accent),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Plan card ───────────────────────────────────────────────────────────────

class _GlassPlanCard extends StatelessWidget {
  final bool selected;
  final String? badge;
  final String title;
  final String price;
  final String period;
  final String subtitle;
  final VoidCallback onTap;

  const _GlassPlanCard({
    required this.selected,
    this.badge,
    required this.title,
    required this.price,
    required this.period,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: selected ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? const Color(0xFF5CD57A)
                    : Colors.white.withValues(alpha: 0.15),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF5CD57A)
                          : Colors.white.withValues(alpha: 0.4),
                      width: 2),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 12, height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF5CD57A),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.5),
                          letterSpacing: -0.1)),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(price,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5)),
                    Text(period,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                        letterSpacing: -0.2)),
                  ],
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5CD57A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(badge!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3)),
              ),
            ),
        ],
      ),
    );
  }
}
