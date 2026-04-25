import 'dart:ui';
import 'package:fiteva/screens/cycle/homecyle.dart';
import 'package:fiteva/widgets/chatbot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'home/home_screen.dart';
import 'workout/workout_screen.dart';
import 'nutrition/nutrition_screen.dart';
import 'community/community_screen.dart';

// ── Nav items data ────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(LucideIcons.home, 'Home'),
  _NavItem(LucideIcons.loader, 'Cycle'),
  _NavItem(LucideIcons.dumbbell, 'Workouts'),
  _NavItem(LucideIcons.apple, 'Nutrition'),
  _NavItem(LucideIcons.users, 'social'),
];

// ── Main Layout ───────────────────────────────────────────────────────
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
    const WorkoutScreen(),
    const NutritionHomeScreen(),
    const CommunityScreen(),
  ];

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    const buttonSize = 56.0;
    const bottomNavHeight = 90.0;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],

          ///  Draggable Chatbot Button tt
          Positioned(
            left: _x,
            top: _y,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _x = (_x + details.delta.dx).clamp(
                    0,
                    screenSize.width - buttonSize,
                  );
                  _y = (_y + details.delta.dy).clamp(
                    padding.top,
                    screenSize.height - buttonSize - bottomNavHeight,
                  );
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _x = _x < screenSize.width / 2
                      ? 0
                      : screenSize.width - buttonSize;
                });
              },
              child: FloatingActionButton(
                onPressed: _openChatbot,
                heroTag: 'ai_chatbot',
                backgroundColor: Colors.transparent,
                elevation: 4,
                child: Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF5CD57A), Color(0xFF1C4D30)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      /// 📌 Glass Bottom Navigation
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ── Glass NavBar ──────────────────────────────────────────────────────
class _GlassNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  @override
  State<_GlassNavBar> createState() => _GlassNavBarState();
}

class _GlassNavBarState extends State<_GlassNavBar> {
  late double _pillIndex;
  bool _isDragging = false;
  int _lastHapticIndex = -1;

  // Flex values — selected item gets more space, others shrink
  static const double _selectedFlex = 3.0;
  static const double _unselectedFlex = 1.0;

  static const double _pillH = 44.0;

  @override
  void initState() {
    super.initState();
    _pillIndex = widget.currentIndex.toDouble();
  }

  @override
  void didUpdateWidget(_GlassNavBar old) {
    super.didUpdateWidget(old);
    if (!_isDragging) _pillIndex = widget.currentIndex.toDouble();
  }

  double _toIndex(double dx, double totalWidth) =>
      (dx / (totalWidth / _navItems.length))
          .clamp(0.0, _navItems.length - 1.0);

  void _onPanStart(DragStartDetails d, double w) {
    setState(() {
      _isDragging = true;
      _pillIndex = _toIndex(d.localPosition.dx, w);
    });
    _haptic(_pillIndex.round());
  }

  void _onPanUpdate(DragUpdateDetails d, double w) {
    final idx = _toIndex(d.localPosition.dx, w);
    setState(() => _pillIndex = idx);
    final rounded = idx.round();
    _haptic(rounded);
    if (rounded != widget.currentIndex) widget.onTap(rounded);
  }

  void _onPanEnd(DragEndDetails _) {
    final snapped = _pillIndex.round();
    setState(() {
      _isDragging = false;
      _pillIndex = snapped.toDouble();
    });
    widget.onTap(snapped);
    _lastHapticIndex = -1;
  }

  void _haptic(int i) {
    if (i != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = i;
    }
  }

  /// Total flex units across all items
  double get _totalFlex =>
      _selectedFlex + _unselectedFlex * (_navItems.length - 1);

  /// Flex for a given index
  double _flexFor(int index) =>
      index == widget.currentIndex ? _selectedFlex : _unselectedFlex;

  /// Pixel width for a given index based on totalWidth
  double _widthFor(int index, double totalWidth) =>
      totalWidth * _flexFor(index) / _totalFlex;

  /// Left offset of the pill — sum of widths of items before the selected one
  double _pillLeft(double totalWidth) {
    double left = 0;
    for (int i = 0; i < _navItems.length; i++) {
      if (i == widget.currentIndex) break;
      left += _widthFor(i, totalWidth);
    }
    final selectedWidth = _widthFor(widget.currentIndex, totalWidth);
    // Center pill inside the selected slot
    return left + (selectedWidth - _pillWidth(totalWidth)) / 2;
  }

  /// Pill width = selected slot width minus horizontal padding
  double _pillWidth(double totalWidth) {
    final slotWidth = _widthFor(widget.currentIndex, totalWidth);
    return (_isDragging ? slotWidth - 8 : slotWidth - 12).clamp(60.0, 300.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              //color: const Color.fromARGB(255, 8, 8, 8).withOpacity(0.12),
                            color: const Color.fromARGB(255, 31, 29, 29).withOpacity(0.5),

              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color.fromARGB(255, 97, 94, 94).withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) => _onPanStart(d, totalWidth),
                  onPanUpdate: (d) => _onPanUpdate(d, totalWidth),
                  onPanEnd: _onPanEnd,
                  onTapUp: (d) {
                    final i =
                        _toIndex(d.localPosition.dx, totalWidth).round();
                    setState(() => _pillIndex = i.toDouble());
                    widget.onTap(i);
                  },
                  child: Stack(
                    children: [
                      /// 💊 Sliding pill — animates to selected slot
                      AnimatedPositioned(
                        duration: _isDragging
                            ? Duration.zero
                            : const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: _pillLeft(totalWidth),
                        top: (68 - _pillH) / 2,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _pillWidth(totalWidth),
                          height: _pillH,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              _isDragging ? 0.22 : 0.20,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      /// 🗂 Nav items — widths animate via AnimatedContainer
                      Row(
                        children: List.generate(
                          _navItems.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: _widthFor(i, totalWidth),
                            child: _NavBarItem(
                              item: _navItems[i],
                              isSelected: i == widget.currentIndex,
                              onTap: () {
                                setState(() => _pillIndex = i.toDouble());
                                widget.onTap(i);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual nav item ───────────────────────────────────────────────
class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🔄 Icon with fade + scale
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    item.icon,
                    key: ValueKey(isSelected),
                    size: 20,
                    color: isSelected
                        ? const Color.fromARGB(255, 251, 250, 250)
                        : const Color.fromARGB(255, 255, 255, 255)
                            .withOpacity(0.45),
                  ),
                ),

                /// 📝 Label — visible only when selected
                /// AnimatedSize handles the width expansion smoothly
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 72),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 252, 252, 252),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        )
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