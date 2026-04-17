import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MoodSection extends StatelessWidget {
  final int selectedMood;
  final Color phaseColor;
  final void Function(int index) onSelect;

  // Contenu repensé pour un style Luxury / Wellness
  final List<Map<String, String>> moodData = const [
    {'emoji': '✨', 'label': 'Épanouie'},
    {'emoji': '☁️', 'label': 'Sereine'},
    {'emoji': '🌙', 'label': 'Fatiguée'},
    {'emoji': '🌪️', 'label': 'Sensible'},
    {'emoji': '🔥', 'label': 'Énergie'},
  ];

  const MoodSection({
    super.key,
    required this.selectedMood,
    required this.phaseColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "VOTRE ÉTAT D'ESPRIT", // Contenu plus formel et élégant
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: Color(0xFFADB5BD),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Comment vous sentez-vous ?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              letterSpacing: -0.8,
              // Une petite touche de serif pour le côté luxury si disponible
              fontFamily: 'Playfair Display', 
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(moodData.length, (i) {
              final isSelected = selectedMood == i;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onSelect(i);
                },
                child: Column(
                  children: [
                   // ... dans le build de MoodSection
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  // Utilisation d'une courbe standard ultra-fluide
  curve: Curves.easeOutExpo, 
  width: isSelected ? 62 : 58, // La largeur change selon la sélection
  height: 78,
  decoration: BoxDecoration(
    // On garde le reste identique
    gradient: isSelected
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              phaseColor.withOpacity(0.15),
              phaseColor.withOpacity(0.05),
            ],
          )
        : null,
    color: isSelected ? null : const Color(0xFFF8F9FA),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: isSelected 
          ? phaseColor.withOpacity(0.4) 
          : Colors.transparent,
      width: 1.5,
    ),
    boxShadow: [
      if (isSelected)
        BoxShadow(
          color: phaseColor.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
    ],
  ),
  child: Center(
    child: Text(
      moodData[i]['emoji']!,
      style: TextStyle(
        fontSize: isSelected ? 28 : 24,
      ),
    ),
  ),
),
                    const SizedBox(height: 12),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isSelected ? 1.0 : 0.5,
                      child: Text(
                        moodData[i]['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? phaseColor : const Color(0xFF495057),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}