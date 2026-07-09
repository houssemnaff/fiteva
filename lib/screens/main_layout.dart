// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';
import 'package:fiteva/screens/sante/sante_screen.dart';
import 'package:fiteva/screens/shop/screens/boutique_screen.dart';
import 'package:fiteva/widgets/chatbot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';
import '../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NAV CONFIG
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Secondary 3 screens revealed by "+" (indices 4–6)
class _SecondaryItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _SecondaryItem(this.icon, this.label, this.color, this.bg);
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with SingleTickerProviderStateMixin {

  int  _currentIndex = 0;
  bool _plusOpen     = false;
  double _x = -1; // -1 = not yet initialized
  double _y = -1;

  late final AnimationController _plusAnim;
  late final Animation<double>   _plusScale;
  late final PageController      _pageController;

  // ── Dynamic tab 1 based on health status ──────────────────────────────────
  Widget _tab1Screen(UserProfile profile) {
    if (profile.healthStatus == 'pregnant') {
      return const PregnancyHubScreen();
    }
    if (profile.healthStatus == 'postpartum') {
      // Vraie date sauvegardée en priorité — fallback sur l'estimation par
      // bucket ppDuration uniquement pour les profils créés avant ce fix.
      final birthDate = profile.ppBirthDate ??
          DateTime.now().subtract(Duration(days: _ppWeeksAgo(profile.ppDuration) * 7));
      return PostpartumHubScreen(birthDate: birthDate);
    }
    return const CycleScreen();
  }

  static int _ppWeeksAgo(String? ppDuration) {
    switch (ppDuration) {
      case '0-2':  return 1;
      case '2-6':  return 4;
      case '6-12': return 9;
      case '3-6m': return 18;
      case '6m+':  return 30;
      default:     return 4;
    }
  }

  _NavItem _tab1NavItem(String? healthStatus, AppL10n l10n) {
    if (healthStatus == 'pregnant')  return _NavItem(Icons.child_friendly_rounded, l10n.navPregnancy);
    if (healthStatus == 'postpartum') return _NavItem(Icons.favorite_rounded, l10n.navPostpartum);
    return _NavItem(LucideIcons.loader, l10n.navCycle);
  }

  @override
  void initState() {
    super.initState();
    _plusAnim      = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _plusScale     = CurvedAnimation(parent: _plusAnim, curve: Curves.easeOutCubic);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _plusAnim.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _togglePlus() {
    HapticFeedback.mediumImpact();
    setState(() => _plusOpen = !_plusOpen);
    _plusOpen ? _plusAnim.forward() : _plusAnim.reverse();
  }

  void _closePlus() {
    if (_plusOpen) {
      setState(() => _plusOpen = false);
      _plusAnim.reverse();
    }
  }

  void _selectMain(int i) {
    _closePlus();
    setState(() => _currentIndex = i);
    if (i < 4) {
      _pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _selectSecondary(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = i + 4;
      _plusOpen = false;
    });
    _plusAnim.reverse();
  }

  void _openChatbot() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChatbotSheet());

  bool get _isSecondary => _currentIndex >= 4;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final l10n    = ref.watch(l10nProvider);
    final chatbotVisible = ref.watch(chatbotVisibilityProvider);
    final size    = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const btnSize = 85.0;
    const navH    = 90.0;

    final List<_SecondaryItem> secondaryItemsL10n = [
      _SecondaryItem(LucideIcons.shoppingBag, l10n.navShop,
          const Color(0xFFB8860B), const Color(0xFFFFF8E7)),
      _SecondaryItem(LucideIcons.users, l10n.navCommunity,
          const Color(0xFF1C4D30), const Color(0xFFEAF3EC)),
      _SecondaryItem(LucideIcons.activity, l10n.navHealth,
          const Color(0xFF9B3E6A), const Color(0xFFFCEEF5)),
    ];

    final List<Widget> secondaryScreens = [
      const BoutiqueScreen(),
      const CommunityScreen(),
      const SanteScreen(),
    ];

    final List<_NavItem> mainNavItems = [
      _NavItem(LucideIcons.home, l10n.navHome),
      _tab1NavItem(profile.healthStatus, l10n),
      _NavItem(LucideIcons.dumbbell, l10n.navWorkout),
      _NavItem(LucideIcons.apple, l10n.navNutrition),
    ];

    final List<Widget> mainScreens = [
      const HomeScreen(),
      _tab1Screen(profile),
      const WorkoutScreen(),
      const NutritionHomeScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ── Swipeable main tabs (0-3) ──────────────────────────
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              _closePlus();
              setState(() => _currentIndex = i);
            },
            children: mainScreens,
          ),

          // ── Secondary screen overlay (boutique, community, santé) ─
          if (_isSecondary)
            secondaryScreens[_currentIndex - 4],

          // ── Secondary menu — ALWAYS in tree, never removed ─────
          // (removing BackdropFilter mid-animation causes mouse_tracker crash)
          _SecondaryMenu(
            animation: _plusScale,
            onCloseTap: _closePlus,
            items: secondaryItemsL10n,
            activeIndex: _isSecondary ? _currentIndex - 4 : -1,
            onTap: _selectSecondary,
            bottomPadding: padding.bottom + navH + 8,
          ),

          // ── Draggable AI chatbot ───────────────────────────────
          if (chatbotVisible)
            Builder(builder: (ctx) {
              if (_x < 0) {
                _x = size.width - btnSize;
                _y = size.height * 0.55;
              }
              return Positioned(
                left: _x, top: _y,
                child: GestureDetector(
                  onPanUpdate: (d) => setState(() {
                    _x = (_x + d.delta.dx).clamp(0, size.width - btnSize);
                    _y = (_y + d.delta.dy).clamp(padding.top, size.height - btnSize - navH);
                  }),
                  onPanEnd: (_) => setState(() {
                    _x = _x < size.width / 2 ? 0 : size.width - btnSize;
                  }),
                  child: GestureDetector(
                    onTap: _openChatbot,
                    child: const _AiChatButton())),
              );
            }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _PlusFloatingButton(
        open: _plusOpen,
        animation: _plusScale,
        onTap: _togglePlus,
      ),
      bottomNavigationBar: _LiquidGlassNavBar(
        currentIndex: _currentIndex,
        isSecondary: _isSecondary,
        navItems: mainNavItems,
        onTap: _selectMain,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECONDARY MENU — dark overlay, iOS action-sheet style
//  Always stays in the widget tree; uses IgnorePointer + FadeTransition
//  so the render object is never added/removed (fixes mouse_tracker crash).
// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryMenu extends StatelessWidget {
  final Animation<double> animation;
  final VoidCallback onCloseTap;
  final List<_SecondaryItem> items;
  final int activeIndex;
  final ValueChanged<int> onTap;
  final double bottomPadding;

  const _SecondaryMenu({
    required this.animation,
    required this.onCloseTap,
    required this.items,
    required this.activeIndex,
    required this.onTap,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) {
        final v = animation.value;
        return IgnorePointer(
          ignoring: v < 0.01,
          child: Stack(
            children: [
              // ── Blurred dark backdrop ───────────────────────────────
              Positioned.fill(
                child: GestureDetector(
                  onTap: onCloseTap,
                  behavior: HitTestBehavior.opaque,
                  child: Opacity(
                    opacity: v * 0.55,
                    child: const ColoredBox(color: Color(0xFF060810)),
                  ),
                ),
              ),

              // ── Cards panel ─────────────────────────────────────────
              Positioned(
                bottom: bottomPadding,
                left: 20, right: 20,
                child: Transform.translate(
                  offset: Offset(0, (1 - v) * 40),
                  child: Opacity(
                    opacity: v.clamp(0.0, 1.0),
                    child: Row(
                      children: items.asMap().entries.map((e) {
                        final i    = e.key;
                        final item = e.value;
                        final sel  = activeIndex == i;

                        // stagger each card slightly
                        final staggered = CurvedAnimation(
                          parent: animation,
                          curve: Interval(i * 0.08, 1.0,
                              curve: Curves.easeOutCubic),
                        );

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 6,
                              right: i == items.length - 1 ? 0 : 6,
                            ),
                            child: Transform.translate(
                              offset: Offset(0, (1 - staggered.value) * 20),
                              child: Opacity(
                                opacity: staggered.value.clamp(0.0, 1.0),
                                child: GestureDetector(
                                  onTap: () => onTap(i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: sel
                                          ? item.color.withOpacity(0.90)
                                          : Colors.white.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: sel
                                            ? item.color
                                            : Colors.white.withOpacity(0.16),
                                        width: 1.2,
                                      ),
                                      boxShadow: sel
                                          ? [BoxShadow(
                                              color: item.color.withOpacity(0.35),
                                              blurRadius: 20,
                                              offset: const Offset(0, 6))]
                                          : [BoxShadow(
                                              color: Colors.black.withOpacity(0.20),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4))],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: sel
                                                ? Colors.white.withOpacity(0.20)
                                                : Colors.white.withOpacity(0.12),
                                          ),
                                          child: Icon(item.icon,
                                            size: 20,
                                            color: Colors.white),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          item.label,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: sel
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
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
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  FLOATING PLUS BUTTON — centred above nav bar via floatingActionButton
// ─────────────────────────────────────────────────────────────────────────────

class _PlusFloatingButton extends StatelessWidget {
  final bool open;
  final Animation<double> animation;
  final VoidCallback onTap;

  const _PlusFloatingButton({
    required this.open,
    required this.animation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Transform.scale(
          scale: 1.0 + animation.value * 0.08,
          child: Container(
            width: 58, height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: open
                    ? [const Color(0xFF3A6B4A), const Color(0xFF1C4D30)]
                    : [const Color(0xFF5CD57A), const Color(0xFF2D8A50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D8A50).withOpacity(0.55),
                  blurRadius: 22, offset: const Offset(0, 8)),
              ],
            ),
            child: AnimatedRotation(
              turns: open ? 0.125 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CLASSY NAV BAR — 4 tabs, floating pill, adaptive dark/light
// ─────────────────────────────────────────────────────────────────────────────

class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isSecondary;
  final List<_NavItem> navItems;
  final ValueChanged<int> onTap;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.isSecondary,
    required this.navItems,
    required this.onTap,
  });

  static const _barH = 70.0;
  static const _r    = 28.0;

  @override
  Widget build(BuildContext context) {
    final bottom  = MediaQuery.of(context).padding.bottom;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    // Pill colours — adaptive
    final pillBg     = isDark
        ? const Color(0xFF12151A)
        : Colors.white;
    final pillBorder = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
    final unselectedColor = isDark
        ? Colors.white.withOpacity(0.38)
        : Colors.black.withOpacity(0.32);
    final accent = const Color(0xFF3DA85A);

    return Container(
      decoration: BoxDecoration(
        color: pillBg,
        border: Border(top: BorderSide(color: pillBorder, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
            blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottom),
      child: Stack(children: [

        // ── Full-width bar ───────────────────────────────────────────────
        Container(height: _barH, color: Colors.transparent),

        // ── Nav items ────────────────────────────────────────────────────
        SizedBox(
          height: _barH,
          child: Row(
            children: List.generate(navItems.length, (i) {
              // leave gap in the middle for the floating + button
              final isSelected = !isSecondary && i == currentIndex;
              final item       = navItems[i];

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Selected dot indicator above icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          width:  isSelected ? 20 : 0,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          decoration: isSelected ? BoxDecoration(
                            color: accent.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(14),
                          ) : null,
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: isSelected ? accent : unselectedColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Label — bigger, classier
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            height: 1.0,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? accent : unselectedColor,
                            letterSpacing: -0.2,
                          ),
                          child: Text(item.label, maxLines: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ]),
    );
  }
}

// ── AI Chat Button ────────────────────────────────────────────────────────────

// ── Waving Robot ──────────────────────────────────────────────────────────────

class _WavingRobot extends StatefulWidget {
  const _WavingRobot();
  @override
  State<_WavingRobot> createState() => _WavingRobotState();
}

class _WavingRobotState extends State<_WavingRobot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(56, 56),
        painter: _StarCirclePainter(t: _ctrl.value),
      ),
    );
  }
}

class _StarCirclePainter extends CustomPainter {
  final double t;
  const _StarCirclePainter({required this.t});

  void _drawStar(Canvas canvas, Offset center, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? r : r * 0.45;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Shadow
    canvas.drawCircle(
      Offset(cx, cy + 2),
      26,
      Paint()..color = const Color(0xFF1C4D30).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main green circle gradient
    final gradient = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF4ADE80), const Color(0xFF16A34A)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 26));
    canvas.drawCircle(Offset(cx, cy), 26, gradient);

    // Sparkle stars orbiting
    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    final starPositions = [
      (0.0, 18.0),
      (2.0 / 3.0, 20.0),
      (1.0 / 3.0, 15.0),
    ];
    for (final (phase, dist) in starPositions) {
      final angle = (t + phase) * 2 * math.pi;
      final sx = cx + dist * math.cos(angle);
      final sy = cy + dist * math.sin(angle);
      _drawStar(canvas, Offset(sx, sy), 4.5, starPaint);
    }

    // Center sparkle ✦
    final centerStar = Paint()..color = Colors.white;
    _drawStar(canvas, Offset(cx, cy), 9, centerStar);

    // Shimmer dot top-left
    canvas.drawCircle(
      Offset(cx - 8, cy - 10),
      2.5,
      Paint()..color = Colors.white.withOpacity(0.6 + 0.4 * math.sin(t * 2 * math.pi)),
    );
  }

  @override
  bool shouldRepaint(_StarCirclePainter old) => old.t != t;
}

class _AiChatButton extends StatelessWidget {
  const _AiChatButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 85, height: 85, child: _WavingRobot()),
    ]);
  }
}


