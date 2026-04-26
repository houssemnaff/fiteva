import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:fiteva/screens/nutrition/widgets/shared/donut_painters.dart';
import 'package:fiteva/screens/nutrition/widgets/shared/shared_widgets.dart';
import 'package:flutter/material.dart';

class DailyTrackingCardhome extends StatelessWidget {
  final Animation<double> anim;
 
  final int caloriesConsumed;
  final int caloriesGoal;

  const DailyTrackingCardhome({
    super.key,
    required this.anim,
    
   
    required this.caloriesConsumed,
    required this.caloriesGoal,
  });
@override
Widget build(BuildContext context) {
  final int remaining = caloriesGoal - caloriesConsumed;

  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        )
      ],
    ),
    child: Column(
      children: [

        // 🔹 HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // LEFT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: kBrown,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Suivi journalier',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // RIGHT BUTTON
            GestureDetector(
             
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Text(
                      'Consulter',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.chevron_right,
                        color: kWhite, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 🔥 BODY
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // LEFT (donut)
            Column(
              children: [
                SizedBox(
                  width: 118,
                  height: 118,
                  child: AnimatedBuilder(
                    animation: anim,
                    builder: (_, __) => CustomPaint(
                      painter: DonutPainter(
                        proteinRatio: 0.25,
                        carbsRatio: 0.54,
                        fatRatio: 0.41,
                        animValue: anim.value,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$caloriesConsumed',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: kTextDark,
                              ),
                            ),
                            const Text(
                              'kcal',
                              style: TextStyle(
                                  fontSize: 11, color: kTextGrey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Objectif: $caloriesGoal kcal',
                  style: const TextStyle(
                    fontSize: 11,
                    color: kTextGrey,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  remaining >= 0
                      ? '$remaining restantes'
                      : '${remaining.abs()} en surplus',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: remaining >= 0 ? kGreen : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 18),

            // RIGHT (macros)
            Expanded(
              child: Column(
                children: [
                  MacroRow('Protéines', '25 g', kPink),
                  const Divider(height: 14, color: Color(0xFFEEE8E0)),
                  MacroRow('Glucides', '128 g', kBlue),
                  const Divider(height: 14, color: Color(0xFFEEE8E0)),
                  MacroRow('Lipides', '26 g', kLime),
                ],
              ),
            ),
          ],
        ),


      
      ],
    ),
  );
}

}