/*import 'package:fiteva/screens/cycle/widgets-cycle/cycle_wheel.dart';
import 'package:flutter/material.dart';
 // pour phaseForDay + kPhases

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
                        color: const Color.fromARGB(255, 200, 41, 41).withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Badge phase animé
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _PhaseBadge(
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

              // Bouton calendrier
              _IconButton(
                icon: Icons.calendar_month_rounded,
                onTap: () {},
                color: phaseColor,
              ),
              const SizedBox(width: 8),
              // Bouton close / retour
              _IconButton(
                icon: Icons.close_rounded,
                onTap: onClose,
                color: phaseColor,
              ),
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

          // ── Ligne 3 : barre de progression des phases ──
          _PhaseProgressBar(
            currentDay: currentDay,
            phaseColors: _phaseColors,
            phaseDays: _phaseDays,
          ),

          const SizedBox(height: 4),

          // Jour / total
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Jour $currentDay / 30',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.60),
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

// ──────────────────────────────────────────────
//  Badge phase (nom + description + point couleur)
// ──────────────────────────────────────────────
class _PhaseBadge extends StatelessWidget {
  final String name;
  final String description;
  final Color color;

  const _PhaseBadge({
    super.key,
    required this.name,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '· ${description.split('·').first.trim()}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.70),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

// ──────────────────────────────────────────────
//  Barre de progression des 4 phases
// ──────────────────────────────────────────────
class _PhaseProgressBar extends StatelessWidget {
  final int currentDay;
  final List<Color> phaseColors;
  final List<int> phaseDays;

  const _PhaseProgressBar({
    required this.currentDay,
    required this.phaseColors,
    required this.phaseDays,
  });

  static const _phaseNames = ['Règles', 'Follic.', 'Ovul.', 'Lutéale'];

  // Calcule le jour de début de chaque phase
  int _startDay(int phaseIndex) {
    int start = 1;
    for (int i = 0; i < phaseIndex; i++) {
      start += phaseDays[i];
    }
    return start;
  }

  int _endDay(int phaseIndex) => _startDay(phaseIndex) + phaseDays[phaseIndex] - 1;

  int _activePhaseIndex() {
    int day = 1;
    for (int i = 0; i < phaseDays.length; i++) {
      day += phaseDays[i];
      if (currentDay < day) return i;
    }
    return phaseDays.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activePhaseIndex();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Segments
        Row(
          children: List.generate(phaseDays.length, (i) {
            final isActive = i == activeIndex;
            final color = phaseColors[i];

            return Expanded(
              flex: phaseDays[i],
              child: Padding(
                padding: EdgeInsets.only(right: i < phaseDays.length - 1 ? 3 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: isActive ? 5 : 3,
                  decoration: BoxDecoration(
                    color: isActive ? color : color.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isActive
                        ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)]
                        : null,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        // Labels sous les segments
        Row(
          children: List.generate(phaseDays.length, (i) {
            final isActive = i == activeIndex;
            return Expanded(
              flex: phaseDays[i],
              child: Text(
                _phaseNames[i],
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? Colors.white.withOpacity(0.90)
                      : Colors.white.withOpacity(0.35),
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
          color: Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: Icon(icon, size: 17, color: Colors.white.withOpacity(0.85)),
      ),
    );
  }
}*/