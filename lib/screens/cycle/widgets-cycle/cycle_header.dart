import 'package:fiteva/screens/cycle/widgets-cycle/cycle_common_widgets.dart';
import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart';
import 'package:flutter/material.dart';

class CycleHeader extends StatelessWidget {
  final int currentDay;
  final bool showWheel;
  final VoidCallback onShowWheel;
  final VoidCallback onShowCalendar;
  final VoidCallback onClose;

  const CycleHeader({
    super.key,
    required this.currentDay,
    required this.showWheel,
    required this.onShowWheel,
    required this.onShowCalendar,
    required this.onClose,
  });

  // Couleurs fixes des 4 phases
  static const _phaseColors = [
    Color(0xFFD94F6B), // Règles
    Color(0xFF5BAE8A), // Folliculaire
    Color(0xFF7DE2D1), // Ovulation
    Color(0xFF6B8FD4), // Lutéale
  ];

  static const _phaseDays = [5, 8, 3, 14]; // durées proportionnelles

  @override
  Widget build(BuildContext context) {
    final phase = phaseForDay(currentDay);
    final phaseColor = phase.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne 1 : titre + badge phase + icônes ─────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titre + badge phase
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MON CYCLE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: Colors.black.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Badge phase animé
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: PhaseBadge(
                        key: ValueKey(phase.name),
                        name: phase.name,
                        description: phase.description,
                        color: phaseColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

             
            ],
          ),

          const SizedBox(height: 12),

          // ── Ligne 2 : toggle Roue / Calendrier ─────────
          _ToggleBar(
            showWheel: showWheel,
            onShowWheel: onShowWheel,
            onShowCalendar: onShowCalendar,
            phaseColor: phaseColor,
          ),

          const SizedBox(height: 10),

          // Jour / total
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Jour $currentDay / 30',
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.55),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// Le Badge est maintenant dans cycle_common_widgets.dart

// ──────────────────────────────────────────────
//  Toggle Roue / Calendrier
// ──────────────────────────────────────────────
class _ToggleBar extends StatelessWidget {
  final bool showWheel;
  final VoidCallback onShowWheel;
  final VoidCallback onShowCalendar;
  final Color phaseColor;

  const _ToggleBar({
    required this.showWheel,
    required this.onShowWheel,
    required this.onShowCalendar,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF3B9566)),
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'Roue',
            icon: Icons.donut_large_rounded,
            isActive: showWheel,
            onTap: onShowWheel,
            phaseColor: phaseColor,
          ),
          _ToggleItem(
            label: 'Calendrier',
            icon: Icons.calendar_today_rounded,
            isActive: !showWheel,
            onTap: onShowCalendar,
            phaseColor: phaseColor,
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Color phaseColor;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? Colors.black : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// La ProgressBar est maintenant dans cycle_common_widgets.dart

// ──────────────────────────────────────────────
//  Bouton icône générique
// ──────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.18),
          border: Border.all(color: color.withOpacity(0.45)),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
