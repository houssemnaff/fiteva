import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecommendationsSection extends StatelessWidget {
  final Color sportColor;
  final Color nutritionColor;
  final Color restColor;

  const RecommendationsSection({
    super.key,
    required this.sportColor,
    required this.nutritionColor,
    required this.restColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SUR MESURE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: Color(0xFFADB5BD),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Votre programme exclusif",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),

          // Liste horizontale ou Row pour un aspect "Magazine"
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildPremiumCard(
                  'PERFORMANCE',
                  'Pilates & Flow',
                  Icons.fitness_center_rounded,
                  sportColor,
                ),
                const SizedBox(width: 16),
                _buildPremiumCard(
                  'NUTRITION',
                  'Équilibre Vital',
                  Icons.auto_awesome_rounded,
                  nutritionColor,
                ),
                const SizedBox(width: 16),
                _buildPremiumCard(
                  'RÉCUPÉRATION',
                  'Sommeil Profond',
                  Icons.wb_twilight_rounded,
                  restColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(String category, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 160,
        height: 190,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black.withOpacity(0.04), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône stylisée
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            // Catégorie en petit
            Text(
              category,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: color.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            // Titre principal
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            // Petit bouton "Découvrir" minimaliste
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}