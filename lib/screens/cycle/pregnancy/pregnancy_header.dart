import 'package:fiteva/screens/cycle/pregnancy/pregnancy_data.dart';
import 'package:flutter/material.dart';

class PregnancyHeader extends StatelessWidget {
  final int currentWeek;
  final bool isPregnancyMode;
  final VoidCallback onToggleMode;
  final VoidCallback onClose;

  const PregnancyHeader({
    super.key,
    required this.currentWeek,
    required this.isPregnancyMode,
    required this.onToggleMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final week = getPregnancyWeek(currentWeek);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──
          Row(
            children: [
              // Phase badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: week.phaseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      week.babySizeEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      week.trimestre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: week.phaseColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Mode toggle
              GestureDetector(
                onTap: onToggleMode,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPregnancyMode
                        ? const Color(0xFFE8A0BF).withOpacity(0.2)
                        : const Color(0xFFF0EBF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPregnancyMode
                          ? const Color(0xFFE8A0BF).withOpacity(0.5)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isPregnancyMode ? '🤰' : '🌸',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPregnancyMode ? 'Grossesse' : 'Cycle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPregnancyMode
                              ? const Color(0xFFE8A0BF)
                              : const Color(0xFF9A8880),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: Color(0xFF9A8880)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Title row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semaine $currentWeek',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3D2033),
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'de grossesse · ${week.babySize}',
                    style: TextStyle(
                      fontSize: 13,
                      color: week.phaseColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Days remaining chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: week.phaseColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      '${40 - currentWeek}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: week.phaseColor,
                        height: 1,
                      ),
                    ),
                    Text(
                      'SA restantes',
                      style: TextStyle(
                        fontSize: 9,
                        color: week.phaseColor.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Progress bar ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progression',
                    style: TextStyle(
                      fontSize: 11,
                      color: week.phaseColor.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(currentWeek / 40 * 100).round()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: week.phaseColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: currentWeek / 40,
                  minHeight: 7,
                  backgroundColor: week.phaseColor.withOpacity(0.12),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(week.phaseColor),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TrimestreLabel('T1', currentWeek <= 13, const Color(0xFFE8A0BF)),
                  _TrimestreLabel('T2', currentWeek >= 14 && currentWeek <= 27, const Color(0xFF9BC4CB)),
                  _TrimestreLabel('T3', currentWeek >= 28, const Color(0xFFB5A0D6)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrimestreLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;

  const _TrimestreLabel(this.label, this.isActive, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? color : color.withOpacity(0.4),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}