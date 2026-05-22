import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
    (icon: LucideIcons.users, label: 'Partenaire'),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface.withOpacity(0.95),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final tab = _tabs[i];
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 15,
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
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