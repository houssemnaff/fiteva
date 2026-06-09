// ignore_for_file: deprecated_member_use
import 'dart:ui';
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/screens/sante/sante_screen.dart';
import 'package:fiteva/screens/shop/screens/boutique_screen.dart';
import 'package:fiteva/widgets/chatbot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'community/community_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  NAV CONFIG
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Main 4 tabs (indices 0–3)
const _mainNavItems = [
  _NavItem(LucideIcons.home,     'Accueil'),
  _NavItem(LucideIcons.loader,   'Cycle'),
  _NavItem(LucideIcons.dumbbell, 'Workout'),
  _NavItem(LucideIcons.apple,    'Nutrition'),
];

// Secondary 3 screens revealed by "+" (indices 4–6)
class _SecondaryItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _SecondaryItem(this.icon, this.label, this.color, this.bg);
}

const _secondaryItems = [
  _SecondaryItem(LucideIcons.shoppingBag, 'Boutique',
      Color(0xFFB8860B), Color(0xFFFFF8E7)),
  _SecondaryItem(LucideIcons.users, 'Communauté',
      Color(0xFF1C4D30), Color(0xFFEAF3EC)),
  _SecondaryItem(LucideIcons.heart, 'Santé',
      Color(0xFF9B3E6A), Color(0xFFFCEEF5)),
];

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN LAYOUT
// ─────────────────────────────────────────────────────────────────────────────

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {

  int  _currentIndex = 0;
  bool _plusOpen     = false;
  double _x = 300;
  double _y = 500;

  late final AnimationController _plusAnim;
  late final Animation<double>   _plusScale;

  final List<Widget> _screens = const [
    HomeScreen(),
    CycleApp(),
    WorkoutScreen(),
    NutritionHomeScreen(),
    BoutiqueScreen(),
    CommunityScreen(),
    SanteScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _plusAnim  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _plusScale = CurvedAnimation(parent: _plusAnim, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _plusAnim.dispose();
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
    final size    = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const btnSize = 56.0;
    const navH    = 90.0;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],

          // ── Secondary menu — ALWAYS in tree, never removed ─────
          // (removing BackdropFilter mid-animation causes mouse_tracker crash)
          _SecondaryMenu(
            animation: _plusScale,
            onCloseTap: _closePlus,
            items: _secondaryItems,
            activeIndex: _isSecondary ? _currentIndex - 4 : -1,
            onTap: _selectSecondary,
            bottomPadding: padding.bottom + navH + 8,
          ),

          // ── Draggable AI chatbot ───────────────────────────────
          Positioned(
            left: _x, top: _y,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() {
                _x = (_x + d.delta.dx).clamp(0, size.width - btnSize);
                _y = (_y + d.delta.dy).clamp(padding.top, size.height - btnSize - navH);
              }),
              onPanEnd: (_) => setState(() {
                _x = _x < size.width / 2 ? 0 : size.width - btnSize;
              }),
              child: FloatingActionButton(
                onPressed: _openChatbot,
                heroTag: 'ai_chatbot',
                backgroundColor: Colors.transparent,
                elevation: 4,
                child: Container(
                  width: btnSize, height: btnSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white))),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _LiquidGlassNavBar(
        currentIndex: _currentIndex,
        plusOpen: _plusOpen,
        isSecondary: _isSecondary,
        onTap: _selectMain,
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
        final v = animation.value; // 0 → 1
        return IgnorePointer(
          // Block touches when fully dismissed
          ignoring: v < 0.01,
          child: Stack(
            children: [
              // ── Dark backdrop (no BackdropFilter — avoids crash) ──
              Positioned.fill(
                child: GestureDetector(
                  onTap: onCloseTap,
                  behavior: HitTestBehavior.opaque,
                  child: Opacity(
                    opacity: v * 0.65,
                    child: const ColoredBox(color: Color(0xFF0A0A0A)),
                  ),
                ),
              ),

              // ── Item list ─────────────────────────────────────────
              Positioned(
                bottom: bottomPadding,
                right: 20,
                left: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: items.asMap().entries.map((e) {
                    final i    = e.key;
                    final item = e.value;
                    final sel  = activeIndex == i;

                    // Per-item stagger: slide from bottom + fade
                    final staggered = CurvedAnimation(
                      parent: animation,
                      curve: Interval(
                        i * 0.10, 1.0,
                        curve: Curves.easeOutCubic),
                    );

                    return Transform.translate(
                      offset: Offset(0, (1 - staggered.value) * 24),
                      child: Opacity(
                        opacity: staggered.value.clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: i < items.length - 1 ? 18 : 0),
                          child: GestureDetector(
                            onTap: () => onTap(i),
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Label
                                Text(
                                  item.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: sel
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.85),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Circle icon button
                                Container(
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: sel
                                        ? item.color.withOpacity(0.90)
                                        : Colors.white.withOpacity(0.13),
                                    border: Border.all(
                                      color: sel
                                          ? item.color
                                          : Colors.white.withOpacity(0.22),
                                      width: 1.5),
                                    boxShadow: sel
                                        ? [BoxShadow(
                                            color: item.color.withOpacity(0.40),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4))]
                                        : const [],
                                  ),
                                  child: Icon(item.icon,
                                    size: 22, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
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
//  LIQUID GLASS NAV BAR
// ─────────────────────────────────────────────────────────────────────────────

class _LiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final bool plusOpen;
  final bool isSecondary;
  final ValueChanged<int> onTap;
  final VoidCallback onPlusTap;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.plusOpen,
    required this.isSecondary,
    required this.onTap,
    required this.onPlusTap,
  });

  @override
  State<_LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<_LiquidGlassNavBar> {
  bool _isDragging = false;
  int  _lastHaptic = -1;

  static const double _barH  = 68.0;
  static const double _pillH = 52.0;
  static const double _plusW = 56.0;

  // Effective index for the liquid pill (only 0–3 for main tabs)
  int get _pillIndex =>
      widget.isSecondary ? -1 : widget.currentIndex;

  // Available width for the 4 main items (excluding "+" button + divider)
  double _navWidth(double total) => total - _plusW - 14;

  double _widthFor(int i, double total) =>
      _navWidth(total) / _mainNavItems.length;

  double _pillLeft(double total) {
    if (_pillIndex < 0) return 0;
    final slotW = _navWidth(total) / _mainNavItems.length;
    final pillW = _pillWidth(total);
    return slotW * _pillIndex + (slotW - pillW) / 2;
  }

  double _pillWidth(double total) {
    if (_pillIndex < 0) return 0;
    final slotW = _navWidth(total) / _mainNavItems.length;
    return (slotW - 8).clamp(40.0, 80.0);
  }

  int _indexAt(double dx, double total) {
    final slotW = _navWidth(total) / _mainNavItems.length;
    return (dx / slotW).floor().clamp(0, _mainNavItems.length - 1);
  }

  void _haptic(int i) {
    if (i != _lastHaptic) {
      HapticFeedback.selectionClick();
      _lastHaptic = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottom + 10),
      child: SizedBox(
        height: _barH,
        child: Stack(
          children: [

            // Drop shadow
            Container(
              height: _barH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 32, offset: const Offset(0, 10),
                    spreadRadius: -6),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
            ),

            // Glass base
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  height: _barH,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                      stops: const [0.0, 0.5, 1.0]),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 0.5)),
                ),
              ),
            ),

            // Specular highlight
            Positioned(top: 0, left: 24, right: 24,
              child: Container(
                height: 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.80),
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.80),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.2, 0.5, 0.8, 1.0])))),

            // Nav items + pill + "+" button
            LayoutBuilder(
              builder: (ctx, constraints) {
                final total = constraints.maxWidth;
                return Row(
                  children: [
                    // ── 4 main tabs ────────────────────────────────
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanStart: (d) {
                          final i = _indexAt(d.localPosition.dx, total);
                          setState(() => _isDragging = true);
                          _haptic(i);
                          widget.onTap(i);
                        },
                        onPanUpdate: (d) {
                          final i = _indexAt(d.localPosition.dx, total);
                          _haptic(i);
                          if (i != widget.currentIndex) widget.onTap(i);
                        },
                        onPanEnd: (_) {
                          setState(() => _isDragging = false);
                          _lastHaptic = -1;
                        },
                        onTapUp: (d) {
                          final i = _indexAt(d.localPosition.dx, total);
                          _haptic(i);
                          widget.onTap(i);
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [

                            // Liquid pill (highlight under selected item)
                            if (_pillIndex >= 0)
                              AnimatedPositioned(
                                duration: _isDragging
                                    ? Duration.zero
                                    : const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                left: _pillLeft(total),
                                top: (_barH - _pillH) / 2,
                                child: _LiquidPill(
                                  width: _pillWidth(total),
                                  height: _pillH),
                              ),

                            // Items row
                            Row(
                              children: List.generate(
                                _mainNavItems.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 340),
                                  curve: Curves.easeOutQuart,
                                  width: _widthFor(i, total),
                                  child: _LiquidNavItem(
                                    item: _mainNavItems[i],
                                    isSelected: !widget.isSecondary &&
                                        i == widget.currentIndex,
                                    onTap: () {
                                      _haptic(i);
                                      widget.onTap(i);
                                    }))),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Divider ────────────────────────────────────
                    Container(
                      width: 1, height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: Colors.white.withOpacity(0.25)),

                    // ── "+" button ─────────────────────────────────
                    _PlusButton(
                      open: widget.plusOpen,
                      isSecondary: widget.isSecondary,
                      onTap: widget.onPlusTap,
                    ),
                    const SizedBox(width: 4),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PLUS BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _PlusButton extends StatelessWidget {
  final bool open;
  final bool isSecondary;
  final VoidCallback onTap;
  const _PlusButton({
    required this.open, required this.isSecondary, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = open || isSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56, height: 68,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle button
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                width: 36, height: 28,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: active
                          ? const LinearGradient(
                              colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight)
                          : null,
                      color: active ? null : Colors.white.withOpacity(0.20),
                      border: Border.all(
                        color: active
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.40),
                        width: 1.5),
                      boxShadow: active
                          ? [BoxShadow(
                              color: const Color(0xFF1C4D30).withOpacity(0.35),
                              blurRadius: 10, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      turns: open ? 0.125 : 0,
                      child: Icon(
                        open ? LucideIcons.x : LucideIcons.plus,
                        size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0.1,
                ),
                child: Text(open ? 'Fermer' : 'Plus', maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LIQUID GLASS PILL
// ─────────────────────────────────────────────────────────────────────────────

class _LiquidPill extends StatelessWidget {
  final double width;
  final double height;
  const _LiquidPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: width, height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.58),
                    Colors.white.withValues(alpha: 0.32),
                    Colors.white.withValues(alpha: 0.18),
                  ],
                  stops: const [0.0, 0.5, 1.0]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.50),
                  width: 0.5),
              ),
            ),
          ),
        ),
        Positioned(top: 0, left: 12, right: 12,
          child: Container(
            height: 0.8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 1.0),
                  Colors.white.withValues(alpha: 0.95),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0])))),
        Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            height: height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.04),
                ]),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22))))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INDIVIDUAL NAV ITEM  — icon above label (vertical)
// ─────────────────────────────────────────────────────────────────────────────

class _LiquidNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _LiquidNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 68,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: isSelected ? 38 : 32,
                height: isSelected ? 28 : 24,
                child: Icon(
                  item.icon,
                  size: isSelected ? 22 : 20,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                ),
              ),
              // Label — always visible, just fades
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: 0.1,
                ),
                child: Text(item.label, maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
