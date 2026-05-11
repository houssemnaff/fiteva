import 'package:fiteva/screens/cycle/pregnancy/pregnancy_week.dart';
import 'package:flutter/material.dart';


class BabyDevelopmentCard extends StatelessWidget {
  final PregnancyWeek week;

  const BabyDevelopmentCard({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: week.phaseColor.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: week.phaseColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    week.babySizeEmoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ton bébé cette semaine',
                      style: TextStyle(
                        fontSize: 11,
                        color: week.phaseColor.withOpacity(0.8),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Taille d\'un(e) ',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9A8880),
                            ),
                          ),
                          TextSpan(
                            text: week.babySize,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: week.phaseColor,
                            ),
                          ),
                          TextSpan(
                            text: ' · ${week.babyCm} cm',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9A8880),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: week.phaseColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.child_care_rounded,
                    size: 16, color: week.phaseColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    week.babyDevelopment,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3D2033),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}