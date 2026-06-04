import 'package:flutter/material.dart';
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF1C4D30)
                      : const Color(0xFFF4F4F2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 13,
                      color: selected
                          ? const Color(0xFF7ABB98)
                          : const Color(0xFF757575),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : const Color(0xFF757575),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}