import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnergySection extends StatelessWidget {
  final double energy;
  final Color phaseColor;
  final String title;
  final void Function(double value) onChanged;

  const EnergySection({
    super.key,
    required this.energy,
    required this.phaseColor,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final int score = (energy * 5).round().clamp(1, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ───────── HEADER ─────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A7A7A),
              ),
            ),
            Text(
              '$score / 5',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: phaseColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ───────── CONTROL BAR ─────────
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F7), // soft green-white surface
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: phaseColor.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              _IconButton(
                icon: Icons.bolt_rounded,
                color: phaseColor,
                active: energy > 0.2,
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: phaseColor.withOpacity(0.85),
                    inactiveTrackColor: phaseColor.withOpacity(0.12),
                    thumbColor: Colors.white,
                    overlayColor: phaseColor.withOpacity(0.08),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 2,
                    ),
                  ),
                  child: Slider(
                    value: energy,
                    onChanged: (val) {
                      if ((val * 5).round() != (energy * 5).round()) {
                        HapticFeedback.selectionClick();
                      }
                      onChanged(val);
                    },
                  ),
                ),
              ),

              _IconButton(
                icon: Icons.local_fire_department_rounded,
                color: phaseColor,
                active: energy > 0.75,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────── ICON COMPONENT ─────────
class _IconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;

  const _IconButton({
    required this.icon,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: active ? color : const Color(0xFFB0B0B0),
      ),
    );
  }
}