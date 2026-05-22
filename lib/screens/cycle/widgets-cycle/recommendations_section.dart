import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label compact
        const Text(
          'SUR MESURE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: FitEvaColors.accent, // Use accent color for label
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Programme exclusif',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: FitEvaColors.text,
          ),
        ),
        const SizedBox(height: 12),
        // 3 cards horizontales dans la largeur disponible
        Row(
          children: [
            Expanded(
              child: _RecommendationCard(
                category: 'SPORT',
                title: 'Pilates\n& Flow',
                icon: Icons.fitness_center_rounded,
                color: sportColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RecommendationCard(
                category: 'NUTRI',
                title: 'Équilibre\nVital',
                icon: Icons.auto_awesome_rounded,
                color: nutritionColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _RecommendationCard(
                category: 'REPOS',
                title: 'Sommeil\nProfond',
                icon: Icons.wb_twilight_rounded,
                color: restColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String category;
  final String title;
  final IconData icon;
  final Color color;

  const _RecommendationCard({
    required this.category,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: FitEvaColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 10),
            // Catégorie
            Text(
              category,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            // Titre
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: FitEvaColors.text,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            // Barre déco
            Container(
              width: 20,
              height: 3,
              decoration: BoxDecoration(
                color: color.withOpacity(0.40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}