import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

const _mascotUrl =
    'https://res.cloudinary.com/dmzvbqocs/image/upload/v1785371674/preview-removebg-preview_i39b7w.png';
const _accent = Color(0xFF5CD57A);

class GuidedTourStep {
  final int tabIndex;
  final String title;
  final String description;
  final IconData icon;

  const GuidedTourStep({
    required this.tabIndex,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class AppTourService {
  static const _key = 'guided_tour_completed';

  static Future<bool> shouldShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markTourDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class GuidedTourOverlay extends StatefulWidget {
  final List<GuidedTourStep> steps;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onFinish;

  const GuidedTourOverlay({
    super.key,
    required this.steps,
    required this.onNavigateToTab,
    required this.onFinish,
  });

  @override
  State<GuidedTourOverlay> createState() => _GuidedTourOverlayState();
}

class _GuidedTourOverlayState extends State<GuidedTourOverlay>
    with SingleTickerProviderStateMixin {
  int _current = 0;
  late AnimationController _anim;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _next() async {
    if (_current >= widget.steps.length - 1) {
      await AppTourService.markTourDone();
      widget.onFinish();
      return;
    }

    await _anim.reverse();
    setState(() => _current++);
    widget.onNavigateToTab(widget.steps[_current].tabIndex);
    await Future.delayed(const Duration(milliseconds: 350));
    _anim.forward();
  }

  void _skip() async {
    await AppTourService.markTourDone();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_current];
    final bottom = MediaQuery.of(context).padding.bottom;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark overlay
          GestureDetector(
            onTap: () {},
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),

          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: bottom + 100,
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mascot — full character, no circle crop
                    CachedNetworkImage(
                      imageUrl: _mascotUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        width: 120, height: 120,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 80, height: 80,
                        decoration: const BoxDecoration(
                          color: _accent, shape: BoxShape.circle,
                        ),
                        child: const Center(
                            child: Text('💪', style: TextStyle(fontSize: 32))),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Step indicator dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.steps.length,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _current ? 22 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == _current
                                      ? _accent
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(step.icon, color: _accent, size: 26),
                          ),
                          const SizedBox(height: 16),

                          // Title
                          Text(
                            step.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Description
                          Text(
                            step.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // CTA
                          GestureDetector(
                            onTap: _next,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  _current == widget.steps.length - 1
                                      ? 'C\'est parti !'
                                      : 'Suivant',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Skip
                          GestureDetector(
                            onTap: _skip,
                            child: Text(
                              'Passer le guide',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
