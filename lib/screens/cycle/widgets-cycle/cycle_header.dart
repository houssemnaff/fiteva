import 'package:flutter/material.dart';
import '../../../theme/FitEvaColors.dart';
import 'cycle_wheel.dart'; // pour phaseForDay + kPhases

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
    FitEvaColors.phaseMenstrual,
    FitEvaColors.phaseFolliculaire,
    FitEvaColors.phaseOvulatoire,
    FitEvaColors.phaseLuteal,
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
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: FitEvaColors.textMuted,
    fontFamily: '.SF Pro Text',
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

            /*  // Bouton calendrier
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
              ),*/
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

       

        

          const SizedBox(height: 4),

          // Jour / total
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Jour $currentDay / 30',
              style: TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w400,
  fontFamily: '.SF Pro Text',
  color: FitEvaColors.textMuted,
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
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.12)),
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
                BoxShadow(color: color.withOpacity(0.3), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
  name,
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: '.SF Pro Display',
    color: FitEvaColors.text,
  ),
),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '· ${description.split('·').first.trim()}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: FitEvaColors.textMuted,
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
        color: FitEvaColors.primary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
            color: isActive ? FitEvaColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive ? FitEvaColors.text : const Color.fromARGB(255, 255, 255, 255),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? FitEvaColors.text : const Color.fromARGB(255, 248, 248, 248),
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
                      ? FitEvaColors.text
                      : FitEvaColors.textMuted,
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
          color: FitEvaColors.surface,
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, size: 17, color: FitEvaColors.text),
      ),
    );
  }
}