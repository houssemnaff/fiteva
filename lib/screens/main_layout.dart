// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/providers/main_tab_provider.dart';
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/screens/cycle/pregnancy/PregnancyHubScreen.dart';
import 'package:fiteva/screens/cycle/pregnancy/postpartum/postpartum_hub_screen.dart';
import 'package:fiteva/screens/sante/sante_screen.dart';
import 'package:fiteva/screens/shop/screens/boutique_screen.dart';
import 'package:fiteva/widgets/chatbot_sheet.dart';
import 'package:fiteva/widgets/paywall_sheet.dart';
import 'package:fiteva/providers/subscription_provider.dart';
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
import 'walkthrough/app_walkthrough_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../services/app_tour_service.dart';
import 'paywall/paywall_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NAV CONFIG
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.label, {IconData? activeIcon})
      : activeIcon = activeIcon ?? icon;
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

  bool _plusOpen     = false;
  bool _showTour    = false;
  double _x = -1;
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
    if (healthStatus == 'pregnant')  return _NavItem(Icons.child_friendly_outlined, l10n.navPregnancy, activeIcon: Icons.child_friendly_rounded);
    if (healthStatus == 'postpartum') return _NavItem(Icons.favorite_outline_rounded, l10n.navPostpartum, activeIcon: Icons.favorite_rounded);
    return _NavItem(LucideIcons.loader, l10n.navCycle);
  }

  @override
  void initState() {
    super.initState();
    _plusAnim      = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _plusScale     = CurvedAnimation(parent: _plusAnim, curve: Curves.easeOutCubic);
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTour());
  }

  Future<void> _maybeShowTour() async {
    if (!mounted) return;
    final show = await AppTourService.shouldShowTour();
    if (!show || !mounted) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) setState(() => _showTour = false);
    if (mounted) setState(() => _showTour = true);
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
    ref.read(mainTabIndexProvider.notifier).set(i);
  }

  void _selectSecondary(int i) {
    HapticFeedback.selectionClick();
    ref.read(mainTabIndexProvider.notifier).set(i + 4);
    setState(() => _plusOpen = false);
    _plusAnim.reverse();
  }

  void _openChatbot() {
    if (!ref.read(isProProvider)) {
      showPaywallSheet(
        context,
        feature: 'Coach IA',
        description: 'Discute avec ton assistant santé & fitness personnel, disponible 24/7.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatbotSheet());
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainTabIndexProvider);
    final isSecondary = currentIndex >= 4;
    ref.listen<int>(mainTabIndexProvider, (prev, next) {
      if (next < 4 && _pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        );
      }
    });
    final profile = ref.watch(userProfileProvider);
    final l10n    = ref.watch(l10nProvider);
    final chatbotVisible = ref.watch(chatbotVisibilityProvider);
    final size    = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final cs      = Theme.of(context).colorScheme;
    const btnSize = 85.0;
    const navH    = 88.0;

    final List<_SecondaryItem> secondaryItemsL10n = [
      _SecondaryItem(LucideIcons.shoppingBag, l10n.navShop,
          cs.primary, cs.primary.withValues(alpha: 0.08)),
      _SecondaryItem(LucideIcons.users, l10n.navCommunity,
          cs.secondary, cs.secondary.withValues(alpha: 0.08)),
      _SecondaryItem(LucideIcons.activity, l10n.navHealth,
          cs.primary, cs.primary.withValues(alpha: 0.08)),
    ];

    final List<Widget> secondaryScreens = [
      const BoutiqueScreen(),
      const CommunityScreen(),
      const SanteScreen(),
    ];

    final List<_NavItem> mainNavItems = [
      _NavItem(Icons.home_outlined, l10n.navHome, activeIcon: Icons.home_rounded),
      _tab1NavItem(profile.healthStatus, l10n),
      _NavItem(Icons.fitness_center_outlined, l10n.navWorkout, activeIcon: Icons.fitness_center_rounded),
      _NavItem(Icons.restaurant_outlined, l10n.navNutrition, activeIcon: Icons.restaurant_rounded),
    ];

    final List<Widget> mainScreens = [
      const HomeScreen(),
      _tab1Screen(profile),
      const WorkoutScreen(),
      const NutritionHomeScreen(),
    ];

    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'tour_test',
        backgroundColor: const Color(0xFF5CD57A),
        onPressed: () async {
          await AppTourService.resetTour();
          _selectMain(0);
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) setState(() => _showTour = true);
        },
        child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
      ),
      body: Stack(
        children: [
          // ── Swipeable main tabs (0-3) ──────────────────────────
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (i) {
              _closePlus();
              ref.read(mainTabIndexProvider.notifier).set(i);
            },
            children: mainScreens,
          ),

          // ── Secondary screen overlay (boutique, community, santé) ─
          if (isSecondary)
            secondaryScreens[currentIndex - 4],

          // ── Secondary menu — ALWAYS in tree, never removed ─────
          // (removing BackdropFilter mid-animation causes mouse_tracker crash)
          _SecondaryMenu(
            animation: _plusScale,
            onCloseTap: _closePlus,
            items: secondaryItemsL10n,
            activeIndex: isSecondary ? currentIndex - 4 : -1,
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

          // ── Guided tour overlay ───────────────────────────────
          if (_showTour)
            GuidedTourOverlay(
              steps: const [
                GuidedTourStep(
                  tabIndex: 0,
                  title: 'Bienvenue sur FitEva !',
                  description: 'Ton programme personnalisé selon ton cycle, tes objectifs et ton niveau. C\'est ici que tout commence.',
                  icon: Icons.home_rounded,
                ),
                GuidedTourStep(
                  tabIndex: 2,
                  title: 'Tes workouts',
                  description: 'Salle, maison, danse, récupération… explore les catégories et trouve le workout parfait pour toi.',
                  icon: Icons.fitness_center_rounded,
                ),
                GuidedTourStep(
                  tabIndex: 3,
                  title: 'Ta nutrition',
                  description: 'Ajoute tes repas, scanne un produit ou cherche un aliment. Suis tes calories et macros au quotidien.',
                  icon: Icons.restaurant_rounded,
                ),
                GuidedTourStep(
                  tabIndex: -1,
                  title: 'Boutique, Santé & Communauté',
                  description: 'Appuie sur le bouton + en bas pour découvrir la boutique, ton espace santé et la communauté FitEva.',
                  icon: Icons.add_circle_rounded,
                ),
              ],
              onNavigateToTab: (tabIndex) {
                if (tabIndex == -1) {
                  return;
                }
                _selectMain(tabIndex);
              },
              onFinish: () {
                setState(() => _showTour = false);
                _selectMain(0);
                Future.delayed(const Duration(milliseconds: 400), () {
                  if (!mounted) return;
                  final isPro = ref.read(isProProvider);
                  if (!isPro) {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: true,
                        pageBuilder: (_, __, ___) => const PaywallScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  }
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: currentIndex,
        isSecondary: isSecondary,
        navItems: mainNavItems,
        onTap: _selectMain,
        plusOpen: _plusOpen,
        plusAnimation: _plusScale,
        onPlusTap: _togglePlus,
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

// ─────────────────────────────────────────────────────────────────────────────
//  GLASS NAV BAR — floating pill, glassmorphism, sliding indicator,
//  icon morphing, integrated "+" center button
// ─────────────────────────────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isSecondary;
  final List<_NavItem> navItems;
  final ValueChanged<int> onTap;
  final bool plusOpen;
  final Animation<double> plusAnimation;
  final VoidCallback onPlusTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.isSecondary,
    required this.navItems,
    required this.onTap,
    required this.plusOpen,
    required this.plusAnimation,
    required this.onPlusTap,
  });

  static const _barH   = 68.0;
  static const _margin = 16.0;
  static const _radius = 26.0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;

    final glassBg = isDark
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.72);
    final glassBorder = isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.06);
    final unselected = isDark
        ? Colors.white.withOpacity(0.35)
        : Colors.black.withOpacity(0.30);

    // 5 slots: tab0, tab1, plus, tab2, tab3
    final totalSlots = navItems.length + 1; // 4 tabs + 1 plus

    return Padding(
      padding: EdgeInsets.fromLTRB(_margin, 0, _margin, bottom + 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            height: _barH,
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: glassBorder, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.30 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              final slotW = constraints.maxWidth / totalSlots;
              // Sliding indicator position (only for main tabs 0-3)
              // Tabs map: slot 0=tab0, slot 1=tab1, slot 2=plus, slot 3=tab2, slot 4=tab3
              double indicatorLeft;
              if (isSecondary || currentIndex < 0) {
                indicatorLeft = -slotW; // off-screen
              } else {
                final slotIdx = currentIndex < 2 ? currentIndex : currentIndex + 1;
                indicatorLeft = slotIdx * slotW + (slotW - 42) / 2;
              }

              return Stack(children: [
                // ── Sliding pill indicator ─────────────────────────────
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: indicatorLeft,
                  top: 8,
                  child: AnimatedOpacity(
                    opacity: isSecondary ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 42,
                      height: _barH - 16,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),

                // ── Items row ─────────────────────────────────────────
                Row(children: [
                  // First 2 tabs
                  for (int i = 0; i < 2; i++)
                    _buildTab(i, navItems[i], unselected, slotW, accent: accent),

                  // Center "+" button
                  SizedBox(
                    width: slotW,
                    child: Center(child: _buildPlusButton(accent)),
                  ),

                  // Last 2 tabs
                  for (int i = 2; i < navItems.length; i++)
                    _buildTab(i, navItems[i], unselected, slotW, accent: accent),
                ]),
              ]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, _NavItem item, Color unselected, double width, {required Color accent}) {
    final isSelected = !isSecondary && index == currentIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(index);
      },
      child: SizedBox(
        width: width,
        height: _barH,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon — morphs between outlined and filled
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                size: 23,
                color: isSelected ? accent : unselected,
              ),
            ),

            const SizedBox(height: 4),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.inter(
                fontSize: 10.5,
                height: 1.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? accent : unselected,
                letterSpacing: -0.1,
              ),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusButton(Color accent) {
    return GestureDetector(
      onTap: onPlusTap,
      child: AnimatedBuilder(
        animation: plusAnimation,
        builder: (_, __) => Transform.scale(
          scale: 1.0 + plusAnimation.value * 0.06,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: plusOpen
                    ? [Color.lerp(accent, Colors.black, 0.3)!, Color.lerp(accent, Colors.black, 0.5)!]
                    : [accent, Color.lerp(accent, Colors.black, 0.15)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: plusOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
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
      Paint()..color = const Color(0xFF888888).withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Main circle gradient — uses neutral since CustomPainter can't access theme
    final gradient = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFAAAAAA), const Color(0xFF666666)],
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


