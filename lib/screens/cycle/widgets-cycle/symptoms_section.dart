import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/FitEvaColors.dart';

class SymptomsSection extends StatelessWidget {
  final List<String> symptoms;
  final Set<int> selectedSymptoms;
  final Color phaseColor;
  final Function(int index) onToggle;
  final Widget title;

  const SymptomsSection({
    super.key,
    required this.symptoms,
    required this.selectedSymptoms,
    required this.phaseColor,
    required this.onToggle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          style: const TextStyle(
            fontSize: 20, // ⬆️ augmenté
            fontWeight: FontWeight.w700,
            color: FitEvaColors.text,
            letterSpacing: -0.5,
          ),
          child: title,
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 14,
          children: List.generate(symptoms.length, (i) {
            final isSelected = selectedSymptoms.contains(i);

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggle(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutQuart,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? phaseColor.withOpacity(0.10)
                      : FitEvaColors.cardBg,
                  border: Border.all(
                    color: isSelected
                        ? phaseColor.withOpacity(0.6)
                        : Colors.black.withOpacity(0.05),
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: phaseColor.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isSelected ? 10 : 0,
                      height: 10,
                      margin: EdgeInsets.only(right: isSelected ? 8 : 0),
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 14, // Adjusted for better fit
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? phaseColor
                            : FitEvaColors.textMuted,
                        letterSpacing: -0.2,
                      ),
                      child: Text(symptoms[i]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}