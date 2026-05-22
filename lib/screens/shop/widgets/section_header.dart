import 'package:flutter/material.dart';


class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const SectionHeader({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  'Tout voir',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward, color: colorScheme.primary, size: 13),
              ],
            ),
          ),
        ),
      ],
    );
  }
}