import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';


// ── Back Button ───────────────────────────────────────────────────────────────
class BackBtn extends StatelessWidget {
  final VoidCallback onTap;
  const BackBtn({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: const BoxDecoration(color: kBrown, shape: BoxShape.circle),
      child: const Icon(Icons.chevron_left, color: kWhite, size: 22),
    ),
  );
}

// ── Icon Button ───────────────────────────────────────────────────────────────
class AppIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const AppIconBtn({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: kWhite, borderRadius: BorderRadius.circular(13),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, color: kTextDark, size: 20),
    ),
  );
}

// ── Section Header ────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kTextDark)),
      GestureDetector(
        onTap: onSeeAll,
        child: const Text('Tout voir >', style: TextStyle(fontSize: 12, color: kTextGrey)),
      ),
    ],
  );
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class AppSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  const AppSearchBar({super.key, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(color: kBrown, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        Icon(Icons.search, color: Colors.white.withOpacity(0.8), size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('Trouve ta recette',
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, fontWeight: FontWeight.w500))),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.tune, color: kWhite, size: 14),
        ),
      ]),
    ),
  );
}

// ── Pill Badge ────────────────────────────────────────────────────────────────
class Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;
  const Pill({super.key, required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 9, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Tab Item ──────────────────────────────────────────────────────────────────
class AppTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AppTab(this.label, this.active, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.only(bottom: 10),
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: active ? kTextDark : Colors.transparent, width: 2)),
      ),
      child: Text(label, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: active ? kTextDark : kTextGrey)),
    ),
  );
}

// ── Macro Row (home card) ─────────────────────────────────────────────────────
class MacroRow extends StatelessWidget {
  final String label, value;
  final Color color;
  const MacroRow(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: kTextDark))),
    Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kTextDark)),
  ]);
}

// ── Small Tag (recipe card) ───────────────────────────────────────────────────
class SmallTag extends StatelessWidget {
  final String label;
  const SmallTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: kBg, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: const TextStyle(fontSize: 10, color: kTextDark, fontWeight: FontWeight.w600)),
  );
}