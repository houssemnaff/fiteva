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
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
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

        // ───────── FLOATING CONTROL BAR ─────────
        Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 215, 215, 255),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),  
            ),
          ),
          child: Row(
            children: [
              _SoftIcon(
                icon: Icons.remove_rounded,
                active: energy > 0.1,
                color: phaseColor,
              ),

              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: phaseColor.withOpacity(0.9),
                    inactiveTrackColor: Colors.white.withOpacity(0.08),
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

              _SoftIcon(
                icon: Icons.add_rounded,
                active: energy > 0.7,
                color: phaseColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;

  const _SoftIcon({
    required this.icon,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: active
            ? color.withOpacity(0.12)
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 20,
        color: active ? color : const Color(0xFF8E8E93),
      ),
    );
  }
}