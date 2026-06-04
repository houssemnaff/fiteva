import 'dart:ui';
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/screens/shop/screens/boutique_screen.dart';
import 'package:fiteva/widgets/chatbot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'community/community_screen.dart';

// ── Nav items ─────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(LucideIcons.home,        'Home'),
  _NavItem(LucideIcons.loader,      'Cycle'),
  _NavItem(LucideIcons.shoppingBag, 'Shop'),
  _NavItem(LucideIcons.dumbbell,    'Workouts'),
  _NavItem(LucideIcons.apple,       'Nutrition'),
  _NavItem(LucideIcons.users,       'Social'),
];

// ── Main Layout ───────────────────────────────────────────────────────────────
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  double _x = 300;
  double _y = 500;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CycleApp(),
    const BoutiqueScreen(),
    const WorkoutScreen(),
    const NutritionHomeScreen(),
    const CommunityScreen(),
  ];

  void _openChatbot() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChatbotSheet());

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

          // Draggable AI chatbot button
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
        onTap: (i) => setState(() => _currentIndex = i)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LIQUID GLASS NAVBAR — iOS 26 style
// ══════════════════════════════════════════════════════════════════════════════

class _LiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _LiquidGlassNavBar({required this.currentIndex, required this.onTap});

  @override
  State<_LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<_LiquidGlassNavBar> {
  bool _isDragging = false;
  int  _lastHaptic = -1;

  static const double _barH        = 64.0;
  static const double _pillH        = 44.0;
  static const double _selectedFlex = 3.0;
  static const double _unselFlex    = 1.0;

  double get _totalFlex =>
      _selectedFlex + _unselFlex * (_navItems.length - 1);

  double _flexFor(int i) =>
      i == widget.currentIndex ? _selectedFlex : _unselFlex;

  double _widthFor(int i, double total) =>
      total * _flexFor(i) / _totalFlex;

  double _pillLeft(double total) {
    double left = 0;
    for (int i = 0; i < _navItems.length; i++) {
      if (i == widget.currentIndex) break;
      left += _widthFor(i, total);
    }
    final slot = _widthFor(widget.currentIndex, total);
    final pill = _pillWidth(total);
    return left + (slot - pill) / 2;
  }

  double _pillWidth(double total) {
    final slot = _widthFor(widget.currentIndex, total);
    return (_isDragging ? slot - 6 : slot - 10).clamp(60.0, 300.0);
  }

  int _indexAt(double dx, double total) =>
      (dx / (total / _navItems.length)).clamp(0, _navItems.length - 1.0).round();

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

            // ── 1. Drop shadow ───────────────────────────────────
            Container(
              height: _barH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 36, offset: const Offset(0, 10),
                    spreadRadius: -6),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10, offset: const Offset(0, 3)),
                ],
              ),
            ),

            // ── 2. Backdrop blur + glass base ────────────────────
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

            // ── 3. Specular top highlight ─────────────────────────
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

            // ── 4. Bottom refraction hint ─────────────────────────
            Positioned(bottom: 0, left: 24, right: 24,
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.25),
                      Colors.transparent,
                    ])))),

            // ── 5. Nav items + sliding liquid pill ────────────────
            LayoutBuilder(
              builder: (ctx, constraints) {
                final total = constraints.maxWidth;
                return GestureDetector(
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

                      // Liquid glass pill
                      AnimatedPositioned(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 340),
                        curve: Curves.easeOutQuart,
                        left: _pillLeft(total),
                        top: (_barH - _pillH) / 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 340),
                          curve: Curves.easeOutQuart,
                          width: _pillWidth(total),
                          height: _pillH,
                          child: _LiquidPill(width: _pillWidth(total), height: _pillH)),
                      ),

                      // Nav items row
                      Row(
                        children: List.generate(_navItems.length, (i) =>
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 340),
                            curve: Curves.easeOutQuart,
                            width: _widthFor(i, total),
                            child: _LiquidNavItem(
                              item: _navItems[i],
                              isSelected: i == widget.currentIndex,
                              onTap: () {
                                _haptic(i);
                                widget.onTap(i);
                              }))),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Liquid glass pill ─────────────────────────────────────────────────────────
class _LiquidPill extends StatelessWidget {
  final double width, height;
  const _LiquidPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Pill body with blur
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

        // Pill inner specular highlight (top edge shimmer)
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

        // Pill soft inner shadow (bottom)
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

// ── Individual nav item ───────────────────────────────────────────────────────
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
        height: 64,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Icon with animated opacity
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child)),
                  child: Icon(
                    item.icon,
                    key: ValueKey(isSelected),
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45)),
                ),

                // Label — animates in when selected
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutQuart,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 70),
                            child: Text(item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2))))
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
