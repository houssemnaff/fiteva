import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CommunityTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const CommunityTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _tabs = [
    (icon: LucideIcons.layoutList, label: 'Feed'),
    (icon: LucideIcons.calendarDays, label: 'Événements'),
    (icon: LucideIcons.users, label: 'Partenaires'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTap(i);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 14,
                              color: selected
                                  ? cs.onSurface
                                  : cs.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tab.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected
                                    ? cs.onSurface
                                    : cs.onSurface.withValues(alpha: 0.35),
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          // Animated underline indicator
          LayoutBuilder(builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / _tabs.length;
            return Stack(
              children: [
                // Full-width baseline
                Container(
                  height: 1.5,
                  color: cs.onSurface.withValues(alpha: 0.06),
                ),
                // Active indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: selectedIndex * tabWidth + tabWidth * 0.2,
                  child: Container(
                    width: tabWidth * 0.6,
                    height: 2,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
