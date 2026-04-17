import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour le retour haptique

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // On enveloppe le titre pour s'assurer qu'il a un look premium
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
            child: title,
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 14,
            children: List.generate(symptoms.length, (i) {
              final isSelected = selectedSymptoms.contains(i);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact(); // Petit feedback de luxe
                  onToggle(i);
                },
               child: AnimatedContainer(
  duration: const Duration(milliseconds: 400), // Augmenté un peu pour apprécier la courbe
  curve: Curves.easeOutQuart, // Correction ici
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16),
    color: isSelected 
        ? phaseColor.withOpacity(0.08) 
        : const Color(0xFFF9FAFB),
    border: Border.all(
      color: isSelected 
          ? phaseColor.withOpacity(0.5) 
          : Colors.black.withOpacity(0.05),
      width: 1.5,
    ),
    // ... reste du code (boxShadow, etc.)

                    // Ombre très diffuse (Soft UI)
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: phaseColor.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Point indicateur optionnel pour le style
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isSelected ? 8 : 0,
                        height: 8,
                        margin: EdgeInsets.only(right: isSelected ? 8 : 0),
                        decoration: BoxDecoration(
                          color: phaseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? phaseColor : const Color(0xFF4B5563),
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
      ),
    );
  }
}