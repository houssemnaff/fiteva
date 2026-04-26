import 'package:flutter/material.dart';
import 'cycle_wheel.dart'; // pour phaseForDay

// ──────────────────────────────────────────────
//  Badge phase (nom + description + point couleur)
// ──────────────────────────────────────────────
class PhaseBadge extends StatelessWidget {
  final String name;
  final String description;
  final Color color;
  final bool isMinimal;

  const PhaseBadge({
    super.key,
    required this.name,
    required this.description,
    required this.color,
    this.isMinimal = false,
  });

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF121212);
    final subtitleColor = const Color(0xFF2A2A2A).withOpacity(0.78);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Point couleur de la phase
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          if (!isMinimal) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '· ${description.split('·').first.trim()}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  Barre de progression des 4 phases
// ──────────────────────────────────────────────
class PhaseProgressBar extends StatelessWidget {
  final int currentDay;
  final List<Color> phaseColors;
  final List<int> phaseDays;

  const PhaseProgressBar({
    super.key,
    required this.currentDay,
    required this.phaseColors,
    required this.phaseDays,
  });

  static const _phaseNames = ['Règles', 'Folliculaire', 'Ovulation', 'Lutéale'];

  int _activePhaseIndex() {
    int day = 0;
    for (int i = 0; i < phaseDays.length; i++) {
      day += phaseDays[i];
      if (currentDay <= day) return i;
    }
    return phaseDays.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activePhaseIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Segments ────────────────────────────────
        Row(
          children: List.generate(phaseDays.length, (i) {
            final isActive = i == activeIndex;
            final color = phaseColors[i];

            return Expanded(
              flex: phaseDays[i],
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < phaseDays.length - 1 ? 4 : 0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 3,
                  decoration: BoxDecoration(
                    color: isActive ? color : const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // ── Labels ──────────────────────────────────
        Row(
          children: List.generate(phaseDays.length, (i) {
            final isActive = i == activeIndex;
            return Expanded(
              flex: phaseDays[i],
              child: Text(
                _phaseNames[i],
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? Colors.black.withOpacity(0.85)
                      : Colors.black.withOpacity(0.35),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }
}
