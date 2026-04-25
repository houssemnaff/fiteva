import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/FitEvaColors.dart';

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
    // Calcul du score de 1 à 5
    final int score = (energy * 5).round().clamp(1, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title.toUpperCase(), // Style startup : Tout en majuscule léger
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: FitEvaColors.textMuted, // Use global text muted
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$score',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: phaseColor,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: ' / 5',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: phaseColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: FitEvaColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withOpacity(0.04), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildLuxuryIcon(Icons.bolt_rounded, energy > 0.2),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: phaseColor,
                    inactiveTrackColor: phaseColor.withOpacity(0.1),
                    thumbColor: Colors.white,
                    // Ombre sur le bouton du slider pour le faire ressortir
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 4,
                      pressedElevation: 8,
                    ),
                    overlayColor: phaseColor.withOpacity(0.1),
                    trackShape: const RoundedRectSliderTrackShape(),
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
              _buildLuxuryIcon(Icons.local_fire_department_rounded, energy > 0.8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLuxuryIcon(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive ? phaseColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: isActive ? phaseColor : const Color(0xFFD1D1D6),
        size: 22,
      ),
    );
  }
}